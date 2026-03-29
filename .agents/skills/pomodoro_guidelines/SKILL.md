---
name: Pomodoro App Guidelines
description: Context, guidelines, and strict rules for AI agents working on the minimalist Pomodoro Flutter app.
---

# SKILL.md

> **Purpose:** Context, guidelines, and strict rules for AI agents working on this minimalist Pomodoro Flutter app.
> **Instruction:** ALWAYS read this file before generating code, planning features, or refactoring.

## 1. Project Context

- **Name:** Pom
- **Description:** A minimalist, distraction-free Pomodoro timer app with a playlist-style timer queue.
- **Target Platforms:** iOS, Android.
- **Primary Language:** Dart (Latest Stable, SDK ^3.11.1).
- **Framework:** Flutter (Latest Stable).
- **Design Philosophy:** Minimalist. No cluttered UI. High contrast, large typography, and subtle animations. Full-screen accent-color background (muted tones) with dark text.
- **Typography:** Lexend Deca (via `google_fonts`).

## 2. Tech Stack & Libraries

_Strictly adhere to these choices to keep the app lean but scalable._

| Purpose | Package | Notes |
|---|---|---|
| State Management | `flutter_riverpod` + `riverpod_annotation` | Timer state, settings, all providers |
| Local Storage | `shared_preferences` | Settings, timer queue persistence |
| Notifications | `flutter_local_notifications` | Immediate + scheduled (background) |
| Timezone | `timezone` + `flutter_timezone` | Required for `zonedSchedule` |
| Audio | `audioplayers` | Alert chime on timer completion |
| Typography | `google_fonts` | Lexend Deca font family |
| IDs | `uuid` | Unique timer item IDs |
| App Polish | `flutter_native_splash`, `flutter_launcher_icons` | Launch screen, app icons |
| Linting | `flutter_lints`, `riverpod_lint`, `custom_lint` | Static analysis |
| Code Gen | `build_runner`, `riverpod_generator` | Provider codegen |

## 3. Architectural Standards (Feature-First)

### Folder Structure

```
lib/
├── core/
│   ├── theme/
│   │   └── app_theme.dart          # Colors, theme builder, getColorFromName
│   ├── utils/
│   │   └── time_formatter.dart     # formatDuration (mm:ss)
│   └── services/
│       ├── app_lifecycle_observer.dart  # Background notification scheduling
│       ├── audio_service.dart          # AudioPlayer alert chime
│       ├── clock_service.dart          # Mockable DateTime.now provider
│       ├── notification_service.dart   # Init, show, schedule, cancel
│       └── storage_service.dart        # SharedPreferences provider
├── features/
│   ├── timer/
│   │   ├── application/
│   │   │   └── timer_controller.dart   # Notifier<PomodoroState>
│   │   ├── domain/
│   │   │   └── timer_state.dart        # PomodoroState, TimerItem
│   │   └── presentation/
│   │       ├── timer_screen.dart       # Main timer UI
│   │       └── widgets/
│   │           └── timer_list_item.dart # Playlist queue item
│   └── settings/
│       ├── application/
│       │   └── settings_controller.dart # Notifier<PomodoroSettings>
│       ├── domain/
│       │   └── pomodoro_settings.dart   # PomodoroSettings data class
│       └── presentation/
│           └── settings_screen.dart     # Settings UI
└── main.dart                            # Entry point, provider overrides
```

### Key Domain Rules

1. **Timer Precision:** Never rely solely on `Timer.periodic` for exact duration tracking. Always calculate remaining time based on an absolute `DateTime` endpoint (`_targetTime.difference(DateTime.now())`). The `_targetTime` is stored as `endTime` in `PomodoroState` for lifecycle observer access.
2. **App Lifecycle:** The `AppLifecycleObserver` widget (wrapping `TimerScreen`) handles `AppLifecycleState`. On `paused`: schedules a `zonedSchedule` notification at `endTime`. On `resumed`: cancels it. The timer catches up automatically via DateTime-based tracking.
3. **UI/Logic Separation:** The countdown display only listens to `PomodoroState`. All start/pause/reset/reorder logic lives in `TimerController`.
4. **Mockable Clock:** Never hardcode `DateTime.now()` in domain logic. Use `ref.read(clockProvider)()` (defined in `clock_service.dart`) so unit tests can simulate time without waiting.
5. **Synchronous Initialization:** In `main.dart`, before `runApp()`:
   - Initialize timezone data via `tz_data.initializeTimeZones()`
   - Detect device timezone via `FlutterTimezone.getLocalTimezone()`
   - Initialize `SharedPreferences`
   - Initialize `NotificationService` (including `requestNotificationsPermission()` for Android 13+)
   - Pass all into `ProviderScope(overrides: [...])` for consistency

