import 'package:flutter/material.dart';
import '../../../theme/marg_tokens.dart';

class ItineraryTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onShare;

  const ItineraryTopBar({
    super.key,
    required this.onBack,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Sp.x4, vertical: Sp.x2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left back button
            _CircularGlassButton(
              icon: Icons.arrow_back_ios_new_rounded,
              iconSize: 18,
              color: c.blue,
              onPressed: onBack,
            ),

            // Right share button
            _CircularGlassButton(
              icon: Icons.share_rounded,
              iconSize: 20,
              color: c.blue,
              onPressed: onShare,
            ),
          ],
        ),
      ),
    );
  }
}

class _CircularGlassButton extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final Color color;
  final VoidCallback onPressed;

  const _CircularGlassButton({
    required this.icon,
    required this.iconSize,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Glass(
        radius: 22,
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(icon, color: color, size: iconSize),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
