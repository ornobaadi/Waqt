import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/waqt_theme.dart';
import '../features/counter/counter_screen.dart';
import '../features/duas/duas_screen.dart';
import '../features/now/now_screen.dart';
import '../features/settings/city_picker_screen.dart';
import '../features/settings/checker_screen.dart';
import '../features/settings/developer_screen.dart';
import '../features/settings/notifications_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/today/today_screen.dart';
import '../l10n/app_localizations.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/now',
    routes: [
      GoRoute(path: '/counter', builder: (_, _) => const CounterScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _Shell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/now', builder: (_, _) => const NowScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/today', builder: (_, _) => const TodayScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/duas', builder: (_, _) => const DuasScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (_, _) => const SettingsScreen(),
                routes: [
                  GoRoute(path: 'city', builder: (_, _) => const CityPickerScreen()),
                  GoRoute(path: 'notifications', builder: (_, _) => const NotificationsScreen()),
                  GoRoute(
                    path: 'developer',
                    builder: (_, _) => const DeveloperScreen(),
                    routes: [GoRoute(path: 'check', builder: (_, _) => const CheckerScreen())],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _Shell extends StatelessWidget {
  const _Shell({required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final dark = ThemeData.estimateBrightnessForColor(t.ground) == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: t.ground,
      ),
      child: Scaffold(
        body: shell,
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: t.hairline)),
          ),
          child: NavigationBar(
            selectedIndex: shell.currentIndex,
            onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.wb_twilight_outlined),
                selectedIcon: const Icon(Icons.wb_twilight_rounded),
                label: l.navNow,
              ),
              NavigationDestination(
                icon: const Icon(Icons.view_timeline_outlined),
                selectedIcon: const Icon(Icons.view_timeline_rounded),
                label: l.navToday,
              ),
              NavigationDestination(
                icon: const Icon(Icons.menu_book_outlined),
                selectedIcon: const Icon(Icons.menu_book_rounded),
                label: l.navDuas,
              ),
              NavigationDestination(
                icon: const Icon(Icons.tune_outlined),
                selectedIcon: const Icon(Icons.tune_rounded),
                label: l.navSettings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
