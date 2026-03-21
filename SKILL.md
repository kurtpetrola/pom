---
name: Pomodoro App Guidelines
description: Context, guidelines, and strict rules for AI agents working on the minimalist Pomodoro Flutter app.
---

# SKILL.md

> **Purpose:** Context, guidelines, and strict rules for AI agents working on this minimalist Pomodoro Flutter app.
> **Instruction:** ALWAYS read this file before generating code, planning features, or refactoring.

## 1. Project Context

- **Name:** Pom
- **Description:** A minimalist, distraction-free Pomodoro timer app designed to track work and break intervals.
- **Target Platforms:** iOS, Android.
- **Primary Language:** Dart (Latest Stable).
- **Framework:** Flutter (Latest Stable).
- **Design Philosophy:** Minimalist. No cluttered UI. High contrast, large typography, and subtle animations.

## 2. Tech Stack & Libraries

_Strictly adhere to these choices to keep the app lean but scalable._

- **State Management:** Riverpod (Strictly for managing timer state and session counts).
- **Local Storage:** `shared_preferences` (For saving settings like work duration, break duration, and daily completed cycles).
- **Notifications:** `flutter_local_notifications` (Crucial for alerting the user when a session ends while the app is in the background).
- **Sound/Haptics:** `audioplayers` or `flutter_vibrate`.
- **App Polish:** `flutter_native_splash` (For a seamless launch screen) and `flutter_launcher_icons` (For generating app icons).

## 3. Architectural Standards (Feature-First)

_Even minimalist apps require clean, scalable boundaries._

### Folder Structure

- **Root:** `lib/`
  - `core/`
    - `theme/` (Minimalist color palettes, typography)
    - `utils/` (Time formatters: mm:ss)
    - `services/` (Audio, Notifications, Background execution)
  - `features/`
    - `timer/` (Core Pomodoro logic, Timer Screen)
    - `settings/` (Duration adjustments, toggles)
    - `stats/` (Optional: Simple daily cycle counter)
  - `main.dart`

### Key Domain Rules

1.  **Timer Precision:** Never rely solely on `Timer.periodic` for exact duration tracking, as it drifts. Always calculate the remaining time based on an absolute `DateTime` end point (`endTime.difference(DateTime.now())`).
2.  **App Lifecycle:** The AI MUST handle `AppLifecycleState`. Timers must resume accurately when returning from the background.
3.  **UI/Logic Separation:** The countdown display widget must only listen to the state. All start/pause/reset logic lives in the state controller.
4.  **Mockable Clock:** Never hardcode `DateTime.now()` directly in the domain logic. Always inject the current time (e.g., using a Riverpod `TimeProvider` or the `clock` package) so that unit tests can instantly simulate the passage of time without actually waiting 25 minutes.
5.  **Synchronous Initialization:** Resolve `shared_preferences` in `main.dart` before `runApp()`, and pass it into a `ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)])`. This prevents async UI loading flickers on startup.

## 4. Coding Standards & Style

### UI/UX Guidelines

- **No Clutter:** Avoid unnecessary app bars, floating action buttons, or borders unless requested.
- **Gestures:** Favor intuitive gestures (e.g., tap the screen to pause, long press to reset) over explicit buttons where appropriate.
- **Responsiveness:** Ensure the timer text scales cleanly on smaller devices using `FittedBox` or relative sizing.
- **Subtle Animations:** Favor implicit animations like `AnimatedContainer`, `AnimatedSwitcher`, or `TweenAnimationBuilder` over manually managing `AnimationController` lifecycles to keep the UI code extremely lean.

### Dart/Flutter Best Practices

- **Immutability:** Timer states (e.g., `PomodoroState(timeLeft, currentPhase, isRunning)`) must be immutable.
- **Null Safety:** Strict null safety.
- **Const Widgets:** Maximize the use of `const` constructors to ensure smooth 60/120fps animations for the timer progress indicators.

## 5. Development Workflow & Commands

_We use version management for consistency._

### Code Generation

_Run this if modifying state models or local storage schemas._

- **Command:** `dart run build_runner build --delete-conflicting-outputs`

### Linting & Formatting

- **Lints:** `flutter_lints`
- **Command:** `flutter analyze`
- **Fix:** `dart fix --apply`

### Testing

- **Focus:** Ensure unit tests cover the timer phase transitions (Work -> Short Break -> Work -> Long Break).
- **Command:** `flutter test`

## 6. AI-Specific Behavior Rules

1.  **Background Execution Safety:** If generating timer code, explicitly state how it will behave when the user minimizes the app.
2.  **Audio/Notification Permissions:** If adding alerts, always include the necessary iOS `Info.plist` and Android `AndroidManifest.xml` permission configurations.
3.  **No Over-engineering:** Do not suggest complex local databases (like Isar or SQLite) or network requests unless explicitly asked. `shared_preferences` is enough for a minimalist timer.
4.  **Complete Code:** Provide full implementations for UI files. Do not use placeholders like `// Add minimalist UI here`.
