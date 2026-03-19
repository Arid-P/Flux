import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../lists/presentation/app_drawer.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      drawer: isLandscape ? null : const AppDrawer(),
      body: isLandscape
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: _onTap,
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.check_box_outlined),
                      selectedIcon: Icon(Icons.check_box),
                      label: Text('Tasks'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.calendar_today_outlined),
                      selectedIcon: Icon(Icons.calendar_today),
                      label: Text('Calendar'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.track_changes_outlined),
                      selectedIcon: Icon(Icons.track_changes),
                      label: Text('Habits'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text('Settings'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                const SizedBox(width: 280, child: AppDrawer()),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: navigationShell),
              ],
            )
          : navigationShell,
      bottomNavigationBar: isLandscape
          ? null
          : BottomNavigationBar(
              currentIndex: navigationShell.currentIndex,
              type: BottomNavigationBarType.fixed,
              onTap: _onTap,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.check_box_outlined),
                  activeIcon: Icon(Icons.check_box),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today_outlined),
                  activeIcon: Icon(Icons.calendar_today),
                  label: 'Calendar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.track_changes_outlined),
                  activeIcon: Icon(Icons.track_changes),
                  label: 'Habits',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
    );
  }

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

