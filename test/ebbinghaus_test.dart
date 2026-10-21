import 'package:ebbplan/models/app_data.dart';
import 'package:ebbplan/models/category.dart';
import 'package:ebbplan/models/review_intervals.dart';
import 'package:ebbplan/models/sleep_schedule.dart';
import 'package:ebbplan/models/topic.dart';
import 'package:flutter_test/flutter_test.dart';

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
      expect(defaultData.sleepSchedule.isEnabled, isTrue);
      expect(defaultData.sleepSchedule.startHour, 23);
      expect(defaultData.sleepSchedule.endHour, 7);
    });

    test('SleepSchedule moves nighttime reviews (e.g. 3:00 AM) to morning wake-up time', () {
      const schedule = SleepSchedule(
        isEnabled: true,
        startHour: 23,
        startMinute: 0,
        endHour: 7,
        endMinute: 0,
      );

      // Daytime (15:00) -> not sleeping, no adjustment
      final daytime = DateTime(2026, 1, 1, 15, 0);
      expect(schedule.isSleepingAt(daytime), isFalse);
      expect(schedule.adjust(daytime), daytime);

      // Nighttime before midnight (23:15) -> moved to next morning 07:00
      final nightBeforeMidnight = DateTime(2026, 1, 1, 23, 15);
      expect(schedule.isSleepingAt(nightBeforeMidnight), isTrue);
      expect(
        schedule.adjust(nightBeforeMidnight),
        DateTime(2026, 1, 2, 7, 0),
      );

      // Nighttime after midnight (03:00 AM) -> user's exact case, moved to morning 07:00
      final night3am = DateTime(2026, 1, 2, 3, 0);
      expect(schedule.isSleepingAt(night3am), isTrue);
      expect(
        schedule.adjust(night3am),
        DateTime(2026, 1, 2, 7, 0),
      );

      // Right at wake-up (07:00) -> awake, no adjustment
      final morningWakeUp = DateTime(2026, 1, 2, 7, 0);
      expect(schedule.isSleepingAt(morningWakeUp), isFalse);
      expect(schedule.adjust(morningWakeUp), morningWakeUp);

      // When disabled -> no adjustment
      final disabledSchedule = schedule.copyWith(isEnabled: false);
      expect(disabledSchedule.isSleepingAt(night3am), isFalse);
      expect(disabledSchedule.adjust(night3am), night3am);
    });

    test('ReviewIntervals with SleepSchedule prevents nighttime reviews', () {
      const schedule = SleepSchedule(
        isEnabled: true,
        startHour: 23,
        startMinute: 0,
        endHour: 7,
        endMinute: 0,
      );

      // Review at 15:00, Step 1 (+12h) = 03:00 at night -> moves to 07:00 morning
      final reviewAt15 = DateTime(2026, 1, 1, 15, 0);
      final nextReview = ReviewIntervals.calculateNextReview(
        1,
        baseTime: reviewAt15,
        sleepSchedule: schedule,
      );
      expect(nextReview, DateTime(2026, 1, 2, 7, 0));

      // Review at 22:50, Step 0 (+20m) = 23:10 -> moves to 07:00 morning
      final reviewAtNight = DateTime(2026, 1, 1, 22, 50);
      final nextReview0 = ReviewIntervals.calculateNextReview(
        0,
        baseTime: reviewAtNight,
        sleepSchedule: schedule,
      );
      expect(nextReview0, DateTime(2026, 1, 2, 7, 0));

      // Review at 08:00, Step 1 (+12h) = 20:00 (evening) -> stays 20:00
      final reviewAtMorning = DateTime(2026, 1, 1, 8, 0);
      final nextReviewEvening = ReviewIntervals.calculateNextReview(
        1,
        baseTime: reviewAtMorning,
        sleepSchedule: schedule,
      );
      expect(nextReviewEvening, DateTime(2026, 1, 1, 20, 0));
    });

    test('Topic markReviewed applies SleepSchedule', () {
      const schedule = SleepSchedule(
        isEnabled: true,
        startHour: 23,
        startMinute: 0,
        endHour: 7,
        endMinute: 0,
      );

      final now = DateTime(2026, 1, 1, 15, 0);
      var topic = Topic(
        id: 'sleep-test-1',
        categoryId: 'cat-1',
        title: 'Sleep Safe Topic',
        createdAt: now,
        currentStep: 0,
        nextReviewAt: now.add(const Duration(minutes: 20)),
      );

      // Marking reviewed at 15:00: Step 0 -> Step 1 (+12h = 03:00 -> shifts to 07:00 next day)
      topic = topic.markReviewed(reviewedAt: now, sleepSchedule: schedule);
      expect(topic.currentStep, 1);
      expect(topic.nextReviewAt, DateTime(2026, 1, 2, 7, 0));
    });

    test('AppData JSON preserves custom SleepSchedule', () {
      final customData = AppData(
        categories: [],
        topics: [],
        sleepSchedule: const SleepSchedule(
          isEnabled: true,
          startHour: 22,
          startMinute: 30,
          endHour: 8,
          endMinute: 15,
        ),
      );

      final json = customData.toJson();
      final restored = AppData.fromJson(json);

      expect(restored.sleepSchedule.isEnabled, isTrue);
      expect(restored.sleepSchedule.startHour, 22);
      expect(restored.sleepSchedule.startMinute, 30);
      expect(restored.sleepSchedule.endHour, 8);
      expect(restored.sleepSchedule.endMinute, 15);
      expect(restored.sleepSchedule.startTimeFormatted, '22:30');
      expect(restored.sleepSchedule.endTimeFormatted, '08:15');
    });
  });
}
