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
│   │       ├── notes/
│   │       ├── navigation/
│   │       ├── settings/
│   │       ├── backup/
│   │       ├── data_portability/
│   │       ├── statistics/
│   │       ├── templates/
│   │       ├── smart_recognition/
│   │       └── fluxfoxus_bridge/
│   ├── test/
│   └── pubspec.yaml
│
├── fluxfoxus/         # FluxFoxus Flutter project (build pending)
│   ├── android/
│   ├── lib/
│   │   ├── core/
│   │   └── features/
│   │       ├── home/
│   │       ├── focus_timer/
│   │       ├── breaks/
│   │       ├── streaks/
│   │       ├── app_limits/
│   │       ├── presets/
│   │       ├── planner/
│   │       ├── usage_stats/
│   │       ├── youtube_study_mode/
│   │       ├── fd_integration/
│   │       ├── widget/
│   │       ├── security/
│   │       ├── ai/
│   │       ├── focus_score/
│   │       └── friction/
│   └── pubspec.yaml
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
| Home Widget | home_widget |
| IPC | Flutter MethodChannel |
| Testing | flutter_test + mocktail |

### FluxFoxus

| Area | Package |
|---|---|
| Framework | Flutter (Dart) |
| State Management | riverpod (v2+) |
| Local Database | sqflite + Hive |
| Secure Storage | flutter_secure_storage |
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

**FluxFoxus** uses SQLite via `sqflite` for relational data (sessions, presets, app limits, focus scores) and Hive for fast key-value caching (user preferences, app categorization, channel whitelist, AI settings).

All timestamps are stored as **Unix epoch milliseconds (UTC)**. Application layer handles local time conversion.

---

## Theming — FluxDone

All color values in the widget tree are sourced from `ThemeTokens` — no hardcoded hex values anywhere. This enables Phase 3 JSON custom theming with zero widget rewrites.

- **Phase 1:** Light + Dark themes
- **Phase 3:** JSON-based custom theme (ThemeTokens + list colors + typography). Download/upload or in-app editor. Multiple saved themes, 3 MB storage cap.

List colors are fully user-defined via hex picker. No system-locked colors.

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

| Method | Direction | Purpose |
|---|---|---|
| `FocusBlockRequest` (CREATE/UPDATE/DELETE) | FD → FF | Timed task created/updated/deleted in FD |
| `createTask` | FF → FD | FF session started — writes Focus Session task to FD |
| `getTaskBlocks` | FF → FD | FF queries FD for timed tasks in a date range (P3 auto-scheduling) |
| `getFocusSessions` | FD → FF | FD queries FF for focus sessions in a date range (P4 overlap warning) |
| `getDayTaskSummary` | FF → FD | FF queries FD for task completion data for Focus Score (P4.FF) |

**IPC rule:** Bridge code is built last — after both apps are individually stable per phase. P4.FF is the P4 IPC sub-version.

---

## Development Phases

### FluxDone

| Phase | Scope |
|---|---|
| **P1** | Task CRUD, Calendar View, Habits, Lists/Folders/Sections, Smart Lists, recurring tasks, rich text, light + dark themes. Android. |
| **P2** | Google Drive backup, Google Calendar overlay, drag-to-reschedule, pin tasks, Won't Do task status. |
| **P3** | JSON custom theming, Home screen widgets (WIDGET-01/02), Data Import, Data Export, Subtask progress on list view, Notes. |
| **P4** | Focus time blocking overlap warning, Statistics screen (Tasks + Habits), NLP task parsing (Smart Recognition), Task Templates, Multi-select bulk time-shift on Calendar, Linked tasks. |
| **P5** | Website, Windows, Linux, macOS. |

### FluxFoxus

| Phase | Scope |
|---|---|
| **P1** | Focus Timer (flip clock), Break System, Stop Focusing modal, Streaks, App Limits, YouTube Study Mode, Block Scheduling, Screen Time Tracking, Planner, Weekly Report, Home Widget. Dark only. Android. |
| **P2** | Uninstall protection, Scheduled sessions, AI break negotiation (user API key), Streak grace day, Post-session reflection. |
| **P3** | Focus Score (checkpoint system, weighted formula), Session templates + auto-scheduling, Lock screen session status, AI improvements (Session Debrief, Preset Suggester, Streak Coach, Difficulty Auto-Adjust), Bug fixes + polish. |
| **P4** | Focus Score enhancement (FD task data + AI hybrid), Pre-open friction, Category limits, App limit smart suggestions. |
| **P4.FF** | IPC bridge additions for P4 cross-app features. Built after P4 features are individually stable. |
| **P5** | Website, Windows, Linux, iOS, macOS. |

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

**Spec documents — FluxDone:**
- `FLUX_CONTEXT.md` — shared context for both apps
- `FluxDone_PRD_v2.docx` — product requirements
- `FluxDone_TRD_v2.docx` — technical requirements
- `ui_SCR-01` through `ui_SCR-13` + `ui_ICONS_icon-system.md` — locked P1 UI specs
- `FD_P2_AMENDMENT_wont-do-status.md` — P2 amendment
- `FD_P3_F1` through `FD_P3_F6` + widget specs — P3 specs
- `FD_P4_F1` through `FD_P4_F6` — P4 specs

**Spec documents — FluxFoxus:**
- `FF_PRD_v1.0.md`, `FF_TRD_v1.0.md` — P1 product + technical requirements
- 10 FF P1 UI specification files
- `FF_P2_F1` through `FF_P2_F5` — P2 specs
- `FF_P3_F1` through `FF_P3_F5` — P3 specs
- `FF_P4_F1` through `FF_P4_F4` — P4 specs

**Rule:** No deviation from spec documents without explicit approval from Ari.

---

## Key Principles

- **Spec-first, always.** All decisions locked before any code is written.
- **Modular.** Every feature is a self-contained module. One broken module must not cascade.
- **Offline-first.** Core functionality works with zero network. Network features are enhancements.
- **Token-based theming.** All colors via ThemeTokens in FD. No hardcoded values.
- **Clone first.** Phase 1 replicates the existing apps' workflows exactly.
- **FD before FF.** Build and validate FluxDone completely before beginning FluxFoxus.
- **IPC last.** The MethodChannel bridge is built after both apps are individually stable per phase.
- **No online database.** All features use local SQLite/Hive. No server-side database at any phase.
