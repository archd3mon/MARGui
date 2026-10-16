import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/marg_tokens.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/tile_icon.dart';
import '../../app/app_state.dart';

class LiveScreen extends ConsumerStatefulWidget {
  const LiveScreen({super.key});

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen> {
  final MapController _mapController = MapController();

  void _shareEta() {
    final live = ref.read(liveTripProvider);
    SharePlus.instance.share(ShareParams(text: 'My ETA to ${live.nextStop} is ${live.arrivalTime} (${live.remainingMins} min remaining on Route 144). Marg Pune Bus.'));
  }

  void _endTrip() {
    showDialog(
      context: context,
      builder: (ctx) {
        final c = context.c;
        return AlertDialog(
          backgroundColor: c.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Rad.lg)),
          title: Text('End Trip?', style: MargText.headline.copyWith(color: c.label)),
          content: Text('Are you sure you want to exit live trip guidance?', style: MargText.body.copyWith(color: c.label2)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: MargText.body.copyWith(color: c.label2)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(liveTripProvider.notifier).setTrip(const LiveTripState(isActive: false));
                context.go('/explore');
              },
              child: Text('End Trip', style: MargText.body.copyWith(color: c.red, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final live = ref.watch(liveTripProvider);
    final tripPlan = ref.watch(tripPlanStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileUrl = isDark
        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
        : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png';

    // Route points and bus position
    final busPos = const LatLng(18.545, 73.87);

    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        children: [
          // 1. Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: busPos,
              initialZoom: 13.5,
            ),
            children: [
              TileLayer(
                urlTemplate: tileUrl,
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'in.marg.marg_app',
              ),
              PolylineLayer(
                polylines: [
                  // Full route
                  Polyline(
                    points: [
                      LatLng(tripPlan.from.lat, tripPlan.from.lng),
                      const LatLng(18.5182, 73.8413),
                      const LatLng(18.5308, 73.8475),
                      const LatLng(18.5529, 73.8797),
                      LatLng(tripPlan.to.lat, tripPlan.to.lng),
                    ],
                    strokeWidth: 5,
                    color: c.blue,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  // Live Bus Marker
                  Marker(
                    point: busPos,
                    width: 44,
                    height: 44,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: c.tint(c.blue, 0.25),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: c.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: c.card, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: c.label.withValues(alpha: 0.2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Icon(Icons.directions_bus_rounded, color: c.card, size: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Destination marker
                  Marker(
                    point: LatLng(tripPlan.to.lat, tripPlan.to.lng),
                    width: 22,
                    height: 22,
                    child: Container(
                      decoration: BoxDecoration(color: c.red, shape: BoxShape.circle, border: Border.all(color: c.card, width: 3)),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 2. Top Banner: instruction card (dark glass)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sp.x4, vertical: Sp.x2),
              child: Container(
                padding: const EdgeInsets.all(Sp.x3),
                decoration: BoxDecoration(
                  color: MargColors.dark.glass,
                  borderRadius: BorderRadius.circular(Rad.lg),
                  boxShadow: [
                    BoxShadow(color: MargColors.dark.label.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 6)),
                  ],
                ),
                child: Row(
                  children: [
                    TileIcon(
                      icon: Icons.directions_bus_rounded,
                      color: TileColor.blue,
                      size: 44,
                      iconSize: 22,
                    ),
                    const SizedBox(width: Sp.x3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Get off at',
                            style: MargText.caption.copyWith(color: MargColors.dark.label2),
                          ),
                          Text(
                            live.nextStop,
                            style: MargText.headline.copyWith(
                              color: MargColors.dark.label,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${live.stopsRemaining} stops · Route 144',
                            style: MargText.caption.copyWith(color: MargColors.dark.label2),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: Sp.x2, vertical: Sp.x1 / 2),
                      decoration: BoxDecoration(
                        color: c.tint(c.green, 0.18),
                        borderRadius: BorderRadius.circular(Rad.sm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: c.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'LIVE',
                            style: MargText.caption.copyWith(
                              color: c.green,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Bottom Glass Sheet: Progress track + Stats + Action Buttons
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Glass(
              radius: Rad.sheet,
              topOnly: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Sp.x4, vertical: Sp.x3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 5,
                        decoration: BoxDecoration(color: c.label3, borderRadius: BorderRadius.circular(2.5)),
                      ),
                    ),
                    const SizedBox(height: Sp.x3),

                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          value: '${live.remainingMins}',
                          unit: 'min',
                          label: 'Remaining',
                        ),
                        _StatItem(
                          value: live.arrivalTime,
                          label: 'Arrival',
                        ),
                        _StatItem(
                          value: 'On',
                          unit: ' time',
                          label: 'Route 144',
                          isGreen: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: Sp.x5),

                    // Progress Track
                    Container(
                      height: 24,
                      alignment: Alignment.center,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.centerLeft,
                        children: [
                          // Base track
                          Container(
                            height: 4,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: c.fill,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          // Completed track
                          FractionallySizedBox(
                            widthFactor: live.progressPercent,
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: c.blue,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          // Stop markers along track
                          Positioned(
                            left: 0,
                            child: _StopDot(color: c.blue),
                          ),
                          Positioned(
                            left: MediaQuery.of(context).size.width * 0.25,
                            child: _StopDot(color: c.blue),
                          ),
                          Positioned(
                            left: MediaQuery.of(context).size.width * 0.65,
                            child: _StopDot(color: c.gray),
                          ),
                          Positioned(
                            right: 0,
                            child: _StopDot(color: c.red),
                          ),
                          // Bus marker position
                          Positioned(
                            left: (MediaQuery.of(context).size.width - 48) * live.progressPercent - 12,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: c.blue,
                                shape: BoxShape.circle,
                                border: Border.all(color: c.card, width: 2),
                              ),
                              child: Icon(Icons.directions_bus_rounded, color: c.card, size: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Sp.x5),

                    // Action buttons (Share ETA + End Trip)
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            label: 'Share ETA',
                            variant: ButtonVariant.tinted,
                            onPressed: _shareEta,
                          ),
                        ),
                        const SizedBox(width: Sp.x3),
                        Expanded(
                          child: PrimaryButton(
                            label: 'End Trip',
                            variant: ButtonVariant.danger,
                            onPressed: _endTrip,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Sp.x3),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String? unit;
  final String label;
  final bool isGreen;

  const _StatItem({
    required this.value,
    this.unit,
    required this.label,
    this.isGreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: MargText.title3.copyWith(
                  color: isGreen ? c.green : c.label,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (unit != null)
                TextSpan(
                  text: unit!,
                  style: MargText.footnote.copyWith(
                    color: isGreen ? c.green : c.label2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: MargText.caption.copyWith(color: c.label2),
        ),
      ],
    );
  }
}

class _StopDot extends StatelessWidget {
  final Color color;

  const _StopDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: context.c.card, width: 2),
      ),
    );
  }
}
