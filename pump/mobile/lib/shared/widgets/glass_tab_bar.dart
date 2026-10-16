import 'package:flutter/material.dart';
import '../../theme/marg_tokens.dart';

enum MargTab {
  explore,
  saved,
  alerts,
}

class GlassTabBar extends StatelessWidget {
  final MargTab currentTab;
  final ValueChanged<MargTab> onTabSelected;

  const GlassTabBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(left: Sp.x4, right: Sp.x4, bottom: Sp.x2),
        child: Glass(
          radius: Rad.lg,
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: Sp.x2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _TabItem(
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore,
                  label: 'Explore',
                  isSelected: currentTab == MargTab.explore,
                  onTap: () => onTabSelected(MargTab.explore),
                ),
                _TabItem(
                  icon: Icons.bookmark_border_rounded,
                  activeIcon: Icons.bookmark_rounded,
                  label: 'Saved',
                  isSelected: currentTab == MargTab.saved,
                  onTap: () => onTabSelected(MargTab.saved),
                ),
                _TabItem(
                  icon: Icons.notifications_none_rounded,
                  activeIcon: Icons.notifications_rounded,
                  label: 'Alerts',
                  isSelected: currentTab == MargTab.alerts,
                  onTap: () => onTabSelected(MargTab.alerts),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final color = isSelected ? c.blue : c.label2;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Rad.md),
      child: Container(
        constraints: const BoxConstraints(minWidth: Layout.touch, minHeight: Layout.touch),
        padding: const EdgeInsets.symmetric(horizontal: Sp.x3, vertical: Sp.x1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: color,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: MargText.caption.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
