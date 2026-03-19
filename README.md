# Flux App Family

> **Author:** Ari | **Started:** March 2026 | **Status:** Phase 1 — Active Development

Two custom Android apps built as direct replacements for TickTick and Regain. Built with Flutter. Fully offline-first. AI-directed implementation via Antigravity.

---

## Apps

| App | Replaces | Abbreviation | Status |
|---|---|---|---|
| **FluxDone** | TickTick (task management) | FD | 🟡 Phase 1 in progress |
| **FluxFoxus** | Regain (screen discipline & focus) | FF | 🔴 Spec locked, build pending |

Both apps are separate APKs that communicate via Android MethodChannel IPC on `com.fluxfoxus/fd_integration`.

---

## Monorepo Structure

```
Flux/
├── fluxdone/          # FluxDone Flutter project
│   ├── android/
│   ├── ios/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app.dart
│   │   ├── core/
│   │   │   ├── theme/        # ThemeTokens, AppTheme
│   │   │   ├── router/       # go_router route definitions
│   │   │   ├── events/       # TaskCreatedEvent, TaskUpdatedEvent, TaskDeletedEvent
│   │   │   ├── utils/        # date_formatter, hex_color
│   │   │   └── permissions/  # notification permission wrappers
│   │   └── features/
│   │       ├── tasks/
│   │       ├── calendar/
│   │       ├── habits/
│   │       ├── lists/
│   │       ├── smart_lists/
│   │       ├── navigation/
│   │       ├── settings/
│   │       ├── backup/
│   │       └── fluxfoxus_bridge/
│   ├── test/
│   └── pubspec.yaml
│
├── fluxfoxus/         # FluxFoxus Flutter project (build pending)
│
├── prompts_docx/      # Antigravity GMPs and spec docs (gitignored)
├── FLUX_CONTEXT.md    # Shared context document for both apps
├── .gitignore
└── README.md
```

---

## Architecture — FluxDone

**Pattern:** Clean Architecture + feature-first folder structure

Each feature module owns three layers:

| Layer | Responsibility |
|---|---|
| **Presentation** | Flutter Widgets, Screens, BLoC/Cubit. All visual rendering. |
| **Domain** | Business logic, use cases, entities, repository interfaces. Pure Dart — zero Flutter imports. |
| **Data** | Repository implementations, SQLite DAOs, API clients, MethodChannel wrappers. |
| **Core / Shared** | ThemeTokens, AppRouter, event bus, DI container, shared_preferences wrappers. |

**Critical rule:** No feature module may import another module's internal files. Cross-module communication uses the rxdart event bus or shared repository interfaces only.

---

## Architecture — FluxFoxus

**Pattern:** Feature-first with Riverpod v2

Shares the same Clean Architecture layer model as FD. Key difference: FF requires background execution (WorkManager + flutter_foreground_task) and Android system APIs (UsageStatsManager, AccessibilityService).

**Critical rule:** FF build does not begin until FD Phase 1 is user-validated. IPC bridge is built last, after both apps are individually stable.

---

## Tech Stack

### FluxDone

| Area | Package |
|---|---|
| Framework | Flutter (Dart) |
| State Management | flutter_bloc (BLoC/Cubit) |
| Dependency Injection | get_it + injectable |
| Local Database | sqflite (SQLite) |
| Key-Value Storage | shared_preferences |
| Navigation | go_router |
| Local Notifications | flutter_local_notifications |
| Google Sign-In | google_sign_in |
| Google Calendar | googleapis (calendar_v3) |
| Google Drive | googleapis (drive_v3) |
| Swipe Actions | flutter_slidable |
| Habit Animation | confetti |
| Event Bus | rxdart |
| Date Formatting | intl |
| IPC | Flutter MethodChannel |
| Testing | flutter_test + mocktail |

### FluxFoxus

| Area | Package |
|---|---|
| Framework | Flutter (Dart) |
| State Management | riverpod (v2+) |
| Local Database | sqflite + Hive |
| Navigation | go_router |
| Notifications | flutter_local_notifications |
| Background Tasks | workmanager + flutter_foreground_task |
| Charts | fl_chart |
| Home Widget | home_widget |
| DI | get_it |
| IPC | Flutter MethodChannel |

---

## Database

