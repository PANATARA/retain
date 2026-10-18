class ReviewIntervals {
  ReviewIntervals._();

  static const List<Duration> stepDurations = [
    Duration(minutes: 20), // Шаг 0: 20 минут
    Duration(hours: 12),    // Шаг 1: 12 часов
    Duration(days: 3),      // Шаг 2: 3 дня
    Duration(days: 10),     // Шаг 3: 10 дней
    Duration(days: 30),     // Шаг 4: 30 дней
  ];

  static const int totalSteps = 5;

  static Duration durationForStep(int step) {
    if (step >= 0 && step < stepDurations.length) {
      return stepDurations[step];
    }
    return stepDurations.last;
  }

  static String stepLabel(int step) {
    if (step < 0) return 'Шаг 1 из $totalSteps';
    if (step >= totalSteps) return 'Закреплено';
    return 'Шаг ${step + 1} из $totalSteps';
  }

  static String intervalDescription(int step) {
    switch (step) {
      case 0:
        return '20 минут';
      case 1:
        return '12 часов';
      case 2:
        return '3 дня';
      case 3:
        return '10 дней';
      case 4:
        return '30 дней';
      default:
        return 'Закреплено';
    }
  }

  /// Calculates the next review time for a given step starting from [baseTime] (defaults to DateTime.now()).
  static DateTime calculateNextReview(int step, {DateTime? baseTime}) {
    final start = baseTime ?? DateTime.now();
    return start.add(durationForStep(step));
  }
}