### State Architecture

- **`PomodoroState`** — `queue: List<TimerItem>`, `currentIndex`, `timeLeft: Duration`, `isRunning: bool`, `endTime: DateTime?`
- **`TimerItem`** — `id`, `title`, `duration`, `isCompleted` (JSON serializable for persistence)
- **`PomodoroSettings`** — `workDurationMinutes`, `shortBreakDurationMinutes`, `longBreakDurationMinutes`, `themeColor`, `enableNotifications`, `confirmBeforeNextTimer`, `playSoundWhenCompleted`
- **`PomodoroState.copyWith`** uses `DateTime? Function()?` pattern for `endTime` to distinguish "not provided" from "explicitly null"

## 4. Coding Standards & Style

### UI/UX Guidelines

- **No Clutter:** Avoid unnecessary app bars, floating action buttons, or borders unless requested.
- **Gestures:** The timer screen uses tap-to-pause, dedicated buttons for reset/settings.
- **Responsiveness:** Timer text scales cleanly using relative sizing.
- **Subtle Animations:** Favor implicit animations (`AnimatedContainer`, `AnimatedSwitcher`) over manual `AnimationController` lifecycles.
- **Theme Colors:** Green (default), Yellow, Red, Violet, Blue — selectable via pill toggles in settings.

### Dart/Flutter Best Practices

- **Immutability:** All state classes are immutable with `copyWith`.
- **Null Safety:** Strict null safety.
- **Const Widgets:** Maximize `const` constructors for smooth animation performance.

## 5. Development Workflow & Commands

### Code Generation

_Run if modifying annotated Riverpod providers._

- **Command:** `dart run build_runner build --delete-conflicting-outputs`

### Linting & Formatting

- **Lints:** `flutter_lints` + `riverpod_lint`
- **Enforced rules:** `prefer_relative_imports`, `directives_ordering`, `prefer_single_quotes`
- **Analyze:** `flutter analyze`
- **Fix:** `dart fix --apply`
- **Format:** `dart format .`

### Testing

- **Command:** `flutter test`
- **Existing tests:** Timer queue initialization, basic state validation.
- **Test files:** `test/timer_test.dart`, `test/widget_test.dart`.
- **Test mocks:** `MockAudioService`, `MockNotificationService` in `test/timer_test.dart`.

## 6. Android Configuration

- **Permissions** (in `AndroidManifest.xml`):
  - `RECEIVE_BOOT_COMPLETED` — reschedule notifications after reboot
  - `SCHEDULE_EXACT_ALARM` (maxSdkVersion 32) — scheduled notifications on Android 12
  - `USE_EXACT_ALARM` — scheduled notifications on Android 13+
- **Runtime permission:** `POST_NOTIFICATIONS` requested during `NotificationService.init()` for Android 13+ (API 33)

## 7. AI-Specific Behavior Rules

1. **Background Execution Safety:** Timer code uses `AppLifecycleObserver` to schedule system notifications when backgrounded. Always preserve this pattern.
2. **Audio/Notification Permissions:** When modifying alerts, ensure both iOS `Info.plist` and Android `AndroidManifest.xml` permissions are included, plus runtime permission requests for Android 13+.
3. **No Over-engineering:** Do not suggest complex databases (Isar, SQLite) or network requests. `shared_preferences` is sufficient.
4. **Complete Code:** Provide full implementations. No placeholders like `// Add UI here`.
5. **Notification IDs:** ID `0` = immediate (timer complete while foregrounded). ID `1` = scheduled (background). ID `2` = ongoing (silent countdown while minimized). Keep these separate.
6. **Provider Overrides:** The `NotificationService` instance is created and initialized in `main.dart`, then overridden in `ProviderScope`. Do not create new instances elsewhere.
