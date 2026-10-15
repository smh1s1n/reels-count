# ReelsGuard: Anti-Doomscroll & Short-Video Monitor

A production-ready Flutter mobile application designed to detect, track, and break doomscrolling habits on social media (Instagram Reels, TikTok, YouTube Shorts, Facebook Reels). Built with **Flutter**, **Riverpod**, and **Feature-First Clean Architecture with Domain-Driven Design (DDD)**.

---

## 1. The Core Problem: Doomscrolling & Variable Rewards

Short-form video feeds are algorithmically engineered around variable-ratio dopamine reinforcement schedules. Users lose time perception and count awareness. ReelsGuard provides real-time awareness and mindful interventions:
* Counts individual reels/shorts played.
* Measures active dwell duration in short-form containers.
* Categorizes consumption across Instagram, TikTok, YouTube Shorts, and Facebook Reels.
* Computes a real-time **Doomscroll Risk Index** (0-100) based on reel count, velocity, and dwell time.
* Deploys mindful breathing pauses and cooldown alerts when configured thresholds are exceeded.

---

## 2. Technical Architecture & How Data Is Extracted

### Android Platform (Granular Reel Detection)
* **`AccessibilityService` (`ReelDetectorAccessibilityService.kt`)**:
  - Listens to system-level `AccessibilityEvent.TYPE_VIEW_SCROLLED` and `TYPE_WINDOW_STATE_CHANGED`.
  - Pattern matches active packages (`com.instagram.android`, `com.zhiliaoapp.musically`, `com.google.android.youtube`, `com.facebook.katana`).
  - Identifies reel container view hierarchies (`ClipsViewerFragment`, `reel_player_page_holder`, `shorts_container`, `ViewPager2`).
  - **Dwell Debouncer**: Enforces a minimum dwell time ($\ge 1.2$s) so rapid flings aren't falsely counted, but genuine video views are accurately logged.
  - **Watch Stopwatch**: Ticks every second while the user is actively focused on the reel player.
* **`TrackingForegroundService.kt`**:
  - Displays a persistent, low-priority status notification showing today's reel count and dwell time in real time.
* **`MethodChannel` & `EventChannel` (`MainActivity.kt`)**:
  - Streams live reel increments, session transitions, and limit notifications to Flutter.
* **`SYSTEM_ALERT_WINDOW`**:
  - Permits displaying mindful breathing breaks and interruption dialogs over target social apps.

### iOS Platform Constraints & Strategic Solution
* iOS does not permit third-party applications to inspect another app's UI hierarchy or touch events due to sandbox isolation.
* Apple's **Screen Time API** (`FamilyControls`, `DeviceActivity`) operates at the app bundle ID level (tracking macro time), but cannot count sub-app reels.
* ReelsGuard handles this transparently by supporting macro screen time integration on iOS and provides an interactive **In-App Simulation Engine** for testing, mindful check-ins, and analytics.

---

## 3. Flutter Architecture: Feature-First Clean Architecture + DDD

```
lib/
├── core/
│   ├── constants/             # Supported social apps, channel IDs, defaults
│   ├── theme/                 # Dark cyber-wellness theme & palettes
│   └── utils/                 # Time formatters, digital timers
├── features/
│   ├── reel_tracker/          # CORE ENGINE
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
│   │       └── widgets/       # LiveReelCounterHero, LiveSessionBar, TrackedAppsGrid, SimulationControlCard
│   ├── analytics/             # INSIGHTS & CHARTS
│   │   ├── domain/            # HourlyUsage, WeeklySummary, IAnalyticsRepository
│   │   ├── data/              # AnalyticsRepositoryImpl
│   │   └── presentation/      # DopamineMeterCard, HourlyBarChart (fl_chart), WeeklyTrendCard, AnalyticsScreen
│   ├── limits_and_interventions/ # ANTI-DOOMSCROLL SHIELD
│   │   ├── domain/            # DoomscrollLimit, ILimitsRepository
│   │   ├── data/              # LimitsRepositoryImpl
│   │   └── presentation/      # LimitSliderCard, MindfulBreakDialog (Breathing Circle), LimitsScreen
│   └── permissions/           # SYSTEM ONBOARDING
│       ├── domain/            # SystemPermissionState
│       ├── data/              # PermissionDataSource
│       └── presentation/      # PermissionStepTile, PermissionsScreen
└── main.dart                  # ProviderScope root with NavigationBar shell
```

---

## 4. Key Features

1. **Live Reel Counter Hero**:
   - Circular progress indicator reflecting daily progress vs quota.
   - Real-time reel counter, total active dwell duration, and dynamic risk badge (**Mindful**, **Elevated**, **High Dopamine**, **Doomscrolling**).
2. **Platform Breakdown**:
   - Individual tracking for **Instagram Reels**, **TikTok**, **YouTube Shorts**, and **Facebook Reels**.
3. **Simulation & Testing Engine**:
   - Toggleable simulation suite to test reel scrolls, auto-scroll simulations, and limit triggers directly on any device, emulator, or iOS.
4. **Insights & Metrics**:
   - **Doomscroll Index (0-100)**: Multi-factor scoring taking into account reel volume, rapid scrolling frequency, and dwell duration.
   - **Hourly Distribution Bar Chart**: Visualizes consumption peaks throughout the day.
   - **7-Day Weekly Trend**: Highlights average daily reels and historical progress.
5. **Mindful Interventions & Breaks**:
   - Configurable Daily Reel Limit, Continuous Session Limit, and Max Watch Duration.
   - Interactive **Breathing Break Dialog**: Inhale/Exhale circle animation with cooldown timer to disrupt compulsive phone habits.
6. **Privacy First**:
   - 100% on-device processing. No text, usernames, or video contents are ever read, recorded, or sent to external servers.
