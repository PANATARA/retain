<div align="center">

# 🧠 Retain — Ebbinghaus Planner

**Minimalist, Apple Journal-inspired spaced repetition planner powered by the Ebbinghaus forgetting curve.**  
*Master long-term memory with scientifically optimal review intervals. 100% offline, privacy-first, and zero distractions.*

[![Flutter](https://img.shields.io/badge/Flutter-3.24%2B-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5%2B-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey?logo=apple&logoColor=white)](https://github.com/PANATARA/retain)
[![License](https://img.shields.io/badge/License-Unlicense-blue.svg)](LICENSE)
[![CI/CD](https://img.shields.io/badge/GitHub%20Actions-Automated%20Builds-success?logo=githubactions&logoColor=white)](.github/workflows)
[![Privacy](https://img.shields.io/badge/Privacy-100%25%20Offline%20%26%20Local-green)](https://github.com/PANATARA/retain)

[English](#features) • [Русский](#о-приложении) • [Scientific Method](#ebbinghaus-methodology) • [Installation](#getting-started) • [Build & CI/CD](#building-for-release)

</div>

---

## 📌 Overview

**Retain (Ebbinghaus Planner)** is an open-source mobile application for iOS and Android designed to help you commit anything to permanent memory — languages, medical terms, programming concepts, formulas, or exam prep.

Unlike bloated flashcard apps, Retain is built with an **Apple Journal native aesthetic**: pastel-tinted cards, soft shadows, rounded corners, large typography, and zero clutter. It runs entirely offline on your device, scheduling smart local notifications right when your memory retention begins to decay.

---

## ✨ Features

- ⏳ **Hermann Ebbinghaus Spaced Repetition**: 5 scientifically calibrated review intervals (+20m, +12h, +3d, +10d, +30d). After completing Step 4, topics are locked into permanent memory.
- 🎨 **Apple Journal Native UI**: Elegant dark & light modes with pastel cards (lavender, sage, peach, sky blue), `CupertinoIcons`, and smooth native micro-interactions.
- 📱 **Adaptive Native Experience**: Automatically renders Cupertino modals and pickers on iOS, and Material 3 adaptive dialogs on Android.
- 🔔 **Smart Local Push Notifications**: Exact offline alarms scheduled at the review timestamp (`flutter_local_notifications`), automatically refreshed or cancelled on topic updates.
- 🗂 **Categories & Topic Management**: Organize by subject (e.g. *Languages*, *Algorithms*, *Medicine*, *History*). Reset progress or delete items at any time.
- 🔒 **100% Privacy & Local Storage**: No accounts, no cloud tracking, no analytics. All data is saved strictly in your device sandbox as human-readable JSON.
- 💾 **Easy Backup & Export/Import**: One-tap export via system share sheet (`share_plus` / Files app integration via `UIFileSharingEnabled`) and JSON backup restore (`file_picker`).
- 🌐 **Bilingual (English & Русский)**: English by default with instant runtime language switching in Settings.
- 🎭 **Theme Selector**: Toggle between Apple Journal Minimalist and Material 3 adaptive design.

---

## 🔬 Ebbinghaus Methodology

Human memory decays rapidly after learning new material (the *Forgetting Curve* discovered by psychologist Hermann Ebbinghaus). Reviewing information at exponentially increasing intervals resets the curve and transfers knowledge from short-term memory to permanent storage:

| Step | Interval | Retention Goal | Stage |
| :---: | :---: | :---: | :---: |
| **0** | **+20 minutes** | Immediate consolidation | Initial Retention |
| **1** | **+12 hours** | Overcoming 24h drop | Short-term Reinforcement |
| **2** | **+3 days** | Mid-term stabilization | Intermediate Consolidation |
| **3** | **+10 days** | Resistance to decay | Pre-permanent Retention |
| **4** | **+30 days** | Synaptic consolidation | Permanent Long-Term Memory |
| **✓** | **Mastered** | Permanent knowledge | Marked as Memorized (`isCompleted`) |

> Whenever a review is completed, Retain automatically calculates the exact next deadline and schedules an exact local notification.

---

## 🇷🇺 О приложении (Retain на русском)

**Retain (Ebbinghaus Planner)** — это минималистичный и эстетичный планировщик интервальных повторений, вдохновлённый системным приложением «Дневник» (Apple Journal) на iOS и научной кривой забывания Германа Эббингауза.

### Ключевые возможности:
- **Интервалы Эббингауза**: строгая схема повторений (`+20 минут`, `+12 часов`, `+3 дня`, `+10 дней`, `+30 дней`) для гарантированного закрепления в долговременную память.
- **Эстетика Apple Journal**: пастельные акцентные карточки (шалфей, лаванда, персик, небесный), крупные скругления `BorderRadius.circular(22)`, нативные Cupertino-иконки.
- **100% Офлайн и Приватность**: отсутствие регистрации и серверов. Данные хранятся локально в песочнице устройства. Поддерживается сохранение и восстановление резервной копии в JSON через системное приложение «Файлы».
- **Умные локальные пуши**: точные напоминания в момент наступления срока повторения.
- **Поддержка двух языков**: английский (по умолчанию) и русский с переключением в один клик.

---

## 📱 Tech Stack & Architecture

- **Framework**: [Flutter](https://flutter.dev) (Null-safety, Material 3 & Cupertino)
- **Language**: [Dart](https://dart.dev)
- **State Management**: [Provider](https://pub.dev/packages/provider) with reactive `ChangeNotifier`
- **Notifications**: [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) with exact alarms (`SCHEDULE_EXACT_ALARM`) and iOS notification center delegate
- **Data Persistence**: Offline JSON storage via [path_provider](https://pub.dev/packages/path_provider)
- **File Sharing**: [share_plus](https://pub.dev/packages/share_plus) & [file_picker](https://pub.dev/packages/file_picker)
- **Icons Generator**: [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons) with Android Adaptive Icons and iOS App Store compliance

```
lib/
├── l10n/                 # Localization (AppStrings for English & Russian)
├── main.dart             # App entrypoint & initial routing
├── models/               # Domain models (AppData, Category, Topic, ReviewIntervals)
├── presentation/
│   ├── screens/          # Dashboard, CategoryDetails, Welcome, Settings
│   ├── utils/            # AdaptiveDialogs, DateFormatters
│   └── widgets/          # AppleCard, UpNextCard, CategoryTile, TopicTile, Sheets
├── services/             # StorageService (JSON sandbox), NotificationService
├── state/                # PlannerState (Global reactive state & business logic)
└── theme/                # AppTheme (Apple Journal & Material 3 themes)
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.24.0`)
- [Android Studio](https://developer.android.com/studio) / Android SDK (for Android build)
- [Xcode](https://developer.apple.com/xcode/) (`>= 15.0`, for iOS build on macOS)

### Quick Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/PANATARA/retain.git
   cd retain
   ```

2. **Install Flutter packages:**
   ```bash
   flutter pub get
   ```

3. **Run code analysis and tests:**
   ```bash
   flutter analyze
   flutter test
   ```

4. **Launch the application:**
   ```bash
   flutter run
   ```

---

## 📦 Building for Release

### Android APK & App Bundle

Build an optimized release APK:
```bash
flutter build apk --release
```
The resulting APK will be at:
`build/app/outputs/flutter-apk/app-release.apk`

Build an Android App Bundle (for Google Play):
```bash
flutter build appbundle --release
```

### iOS (Unsigned IPA / Archive)

Build iOS release without code signing:
```bash
flutter build ios --release --no-codesign
```

Package into an installable `.ipa`:
```bash
mkdir -p build/ios/ipa/Payload
cp -r build/ios/iphoneos/Runner.app build/ios/ipa/Payload/
cd build/ios/ipa
zip -r -9 retain-unsigned.ipa Payload
```

---

## ⚙️ Automated CI/CD (GitHub Actions)

This repository includes pre-configured GitHub Actions workflows in `.github/workflows/`:
- **`build-android.yml`**: Automatically analyzes, runs tests, and compiles the release APK.
- **`build-ios.yml`**: Runs on macOS runners, runs tests, builds the iOS Runner, and packages an unsigned IPA.
- **Automated Releases**: Pushing a git tag (e.g., `git tag v1.0.0 && git push origin v1.0.0`) automatically publishes release artifacts.

---

## 📄 License

This project is released under the **Unlicense** (Public Domain) — feel free to use, modify, and distribute for any personal or commercial purpose. See [LICENSE](LICENSE) for details.

---

<div align="center">

**Keywords**: *spaced repetition, ebbinghaus curve, ebbinghaus planner, forgetting curve, apple journal app, offline flashcards, memory retention, study planner, open source flutter app, интервальные повторения, кривая забывания, эббингауз.*

Made with ❤️ for lifelong learners.

</div>