**FluxDone** uses SQLite exclusively via `sqflite`. No Hive. `shared_preferences` handles lightweight key-value settings (theme selection, last calendar view mode, folder expanded states, last backup timestamp).

**FluxFoxus** uses SQLite via `sqflite` for relational data (sessions, presets, app limits) and Hive for fast key-value caching (screen time cache, widget refresh data).

All timestamps are stored as **Unix epoch milliseconds (UTC)**. Application layer handles local time conversion.

---

## Theming — FluxDone

All color values in the widget tree are sourced from `ThemeTokens` — no hardcoded hex values anywhere. This enables Phase 3 JSON custom theming with zero widget rewrites.

- **Phase 1:** Light + Dark themes
- **Phase 3:** JSON-based custom theme upload/download (VSCode-style)

7 academic domain colors are system-locked and mirrored in the Notewise companion app:

| Domain | Hex |
|---|---|
| Number Theory | `#2E7D32` |
| Geometry | `#1565C0` |
| Combinatorics | `#43A047` |
| Algebra P1 | `#FB8C00` |
| Algebra P2 | `#E64A19` |
| Tests | `#E53935` |
| Neev Diamond | `#576481` |

All other lists use a fully user-defined hex color picker.

---

## Design System — FluxFoxus

Dark mode only in Phase 1.

| Token | Value |
|---|---|
| Background | `#0F172A` |
| Surface | `#1E293B` |
| Primary | `#6366F1` |
| Accent | `#22D3EE` |
| Text | `#F8FAFC` |
| Font | Inter / Gilroy |

---

## FD ↔ FF IPC

Channel name: `com.fluxfoxus/fd_integration`

**FD → FF:** When a task with `start_time` + `end_time` is created, updated, or deleted, FD sends a `FocusBlockRequest` (action: CREATE / UPDATE / DELETE). FF creates, updates, or deletes the linked FocusSession.

**FF → FD:** When a focus session is started directly from FF, FF calls `createTask` on FD. FD writes a "Focus Session" task to the `FF` section of the default list. This section is auto-created on FD's first launch; its `sectionId` is stored in `shared_preferences`.

---

## Development Phases

### FluxDone
| Phase | Scope |
|---|---|
| **Phase 1** | All P0 + P1 features. Both light and dark themes. Offline-only. Android. |
| **Phase 2** | Google Drive backup, Google Calendar overlay, drag-to-reschedule, pin tasks, iOS + Web. |
| **Phase 3** | JSON custom theming UI. |

### FluxFoxus
| Phase | Scope |
|---|---|
| **Phase 1** | Full feature set (Focus Timer, App Limits, Block Scheduling, YouTube Study Mode, Screen Time Tracking, Home Widget, Weekly Report). Dark only. Android. |
| **Phase 2** | iOS. |

---

## Setup

### Prerequisites
- Flutter SDK (stable channel)
- Android Studio or VS Code with Flutter + Dart extensions
- Android SDK API 34 (target), API 26 minimum
- Java 17+

### FluxDone

```bash
cd fluxdone
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

> `build_runner` is required for `injectable` code generation. Run it after any DI registration changes.

### Android minimum SDK

In `fluxdone/android/app/build.gradle`:
```gradle
minSdkVersion 26
targetSdkVersion 34
```

---

## Implementation

All code is generated via **Antigravity (ag)** — an AI coding agent. Ari directs architecture and logic; Antigravity writes all implementation. Specification documents in `prompts_docx/` (gitignored) are the source of truth for every implementation decision.

**Spec documents:**
- `FLUX_CONTEXT.md` — shared context for both apps
- `FluxDone_PRD_v2.docx` — product requirements
- `FluxDone_TRD_v2.docx` — technical requirements
- `ui_SCR-01` through `ui_SCR-13` — locked UI specifications (13 screens)
- `ui_ICONS_icon-system.md` — icon system spec
- `FF_PRD_v1.0.md`, `FF_TRD_v1.0.md` — FF product + technical requirements
- 10 FF UI specification files

**Rule:** No deviation from spec documents without explicit approval from Ari.

---

## Notes

- FD must be fully user-validated before FF build begins.
- IPC bridge is built last — after both apps are individually stable.
- `flutter.zip` at repo root: delete it, it has no place here.
