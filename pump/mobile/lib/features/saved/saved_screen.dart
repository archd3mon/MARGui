import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/marg_tokens.dart';
import '../../shared/widgets/bus_chip.dart';
import '../../shared/widgets/tile_icon.dart';
import '../../data/models/saved_item.dart';
import '../../data/models/place.dart';
import '../../app/app_state.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  void _onPlaceTap(BuildContext context, WidgetRef ref, SavedPlace place) {
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

  void _onRouteTap(BuildContext context, WidgetRef ref, SavedRoute route) {
    ref.read(tripPlanStateProvider.notifier).updatePlan((state) => state.copyWith(
      from: Place(
        id: 'src_${route.id}',
        name: route.fromName,
        displayName: 'Pune',
        lat: route.sourceLat,
        lng: route.sourceLng,
      ),
      to: Place(
        id: 'dest_${route.id}',
        name: route.toName,
        displayName: 'Pune',
        lat: route.destLat,
        lng: route.destLng,
      ),
    ));
    context.push('/results');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final places = ref.watch(savedPlacesProvider);
    final routes = ref.watch(savedRoutesProvider);

    final homePlace = places.firstWhere(
      (p) => p.type == 'home',
      orElse: () => const SavedPlace(id: 'home', name: 'Home', locationName: 'Kothrud', lat: 18.5074, lng: 73.8077, type: 'home'),
    );
    final workPlace = places.firstWhere(
      (p) => p.type == 'work',
      orElse: () => const SavedPlace(id: 'work', name: 'Work', locationName: 'Viman Nagar', lat: 18.5679, lng: 73.9143, type: 'work'),
    );

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: Sp.x4),
          children: [
            const SizedBox(height: Sp.x4),
            Text(
              'Saved',
              style: MargText.largeTitle.copyWith(color: c.label),
            ),
            const SizedBox(height: Sp.x4),

            // Quick places grid (Home & Work)
            Row(
              children: [
                Expanded(
                  child: _PlaceCard(
                    place: homePlace,
                    icon: Icons.home_rounded,
                    color: TileColor.blue,
                    onTap: () => _onPlaceTap(context, ref, homePlace),
                  ),
                ),
                const SizedBox(width: Sp.x3),
                Expanded(
                  child: _PlaceCard(
                    place: workPlace,
                    icon: Icons.work_rounded,
                    color: TileColor.orange,
                    onTap: () => _onPlaceTap(context, ref, workPlace),
                  ),
                ),
              ],
            ),

            const SizedBox(height: Sp.x6),

            // Routes Section Header
            Text(
              'Routes',
              style: MargText.headline.copyWith(
                color: c.label,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: Sp.x2),

            // Saved Routes grouped list
            Container(
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(Rad.md),
                border: Border.all(color: c.separator, width: 0.5),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < routes.length; i++) ...[
                    _SavedRouteRow(
                      route: routes[i],
                      onTap: () => _onRouteTap(context, ref, routes[i]),
                    ),
                    if (i < routes.length - 1)
                      Divider(color: c.separator, height: 1, indent: Sp.x4),
                  ],
                ],
              ),
            ),

            const SizedBox(height: Sp.x3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sp.x2),
              child: Text(
                'Saved routes check live conditions and alert you before you leave.',
                style: MargText.footnote.copyWith(color: c.label2),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  final SavedPlace place;
  final IconData icon;
  final TileColor color;
  final VoidCallback onTap;

  const _PlaceCard({
    required this.place,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Rad.md),
      child: Container(
        padding: const EdgeInsets.all(Sp.x3),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(Rad.md),
          border: Border.all(color: c.separator, width: 0.5),
        ),
        child: Row(
          children: [
            TileIcon(icon: icon, color: color, size: 40, iconSize: 20),
            const SizedBox(width: Sp.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: MargText.headline.copyWith(color: c.label),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    place.locationName,
                    style: MargText.footnote.copyWith(color: c.label2),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedRouteRow extends StatelessWidget {
  final SavedRoute route;
  final VoidCallback onTap;

  const _SavedRouteRow({
    required this.route,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Rad.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Sp.x4, vertical: Sp.x3 + 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route.title,
                    style: MargText.headline.copyWith(color: c.label),
                  ),
                  const SizedBox(height: Sp.x1),
                  Row(
                    children: [
                      for (int i = 0; i < route.busLines.length; i++) ...[
                        BusChip(line: route.busLines[i]),
                        if (i < route.busLines.length - 1)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Sp.x1 / 2),
                            child: Icon(Icons.chevron_right, size: 12, color: c.label3),
                          ),
                      ],
                      const SizedBox(width: Sp.x2),
                      Text(
                        route.scheduleText,
                        style: MargText.footnote.copyWith(color: c.label2),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${route.totalTimeMins}',
                        style: MargText.headline.copyWith(
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
                const SizedBox(height: 2),
                Text(
                  route.statusText,
                  style: MargText.footnote.copyWith(
                    color: route.isOnTime ? c.green : c.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
