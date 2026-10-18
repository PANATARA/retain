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
import 'category_badge.dart';

class UpNextCard extends StatefulWidget {
  final Topic topic;
  final Category? category;
  final VoidCallback onReview;
  final VoidCallback? onTap;

  const UpNextCard({
    super.key,
    required this.topic,
    required this.category,
    required this.onReview,
    this.onTap,
  });

  @override
  State<UpNextCard> createState() => _UpNextCardState();
}

class _UpNextCardState extends State<UpNextCard> {
  bool _isChecking = false;

  void _handleReview() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);
    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      widget.onReview();
      setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isApple = AdaptiveDialogs.isApple(context);
    final s = context.watch<PlannerState>().strings;
    final categoryColor = widget.category?.color ?? const Color(0xFFB8A9F8);
    final isOverdue = widget.topic.isOverdue;

    final timeText = DateFormatters.formatReviewTime(
      widget.topic.nextReviewAt,
      strings: s,
    );

    return AppleCard(
      accentColor: categoryColor,
      onTap: widget.onTap,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Category badge & Time status
          Row(
            children: [
              CategoryBadge(
                title: widget.category?.title ?? (s.isRussian ? 'Без категории' : 'No category'),
                color: categoryColor,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isOverdue
                      ? (isDark
                          ? const Color(0xFF421C1F)
                          : const Color(0xFFFFEBEF))
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.05)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isOverdue
                        ? (isDark
                            ? const Color(0xFFE5484D).withValues(alpha: 0.5)
                            : const Color(0xFFE5484D).withValues(alpha: 0.3))
                        : Colors.transparent,
                    width: 0.8,
                  ),
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
                      size: 13,
                      color: isOverdue
                          ? const Color(0xFFE5484D)
                          : (isDark ? Colors.white70 : Colors.black54),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      timeText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isOverdue
                            ? const Color(0xFFE5484D)
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Topic Title
          Text(
            widget.topic.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: isDark ? Colors.white : const Color(0xFF1C1C1E),
            ),
          ),

          const SizedBox(height: 14),

          // Step Progress Bar (5 segments)
          Row(
            children: List.generate(ReviewIntervals.totalSteps, (index) {
              final isPassed = index <= widget.topic.currentStep;
              final isCurrent = index == widget.topic.currentStep;

              return Expanded(
                child: Container(
                  height: 5,
                  margin: EdgeInsets.only(
                    right: index == ReviewIntervals.totalSteps - 1 ? 0 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: isPassed
                        ? categoryColor
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.black.withValues(alpha: 0.08)),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: categoryColor.withValues(alpha: 0.5),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            )
                          ]
                        : null,
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 8),

          // Step description
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s.stepLabel(widget.topic.currentStep, ReviewIntervals.totalSteps),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              Text(
                '${s.intervalPrefix} ${s.intervalDescription(widget.topic.currentStep)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Action row: tactile "Reviewed" button
          SizedBox(
            width: double.infinity,
            child: isApple
                ? CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    color: categoryColor,
                    borderRadius: BorderRadius.circular(16),
                    onPressed: _isChecking ? null : _handleReview,
                    child: _buildButtonContent(isDark: isDark, isApple: true, label: s.reviewedBtn),
                  )
                : FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: categoryColor,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _isChecking ? null : _handleReview,
                    child: _buildButtonContent(isDark: isDark, isApple: false, label: s.reviewedBtn),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonContent({
    required bool isDark,
    required bool isApple,
    required String label,
  }) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: _isChecking
          ? SizedBox(
              height: 20,
              width: 20,
              child: isApple
                  ? const CupertinoActivityIndicator(color: Colors.white)
                  : const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isApple
                      ? CupertinoIcons.checkmark_alt_circle_fill
                      : Icons.check_circle,
                  size: 20,
                  color: isDark ? const Color(0xFF0F1015) : Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF0F1015) : Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
    );
  }
}
