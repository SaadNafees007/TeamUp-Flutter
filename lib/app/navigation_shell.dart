import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_constants.dart';
import '../features/requests/providers/requests_provider.dart';

class NavigationShellScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const NavigationShellScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingCount = ref.watch(requestsProvider).pendingIncomingCount;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore_rounded),
              label: 'Discover',
            ),
            const NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(Icons.auto_awesome_rounded),
              label: 'Best Matches',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: pendingCount > 0,
                backgroundColor: AppColors.primaryIndigo,
                label: Text(
                  '$pendingCount',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                child: const Icon(Icons.mail_outline_rounded),
              ),
              selectedIcon: Badge(
                isLabelVisible: pendingCount > 0,
                backgroundColor: AppColors.primaryIndigo,
                label: Text(
                  '$pendingCount',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                child: const Icon(Icons.mail_rounded),
              ),
              label: 'Requests',
            ),
            const NavigationDestination(
              icon: Icon(Icons.groups_outlined),
              selectedIcon: Icon(Icons.groups_rounded),
              label: 'My Team',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
