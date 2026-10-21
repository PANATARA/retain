import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../l10n/app_strings.dart';
import '../models/app_data.dart';
import '../models/category.dart';
import '../models/review_intervals.dart';
import '../models/sleep_schedule.dart';
import '../models/topic.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

class PlannerState extends ChangeNotifier {
  final StorageService _storageService;
  final NotificationService _notificationService;
  final Uuid _uuid = const Uuid();

  PlannerState({
    StorageService? storageService,
    NotificationService? notificationService,
  })  : _storageService = storageService ?? StorageService(),
        _notificationService =
            notificationService ?? NotificationService.instance;

  List<Category> _categories = [];
  List<Topic> _topics = [];
  String _appStyle = 'appleJournal';
  String _themeMode = 'system';
  String _language = 'en'; // Default English as requested
  bool _hasSeenOnboarding = false;
  SleepSchedule _sleepSchedule = const SleepSchedule();
  bool _isLoading = true;
  String? _errorMessage;

  List<Category> get categories => List.unmodifiable(_categories);
  List<Topic> get topics => List.unmodifiable(_topics);
  String get appStyle => _appStyle;
  String get themeMode => _themeMode;
  String get language => _language;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  SleepSchedule get sleepSchedule => _sleepSchedule;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AppStrings get strings => AppStrings(_language);

  AppVisualTheme get visualTheme =>
      _appStyle == 'material3' ? AppVisualTheme.material3 : AppVisualTheme.appleJournal;

  ThemeMode get materialThemeMode {
    switch (_themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Map<String, Category> get categoriesMap => {
        for (final cat in _categories) cat.id: cat,
      };

  Category? getCategoryById(String id) => categoriesMap[id];

  /// Active topics (not completed), sorted by next review time ascending.
  List<Topic> get activeTopics {
    final list = _topics.where((t) => !t.isCompleted).toList();
    list.sort((a, b) => a.nextReviewAt.compareTo(b.nextReviewAt));
    return list;
  }

  /// Up Next reviews: overdue topics first, then upcoming topics sorted by time.
  List<Topic> get upNextTopics {
    return activeTopics;
  }

  /// Topics filtered for a specific category.
  List<Topic> getTopicsForCategory(String categoryId) {
    final list = _topics.where((t) => t.categoryId == categoryId).toList();
    list.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return a.nextReviewAt.compareTo(b.nextReviewAt);
    });
    return list;
  }

  int getActiveCountForCategory(String categoryId) {
    return _topics
        .where((t) => t.categoryId == categoryId && !t.isCompleted)
        .length;
  }

  int getCompletedCountForCategory(String categoryId) {
    return _topics
        .where((t) => t.categoryId == categoryId && t.isCompleted)
        .length;
  }

  /// Initialize application data and notifications.
  Future<void> init() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _notificationService.init();
      await _notificationService.requestPermissions();

      final data = await _storageService.loadData();
      _categories = data.categories;
      _topics = data.topics;
      _appStyle = data.appStyle;
      _themeMode = data.themeMode;
      _language = data.language;
      _hasSeenOnboarding = data.hasSeenOnboarding;
      _sleepSchedule = data.sleepSchedule;

      // Sync active notifications
      await _syncNotifications();
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _syncNotifications() async {
    await _notificationService.syncAllNotifications(
      topics: _topics,
      categoriesMap: categoriesMap,
      bodyBuilder: (topic, categoryTitle) => strings.notificationBody(
        topicTitle: topic.title,
        categoryTitle: categoryTitle,
      ),
    );
  }

  Future<void> _persist() async {
    final appData = AppData(
      version: 1,
      appStyle: _appStyle,
      themeMode: _themeMode,
      language: _language,
      hasSeenOnboarding: _hasSeenOnboarding,
      sleepSchedule: _sleepSchedule,
      categories: _categories,
      topics: _topics,
    );
    await _storageService.saveData(appData);
  }

  // --- Onboarding & Preferences ---

  Future<void> completeOnboarding() async {
    _hasSeenOnboarding = true;
    await _persist();
    notifyListeners();
  }

  Future<void> updateSleepSchedule({
    bool? isEnabled,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
  }) async {
    _sleepSchedule = _sleepSchedule.copyWith(
      isEnabled: isEnabled,
      startHour: startHour,
      startMinute: startMinute,
      endHour: endHour,
      endMinute: endMinute,
    );

    // If enabled, adjust any future reviews that fall in the sleep hours
    if (_sleepSchedule.isEnabled) {
      final now = DateTime.now();
      for (int i = 0; i < _topics.length; i++) {
        final t = _topics[i];
        if (!t.isCompleted && t.nextReviewAt.isAfter(now)) {
          if (_sleepSchedule.isSleepingAt(t.nextReviewAt)) {
            final adjusted = _sleepSchedule.adjust(t.nextReviewAt);
            _topics[i] = t.copyWith(nextReviewAt: adjusted);
          }
        }
      }
    }

    await _persist();
    await _syncNotifications();
    notifyListeners();
  }

  Future<void> setLanguage(String newLang) async {
    if (_language == newLang) return;
    _language = newLang;
    await _persist();
    await _syncNotifications();
    notifyListeners();
  }

  Future<void> setAppStyle(String newStyle) async {
    if (_appStyle == newStyle) return;
    _appStyle = newStyle;
    await _persist();
    notifyListeners();
  }

