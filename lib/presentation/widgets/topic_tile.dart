import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart';
import '../../models/review_intervals.dart';
import '../../models/topic.dart';
import '../../state/planner_state.dart';
import '../utils/adaptive_dialogs.dart';
import '../utils/date_formatters.dart';
import 'apple_card.dart';

class TopicTile extends StatelessWidget {
  final Topic topic;
  final Category? category;
  final VoidCallback onReview;
  final VoidCallback onReset;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TopicTile({
    super.key,
    required this.topic,
    required this.category,
    required this.onReview,
    required this.onReset,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isApple = AdaptiveDialogs.isApple(context);
    final s = context.watch<PlannerState>().strings;
    final color = category?.color ?? const Color(0xFFB8A9F8);
    final isOverdue = topic.isOverdue;

    if (topic.isCompleted) {
      return AppleCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF8EC89A)
                    .withValues(alpha: isDark ? 0.25 : 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isApple
                    ? CupertinoIcons.checkmark_seal_fill
                    : Icons.verified,
                size: 18,
                color: const Color(0xFF8EC89A),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    s.memorizedSubtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white38 : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
            _buildPopupMenu(context, isDark: isDark, isApple: isApple, s: s),
          ],
        ),
      );
    }

    final timeText = DateFormatters.formatReviewTime(
      topic.nextReviewAt,
      strings: s,
    );

    return AppleCard(
      accentColor: color,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  topic.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildPopupMenu(context, isDark: isDark, isApple: isApple, s: s),
            ],
          ),

          const SizedBox(height: 10),

          // Steps indicator and status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.25 : 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  s.stepLabel(topic.currentStep, ReviewIntervals.totalSteps),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isOverdue
                      ? (isDark
                          ? const Color(0xFF421C1F)
                          : const Color(0xFFFFEBEF))
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.05)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOverdue
                          ? (isApple
                              ? CupertinoIcons.exclamationmark_circle_fill
                              : Icons.error)
                          : (isApple
                              ? CupertinoIcons.clock
                              : Icons.access_time),
                      size: 11,
                      color: isOverdue
                          ? const Color(0xFFE5484D)
                          : (isDark ? Colors.white60 : Colors.black54),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isOverdue
                            ? const Color(0xFFE5484D)
                            : (isDark ? Colors.white60 : Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Quick "Reviewed" button
              if (isApple)
                CupertinoButton(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  minimumSize: const Size(40, 32),
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onReview();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.checkmark_alt,
                        size: 14,
                        color: isDark
                            ? const Color(0xFF0F1015)
                            : Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        s.reviewedBtn,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFF0F1015)
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              else
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: color,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    minimumSize: const Size(40, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onReview();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check,
                        size: 14,
                        color: isDark
                            ? const Color(0xFF0F1015)
                            : Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        s.reviewedBtn,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFF0F1015)
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPopupMenu(
    BuildContext context, {
    required bool isDark,
    required bool isApple,
    required dynamic s,
  }) {
    return PopupMenuButton<String>(
      icon: Icon(
        isApple ? CupertinoIcons.ellipsis : Icons.more_vert,
        size: 18,
        color: isDark ? Colors.white54 : Colors.black45,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      onSelected: (value) {
        if (value == 'edit') {
          onEdit();
        } else if (value == 'reset') {
          onReset();
        } else if (value == 'delete') {
          onDelete();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(isApple ? CupertinoIcons.pencil : Icons.edit, size: 16),
              const SizedBox(width: 10),
              Text(s.edit),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'reset',
          child: Row(
            children: [
              Icon(
                  isApple
                      ? CupertinoIcons.arrow_counterclockwise
                      : Icons.restart_alt,
                  size: 16),
              const SizedBox(width: 10),
              Text(s.resetProgress),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(isApple ? CupertinoIcons.trash : Icons.delete,
                  size: 16, color: const Color(0xFFE5484D)),
              const SizedBox(width: 10),
              Text(s.delete,
                  style: const TextStyle(color: Color(0xFFE5484D))),
            ],
          ),
        ),
      ],
    );
  }
}
