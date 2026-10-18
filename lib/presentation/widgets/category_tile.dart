import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart';
import '../../state/planner_state.dart';
import '../utils/adaptive_dialogs.dart';
import 'apple_card.dart';

class CategoryTile extends StatelessWidget {
  final Category category;
  final int activeCount;
  final int totalCount;
  final VoidCallback onTap;

  const CategoryTile({
    super.key,
    required this.category,
    required this.activeCount,
    required this.totalCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isApple = AdaptiveDialogs.isApple(context);
    final s = context.watch<PlannerState>().strings;
    final color = category.color;

    return AppleCard(
      accentColor: color,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          // Pastel icon circle
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.25 : 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: isDark ? 0.4 : 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              isApple ? CupertinoIcons.folder_fill : Icons.folder,
              size: 22,
              color: isDark ? color : Color.alphaBlend(Colors.black.withValues(alpha: 0.2), color),
            ),
          ),

          const SizedBox(width: 16),

          // Category Title and Active Topics Counter
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  category.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activeCount > 0
                      ? s.topicsToReview(activeCount)
                      : (totalCount > 0
                          ? s.allTopicsReviewed
                          : s.noActiveTopics),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: activeCount > 0
                        ? (isDark ? Colors.white70 : Colors.black87)
                        : (isDark ? Colors.white38 : Colors.black45),
                  ),
                ),
              ],
            ),
          ),

          // Active indicator pill
          if (activeCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.3 : 0.22),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$activeCount',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                ),
              ),
            ),

          const SizedBox(width: 8),

          Icon(
            isApple ? CupertinoIcons.chevron_forward : Icons.chevron_right,
            size: 18,
            color: isDark ? Colors.white30 : Colors.black26,
          ),
        ],
      ),
    );
  }
}
