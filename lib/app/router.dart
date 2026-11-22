import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/local_storage/local_store.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/discover/screens/discover_screen.dart';
import '../features/matching/screens/best_matches_screen.dart';
import '../features/requests/screens/requests_screen.dart';
import '../features/team/screens/my_team_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import 'navigation_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (BuildContext context, GoRouterState state) {
    final activeUserId = LocalStore.getActiveSessionUserId();
    final loc = state.matchedLocation;
    final isSplash = loc == '/splash';
    final isAuthRoute = loc == '/login' || loc == '/register';

    if (activeUserId == null) {
      // Unauthenticated users can only access splash, login, and register
      if (isSplash || isAuthRoute) return null;
      return '/login';
    }

    // Authenticated users trying to access login/register get redirected to discover
    if (isAuthRoute) {
      return '/discover';
    }

    return null;
  },
  routes: [
    // 1. Splash Screen
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // 2. Login Screen
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    // 3. Register Screen
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // 4. Authenticated Main Shell (5 Bottom Nav Destinations)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return NavigationShellScaffold(navigationShell: navigationShell);
      },
      branches: [
        // Discover
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/discover',
              builder: (context, state) => const DiscoverScreen(),
            ),
          ],
        ),
        // Best Matches
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/matches',
              builder: (context, state) => const BestMatchesScreen(),
            ),
          ],
        ),
        // Requests
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/requests',
              builder: (context, state) => const RequestsScreen(),
            ),
          ],
        ),
        // My Team
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/team',
              builder: (context, state) => const MyTeamScreen(),
            ),
          ],
        ),
        // Profile
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
