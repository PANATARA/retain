import 'dart:io';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/category.dart';
import '../models/topic.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();

  factory NotificationService() => instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone database
      tz.initializeTimeZones();
      try {
        final TimezoneInfo tzInfo = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
      } catch (e) {
        debugPrint('Could not get local timezone, fallback to UTC: $e');
        tz.setLocalLocation(tz.getLocation('UTC'));
      }

      // Android initialization settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS / Darwin initialization settings
      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _notificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          debugPrint('Notification clicked: ${details.payload}');
        },
      );

      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize NotificationService: $e');
    }
  }

  /// Request permissions for iOS and Android 13+
  Future<bool> requestPermissions() async {
    try {
      if (Platform.isIOS) {
        final result = await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
        return result ?? false;
      } else if (Platform.isAndroid) {
        final androidPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        final bool? granted = await androidPlugin?.requestNotificationsPermission();
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
    return true;
  }

  /// Schedules a review notification for a topic at [topic.nextReviewAt].
  Future<void> scheduleTopicReview({
    required Topic topic,
    required String categoryTitle,
    String? customBody,
  }) async {
    if (!_isInitialized) {
      await init();
    }

    // Do not schedule if already completed
    if (topic.isCompleted) {
      await cancelTopicNotification(topic.notificationId);
      return;
    }

    final scheduledDate = topic.nextReviewAt;
    final now = DateTime.now();

    // If time has already passed, don't schedule a future notification
    if (scheduledDate.isBefore(now)) {
      return;
    }

    final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'ebbinghaus_reviews',
      'Ebbinghaus Reviews',
      channelDescription: 'Notifications for spaced repetition review curve',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final notificationBody = customBody ??
        'Time to review: ${topic.title} from $categoryTitle';

    try {
      await _notificationsPlugin.zonedSchedule(
        id: topic.notificationId,
        title: 'Retain',
        body: notificationBody,
        scheduledDate: tzDateTime,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: topic.id,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  /// Cancels scheduled notification for a topic.
  Future<void> cancelTopicNotification(int notificationId) async {
    try {
      await _notificationsPlugin.cancel(id: notificationId);
    } catch (e) {
      debugPrint('Error canceling notification $notificationId: $e');
    }
  }

  /// Cancels all scheduled notifications.
  Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Error canceling all notifications: $e');
    }
  }

  /// Synchronizes scheduled notifications with current active topics.
  Future<void> syncAllNotifications({
    required List<Topic> topics,
    required Map<String, Category> categoriesMap,
    String Function(Topic topic, String categoryTitle)? bodyBuilder,
  }) async {
    await cancelAll();
    final now = DateTime.now();
    for (final topic in topics) {
      if (!topic.isCompleted && topic.nextReviewAt.isAfter(now)) {
        final categoryTitle =
            categoriesMap[topic.categoryId]?.title ?? 'General';
        final body = bodyBuilder != null
            ? bodyBuilder(topic, categoryTitle)
            : null;
        await scheduleTopicReview(
          topic: topic,
          categoryTitle: categoryTitle,
          customBody: body,
        );
      }
    }
  }
}
