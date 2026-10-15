# 🛡️ ReelsGuard: Anti-Doomscroll & Short-Video Monitor

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20DDD%20%2B%20Riverpod-teal)](#-architecture--codebase-structure)
[![UI Style](https://img.shields.io/badge/Design-Neumorphism%20Tactile%203D-1E222B)](#-neumorphic-design-system)
[![Tests](https://img.shields.io/badge/Tests-28%2F28%20Passing%20(100%25)-success)](#-automated-testing--quality-assurance)
[![Google Play Compliant](https://img.shields.io/badge/Google%20Play-100%25%20Policy%20Compliant-brightgreen)](#-google-play--app-store-permission-compliance)
[![Privacy](https://img.shields.io/badge/Privacy-100%25%20On--Device-blueviolet)](#-privacy-first-guarantee)

**ReelsGuard** is a high-performance, privacy-focused mobile application built with Flutter to detect, track, and disrupt compulsive short-form video consumption (Instagram Reels, TikTok, YouTube Shorts, and Facebook Reels). Engineered with **Tactile Neumorphic UX**, **Feature-First Clean Architecture**, and an **Outside-the-App Automated Intervention Engine**.

---

## 🌟 Key Highlights & Capabilities

### 1. 🎛️ Tactile Neumorphic Design System
ReelsGuard departs from flat, stacked Material cards in favor of an authentic **Neumorphism** visual language:
- **Unified Plastic Canvas (`#1E222B`)**: Seamless extruded containers blending directly into the backdrop without sharp elevation seams.
- **Dual Soft-Shadow Physics**: Top-left ambient highlight (`#2D3442`) and bottom-right deep shadow (`#0F1116`) creating genuine tactile depth.
- **Debossed / Stamped Wells**: Inset directional gradients simulating physical grooves for progress tracks, metric badges, and switch channels.
- **Micro-Haptic Depress Interaction**: Buttons (`NeuButton`) and toggles (`NeuSwitch`) visibly depress into the surface upon tap.
- **Concentric Counter Dial**: A central extruded dial with an inner debossed progress groove and floating count island.

### 2. ⚡ Granular Real-Time Reel & Dwell Tracking
- **Android `AccessibilityService` Detection**: Captures `TYPE_VIEW_SCROLLED` events inside verified video containers (`ClipsViewerFragment`, `shorts_container`, `reel_player_page_holder`, `ViewPager2`).
- **Dwell Debouncer ($\ge 1.2$s)**: Distinguishes between intentional video watches and quick scroll flings to ensure metrics are reliable.
- **Tick-by-Tick Stopwatch**: Measures dwell time per reel down to the second, calculating consumption velocity and attention span.

### 3. 🚨 Outside-the-App Background Service & Auto-Interventions
- **Autonomous Detection**: Runs as an Android Foreground Service (`TrackingForegroundService`) synchronized with the Accessibility Service.
- **Auto-Intervention Overlay**: When a user hits their configured reel target (e.g. 15 or 30 reels) or continuous watch limit, ReelsGuard automatically displays the **Mindful Break Dialog** directly on top of the active social media app (Instagram, TikTok, YouTube Shorts, or Facebook).
- **Two-Way Synchronization**: Real-time limits, active thresholds, and snooze states communicate seamlessly between Kotlin and Flutter via `MethodChannel`.

### 4. 🧘 Mindful Break Dialog & Healthy Habit Swaps
When an intervention triggers, users are gently guided through interactive, science-backed behavioral breaks:
- **Guided Breath Mode**:
  - Animated pulsing breathing orb cycling smoothly through **Inhale (4s)** $\rightarrow$ **Hold (4s)** $\rightarrow$ **Exhale (4s)** $\rightarrow$ **Rest (2s)**.
  - Dynamically rotating mindfulness cues to de-escalate dopamine craving.
- **Mindful Swap Ecosystem** (Interactive Sheets):
  - 💧 **Hydrate Body**: Interactive water tracker sheet to log water glasses, view daily hydration goals, and read physical wellness benefits.
  - 🤸 **Quick Stretch**: Multi-stage physical movement routine with guided neck rolls, shoulder shrugs, and wrist releases with step-by-step interactive controls.
  - 👁️ **Eye Rest (20-20-20 Rule)**: Optometric eye-rest guide with a live 20-second timer to relax optical muscles by focusing on an object 20 feet away.
  - 💬 **Reach Out**: Ready-to-send conversation starters and one-tap launching into WhatsApp, Telegram, or Messages to reconnect with real friends.

### 5. 📱 Dynamic Device-Installed Social App Filtering
- The **Platform Breakdown** queries Android's `PackageManager` on startup to detect which supported social applications are physically installed.
- Uninstalled platforms are automatically omitted from the dashboard, keeping the interface uncluttered and relevant to the user's setup.

### 6. 🛡️ Google Play & App Store Permission Compliance
ReelsGuard adheres strictly to Google Play Console Accessibility API and User Data Policies:
- **Prominent In-App Disclosure Bottom Sheet**: Displays comprehensive, plain-language disclosures *before* requesting any system authorization (`AccessibilityService`, `UsageStats`, `Overlay`, `Notifications`).
- **Data Safety Transparency**:
  - Clearly explains *Why ReelsGuard Needs This*.
  - Explicitly states *Data Accessed (Functional Use Only)* vs *Data Never Accessed (Privacy Safeguards)*.
- **Android 13+ Restricted Settings Guidance**: Includes step-by-step interactive assistance for bypassing Android 13/14 restricted settings blocks.
- **100% On-Device Processing**: No text, keystrokes, personal messages, accounts, or video data are ever read, stored, or transmitted remotely.

### 7. 🧪 In-App Simulation & Testing Engine
- Built-in simulation suite allowing users and developers to test scroll events, auto-scroll feeds, and limit threshold alerts without needing to install or browse social media apps.

---

## 🏛️ Architecture & Codebase Structure

The project follows **Feature-First Clean Architecture with Domain-Driven Design (DDD)** and **Riverpod** state management:

```
lib/
├── core/
│   ├── constants/             # Supported social apps, channel IDs, defaults
│   ├── theme/
│   │   ├── app_theme.dart     # Canvas, colors, typography, Material3 integration
│   │   └── neumorphic.dart    # NEUMORPHIC CORE: NeuContainer, NeuButton, NeuSwitch, dual shadows
│   └── utils/                 # Time formatters, digital timers
├── features/
│   ├── reel_tracker/          # REAL-TIME DETECTION & METRICS
│   │   ├── domain/
│   │   │   ├── entities/      # ReelEvent, ReelSession, TrackedApp, DailyStats
│   │   │   ├── value_objects/ # DoomscrollScore, RiskLevel
│   │   │   └── repositories/  # IReelTrackerRepository
│   │   ├── data/
│   │   │   ├── datasources/   # NativePlatformDataSource, SimulatedReelDataSource, LocalStorageDataSource
│   │   │   ├── models/        # DailyStatsModel
│   │   │   └── repositories/  # ReelTrackerRepositoryImpl
│   │   └── presentation/
│   │       ├── controllers/   # ReelTrackerController (Riverpod StateNotifier)
│   │       ├── screens/       # DashboardScreen
│   │       └── widgets/       # LiveReelCounterHero, LiveSessionBar, TrackedAppsGrid, SimulationToggleWidget
│   ├── analytics/             # STATISTICAL INSIGHTS & CHARTS
│   │   ├── domain/            # HourlyUsage, WeeklySummary, IAnalyticsRepository
│   │   ├── data/              # AnalyticsRepositoryImpl
│   │   └── presentation/      # DopamineMeterCard, HourlyBarChart (fl_chart), WeeklyTrendCard, AnalyticsScreen
│   ├── limits_and_interventions/ # ANTI-DOOMSCROLL SHIELD & BREAKS
│   │   ├── domain/            # DoomscrollLimit, ILimitsRepository
│   │   ├── data/              # LimitsRepositoryImpl
│   │   └── presentation/      # LimitSliderCard, MindfulBreakDialog, Swap Sheets, LimitsScreen
│   └── permissions/           # SYSTEM ONBOARDING & DISCLOSURES
│       ├── domain/            # SystemPermissionState, PermissionType
│       ├── data/              # PermissionDataSource
│       └── presentation/      # PermissionStepTile, PermissionDisclosureBottomSheet, PermissionsScreen
└── main.dart                  # ProviderScope root with Neumorphic Bottom Navigation Dock
```

---

## ⚙️ Native Android Interoperability

ReelsGuard connects Flutter to Android system APIs via optimized Kotlin services:

| Component | Class | Responsibility |
| :--- | :--- | :--- |
| **Accessibility Engine** | `ReelDetectorAccessibilityService.kt` | Monitors short-form video containers, scroll flings, and dwell duration across Instagram, TikTok, YouTube Shorts, and Facebook. |
| **Background Service** | `TrackingForegroundService.kt` | Keeps tracking alive in the background and displays a persistent real-time notification with today's reel count and dwell time. |
| **System Alert Window** | `InterventionOverlayManager.kt` | Spawns the full-screen mindful break intervention over other applications when limits are triggered. |
| **Platform Bridge** | `MainActivity.kt` | Bridges MethodChannels and EventChannels for permissions, app queries, settings navigation, and metric streams. |

---

## 🧪 Automated Testing & Quality Assurance

ReelsGuard includes a comprehensive automated test suite with **100% pass rate** and **zero static analysis warnings**:

```bash
# Run static analysis
flutter analyze
# Output: No issues found!

# Run full automated test suite
flutter test
# Output: All 28 tests passed!
```

### Test Coverage Highlights:
- **`permissions_handling_test.dart`**:
  - Validates `SystemPermissionState` calculation and setup progress bar.
  - Verifies Google Play prominent in-app disclosure content, data access safety statements, and affirmative consent buttons.
  - Tests Restricted Settings assistance flow and permissions screen integration.
- **`mindful_break_dialog_test.dart`**:
  - Tests rendering of the concentric breathing orb, tab switcher, and cooldown mechanisms.
  - Validates interactive **Hydrate Body** sheet (counter increments and target logging).
  - Validates interactive **Quick Stretch** sheet (stage transitions and routine completion).
  - Validates interactive **Eye Rest** sheet (20-20-20 rule countdown).
  - Validates interactive **Connect Real** sheet (message template rendering and intent dispatch).
- **`reel_tracking_and_calculation_test.dart`**:
  - Verifies dwell duration and reel scroll counting math in local storage and controller state.
- **`widget_test.dart`**:
  - End-to-end smoke test validating all bottom navigation tabs and screen switches.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev) (v3.24.0 or higher)
- [Dart SDK](https://dart.dev) (v3.5.0 or higher)
- Android Studio / Android SDK (API 34+ recommended)
- Physical Android device or Android Emulator with Developer Mode enabled

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/reels-count.git
   cd reels-count
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify analyzer status**:
   ```bash
   flutter analyze
   ```

4. **Run the test suite**:
   ```bash
   flutter test
   ```

5. **Build and install on Android**:
   ```bash
   flutter run
   ```
   Or assemble an arm64 debug APK directly:
   ```bash
   flutter build apk --debug --target-platform android-arm64
   ```

---

## 🔒 Privacy-First Guarantee

ReelsGuard was built on the fundamental principle that digital wellbeing tools must respect user privacy:
- 🚫 **No Analytics or Trackers**: Zero third-party telemetry, advertising SDKs, or analytics services.
- 🚫 **No Network Transmission**: All metrics, dwell times, and calculations remain 100% on your local device.
- 🚫 **No Personal Content Access**: ReelsGuard cannot and does not read messages, search history, account credentials, keystrokes, or media content.
- 🛡️ **Functional Accessibility Only**: The Accessibility Service is restricted solely to detecting vertical scroll events within video player view containers.

---

## 📄 License
This project is open-source and available under the [MIT License](LICENSE).
