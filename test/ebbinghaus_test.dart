import 'package:flutter_test/flutter_test.dart';
import 'package:ebbplan/models/category.dart';
import 'package:ebbplan/models/topic.dart';
import 'package:ebbplan/models/review_intervals.dart';
import 'package:ebbplan/models/app_data.dart';

void main() {
  group('ReviewIntervals Ebbinghaus Tests', () {
    test('Verifies strict Ebbinghaus curve intervals', () {
      expect(ReviewIntervals.totalSteps, 5);
      expect(ReviewIntervals.durationForStep(0), const Duration(minutes: 20));
      expect(ReviewIntervals.durationForStep(1), const Duration(hours: 12));
      expect(ReviewIntervals.durationForStep(2), const Duration(days: 3));
      expect(ReviewIntervals.durationForStep(3), const Duration(days: 10));
      expect(ReviewIntervals.durationForStep(4), const Duration(days: 30));
    });

    test('Topic step advancement and completion', () {
      final now = DateTime(2026, 1, 1, 12, 0);
      var topic = Topic(
        id: 'test-1',
        categoryId: 'cat-1',
        title: 'Present Perfect',
        createdAt: now,
        currentStep: 0,
        nextReviewAt: ReviewIntervals.calculateNextReview(0, baseTime: now),
      );

      expect(topic.currentStep, 0);
      expect(topic.nextReviewAt, now.add(const Duration(minutes: 20)));
      expect(topic.isCompleted, isFalse);

      // Step 0 -> Step 1 (+12h)
      topic = topic.markReviewed(reviewedAt: now);
      expect(topic.currentStep, 1);
      expect(topic.nextReviewAt, now.add(const Duration(hours: 12)));
      expect(topic.isCompleted, isFalse);

      // Step 1 -> Step 2 (+3d)
      topic = topic.markReviewed(reviewedAt: now);
      expect(topic.currentStep, 2);
      expect(topic.nextReviewAt, now.add(const Duration(days: 3)));
      expect(topic.isCompleted, isFalse);

      // Step 2 -> Step 3 (+10d)
      topic = topic.markReviewed(reviewedAt: now);
      expect(topic.currentStep, 3);
      expect(topic.nextReviewAt, now.add(const Duration(days: 10)));
      expect(topic.isCompleted, isFalse);

      // Step 3 -> Step 4 (+30d)
      topic = topic.markReviewed(reviewedAt: now);
      expect(topic.currentStep, 4);
      expect(topic.nextReviewAt, now.add(const Duration(days: 30)));
      expect(topic.isCompleted, isFalse);

      // Step 4 -> Completed!
      topic = topic.markReviewed(reviewedAt: now);
      expect(topic.isCompleted, isTrue);
    });

    test('Topic reset returns to Step 0 (+20 minutes)', () {
      final now = DateTime(2026, 1, 1, 12, 0);
      var topic = Topic(
        id: 'test-2',
        categoryId: 'cat-1',
        title: 'Git Rebase',
        createdAt: now,
        currentStep: 3,
        nextReviewAt: now.add(const Duration(days: 10)),
      );

      final reset = topic.resetProgress(resetAt: now);
      expect(reset.currentStep, 0);
      expect(reset.nextReviewAt, now.add(const Duration(minutes: 20)));
      expect(reset.isCompleted, isFalse);
    });

    test('AppData JSON serialization and deserialization', () {
      final now = DateTime(2026, 1, 1, 12, 0);
      final category = Category(
        id: 'cat-test',
        title: 'English',
        colorHex: '#B8A9F8',
        createdAt: now,
      );
      final topic = Topic(
        id: 'topic-test',
        categoryId: 'cat-test',
        title: 'Vocabulary',
        createdAt: now,
        currentStep: 1,
        nextReviewAt: now.add(const Duration(hours: 12)),
        isCompleted: false,
      );

      final appData = AppData(
        version: 1,
        categories: [category],
        topics: [topic],
      );

      final json = appData.toJson();
      final restored = AppData.fromJson(json);

      expect(restored.categories.length, 1);
      expect(restored.categories.first.title, 'English');
      expect(restored.categories.first.colorHex, '#B8A9F8');
      expect(restored.topics.length, 1);
      expect(restored.topics.first.title, 'Vocabulary');
      expect(restored.topics.first.currentStep, 1);
      expect(restored.topics.first.isCompleted, false);
    });

    test('AppData default data is empty, defaults to English and onboarding unseen', () {
      final defaultData = AppData.defaultData();
      expect(defaultData.categories, isEmpty);
      expect(defaultData.topics, isEmpty);
      expect(defaultData.language, 'en');
      expect(defaultData.hasSeenOnboarding, isFalse);
    });
  });
}
