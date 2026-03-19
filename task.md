# FluxDone Implementation Tasks

## Environment & Setup
- [x] Create `fluxdone` Flutter project
- [x] Update `android/app/build.gradle` (minSdkVersion 26)
- [x] Install dependencies via `flutter pub add`

## Phase 1-A: Foundation
- [x] Step 1: ThemeTokens + AppTheme (light/dark sets, context extension)
- [x] Step 2: Database + DI (DatabaseHelper schemas, get_it + injectable)
- [x] Step 3: go_router + Navigation Shell (4 tabs: Tasks, Calendar, Habits, Settings)
- [x] Step 4: AppDrawer SCR-08 (Folders, Lists, Smart Lists, rename/delete dialogs)

## Phase 1-B: Core Task System
- [x] Step 5: Lists Module (CRUD, Creation sheet)
- [x] Step 6: Task CRUD (ITaskRepository, TaskRepositoryImpl)
- [x] Step 7: Smart Lists (Queries for Today, Tomorrow, Upcoming, etc.)
- [x] Step 8: List View SCR-01 (Task card, priority, sections, slidable)
- [x] Step 9: Task Creation Sheet SCR-03 (DraggableScrollableSheet, Date/Time pickers)
- [x] Step 10: Task Detail Sheet SCR-02 (Auto-save, rich text editor, subtasks)
- [x] Step 11: Recurring Tasks
- [x] Step 12: Trash SCR-12

## Phase 1-C: Calendar
- [x] Step 13: Calendar View SCR-04 (Custom timeline grid, day/3-day/week modes)

## Phase 1-D: Habits
- [x] Step 14: Habit Tracker SCR-05/06/07 (Cards, detail view, creation sheet)

## Phase 1-E: Settings + Reminders
- [ ] Step 15: Settings SCR-09 (Appearance, Account, Calendar, Notifications)
- [ ] Step 16: Local Notifications

## Phase 1-F: FluxFocus Bridge
- [ ] Step 17: MethodChannel IPC (FocusBlockRequest, createTask)

## Verification
- [x] Compilation & Analysis
- [x] Live Functional Test (Chrome Web)
