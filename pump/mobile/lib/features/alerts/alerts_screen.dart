import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/marg_tokens.dart';
import '../../shared/widgets/segmented_control.dart';
import '../../shared/widgets/tile_icon.dart';
import '../../data/models/alert_model.dart';
import '../../app/app_state.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  String _selectedSegment = 'my_routes';

  late bool _notifyDelays;
  late bool _notifyLeaveNow;
  late bool _notifyServiceChanges;

  @override
  void initState() {
    super.initState();
    final storage = ref.read(storageServiceProvider);
    _notifyDelays = storage.notifyDelays;
    _notifyLeaveNow = storage.notifyLeaveNow;
    _notifyServiceChanges = storage.notifyServiceChanges;
  }

  void _updateNotifyDelays(bool val) {
    setState(() => _notifyDelays = val);
    ref.read(storageServiceProvider).setNotifyDelays(val);
  }

  void _updateNotifyLeaveNow(bool val) {
    setState(() => _notifyLeaveNow = val);
    ref.read(storageServiceProvider).setNotifyLeaveNow(val);
  }

  void _updateNotifyServiceChanges(bool val) {
    setState(() => _notifyServiceChanges = val);
    ref.read(storageServiceProvider).setNotifyServiceChanges(val);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final repo = ref.watch(transitRepositoryProvider);
    final alerts = repo.getAlerts(myRoutesOnly: _selectedSegment == 'my_routes');

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: Sp.x4),
          children: [
            const SizedBox(height: Sp.x4),
            Text(
              'Alerts',
              style: MargText.largeTitle.copyWith(color: c.label),
            ),
            const SizedBox(height: Sp.x3),

            // Segmented Control (My Routes / All Service)
            MargSegmentedControl<String>(
              items: const [
                SegmentItem(value: 'my_routes', title: 'My Routes'),
                SegmentItem(value: 'all_service', title: 'All Service'),
              ],
              selectedValue: _selectedSegment,
              onValueChanged: (val) {
                setState(() => _selectedSegment = val);
              },
            ),

            const SizedBox(height: Sp.x4),

            // Alerts Grouped List
            Container(
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(Rad.md),
                border: Border.all(color: c.separator, width: 0.5),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < alerts.length; i++) ...[
                    _AlertRow(alert: alerts[i]),
                    if (i < alerts.length - 1)
                      Divider(color: c.separator, height: 1, indent: 56),
                  ],
                ],
              ),
            ),

            const SizedBox(height: Sp.x6),

            // "Notify me" Section Header
            Text(
              'Notify me',
              style: MargText.headline.copyWith(
                color: c.label,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: Sp.x2),

            // Notification Toggles Container
            Container(
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(Rad.md),
                border: Border.all(color: c.separator, width: 0.5),
              ),
              child: Column(
                children: [
                  _ToggleRow(
                    title: 'Delays on saved routes',
                    value: _notifyDelays,
                    onChanged: _updateNotifyDelays,
                  ),
                  Divider(color: c.separator, height: 1, indent: Sp.x4),
                  _ToggleRow(
                    title: 'Leave-now reminders',
                    value: _notifyLeaveNow,
                    onChanged: _updateNotifyLeaveNow,
                  ),
                  Divider(color: c.separator, height: 1, indent: Sp.x4),
                  _ToggleRow(
                    title: 'Service changes',
                    value: _notifyServiceChanges,
                    onChanged: _updateNotifyServiceChanges,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  final TransitAlert alert;

  const _AlertRow({required this.alert});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final (icon, color) = switch (alert.type) {
      'delay' => (Icons.warning_amber_rounded, TileColor.orange),
      'diversion' => (Icons.alt_route, TileColor.blue),
      _ => (Icons.access_time_rounded, TileColor.green),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sp.x4, vertical: Sp.x3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TileIcon(icon: icon, color: color, size: 40, iconSize: 20),
          const SizedBox(width: Sp.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      alert.title,
                      style: MargText.headline.copyWith(color: c.label),
                    ),
                    Text(
                      alert.timeAgo,
                      style: MargText.caption.copyWith(color: c.label3),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  alert.body,
                  style: MargText.footnote.copyWith(color: c.label2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sp.x4, vertical: Sp.x1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: MargText.body.copyWith(color: c.label),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: c.card,
            activeTrackColor: c.green,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
