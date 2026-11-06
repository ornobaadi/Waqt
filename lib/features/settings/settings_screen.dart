import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_state.dart';
import '../../core/config/flavor.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../core/widgets/waqt_widgets.dart';
import '../../l10n/app_localizations.dart';

/// Endonyms: each language is named in its own script.
const supportedLanguageNames = {'en': 'English', 'ar': 'العربية'};

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final override = ref.watch(localeOverrideProvider);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, WaqtSpace.x8),
        children: [
          ScreenTitle(l.navSettings),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.screen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RowGroup(
                  children: [
                    RowTile(
                      title: l.settingsLanguage,
                      value: override == null
                          ? l.settingsLanguageSystem
                          : supportedLanguageNames[override.languageCode],
                      onTap: () => _pickLanguage(context, ref),
                    ),
                  ],
                ),
                if (AppConfig.debugTools) ...[
                  SectionLabel(l.settingsDeveloper),
                  RowGroup(
                    children: [
                      RowTile(
                        title: l.debugTitle,
                        subtitle: l.settingsDeveloperHint,
                        onTap: () => context.go('/settings/developer'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final current = ref.read(localeOverrideProvider);
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: t.ground,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(WaqtRadii.card))),
      builder: (sheet) {
        Widget option(String label, Locale? value) => RowTile(
          title: label,
          value: current == value ? '✓' : null,
          onTap: () {
            ref.read(localeOverrideProvider.notifier).set(value);
            Navigator.of(sheet).pop();
          },
        );
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, 0, WaqtSpace.screen, WaqtSpace.x4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.settingsLanguage, style: WaqtText.titleSmall.copyWith(color: t.ink)),
                const SizedBox(height: WaqtSpace.x4),
                RowGroup(
                  children: [
                    option(l.settingsLanguageSystem, null),
                    for (final e in supportedLanguageNames.entries) option(e.value, Locale(e.key)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
