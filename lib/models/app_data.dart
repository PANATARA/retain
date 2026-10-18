import 'category.dart';
import 'topic.dart';

enum AppVisualTheme {
  appleJournal,
  material3,
}

enum AppThemeMode {
  system,
  light,
  dark,
}

class AppData {
  final int version;
  final String appStyle; // 'appleJournal' or 'material3'
  final String themeMode; // 'system', 'light', 'dark'
  final String language; // 'en' or 'ru' (default 'en')
  final bool hasSeenOnboarding;
  final List<Category> categories;
  final List<Topic> topics;

  const AppData({
    this.version = 1,
    this.appStyle = 'appleJournal',
    this.themeMode = 'system',
    this.language = 'en',
    this.hasSeenOnboarding = false,
    required this.categories,
    required this.topics,
  });

  AppVisualTheme get visualTheme =>
      appStyle == 'material3' ? AppVisualTheme.material3 : AppVisualTheme.appleJournal;

  AppThemeMode get appThemeMode {
    switch (themeMode) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      default:
        return AppThemeMode.system;
    }
  }

  AppData copyWith({
    int? version,
    String? appStyle,
    String? themeMode,
    String? language,
    bool? hasSeenOnboarding,
    List<Category>? categories,
    List<Topic>? topics,
  }) {
    return AppData(
      version: version ?? this.version,
      appStyle: appStyle ?? this.appStyle,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      categories: categories ?? this.categories,
      topics: topics ?? this.topics,
    );
  }

  Map<String, dynamic> toJson() => {
    'version': version,
    'appStyle': appStyle,
    'themeMode': themeMode,
    'language': language,
    'hasSeenOnboarding': hasSeenOnboarding,
    'categories': categories.map((c) => c.toJson()).toList(),
    'topics': topics.map((t) => t.toJson()).toList(),
  };

  factory AppData.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('categories') || !json.containsKey('topics')) {
      throw const FormatException('Некорректная структура JSON: отсутствуют обязательные поля categories или topics');
    }

    final rawCategories = json['categories'] as List<dynamic>? ?? [];
    final rawTopics = json['topics'] as List<dynamic>? ?? [];

    return AppData(
      version: (json['version'] as num?)?.toInt() ?? 1,
      appStyle: json['appStyle'] as String? ?? 'appleJournal',
      themeMode: json['themeMode'] as String? ?? 'system',
      language: json['language'] as String? ?? 'en',
      hasSeenOnboarding: json['hasSeenOnboarding'] as bool? ?? false,
      categories: rawCategories
          .map((item) => Category.fromJson(item as Map<String, dynamic>))
          .toList(),
      topics: rawTopics
          .map((item) => Topic.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  static AppData defaultData() {
    return const AppData(
      version: 1,
      appStyle: 'appleJournal',
      themeMode: 'system',
      language: 'en',
      hasSeenOnboarding: false,
      categories: [], // Clean empty default as requested
      topics: [],
    );
  }
}
