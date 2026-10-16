import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/marg_tokens.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/segmented_control.dart';
import '../../shared/widgets/tile_icon.dart';
import '../../data/models/place.dart';
import '../../app/app_state.dart';

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  String _selectedPriority = 'fastest';
  String _travelMode = 'bus';
  String _departureTime = 'Now · 8:42 AM';

  void _swapPoints() {
    final state = ref.read(tripPlanStateProvider);
    ref.read(tripPlanStateProvider.notifier).setPlan(state.copyWith(
      from: state.to,
      to: state.from,
    ));
  }

  void _showPlaceSearch(bool isSelectingFrom) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PlaceSearchSheet(
        isSelectingFrom: isSelectingFrom,
        onPlaceSelected: (place) {
          final s = ref.read(tripPlanStateProvider);
          if (isSelectingFrom) {
            ref.read(tripPlanStateProvider.notifier).setPlan(s.copyWith(from: place));
          } else {
            ref.read(tripPlanStateProvider.notifier).setPlan(s.copyWith(to: place));
            ref.read(storageServiceProvider).addRecentSearch(place);
          }
        },
      ),
    );
  }

  void _showTimePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final c = context.c;
        return Glass(
          radius: Rad.sheet,
          topOnly: true,
          child: Padding(
            padding: const EdgeInsets.all(Sp.x4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(color: c.label3, borderRadius: BorderRadius.circular(2.5)),
                  ),
                ),
                const SizedBox(height: Sp.x3),
                Text('Departure Time', style: MargText.headline.copyWith(color: c.label)),
                const SizedBox(height: Sp.x3),
                ListTile(
                  leading: Icon(Icons.access_time_rounded, color: c.blue),
                  title: Text('Leave Now', style: MargText.body.copyWith(color: c.label)),
                  onTap: () {
                    setState(() => _departureTime = 'Now · 8:42 AM');
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.schedule_rounded, color: c.label2),
                  title: Text('Set Departure Time (9:00 AM)', style: MargText.body.copyWith(color: c.label)),
                  onTap: () {
                    setState(() => _departureTime = 'Today · 9:00 AM');
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.schedule_rounded, color: c.label2),
                  title: Text('Set Departure Time (9:30 AM)', style: MargText.body.copyWith(color: c.label)),
                  onTap: () {
                    setState(() => _departureTime = 'Today · 9:30 AM');
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: Sp.x2),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final tripPlan = ref.watch(tripPlanStateProvider);
    final recents = ref.watch(storageServiceProvider).getRecentSearches();

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 80,
        leading: TextButton(
          onPressed: () => context.pop(),
          child: Text(
            'Cancel',

            style: MargText.headline.copyWith(
              color: c.blue,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        title: Text(
          'Plan Trip',
          style: MargText.headline.copyWith(
            color: c.label,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: Sp.x4),
                children: [
                  const SizedBox(height: Sp.x2),
                  // Origin / Destination Card
                  Container(
                    padding: const EdgeInsets.all(Sp.x3),
                    decoration: BoxDecoration(
                      color: c.card,
                      borderRadius: BorderRadius.circular(Rad.md),
                      border: Border.all(color: c.separator, width: 0.5),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            // From
                            InkWell(
                              onTap: () => _showPlaceSearch(true),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: Sp.x1),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(color: c.blue, shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: Sp.x3),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('From', style: MargText.caption.copyWith(color: c.label3)),
                                          Text(
                                            tripPlan.from.name,
                                            style: MargText.body.copyWith(
                                              color: c.blue,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 40),
                                  ],
                                ),
                              ),
                            ),
                            Divider(color: c.separator, height: Sp.x3),
                            // To
                            InkWell(
                              onTap: () => _showPlaceSearch(false),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: Sp.x1),
                                child: Row(
                                  children: [
                                    Icon(Icons.location_on, color: c.red, size: 14),
                                    const SizedBox(width: Sp.x3 - 2),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('To', style: MargText.caption.copyWith(color: c.label3)),
                                          Text(
                                            tripPlan.to.name,
                                            style: MargText.body.copyWith(
                                              color: c.label,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 40),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Swap button
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: IconButton(
                              icon: Icon(Icons.swap_vert_rounded, color: c.blue),
                              onPressed: _swapPoints,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: Sp.x3),

                  // Leave Row
                  Container(
                    decoration: BoxDecoration(
                      color: c.card,
                      borderRadius: BorderRadius.circular(Rad.md),
                      border: Border.all(color: c.separator, width: 0.5),
                    ),
                    child: ListTile(
                      onTap: _showTimePicker,
                      leading: TileIcon(
                        icon: Icons.access_time_rounded,
                        color: TileColor.blue,
                        size: 32,
                        iconSize: 16,
                      ),
                      title: Text('Leave', style: MargText.body.copyWith(color: c.label)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _departureTime,
                            style: MargText.body.copyWith(color: c.label2),
                          ),
                          const SizedBox(width: Sp.x1),
                          Icon(Icons.chevron_right, color: c.label3, size: 20),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: Sp.x4),

                  // Travel By
                  Text(
                    'Travel by',
                    style: MargText.footnote.copyWith(
                      color: c.label2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: Sp.x2),
                  MargSegmentedControl<String>(
                    items: const [
                      SegmentItem(
                        value: 'bus',
                        title: 'Bus',
                        icon: Icon(Icons.directions_bus_rounded, size: 16),
                      ),
                      SegmentItem(
                        value: 'metro',
                        title: 'Metro',
                        icon: Icon(Icons.subway_rounded, size: 16),
                        badge: 'Soon',
                        disabled: true,
                      ),
                    ],
                    selectedValue: _travelMode,
                    onValueChanged: (val) {
                      setState(() => _travelMode = val);
                    },
                  ),

                  const SizedBox(height: Sp.x4),

                  // Prioritise
                  Text(
                    'Prioritise',
                    style: MargText.footnote.copyWith(
                      color: c.label2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: Sp.x2),
                  Wrap(
                    spacing: Sp.x2,
                    runSpacing: Sp.x2,
                    children: [
                      _PriorityFilterChip(
                        title: 'Fastest',
                        icon: Icons.bolt,
                        isSelected: _selectedPriority == 'fastest',
                        onTap: () => setState(() => _selectedPriority = 'fastest'),
                      ),
                      _PriorityFilterChip(
                        title: 'Fewer transfers',
                        isSelected: _selectedPriority == 'least_transfers',
                        onTap: () => setState(() => _selectedPriority = 'least_transfers'),
                      ),
                      _PriorityFilterChip(
                        title: 'Less walking',
                        isSelected: _selectedPriority == 'least_walking',
                        onTap: () => setState(() => _selectedPriority = 'least_walking'),
                      ),
                    ],
                  ),

                  const SizedBox(height: Sp.x5),

                  // Recent
                  Text(
                    'Recent',
                    style: MargText.footnote.copyWith(
                      color: c.label2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: Sp.x2),
                  Container(
                    decoration: BoxDecoration(
                      color: c.card,
                      borderRadius: BorderRadius.circular(Rad.md),
                      border: Border.all(color: c.separator, width: 0.5),
                    ),
                    child: Column(
                      children: recents.map((item) {
                        return Column(
                          children: [
                            ListTile(
                              leading: TileIcon(
                                icon: Icons.access_time_rounded,
                                color: TileColor.gray,
                                size: 32,
                                iconSize: 16,
                              ),
                              title: Text(item.name, style: MargText.body.copyWith(color: c.label)),
                              subtitle: Text(item.displayName, style: MargText.caption.copyWith(color: c.label2)),
                              onTap: () {
                                ref.read(tripPlanStateProvider.notifier).updatePlan((state) => state.copyWith(to: item));
                              },
                            ),
                            if (item != recents.last) Divider(color: c.separator, height: 1, indent: 56),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: Sp.x4),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sp.x4, vertical: Sp.x3),
              child: PrimaryButton(
                label: 'Show Routes',
                onPressed: () {
                  ref.read(tripPlanStateProvider.notifier).updatePlan(
                    (s) => s.copyWith(
                      departureTime: _departureTime,
                      priority: _selectedPriority,
                    ),
                  );
                  context.push('/results');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityFilterChip extends StatelessWidget {
  final String title;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PriorityFilterChip({
    required this.title,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Motion.fast,
        padding: const EdgeInsets.symmetric(horizontal: Sp.x3, vertical: Sp.x2),
        decoration: BoxDecoration(
          color: isSelected ? c.blue : c.card,
          borderRadius: BorderRadius.circular(Rad.md),
          border: Border.all(color: isSelected ? c.blue : c.separator, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: isSelected ? c.card : c.label2),
              const SizedBox(width: Sp.x1),
            ],
            Text(
              title,
              style: MargText.subhead.copyWith(
                color: isSelected ? c.card : c.label,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceSearchSheet extends ConsumerStatefulWidget {
  final bool isSelectingFrom;
  final ValueChanged<Place> onPlaceSelected;

  const _PlaceSearchSheet({
    required this.isSelectingFrom,
    required this.onPlaceSelected,
  });

  @override
  ConsumerState<_PlaceSearchSheet> createState() => _PlaceSearchSheetState();
}

class _PlaceSearchSheetState extends ConsumerState<_PlaceSearchSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<Place> _results = [];
  bool _isSearching = false;

  void _onSearchChanged(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _isSearching = true);
    final places = await ref.read(transitRepositoryProvider).searchGeocode(query);
    if (mounted) {
      setState(() {
        _results = places;
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Glass(
      radius: Rad.sheet,
      topOnly: true,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(Sp.x4),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(color: c.label3, borderRadius: BorderRadius.circular(2.5)),
              ),
            ),
            const SizedBox(height: Sp.x3),
            TextField(
              controller: _searchCtrl,
              autofocus: true,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: widget.isSelectingFrom ? 'Search origin...' : 'Search destination...',
                prefixIcon: Icon(Icons.search, color: c.label2),
                filled: true,
                fillColor: c.fill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Rad.md),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: Sp.x3),
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (ctx, i) {
                        final p = _results[i];
                        return ListTile(
                          leading: TileIcon(
                            icon: p.type == 'stop' ? Icons.directions_bus_rounded : Icons.location_on_outlined,
                            color: TileColor.blue,
                            size: 32,
                            iconSize: 16,
                          ),
                          title: Text(p.name, style: MargText.body.copyWith(color: c.label)),
                          subtitle: Text(p.displayName, style: MargText.caption.copyWith(color: c.label2)),
                          onTap: () {
                            widget.onPlaceSelected(p);
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
