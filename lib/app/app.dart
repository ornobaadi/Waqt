import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/tokens.dart';
import '../core/theme/waqt_theme.dart';
import '../l10n/app_localizations.dart';
import 'app_state.dart';
import 'router.dart';

class WaqtApp extends ConsumerWidget {
  const WaqtApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(activePaletteProvider);
    final reduceMotion = WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations;

    return MaterialApp.router(
      onGenerateTitle: (c) => AppLocalizations.of(c).appName,
      debugShowCheckedModeBanner: false,
      theme: buildWaqtTheme(palette),
      // The moment changes the sky; the theme crossfades rather than snaps.
      themeAnimationDuration: reduceMotion ? Duration.zero : WaqtMotion.palette,
      themeAnimationCurve: WaqtMotion.ease,
      locale: ref.watch(localeOverrideProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
