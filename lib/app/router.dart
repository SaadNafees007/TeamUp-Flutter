import 'package:go_router/go_router.dart';
import '../features/discover/screens/discover_screen.dart';
import '../features/matching/screens/best_matches_screen.dart';
import '../features/requests/screens/requests_screen.dart';
import '../features/team/screens/my_team_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import 'navigation_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/discover',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return NavigationShellScaffold(navigationShell: navigationShell);
      },
      branches: [
        // 1. Discover
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/discover',
              builder: (context, state) => const DiscoverScreen(),
            ),
          ],
        ),
        // 2. Best Matches
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/matches',
              builder: (context, state) => const BestMatchesScreen(),
            ),
          ],
        ),
        // 3. Requests
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/requests',
              builder: (context, state) => const RequestsScreen(),
            ),
          ],
        ),
        // 4. My Team
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/team',
              builder: (context, state) => const MyTeamScreen(),
            ),
          ],
        ),
        // 5. Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