  Future<void> setThemeMode(String newMode) async {
    if (_themeMode == newMode) return;
    _themeMode = newMode;
    await _persist();
    notifyListeners();
  }

  // --- Category Management ---

  Future<void> addCategory({
    required String title,
    required String colorHex,
  }) async {
    final newCategory = Category(
      id: _uuid.v4(),
      title: title.trim(),
      colorHex: colorHex,
      createdAt: DateTime.now(),
    );

    _categories.add(newCategory);
    await _persist();
    notifyListeners();
  }

  Future<void> updateCategory({
    required String id,
    required String title,
    required String colorHex,
  }) async {
    final index = _categories.indexWhere((c) => c.id == id);
    if (index != -1) {
      _categories[index] = _categories[index].copyWith(
        title: title.trim(),
        colorHex: colorHex,
      );
      await _persist();
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    final topicsToDelete =
        _topics.where((t) => t.categoryId == categoryId).toList();
    for (final topic in topicsToDelete) {
      await _notificationService.cancelTopicNotification(topic.notificationId);
    }

    _categories.removeWhere((c) => c.id == categoryId);
    _topics.removeWhere((t) => t.categoryId == categoryId);

    await _persist();
    notifyListeners();
  }

  // --- Topic Management ---

  Future<Topic> addTopic({
    required String categoryId,
    required String title,
  }) async {
    final now = DateTime.now();
    final firstReview = ReviewIntervals.calculateNextReview(
      0,
      baseTime: now,
      sleepSchedule: _sleepSchedule,
    );

    final newTopic = Topic(
      id: _uuid.v4(),
      categoryId: categoryId,
      title: title.trim(),
      createdAt: now,
      currentStep: 0,
      nextReviewAt: firstReview,
      isCompleted: false,
    );

    _topics.add(newTopic);
    await _persist();

    final categoryTitle = categoriesMap[categoryId]?.title ?? 'General';
    await _notificationService.scheduleTopicReview(
      topic: newTopic,
      categoryTitle: categoryTitle,
      customBody: strings.notificationBody(
        topicTitle: newTopic.title,
        categoryTitle: categoryTitle,
      ),
    );

    notifyListeners();
    return newTopic;
  }

  Future<void> markTopicReviewed(String topicId) async {
    final index = _topics.indexWhere((t) => t.id == topicId);
    if (index == -1) return;

    final current = _topics[index];
    final updated = current.markReviewed(sleepSchedule: _sleepSchedule);
    _topics[index] = updated;

    await _persist();

    if (updated.isCompleted) {
      await _notificationService.cancelTopicNotification(updated.notificationId);
    } else {
      final categoryTitle =
          categoriesMap[updated.categoryId]?.title ?? 'General';
      await _notificationService.scheduleTopicReview(
        topic: updated,
        categoryTitle: categoryTitle,
        customBody: strings.notificationBody(
          topicTitle: updated.title,
          categoryTitle: categoryTitle,
        ),
      );
    }

    notifyListeners();
  }

  Future<void> resetTopicProgress(String topicId) async {
    final index = _topics.indexWhere((t) => t.id == topicId);
    if (index == -1) return;

    final current = _topics[index];
    final reset = current.resetProgress(sleepSchedule: _sleepSchedule);
    _topics[index] = reset;

    await _persist();

    final categoryTitle = categoriesMap[reset.categoryId]?.title ?? 'General';
    await _notificationService.scheduleTopicReview(
      topic: reset,
      categoryTitle: categoryTitle,
      customBody: strings.notificationBody(
        topicTitle: reset.title,
        categoryTitle: categoryTitle,
      ),
    );

    notifyListeners();
  }

  Future<void> updateTopicTitle(String topicId, String newTitle) async {
    final index = _topics.indexWhere((t) => t.id == topicId);
    if (index == -1) return;

    final current = _topics[index];
    final updated = current.copyWith(title: newTitle.trim());
    _topics[index] = updated;

    await _persist();

    if (!updated.isCompleted) {
      final categoryTitle =
          categoriesMap[updated.categoryId]?.title ?? 'General';
      await _notificationService.scheduleTopicReview(
        topic: updated,
        categoryTitle: categoryTitle,
        customBody: strings.notificationBody(
          topicTitle: updated.title,
          categoryTitle: categoryTitle,
        ),
      );
    }

    notifyListeners();
  }

  Future<void> deleteTopic(String topicId) async {
    final index = _topics.indexWhere((t) => t.id == topicId);
    if (index == -1) return;

    final topic = _topics[index];
    await _notificationService.cancelTopicNotification(topic.notificationId);

    _topics.removeAt(index);
    await _persist();
    notifyListeners();
  }

  // --- Export / Import Backup ---

  Future<void> exportBackup({Rect? sharePositionOrigin}) async {
    await _storageService.exportData(sharePositionOrigin: sharePositionOrigin);
  }

  Future<bool> importBackup() async {
    final imported = await _storageService.importData();
    if (imported == null) {
      return false; // Canceled by user
    }

    _categories = imported.categories;
    _topics = imported.topics;
    _appStyle = imported.appStyle;
    _themeMode = imported.themeMode;
    _language = imported.language;
    _hasSeenOnboarding = imported.hasSeenOnboarding;
    _sleepSchedule = imported.sleepSchedule;

    await _syncNotifications();
    notifyListeners();
    return true;
  }
}
