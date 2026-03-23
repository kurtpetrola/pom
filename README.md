# Pom

A minimalist, distraction-free Pomodoro timer app built with Flutter.

## Features

- **Playlist-style timer queue** — Stack work phases, short breaks, and long breaks in any order
- **Drag-to-reorder** — Rearrange your timer queue on the fly
- **Editable timers** — Tap to rename or adjust duration of any timer
- **Background notifications** — Get notified when a timer completes, even when minimized
- **Alert chime** — Audio alert on timer completion
- **Theme colors** — Choose from Green, Yellow, Red, Violet, or Blue accent
- **Persistent state** — Your timer queue and settings survive app restarts

## Tech Stack

- **Flutter** + **Dart**
- **Riverpod** — State management
- **SharedPreferences** — Local persistence
- **flutter_local_notifications** — Scheduled & immediate notifications
- **audioplayers** — Completion alert sound

## Project Structure

```
lib/
├── core/
│   ├── theme/          # Colors, theme builder
│   ├── utils/          # Time formatter
│   └── services/       # Audio, notifications, lifecycle, clock, storage
├── features/
│   ├── timer/          # Timer controller, state, screen, widgets
│   └── settings/       # Settings controller, state, screen
└── main.dart
```

> **Note:** The goal of this app was to also test out SKILL.md and its effectiveness in AI-assisted app development.

## License

This project is licensed under the **MIT License** - see the **[LICENSE](https://github.com/kurtpetrola/pom/blob/main/LICENSE)** file for details.
