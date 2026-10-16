import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../theme/marg_tokens.dart';
import '../../shared/widgets/bus_chip.dart';
import '../../shared/widgets/tile_icon.dart';
import '../../data/models/stop.dart';
import '../../data/models/place.dart';
import '../../app/app_state.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final MapController _mapController = MapController();
  final LatLng _puneCenter = const LatLng(18.5074, 73.8077);
  List<TransitStop> _nearbyStops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNearbyStops();
  }

  Future<void> _loadNearbyStops() async {
    final repo = ref.read(transitRepositoryProvider);
    final stops = await repo.getNearbyStops(_puneCenter.latitude, _puneCenter.longitude);
    if (mounted) {
      setState(() {
        _nearbyStops = stops;
        _isLoading = false;
      });
    }
  }

  void _onSearchTap() {
    context.push('/plan');
  }

  void _onShortcutTap(String type) {
    final places = ref.read(savedPlacesProvider);
    final place = places.firstWhere((p) => p.type == type, orElse: () => places.first);
    ref.read(tripPlanStateProvider.notifier).updatePlan((state) => state.copyWith(
      to: Place(
        id: place.id,
        name: place.name,
        displayName: place.locationName,
        lat: place.lat,
        lng: place.lng,
        type: place.type,
      ),
    ));
    context.push('/plan');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    const tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';


    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        children: [
          // 1. Full-bleed interactive Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _puneCenter,
              initialZoom: 14.5,
              minZoom: 10,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: tileUrl,
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'in.marg.marg_app',
              ),
              MarkerLayer(
                markers: [
                  // User Location marker (Blue pulsing dot)
                  Marker(
                    point: _puneCenter,
                    width: 48,
                    height: 48,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: c.tint(c.blue, 0.25),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: c.card,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: c.label.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: c.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Nearby stop markers
                  ..._nearbyStops.take(4).map((stop) => Marker(
                        point: LatLng(stop.lat, stop.lng),
                        width: 24,
                        height: 24,
                        child: Container(
                          decoration: BoxDecoration(
                            color: c.card,
                            shape: BoxShape.circle,
                            border: Border.all(color: c.blue, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: c.label.withValues(alpha: 0.15),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ],
          ),

          // 2. Top-right floating glass buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: Sp.x3, right: Sp.x4),
              child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _FloatingGlassButton(
                      icon: Icons.navigation_rounded,
                      onPressed: () {
                        _mapController.move(_puneCenter, 15.0);
                      },
                    ),
                    const SizedBox(height: Sp.x2),
                    _FloatingGlassButton(
                      icon: Icons.layers_outlined,
                      onPressed: () {
                        // Toggle map layer/view
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Draggable Scrollable Sheet (snaps: 0.14, 0.5, 0.92)
          DraggableScrollableSheet(
            initialChildSize: Layout.snaps[1],
            minChildSize: Layout.snaps[0],
            maxChildSize: Layout.snaps[2],
            snap: true,
            snapSizes: Layout.snaps,
            builder: (context, scrollController) {
              return Glass(
                radius: Rad.sheet,
                topOnly: true,
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: Sp.x4),
                  children: [
                    const SizedBox(height: Sp.x2),
                    // Grabber pill
                    Center(
                      child: Container(
                        width: 36,
                        height: 5,
                        decoration: BoxDecoration(
                          color: c.label3,
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: Sp.x3),

                    // "Where to?" Search Bar
                    InkWell(
                      onTap: _onSearchTap,
                      borderRadius: BorderRadius.circular(Rad.md),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: Sp.x3, vertical: Sp.x3),
                        decoration: BoxDecoration(
                          color: c.fill,
                          borderRadius: BorderRadius.circular(Rad.md),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: c.label2, size: 20),
                            const SizedBox(width: Sp.x2),
                            Text(
                              'Where to?',
                              style: MargText.headline.copyWith(
                                color: c.label2,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: Sp.x4),

                    // Shortcuts (Home, Work, Add)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ShortcutButton(
                          title: 'Home',
                          icon: Icons.home_rounded,
                          color: TileColor.blue,
                          onTap: () => _onShortcutTap('home'),
                        ),
                        _ShortcutButton(
                          title: 'Work',
                          icon: Icons.work_rounded,
                          color: TileColor.orange,
                          onTap: () => _onShortcutTap('work'),
                        ),
                        _ShortcutButton(
                          title: 'Add',
                          icon: Icons.add,
                          color: TileColor.gray,
                          onTap: () {
                            context.push('/saved');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: Sp.x5),

                    // Nearby stops section header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nearby stops',
                          style: MargText.headline.copyWith(
                            color: c.label,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'See All',
                            style: MargText.subhead.copyWith(
                              color: c.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Sp.x3),

                    // List of nearby stops
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(Sp.x6),
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      )
                    else
                      ..._nearbyStops.map((stop) => _StopItem(
                            stop: stop,
                            onTap: () {
                              ref.read(tripPlanStateProvider.notifier).updatePlan((state) => state.copyWith(
                                from: Place(
                                  id: stop.id,
                                  name: stop.name,
                                  displayName: stop.subtext,
                                  lat: stop.lat,
                                  lng: stop.lng,
                                  type: 'stop',
                                ),
                              ));
                              context.push('/plan');
                            },
                          )),
                    const SizedBox(height: 80), // extra padding for bottom tab bar
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

class _FloatingGlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _FloatingGlassButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Glass(
      radius: Rad.md,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(Rad.md),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, color: c.blue, size: 20),
          ),
        ),
      ),
    );
  }
}

class _ShortcutButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final TileColor color;
  final VoidCallback onTap;

  const _ShortcutButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TileIcon(icon: icon, color: color, size: 50, iconSize: 24),
          const SizedBox(height: Sp.x1),
          Text(
            title,
            style: MargText.caption.copyWith(
              color: c.label,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StopItem extends StatelessWidget {
  final TransitStop stop;
  final VoidCallback onTap;

  const _StopItem({required this.stop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Rad.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Sp.x3),
        child: Row(
          children: [
            TileIcon(
              icon: Icons.directions_bus_rounded,
              color: TileColor.blue,
              size: 40,
              iconSize: 20,
            ),
            const SizedBox(width: Sp.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stop.name,
                    style: MargText.headline.copyWith(color: c.label),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${stop.distanceMeters} m · ${stop.subtext}',
                    style: MargText.footnote.copyWith(color: c.label2),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: stop.etas
                      .map((e) => Padding(
                            padding: const EdgeInsets.only(left: Sp.x1),
                            child: BusChip(line: e.route),
                          ))
                      .toList(),
                ),
                if (stop.etas.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    '${stop.etas.first.mins} min',
                    style: MargText.caption.copyWith(
                      color: c.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
