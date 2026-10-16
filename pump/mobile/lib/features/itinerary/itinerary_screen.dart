import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/marg_tokens.dart';
import '../../shared/widgets/bus_chip.dart';
import '../../shared/widgets/badge_label.dart';
import '../../shared/widgets/primary_button.dart';
import '../../data/models/saved_item.dart';
import '../../app/app_state.dart';

class ItineraryScreen extends ConsumerStatefulWidget {
  const ItineraryScreen({super.key});

  @override
  ConsumerState<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends ConsumerState<ItineraryScreen> {
  final MapController _mapController = MapController();
  final Set<int> _expandedLegs = {};

  void _toggleExpand(int index) {
    setState(() {
      if (_expandedLegs.contains(index)) {
        _expandedLegs.remove(index);
      } else {
        _expandedLegs.add(index);
      }
    });
  }

  void _shareTrip() {
    final route = ref.read(selectedRouteProvider);
    final tripPlan = ref.read(tripPlanStateProvider);
    final text = 'Marg Pune Bus Trip: ${tripPlan.from.name} to ${tripPlan.to.name}\n'
        'Duration: ${route?.totalTimeMins ?? 55} min · ETA: 9:37 AM\n'
        'Buses: 17, 144 · Safe travels!';
    SharePlus.instance.share(ShareParams(text: text));
  }

  void _saveRoute() {
    final route = ref.read(selectedRouteProvider);
    final tripPlan = ref.read(tripPlanStateProvider);
    final savedRoute = SavedRoute(
      id: 'sr_${DateTime.now().millisecondsSinceEpoch}',
      title: '${tripPlan.from.name} → ${tripPlan.to.name}',
      fromName: tripPlan.from.name,
      toName: tripPlan.to.name,
      busLines: const ['17', '144'],
      scheduleText: 'Mon–Fri · 8:40',
      totalTimeMins: route?.totalTimeMins ?? 55,
      statusText: 'On time',
      isOnTime: true,
      sourceLat: tripPlan.from.lat,
      sourceLng: tripPlan.from.lng,
      destLat: tripPlan.to.lat,
      destLng: tripPlan.to.lng,
    );
    ref.read(savedRoutesProvider.notifier).toggleSave(savedRoute);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Route saved to Saved tab'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _startTrip() {
    final route = ref.read(selectedRouteProvider);
    ref.read(liveTripProvider.notifier).setTrip(LiveTripState(
      isActive: true,
      route: route,
      remainingMins: 12,
      nextStop: 'Viman Nagar',
      stopsRemaining: 4,
      arrivalTime: '9:37',
      statusText: 'On time',
      progressPercent: 0.65,
    ));
    context.push('/live');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final tripPlan = ref.watch(tripPlanStateProvider);
    final route = ref.watch(selectedRouteProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileUrl = isDark
        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
        : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png';

    final routePoints = [
      LatLng(tripPlan.from.lat, tripPlan.from.lng),
      const LatLng(18.5182, 73.8413),
      const LatLng(18.5308, 73.8475),
      const LatLng(18.5529, 73.8797),
      LatLng(tripPlan.to.lat, tripPlan.to.lng),
    ];

    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        children: [
          // 1. Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(18.535, 73.86),
              initialZoom: 12.5,
            ),
            children: [
              TileLayer(
                urlTemplate: tileUrl,
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'in.marg.marg_app',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(points: routePoints, strokeWidth: 8, color: c.card),
                  Polyline(points: routePoints, strokeWidth: 5, color: c.blue),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(tripPlan.from.lat, tripPlan.from.lng),
                    width: 24,
                    height: 24,
                    child: Container(
                      decoration: BoxDecoration(color: c.blue, shape: BoxShape.circle, border: Border.all(color: c.card, width: 3)),
                    ),
                  ),
                  Marker(
                    point: const LatLng(18.5182, 73.8413),
                    width: 20,
                    height: 20,
                    child: Container(
                      decoration: BoxDecoration(color: c.card, shape: BoxShape.circle, border: Border.all(color: c.blue, width: 3)),
                    ),
                  ),
                  Marker(
                    point: LatLng(tripPlan.to.lat, tripPlan.to.lng),
                    width: 24,
                    height: 24,
                    child: Container(
                      decoration: BoxDecoration(color: c.red, shape: BoxShape.circle, border: Border.all(color: c.card, width: 3)),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 2. Floating Top Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sp.x4, vertical: Sp.x2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Glass(
                    radius: Rad.sheet,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: c.label, size: 18),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  Glass(
                    radius: Rad.sheet,
                    child: IconButton(
                      icon: Icon(Icons.share_outlined, color: c.label, size: 20),
                      onPressed: _shareTrip,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Bottom Glass Sheet with Journey Timeline
          DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.35,
            maxChildSize: 0.95,
            snap: true,
            builder: (context, scrollController) {
              return Glass(
                radius: Rad.sheet,
                topOnly: true,
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: Sp.x4),
                  children: [
                    const SizedBox(height: Sp.x2),
                    Center(
                      child: Container(
                        width: 36,
                        height: 5,
                        decoration: BoxDecoration(color: c.label3, borderRadius: BorderRadius.circular(2.5)),
                      ),
                    ),
                    const SizedBox(height: Sp.x3),

                    // Itinerary Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${route?.totalTimeMins ?? 55} min',
                              style: MargText.largeTitle.copyWith(color: c.label),
                            ),
                            Text(
                              'Arrive 9:37 AM · ${route?.transfers ?? 1} transfer · ${route?.totalWalkM ?? 650} m walk',
                              style: MargText.footnote.copyWith(color: c.label2),
                            ),
                          ],
                        ),
                        const BadgeLabel(type: BadgeType.fastest),
                      ],
                    ),
                    const SizedBox(height: Sp.x5),

                    // Step 1: Walk to bus stop
                    _TimelineStep(
                      time: '8:42',
                      isWalk: true,
                      title: 'Current Location',
                      subtitle: 'Walk 6 min · 450 m',
                      icon: Icons.directions_walk,
                    ),

                    // Step 2: Bus 17
                    _TimelineStep(
                      time: '8:48',
                      isWalk: false,
                      title: 'Kothrud Depot',
                      busLine: '17',
                      direction: 'towards Deccan Gymkhana',
                      meta: 'Every 10 min · 9 stops · 18 min',
                      isExpanded: _expandedLegs.contains(1),
                      onToggleExpand: () => _toggleExpand(1),
                      intermediateStops: const ['Paud Phata', 'More Vidyalaya', 'Ideal Colony', 'Nal Stop', 'SNDT College', 'Canara Bank', 'Garware College', 'Deccan Corner'],
                    ),

                    // Step 3: Transfer at Deccan Gymkhana & Bus 144
                    _TimelineStep(
                      time: '9:06',
                      depTime: 'Dep 9:10',
                      isWalk: false,
                      title: 'Deccan Gymkhana',
                      subtitle: 'Change buses · 4 min wait',
                      busLine: '144',
                      direction: 'towards Viman Nagar',
                      meta: '11 stops · 24 min',
                      isExpanded: _expandedLegs.contains(2),
                      onToggleExpand: () => _toggleExpand(2),
                      intermediateStops: const ['Goodluck Chowk', 'FC Road', 'Shivajinagar Station', 'COEP', 'Wakdewadi', 'Sangamwadi', 'Yerawada', 'Gunjan Talkies', 'Golf Club', 'Shastri Nagar', 'Airport Corner'],
                    ),

                    // Step 4: Alight & walk
                    _TimelineStep(
                      time: '9:34',
                      isWalk: true,
                      title: 'Viman Nagar Bus Stop',
                      subtitle: 'Walk 3 min · 200 m',
                      icon: Icons.directions_walk,
                    ),

                    // Step 5: Final Destination
                    _TimelineStep(
                      time: '9:37',
                      isLast: true,
                      title: 'Viman Nagar',
                    ),

                    const SizedBox(height: Sp.x5),

                    // Bottom Action Row (Start Trip CTA + Save Bookmark)
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            label: 'Start Trip',
                            icon: Icon(Icons.navigation_rounded, color: c.card, size: 18),
                            onPressed: _startTrip,
                          ),
                        ),
                        const SizedBox(width: Sp.x3),
                        Container(
                          width: 52,
                          height: Layout.touch + 2,
                          decoration: BoxDecoration(
                            color: c.tint(c.blue, 0.12),
                            borderRadius: BorderRadius.circular(Rad.md),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.bookmark_border_rounded, color: c.blue),
                            onPressed: _saveRoute,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Sp.x6),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String time;
  final String? depTime;
  final String title;
  final String? subtitle;
  final String? busLine;
  final String? direction;
  final String? meta;
  final IconData? icon;
  final bool isWalk;
  final bool isLast;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;
  final List<String> intermediateStops;

  const _TimelineStep({
    required this.time,
    this.depTime,
    required this.title,
    this.subtitle,
    this.busLine,
    this.direction,
    this.meta,
    this.icon,
    this.isWalk = false,
    this.isLast = false,
    this.isExpanded = false,
    this.onToggleExpand,
    this.intermediateStops = const [],
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time column
          SizedBox(
            width: 52,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: MargText.footnote.copyWith(
                    color: c.label,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (depTime != null)
                  Text(
                    depTime!,
                    style: MargText.caption.copyWith(
                      color: c.label3,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),

          // Rail column
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: isLast ? c.red : c.card,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isLast ? c.card : (isWalk ? c.gray : c.blue),
                    width: isLast ? 2.5 : 3,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 3,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: isWalk ? c.separator : c.blue,
                  ),
                ),
            ],
          ),
          const SizedBox(width: Sp.x3),

          // Content column
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: Sp.x5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: MargText.headline.copyWith(color: c.label),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 14, color: c.label2),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          subtitle!,
                          style: MargText.footnote.copyWith(color: c.label2),
                        ),
                      ],
                    ),
                  ],
                  if (busLine != null) ...[
                    const SizedBox(height: Sp.x2),
                    Row(
                      children: [
                        BusChip(line: busLine!, showIcon: true),
                        const SizedBox(width: Sp.x2),
                        if (direction != null)
                          Expanded(
                            child: Text(
                              direction!,
                              style: MargText.subhead.copyWith(color: c.label),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ],
                  if (meta != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      meta!,
                      style: MargText.footnote.copyWith(color: c.label2),
                    ),
                  ],
                  if (intermediateStops.isNotEmpty) ...[
                    const SizedBox(height: Sp.x1),
                    InkWell(
                      onTap: onToggleExpand,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isExpanded ? 'Hide stops' : 'Show stops',
                            style: MargText.caption.copyWith(
                              color: c.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Icon(
                            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            size: 16,
                            color: c.blue,
                          ),
                        ],
                      ),
                    ),
                    if (isExpanded)
                      Padding(
                        padding: const EdgeInsets.only(top: Sp.x2, left: Sp.x2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: intermediateStops
                              .map((s) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Text(
                                      '• $s',
                                      style: MargText.caption.copyWith(color: c.label2),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
