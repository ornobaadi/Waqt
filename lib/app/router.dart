import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/waqt_theme.dart';
import 'dock.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/counter/counter_screen.dart';
import '../features/duas/dua_views.dart';
import '../features/duas/duas_screen.dart';
import '../features/duas/library_views.dart';
import '../features/now/now_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../data/user/user_prefs.dart';
import '../features/progress/progress_screen.dart';
import '../features/qibla/qibla_screen.dart';
import '../features/settings/city_picker_screen.dart';
import '../features/settings/checker_screen.dart';
import '../features/settings/adjust_screen.dart';
import '../features/settings/developer_screen.dart';
import '../features/settings/reading_screen.dart';
import '../features/settings/notifications_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/today/today_screen.dart';
import '../l10n/app_localizations.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: needsOnboarding(ref.read(sharedPrefsProvider)) ? '/welcome' : '/now',
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (_, _) => const OnboardingScreen(),
        routes: [GoRoute(path: 'city', builder: (_, _) => const CityPickerScreen())],
      ),
      GoRoute(path: '/counter', builder: (_, _) => const CounterScreen()),
      GoRoute(
        path: '/calendar',
        builder: (_, s) => CalendarScreen(focus: DateTime.tryParse(s.uri.queryParameters['day'] ?? '')),
      ),
      GoRoute(path: '/qibla', builder: (_, _) => const QiblaScreen()),
      // Above the dock: the pager has its own Previous / Next bar.
      GoRoute(
        path: '/dua/:task/:index',
        builder: (_, s) =>
            DuaPagerScreen(task: s.pathParameters['task']!, index: int.tryParse(s.pathParameters['index']!) ?? 0),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _Shell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/now', builder: (_, _) => const NowScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/today',
                builder: (_, _) => const TodayScreen(),
                routes: [GoRoute(path: 'progress', builder: (_, _) => const ProgressScreen())],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/duas',
                builder: (_, _) => const DuasScreen(),
                routes: [
                  GoRoute(
                    path: 'task/:id',
                    builder: (_, s) => DuaTaskScreen(id: s.pathParameters['id']!),
                  ),
                  GoRoute(
                    path: 'topic/:id',
                    builder: (_, s) => TopicScreen(id: int.parse(s.pathParameters['id']!)),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (_, _) => const SettingsScreen(),
                routes: [
                  GoRoute(path: 'city', builder: (_, _) => const CityPickerScreen()),
                  GoRoute(path: 'reading', builder: (_, _) => const ReadingScreen()),
                  GoRoute(path: 'adjust', builder: (_, _) => const AdjustScreen()),
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

    return PopScope(
      canPop: shell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) shell.goBranch(0);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarContrastEnforced: false,
        ),
        child: Scaffold(
          // The dock floats: content runs under it, visible and touchable
          // around it, and scrolling lists get its height as bottom padding.
          extendBody: true,
          body: shell,
          bottomNavigationBar: WaqtDock(
            selected: shell.currentIndex,
            onSelect: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
            items: [
              DockItem(icon: Icons.wb_twilight_outlined, selectedIcon: Icons.wb_twilight_rounded, label: l.navNow),
              DockItem(
                icon: Icons.view_timeline_outlined,
                selectedIcon: Icons.view_timeline_rounded,
                label: l.navToday,
              ),
              DockItem(icon: Icons.menu_book_outlined, selectedIcon: Icons.menu_book_rounded, label: l.navDuas),
              DockItem(icon: Icons.tune_outlined, selectedIcon: Icons.tune_rounded, label: l.navSettings),
            ],
          ),
        ),
      ),
    );
  }
}
