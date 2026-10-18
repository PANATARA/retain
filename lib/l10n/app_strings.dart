class AppStrings {
  final String languageCode;

  const AppStrings(this.languageCode);

  bool get isRussian => languageCode == 'ru';

  // App General
  String get appName => 'Ebbinghaus Planner';

  // Dashboard
  String get today => isRussian ? 'Сегодня' : 'Today';
  String get upNext => isRussian ? 'БЛИЖАЙШИЕ ПОВТОРЕНИЯ' : 'UP NEXT';
  String get categories => isRussian ? 'РАЗДЕЛЫ' : 'CATEGORIES';
  String get addCategoryBtn => isRussian ? '+ Раздел' : '+ Category';
  String get newTopic => isRussian ? 'Новая тема' : 'New Topic';
  String get allCaughtUpTitle => isRussian ? 'Все темы повторены!' : 'All caught up!';
  String get allCaughtUpSubtitle => isRussian
      ? 'Вы на верном пути к долгосрочному запоминанию. Добавьте новую тему для повторения.'
      : "You're on track for long-term retention. Add a new topic to review.";
  String get noCategoriesTitle => isRussian ? 'Нет созданных разделов' : 'No categories yet';
  String get noCategoriesSubtitle => isRussian
      ? 'Создайте раздел, например «Английский» или «Медицина», чтобы распределять темы.'
      : 'Create a category like "Languages" or "Medicine" to organize your topics.';

  // Up Next & Topic Card
  String get reviewedBtn => isRussian ? 'Повторил' : 'Reviewed';
  String get overdue => isRussian ? 'Просрочено' : 'Overdue';
  String get dueNow => isRussian ? 'Прямо сейчас' : 'Due now';
  String get justNow => isRussian ? 'Только что' : 'Just now';
  String get intervalPrefix => isRussian ? 'Интервал:' : 'Interval:';
  String stepLabel(int step, int total) {
    if (step >= total) return isRussian ? 'Закреплено' : 'Memorized';
    return isRussian ? 'Шаг ${step + 1} из $total' : 'Step ${step + 1} of $total';
  }
  String intervalDescription(int step) {
    switch (step) {
      case 0:
        return isRussian ? '20 минут' : '20 minutes';
      case 1:
        return isRussian ? '12 часов' : '12 hours';
      case 2:
        return isRussian ? '3 дня' : '3 days';
      case 3:
        return isRussian ? '10 дней' : '10 days';
      case 4:
        return isRussian ? '30 дней' : '30 days';
      default:
        return isRussian ? 'Закреплено' : 'Memorized';
    }
  }

  // Relative Time
  String overdueByMinutes(int mins) => isRussian ? 'Просрочено на $mins мин' : 'Overdue by $mins m';
  String overdueByHours(int hrs) => isRussian ? 'Просрочено на $hrs ч' : 'Overdue by $hrs h';
  String overdueByDays(int days) => isRussian ? 'Просрочено на $days дн' : 'Overdue by $days d';
  String inMinutes(int mins) => isRussian ? 'Через $mins мин' : 'In $mins min';
  String todayAt(String time) => isRussian ? 'Сегодня в $time' : 'Today at $time';
  String tomorrowAt(String time) => isRussian ? 'Завтра в $time' : 'Tomorrow at $time';
  String dayAfterAt(String time) => isRussian ? 'Послезавтра в $time' : 'In 2 days at $time';

  // Category Tile
  String topicsToReview(int count) {
    if (isRussian) {
      final mod10 = count % 10;
      final mod100 = count % 100;
      String word = 'тем';
      if (mod100 < 11 || mod100 > 19) {
        if (mod10 == 1) {
          word = 'тема';
        } else if (mod10 >= 2 && mod10 <= 4) {
          word = 'темы';
        }
      }
      return '$count $word к повторению';
    } else {
      return count == 1 ? '1 topic to review' : '$count topics to review';
    }
  }
  String get allTopicsReviewed => isRussian ? 'Все темы повторены' : 'All topics reviewed';
  String get noActiveTopics => isRussian ? 'Нет активных тем' : 'No active topics';

  // Category Details
  String get activeTopicsHeader => isRussian ? 'АКТИВНЫХ ТЕМ' : 'ACTIVE TOPICS';
  String get memorizedHeader => isRussian ? 'ЗАКРЕПЛЕНО' : 'MEMORIZED';
  String get topicsToReviewHeader => isRussian ? 'ТЕМЫ ДЛЯ ПОВТОРЕНИЯ' : 'TOPICS TO REVIEW';
  String memorizedCountHeader(int count) =>
      isRussian ? 'ЗАКРЕПЛЕННЫЕ ТЕМЫ ($count)' : 'MEMORIZED TOPICS ($count)';
  String get memorizedSubtitle =>
      isRussian ? 'Закреплено по методу Эббингауза' : 'Memorized via Ebbinghaus curve';
  String get categoryNotFound => isRussian ? 'Раздел не найден' : 'Category not found';

  // Topic Actions
  String get edit => isRussian ? 'Редактировать' : 'Edit';
  String get resetProgress => isRussian ? 'Сбросить прогресс' : 'Reset progress';
  String get delete => isRussian ? 'Удалить' : 'Delete';
  String get editTopicTitle => isRussian ? 'Редактировать тему' : 'Edit Topic';
  String get deleteTopicTitle => isRussian ? 'Удалить тему?' : 'Delete topic?';
  String deleteTopicContent(String title) => isRussian
      ? 'Вы уверены, что хотите удалить «$title»? Запланированные напоминания будут отменены.'
      : 'Are you sure you want to delete "$title"? Scheduled reminders will be canceled.';
  String deleteCategoryTitle(String title) => isRussian
      ? 'Удалить раздел «$title»?'
      : 'Delete category "$title"?';
  String get deleteCategoryContent => isRussian
      ? 'Все темы внутри этого раздела и их напоминания будут безвозвратно удалены.'
      : 'All topics within this category and their reminders will be permanently deleted.';

  // Add Topic Sheet
  String get newTopicTitle => isRussian ? 'Новая тема' : 'New Topic';
  String get sectionLabel => isRussian ? 'РАЗДЕЛ' : 'CATEGORY';
  String get topicTitleLabel => isRussian ? 'НАЗВАНИЕ ТЕМЫ' : 'TOPIC TITLE';
  String get topicTitlePlaceholder => isRussian
      ? 'Например: Правило Парето или Past Simple'
      : 'e.g. Present Perfect or Pareto Principle';
  String get firstReviewNotice => isRussian
      ? 'Первое повторение запланировано через 20 минут. Пуш-уведомление напомнит вовремя.'
      : 'First review is scheduled in 20 minutes. A push notification will remind you on time.';
  String get createTopicBtn => isRussian ? 'Создать тему' : 'Create Topic';
  String get needCategoryNotice => isRussian
      ? 'Сначала создайте хотя бы один раздел'
      : 'Please create at least one category first';

  // Add / Edit Category Sheet
  String get newCategorySheetTitle => isRussian ? 'Новый раздел' : 'New Category';
  String get editCategorySheetTitle => isRussian ? 'Изменить раздел' : 'Edit Category';
  String get categoryNameLabel => isRussian ? 'НАЗВАНИЕ РАЗДЕЛА' : 'CATEGORY NAME';
  String get categoryNamePlaceholder => isRussian
      ? 'Например: Английский, Архитектура, Медицина'
      : 'e.g. English, Coding, Medicine';
  String get pastelColorLabel => isRussian ? 'ПАСТЕЛЬНЫЙ ЦВЕТ' : 'PASTEL COLOR';
  String get createCategoryBtn => isRussian ? 'Создать раздел' : 'Create Category';
  String get saveChangesBtn => isRussian ? 'Сохранить изменения' : 'Save Changes';

  // Settings
  String get settingsAndData => isRussian ? 'Настройки и данные' : 'Settings & Data';
  String get appearanceAndStyle => isRussian ? 'СТИЛЬ И ТЕМА ИНТЕРФЕЙСА' : 'APPEARANCE & STYLE';
  String get visualDesign => isRussian ? 'Визуальный дизайн' : 'Visual Design';
  String get appleJournalStyle => 'Apple Journal';
  String get appleJournalSubtitle => isRussian ? 'iOS нативный стиль' : 'iOS native style';
  String get material3Style => 'Material 3';
  String get material3Subtitle => isRussian ? 'Android стиль' : 'Android style';
  String get colorScheme => isRussian ? 'Цветовая схема' : 'Color Scheme';
  String get systemMode => isRussian ? 'Системная' : 'System';
  String get lightMode => isRussian ? 'Светлая' : 'Light';
  String get darkMode => isRussian ? 'Темная' : 'Dark';
  String get languageSection => isRussian ? 'ЯЗЫК ИНТЕРФЕЙСА' : 'LANGUAGE';
  String get englishLang => 'English';
  String get russianLang => 'Русский';
  String get backupSection => isRussian ? 'РЕЗЕРВНОЕ КОПИРОВАНИЕ' : 'BACKUP & RESTORE';
  String get exportBackup => isRussian ? 'Экспорт резервной копии (JSON)' : 'Export Backup (JSON)';
  String get exportBackupSubtitle => isRussian
      ? 'Сохранить в «Файлы», AirDrop или отправить'
      : 'Save to Files, AirDrop or share';
  String get importBackup => isRussian ? 'Импорт резервной копии (JSON)' : 'Import Backup (JSON)';
  String get importBackupSubtitle => isRussian
      ? 'Восстановить категории и темы из файла'
      : 'Restore categories and topics from file';
  String get importSuccess => isRussian ? 'Данные успешно импортированы!' : 'Data imported successfully!';
  String get intervalsSection => isRussian
      ? 'ИНТЕРВАЛЫ ПОВТОРЕНИЙ ЭББИНГАУЗА'
      : 'EBBINGHAUS FORGETTING CURVE';
  String get welcomeGuideAction => isRussian ? 'Инструкция и методология' : 'How it works / Welcome Guide';
  String get versionInfo => 'Ebbinghaus Planner v1.2';

  // Common Dialogs
  String get cancel => isRussian ? 'Отмена' : 'Cancel';
  String get save => isRussian ? 'Сохранить' : 'Save';
  String get gotIt => isRussian ? 'Понятно' : 'Got it';
  String get errorExportTitle => isRussian ? 'Ошибка экспорта' : 'Export Failed';
  String get errorImportTitle => isRussian ? 'Ошибка импорта' : 'Import Failed';
  String errorExportMsg(dynamic e) => isRussian ? 'Не удалось экспортировать файл: $e' : 'Failed to export file: $e';
  String errorImportMsg(dynamic e) => isRussian
      ? 'Выбранный файл поврежден или имеет неверный формат: $e'
      : 'Selected file is corrupted or has an invalid format: $e';

  // Notification
  String get notificationTitle => 'Ebbinghaus Planner';
  String notificationBody({required String topicTitle, required String categoryTitle}) =>
      isRussian
          ? 'Время закрепить: $topicTitle из раздела $categoryTitle'
          : 'Time to review: $topicTitle from $categoryTitle';

  // Onboarding / Welcome Screen
  String get welcomeTitle => isRussian ? 'Добро пожаловать в Ebbinghaus Planner' : 'Welcome to Ebbinghaus Planner';
  String get welcomeSubtitle => isRussian
      ? 'Интервальные повторения для надежного долговременного запоминания'
      : 'Master long-term memory with scientific spaced repetition';

  String get onbFeature1Title => isRussian ? 'Кривая забывания Эббингауза' : 'Scientific Spaced Repetition';
  String get onbFeature1Desc => isRussian
      ? 'Темы повторяются через выверенные интервалы: +20 мин, +12 ч, +3 дня, +10 дней, +30 дней. Это переносит знания в долгосрочную память.'
      : 'Review topics at scientifically optimal intervals: +20m, +12h, +3d, +10d, +30d. Lock knowledge into permanent memory.';

  String get onbFeature2Title => isRussian ? 'Умные локальные пуши' : 'Smart Local Notifications';
  String get onbFeature2Desc => isRussian
      ? 'Приложение присылает точные напоминания именно в момент, когда память начинает ослабевать.'
      : 'Receive exact push notifications right when your memory retention starts fading.';

  String get onbFeature3Title => isRussian ? 'Разделы и 100% приватность' : 'Categories & 100% Privacy';
  String get onbFeature3Desc => isRussian
      ? 'Организуйте любые темы (языки, программирование, экзамены). Все данные хранятся локально в песочнице с поддержкой экспорта.'
      : 'Organize anything (languages, coding, exams, medicine). All data stays offline in your device sandbox with easy JSON backup.';

  String get getStartedBtn => isRussian ? 'Начать работу' : 'Get Started';
}
