import 'review_intervals.dart';

class Topic {
  final String id;
  final String categoryId;
  final String title;
  final DateTime createdAt;
  final int currentStep; // 0 to 4
  final DateTime nextReviewAt;
  final bool isCompleted;

  const Topic({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.createdAt,
    this.currentStep = 0,
    required this.nextReviewAt,
    this.isCompleted = false,
  });

  /// Stable notification ID for flutter_local_notifications (positive 31-bit integer).
  int get notificationId => id.hashCode & 0x7FFFFFFF;

  /// True if the topic is active and the review time has passed.
  bool get isOverdue => !isCompleted && DateTime.now().isAfter(nextReviewAt);

  /// True if the topic is due today or overdue.
  bool get isDueTodayOrOverdue {
    if (isCompleted) return false;
    final now = DateTime.now();
    if (now.isAfter(nextReviewAt)) return true;
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return nextReviewAt.isBefore(endOfToday);
  }

  /// Advances the review step or marks completed if at step 4.
  Topic markReviewed({DateTime? reviewedAt}) {
    final now = reviewedAt ?? DateTime.now();
    if (currentStep >= ReviewIntervals.totalSteps - 1) {
      // Completed step 4 (30 days) -> Mark completed!
      return copyWith(
        isCompleted: true,
      );
    } else {
      final nextStep = currentStep + 1;
      final nextTime = ReviewIntervals.calculateNextReview(nextStep, baseTime: now);
      return copyWith(
        currentStep: nextStep,
        nextReviewAt: nextTime,
        isCompleted: false,
      );
    }
  }

  /// Resets review progress back to Step 0 (+20 minutes).
  Topic resetProgress({DateTime? resetAt}) {
    final now = resetAt ?? DateTime.now();
    return copyWith(
      currentStep: 0,
      nextReviewAt: ReviewIntervals.calculateNextReview(0, baseTime: now),
      isCompleted: false,
    );
  }

  Topic copyWith({
    String? id,
    String? categoryId,
    String? title,
    DateTime? createdAt,
    int? currentStep,
    DateTime? nextReviewAt,
    bool? isCompleted,
  }) {
    return Topic(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      currentStep: currentStep ?? this.currentStep,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'categoryId': categoryId,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'currentStep': currentStep,
    'nextReviewAt': nextReviewAt.toIso8601String(),
    'isCompleted': isCompleted,
  };

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      currentStep: (json['currentStep'] as num?)?.toInt() ?? 0,
      nextReviewAt: DateTime.parse(json['nextReviewAt'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}
