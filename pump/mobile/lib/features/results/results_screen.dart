import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../theme/marg_tokens.dart';
import '../../shared/widgets/bus_chip.dart';
import '../../shared/widgets/walk_chip.dart';
import '../../shared/widgets/badge_label.dart';
import '../../data/models/route_model.dart';
import '../../app/app_state.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  final MapController _mapController = MapController();
  List<TransitRoute> _routes = [];
  TransitRoute? _selectedRoute;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRoutes();
  }

  Future<void> _fetchRoutes() async {
    final tripPlan = ref.read(tripPlanStateProvider);
    final repo = ref.read(transitRepositoryProvider);
    final routes = await repo.searchRoutes(
      srcLat: tripPlan.from.lat,
      srcLng: tripPlan.from.lng,
      destLat: tripPlan.to.lat,
      destLng: tripPlan.to.lng,
      departureTime: tripPlan.departureTime,
      priority: tripPlan.priority,
    );
    if (mounted) {
      setState(() {
        _routes = routes;
        _selectedRoute = routes.isNotEmpty ? routes.first : null;
        _isLoading = false;
      });
      if (_selectedRoute != null) {
        ref.read(selectedRouteProvider.notifier).setRoute(_selectedRoute);
      }
    }
  }

  void _onRouteCardTap(TransitRoute route) {
    setState(() {
      _selectedRoute = route;
    });
    ref.read(selectedRouteProvider.notifier).setRoute(route);
    context.push('/itinerary');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final tripPlan = ref.watch(tripPlanStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileUrl = isDark
        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
        : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png';

    // Polyline points for route visualization
    final routePoints = [
      LatLng(tripPlan.from.lat, tripPlan.from.lng),
      const LatLng(18.5182, 73.8413), // Deccan
      const LatLng(18.5308, 73.8475), // Shivajinagar
      const LatLng(18.5529, 73.8797), // Yerawada
      LatLng(tripPlan.to.lat, tripPlan.to.lng),
    ];

    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        children: [
          // 1. Map showing Route
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
                  // Casing
                  Polyline(
                    points: routePoints,
                    strokeWidth: 8,
                    color: c.card,
                  ),
                  // Solid Blue Bus route line
                  Polyline(
                    points: routePoints,
                    strokeWidth: 5,
                    color: c.blue,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  // Origin
                  Marker(
                    point: LatLng(tripPlan.from.lat, tripPlan.from.lng),
                    width: 24,
                    height: 24,
                    child: Container(
                      decoration: BoxDecoration(
                        color: c.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.card, width: 3),
                      ),
                    ),
                  ),
                  // Transfer node
                  Marker(
                    point: const LatLng(18.5182, 73.8413),
                    width: 20,
                    height: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: c.card,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.blue, width: 3),
                      ),
                    ),
                  ),
                  // Destination
                  Marker(
                    point: LatLng(tripPlan.to.lat, tripPlan.to.lng),
                    width: 24,
                    height: 24,
                    child: Container(
                      decoration: BoxDecoration(
                        color: c.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.card, width: 3),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 2. Floating Top Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sp.x4, vertical: Sp.x2),
              child: Row(
                children: [
                  Glass(
                    radius: Rad.sheet,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: c.label, size: 18),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const SizedBox(width: Sp.x3),
                  Expanded(
                    child: Glass(
                      radius: Rad.sheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: Sp.x4, vertical: Sp.x2 + 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              tripPlan.from.name,
                              style: MargText.subhead.copyWith(
                                color: c.label,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: Sp.x2),
                              child: Icon(Icons.chevron_right, size: 16, color: c.label2),
                            ),
                            Expanded(
                              child: Text(
                                tripPlan.to.name,
                                overflow: TextOverflow.ellipsis,
                                style: MargText.subhead.copyWith(
                                  color: c.label,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Bottom Glass Sheet with Ranked Route Cards
          DraggableScrollableSheet(
            initialChildSize: 0.58,
            minChildSize: 0.25,
            maxChildSize: 0.88,
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
                        decoration: BoxDecoration(
                          color: c.label3,
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: Sp.x3),

                    // Results header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_routes.length} routes',
                              style: MargText.title3.copyWith(color: c.label),
                            ),
                            Text(
                              'PMPML buses · live schedule',
                              style: MargText.footnote.copyWith(color: c.label2),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: Sp.x3, vertical: Sp.x1),
                          decoration: BoxDecoration(
                            color: c.fill,
                            borderRadius: BorderRadius.circular(Rad.sm),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.access_time_rounded, size: 14, color: c.label),
                              const SizedBox(width: Sp.x1),
                              Text(
                                'Leave now',
                                style: MargText.footnote.copyWith(
                                  color: c.label,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Sp.x4),

                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(Sp.x8),
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      )
                    else
                      ..._routes.map((route) {
                        final isSelected = _selectedRoute?.routeId == route.routeId;
                        return _RouteCard(
                          route: route,
                          isSelected: isSelected,
                          onTap: () => _onRouteCardTap(route),
                        );
                      }),
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

class _RouteCard extends StatelessWidget {
  final TransitRoute route;
  final bool isSelected;
  final VoidCallback onTap;

  const _RouteCard({
    required this.route,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    final badgeType = switch (route.routeType) {
      'fastest' => BadgeType.fastest,
      'least_transfers' => BadgeType.fewerTransfers,
      'least_walking' => BadgeType.lessWalking,
      _ => null,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: Sp.x3),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(Rad.md),
        border: Border.all(
          color: isSelected ? c.blue : c.separator,
          width: isSelected ? 2.0 : 0.5,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: c.tint(c.blue, 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Rad.md),
          child: Padding(
            padding: const EdgeInsets.all(Sp.x3 + 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Badge and Total Time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (badgeType != null)
                      BadgeLabel(type: badgeType)
                    else
                      const SizedBox(),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${route.totalTimeMins}',
                            style: MargText.title3.copyWith(
                              color: c.label,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: ' min',
                            style: MargText.caption.copyWith(
                              color: c.label2,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Sp.x3),

                // Legs chips row: e.g. [Walk 6] > [Bus 17] > [Bus 144] > [Walk 3]
                Row(
                  children: [
                    for (int i = 0; i < route.legs.length; i++) ...[
                      if (route.legs[i].mode == 'walk')
                        WalkChip(durationMins: route.legs[i].durationMins)
                      else if (route.legs[i].mode == 'bus')
                        BusChip(line: route.legs[i].line ?? 'Bus', showIcon: true),
                      if (i < route.legs.length - 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Sp.x1),
                          child: Icon(Icons.chevron_right, size: 14, color: c.label3),
                        ),
                    ],
                  ],
                ),
                const SizedBox(height: Sp.x3),

                // Meta footer: arrival info, transfers, walking
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      route.transfers == 0
                          ? 'Arrive 9:45 AM · Direct'
                          : 'Arrive 9:37 AM · ${route.transfers} transfer',
                      style: MargText.footnote.copyWith(color: c.label2),
                    ),
                    if (route.nextBusMins != null)
                      Text(
                        'Next bus in ${route.nextBusMins} min',
                        style: MargText.footnote.copyWith(
                          color: c.green,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      Text(
                        '${route.totalWalkM} m walk',
                        style: MargText.footnote.copyWith(color: c.label2),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
