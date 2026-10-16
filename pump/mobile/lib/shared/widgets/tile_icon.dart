import 'package:flutter/material.dart';
import '../../theme/marg_tokens.dart';

enum TileColor {
  blue,
  orange,
  green,
  red,
  gray,
}

class TileIcon extends StatelessWidget {
  final IconData icon;
  final TileColor color;
  final double size;
  final double iconSize;

  const TileIcon({
    super.key,
    required this.icon,
    this.color = TileColor.blue,
    this.size = 36,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final (bg, fg) = switch (color) {
      TileColor.blue => (c.tint(c.blue, 0.15), c.blue),
      TileColor.orange => (c.tint(c.orange, 0.15), c.orange),
      TileColor.green => (c.tint(c.green, 0.15), c.green),
      TileColor.red => (c.tint(c.red, 0.15), c.red),
      TileColor.gray => (c.fill, c.label2),
    };

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Rad.sm),
      ),
      child: Center(
        child: Icon(icon, color: fg, size: iconSize),
      ),
    );
  }
}
