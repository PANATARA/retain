import 'package:flutter/material.dart';

class CategoryBadge extends StatelessWidget {
  final String title;
  final Color color;
  final bool compact;

  const CategoryBadge({
    super.key,
    required this.title,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark
        ? color.withValues(alpha: 0.22)
        : color.withValues(alpha: 0.18);
    final textColor = isDark
        ? Color.alphaBlend(color, Colors.white)
        : Color.alphaBlend(Colors.black.withValues(alpha: 0.3), color);
    final borderColor = color.withValues(alpha: isDark ? 0.35 : 0.3);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w600,
                color: textColor,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
