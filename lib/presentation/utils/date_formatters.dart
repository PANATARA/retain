import 'package:intl/intl.dart';
import '../../l10n/app_strings.dart';

class DateFormatters {
  DateFormatters._();

  static String formatReviewTime(DateTime dateTime, {required AppStrings strings}) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    final isOverdue = difference.isNegative;

    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final timeStr = DateFormat('HH:mm').format(dateTime);

    if (isOverdue) {
      final absDiff = difference.abs();
      if (absDiff.inMinutes < 60) {
        final mins = absDiff.inMinutes;
        return mins <= 1 ? strings.justNow : strings.overdueByMinutes(mins);
      } else if (absDiff.inHours < 24) {
        return strings.overdueByHours(absDiff.inHours);
      } else {
        return strings.overdueByDays(absDiff.inDays);
      }
    }

    // Future
    if (difference.inMinutes <= 60) {
      final mins = difference.inMinutes;
      return mins <= 0 ? strings.dueNow : strings.inMinutes(mins);
    }

    if (targetDate == today) {
      return strings.todayAt(timeStr);
    }

    final tomorrow = today.add(const Duration(days: 1));
    if (targetDate == tomorrow) {
      return strings.tomorrowAt(timeStr);
    }

    final dayAfter = today.add(const Duration(days: 2));
    if (targetDate == dayAfter) {
      return strings.dayAfterAt(timeStr);
    }

    if (strings.isRussian) {
      final ruMonths = [
        '',
        'янв',
        'фев',
        'мар',
        'апр',
        'мая',
        'июн',
        'июл',
        'авг',
        'сен',
        'окт',
        'ноя',
        'дек'
      ];
      return '${dateTime.day} ${ruMonths[dateTime.month]}, $timeStr';
    } else {
      final enMonths = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${dateTime.day} ${enMonths[dateTime.month]}, $timeStr';
    }
  }

  static String formatTodayHeader({required AppStrings strings}) {
    final now = DateTime.now();
    if (strings.isRussian) {
      final weekDays = [
        '',
        'ПОНЕДЕЛЬНИК',
        'ВТОРНИК',
        'СРЕДА',
        'ЧЕТВЕРГ',
        'ПЯТНИЦА',
        'СУББОТА',
        'ВОСКРЕСЕНЬЕ'
      ];
      final ruMonths = [
        '',
        'ЯНВАРЯ',
        'ФЕВРАЛЯ',
        'МАРТА',
        'АПРЕЛЯ',
        'МАЯ',
        'ИЮНЯ',
        'ИЮЛЯ',
        'АВГУСТА',
        'СЕНТЯБРЯ',
        'ОКТЯБРЯ',
        'НОЯБРЯ',
        'ДЕКАБРЯ'
      ];
      return '${weekDays[now.weekday]}, ${now.day} ${ruMonths[now.month]}';
    } else {
      final weekDays = [
        '',
        'MONDAY',
        'TUESDAY',
        'WEDNESDAY',
        'THURSDAY',
        'FRIDAY',
        'SATURDAY',
        'SUNDAY'
      ];
      final enMonths = [
        '',
        'JANUARY',
        'FEBRUARY',
        'MARCH',
        'APRIL',
        'MAY',
        'JUNE',
        'JULY',
        'AUGUST',
        'SEPTEMBER',
        'OCTOBER',
        'NOVEMBER',
        'DECEMBER'
      ];
      return '${weekDays[now.weekday]}, ${enMonths[now.month]} ${now.day}';
    }
  }
}
