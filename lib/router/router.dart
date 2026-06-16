import 'package:go_router/go_router.dart';

import 'package:doomsdayfound/pages/dashboard/categories/index.dart';
import 'package:doomsdayfound/pages/dashboard/index.dart';
import 'package:doomsdayfound/pages/settings/index.dart';
import 'main_shell.dart';

final router = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardPage(),
              routes: [
                GoRoute(
                  path: 'categories',
                  builder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>;
                    return ManageCategoriesPage(
                      currentBalance: extra['currentBalance'] as double,
                      snapshotId: extra['snapshotId'] as int,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
