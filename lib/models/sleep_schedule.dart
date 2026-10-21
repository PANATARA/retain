class SleepSchedule {
  final bool isEnabled;
  final int startHour; // 0..23 (e.g. 23:00)
  final int startMinute; // 0..59 (e.g. 0)
  final int endHour; // 0..23 (e.g. 7:00)
  final int endMinute; // 0..59 (e.g. 0)

  const SleepSchedule({
    this.isEnabled = true,
    this.startHour = 23,
    this.startMinute = 0,
    this.endHour = 7,
    this.endMinute = 0,
  });

  /// Formatted start time, e.g. "23:00".
  String get startTimeFormatted =>
      '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';

  /// Formatted wake-up time, e.g. "07:00".
  String get endTimeFormatted =>
      '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';

  /// Checks whether a given [time] falls inside the sleep window.
  bool isSleepingAt(DateTime time) {
    if (!isEnabled) return false;
    final targetMins = time.hour * 60 + time.minute;
    final startMins = startHour * 60 + startMinute;
    final endMins = endHour * 60 + endMinute;

    if (startMins == endMins) {
      return false;
    } else if (startMins > endMins) {
      // Crosses midnight, e.g. 23:00 to 07:00
      return targetMins >= startMins || targetMins < endMins;
    } else {
      // Same day, e.g. 01:00 to 08:00
      return targetMins >= startMins && targetMins < endMins;
    }
  }

  /// Adjusts [time] so that if it falls inside sleep hours, it is moved forward
  /// to the wake-up time (endHour:endMinute).
  DateTime adjust(DateTime time) {
    if (!isEnabled) return time;

    final targetMins = time.hour * 60 + time.minute;
    final startMins = startHour * 60 + startMinute;
    final endMins = endHour * 60 + endMinute;

    if (startMins == endMins) {
      return time;
    }

    if (startMins > endMins) {
      // Crosses midnight (e.g. 23:00 to 07:00)
      if (targetMins >= startMins) {
        // e.g. 23:20 -> wake up is next morning (day + 1) at endHour:endMinute
        return DateTime(time.year, time.month, time.day + 1, endHour, endMinute, 0);
      } else if (targetMins < endMins) {
        // e.g. 03:00 -> wake up is today at endHour:endMinute
        return DateTime(time.year, time.month, time.day, endHour, endMinute, 0);
      }
    } else {
      // Same day sleep (e.g. 01:00 to 08:00)
      if (targetMins >= startMins && targetMins < endMins) {
        return DateTime(time.year, time.month, time.day, endHour, endMinute, 0);
      }
    }

    return time;
  }

  SleepSchedule copyWith({
    bool? isEnabled,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
  }) {
    return SleepSchedule(
      isEnabled: isEnabled ?? this.isEnabled,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
    );
  }

  Map<String, dynamic> toJson() => {
        'isEnabled': isEnabled,
        'startHour': startHour,
        'startMinute': startMinute,
        'endHour': endHour,
        'endMinute': endMinute,
      };

  factory SleepSchedule.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SleepSchedule();
    return SleepSchedule(
      isEnabled: json['isEnabled'] as bool? ?? true,
      startHour: (json['startHour'] as num?)?.toInt() ?? 23,
      startMinute: (json['startMinute'] as num?)?.toInt() ?? 0,
      endHour: (json['endHour'] as num?)?.toInt() ?? 7,
      endMinute: (json['endMinute'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepSchedule &&
          runtimeType == other.runtimeType &&
          isEnabled == other.isEnabled &&
          startHour == other.startHour &&
          startMinute == other.startMinute &&
          endHour == other.endHour &&
          endMinute == other.endMinute;

  @override
  int get hashCode =>
      isEnabled.hashCode ^
      startHour.hashCode ^
      startMinute.hashCode ^
      endHour.hashCode ^
      endMinute.hashCode;
}
