import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/navigation/presentation/app_shell.dart';
import '../../features/tasks/presentation/tasks_screen.dart';
import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/habits/presentation/habits_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorTasksKey = GlobalKey<NavigatorState>(debugLabel: 'shellTasks');
final GlobalKey<NavigatorState> _shellNavigatorCalendarKey = GlobalKey<NavigatorState>(debugLabel: 'shellCalendar');
final GlobalKey<NavigatorState> _shellNavigatorHabitsKey = GlobalKey<NavigatorState>(debugLabel: 'shellHabits');
final GlobalKey<NavigatorState> _shellNavigatorSettingsKey = GlobalKey<NavigatorState>(debugLabel: 'shellSettings');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/tasks',
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          navigatorKey: _shellNavigatorTasksKey,
          routes: <RouteBase>[
            GoRoute(
              path: '/tasks',
              builder: (BuildContext context, GoRouterState state) => const TasksScreen(),
              routes: [
                GoRoute(
                  path: ':listId',
                  builder: (context, state) => TasksScreen(listId: state.pathParameters['listId']),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorCalendarKey,
          routes: <RouteBase>[
            GoRoute(
              path: '/calendar',
              builder: (BuildContext context, GoRouterState state) => const CalendarScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHabitsKey,
          routes: <RouteBase>[
            GoRoute(
              path: '/habits',
              builder: (BuildContext context, GoRouterState state) => const HabitsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorSettingsKey,
          routes: <RouteBase>[
            GoRoute(
              path: '/settings',
              builder: (BuildContext context, GoRouterState state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
