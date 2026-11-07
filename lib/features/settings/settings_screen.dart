import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_state.dart';
import '../../core/config/flavor.dart';
import '../../core/config/test_mode.dart';
import '../../data/hijri/calendar_sync.dart';
import '../../core/diagnostics/reports.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../core/utils/digits.dart';
import '../../core/widgets/option_sheet.dart';
import '../../core/widgets/waqt_widgets.dart';
import '../../data/user/user_prefs.dart';
import '../../domain/hijri/hijri_service.dart';
import '../../domain/location/place.dart';
import '../../domain/prayer/prayer_settings.dart';
import '../../domain/prayer/prayer_times_service.dart';
import '../../l10n/app_localizations.dart';
import '../common/labels.dart';

/// Endonyms: each language is named in its own script.
const supportedLanguageNames = {
  'en': 'English',
  'ar': 'العربية',
  'ur': 'اردو',
  'bn': 'বাংলা',
  'id': 'Bahasa Indonesia',
  'tr': 'Türkçe',
  'fr': 'Français',
};

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _locating = false;

  Future<void> _useGps() async {
    setState(() => _locating = true);
    final err = await locateWithGps(ref);
    if (!mounted) return;
    setState(() => _locating = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).gps(err))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final prefs = ref.watch(userPrefsProvider);
    final sync = ref.watch(calendarSyncProvider);
    final settings = ref.watch(prayerSettingsProvider);
    final locale = ref.watch(localeOverrideProvider);
    final notifier = ref.read(userPrefsProvider.notifier);
    final place = prefs.place;

    void update(PrayerSettings s) => notifier.setPrayer(s);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: WaqtSpace.x8),
        children: [
          ScreenTitle(l.navSettings),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.screen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionLabel(l.settingsLocation),
                RowGroup(
                  children: [
                    RowTile(
                      title: place == null ? l.settingsNotSet : place.name,
                      subtitle: place == null
                          ? null
                          : [
                              place.country ?? place.countryCode,
                              if (place.source == PlaceSource.gps) l.settingsGpsSource,
                            ].join('  ·  '),
                      onTap: () => context.push('/settings/city'),
                    ),
                    RowTile(
                      title: _locating ? l.locationLocating : l.settingsUseGps,
                      onTap: _locating ? null : _useGps,
                    ),
                  ],
                ),
                SectionLabel(l.settingsPrayerTimes),
                RowGroup(
                  children: [
                    RowTile(
                      title: l.settingsMethod,
                      subtitle: prefs.prayer == null
                          ? '${l.method(settings.method)}  ·  ${l.settingsRegionalDefault}'
                          : l.method(settings.method),
                      onTap: () async {
                        final m = await showOptionSheet(
                          context,
                          title: l.settingsMethod,
                          selected: settings.method,
                          options: [for (final m in CalcMethod.values) SheetOption(m, l.method(m), hint: m.angles)],
                        );
                        if (m != null) update(settings.copyWith(method: m));
                      },
                    ),
                    RowTile(
                      title: l.settingsAsr,
                      value: l.asr(settings.asr),
                      onTap: () async {
                        final a = await showOptionSheet(
                          context,
                          title: l.settingsAsr,
                          selected: settings.asr,
                          options: [
                            SheetOption(AsrSchool.standard, l.asrStandard, hint: l.asrStandardHint),
                            SheetOption(AsrSchool.hanafi, l.asrHanafi, hint: l.asrHanafiHint),
                          ],
                        );
                        if (a != null) update(settings.copyWith(asr: a));
                      },
                    ),
                    RowTile(
                      title: l.settingsHighLat,
                      value: l.highLat(settings.highLatitude),
                      onTap: () async {
                        final r = await showOptionSheet(
                          context,
                          title: l.settingsHighLat,
                          selected: settings.highLatitude,
                          options: [
                            for (final r in HighLatitudeRule.values)
                              SheetOption(r, l.highLat(r), hint: r == HighLatitudeRule.auto ? l.highLatAutoHint : null),
                          ],
                        );
                        if (r != null) update(settings.copyWith(highLatitude: r));
                      },
                    ),
                    RowTile(
                      title: l.adjustTitle,
                      subtitle: l.adjustRowHint,
                      value: settings.minutes.isEmpty ? l.adjustNone : l.adjustSome(settings.minutes.length),
                      onTap: () => context.push('/settings/adjust'),
                    ),
                  ],
                ),
                SectionLabel(l.notifTitle),
                RowGroup(
                  children: [
                    RowTile(
                      title: l.notifTitle,
                      subtitle: l.notifHint,
                      onTap: () => context.push('/settings/notifications'),
                    ),
                  ],
                ),
                SectionLabel(l.settingsCalendar),
                RowGroup(
                  children: [
                    RowTile(
                      title: l.settingsCalendar,
                      subtitle: l.authorityName(sync.authority),
                      onTap: () async {
                        final picked = await showOptionSheet<HijriAuthority>(
                          context,
                          title: l.settingsCalendar,
                          selected: sync.authority,
                          options: [
                            for (final a in HijriAuthority.values)
                              SheetOption(a, l.authorityName(a), hint: _authorityHint(l, a)),
                          ],
                        );
                        if (picked != null) ref.read(calendarSyncProvider.notifier).setAuthority(picked);
                      },
                    ),
                    // An authority's announced dates are used as they are; the
                    // day adjustment is for local sighting only.
                    if (sync.authority == HijriAuthority.local)
                      RowTile(
                        title: l.settingsHijriAdjust,
                        subtitle: l.hijriAdjustHint,
                        value: l.hijriOffset(prefs.hijriOffset),
                        onTap: () => _pickHijriOffset(context, prefs.hijriOffset),
                      ),
                  ],
                ),
                SectionLabel(l.settingsLanguage),
                RowGroup(
                  children: [
                    RowTile(
                      title: l.readingTitle,
                      subtitle: l.readingHint,
                      onTap: () => context.push('/settings/reading'),
                    ),
                    RowTile(
                      title: l.settingsLanguage,
                      value: locale == null ? l.settingsLanguageSystem : supportedLanguageNames[locale.languageCode],
                      onTap: () async {
                        final picked = await showOptionSheet<String>(
                          context,
                          title: l.settingsLanguage,
                          selected: locale?.languageCode ?? '',
                          options: [
                            SheetOption('', l.settingsLanguageSystem),
                            for (final e in supportedLanguageNames.entries) SheetOption(e.key, e.value),
                          ],
                        );
                        if (picked != null) {
                          ref.read(localeOverrideProvider.notifier).set(picked.isEmpty ? null : Locale(picked));
                        }
                      },
                    ),
                  ],
                ),
                SectionLabel(l.settingsAbout),
                RowGroup(
                  children: [
                    RowTile(title: l.privacyTitle, subtitle: l.privacyBody),
                    RowTile(title: l.reportProblem, subtitle: l.reportProblemHint, onTap: Reports.reportProblem),
                    const _VersionTile(),
                  ],
                ),
                if (ref.watch(testModeProvider.select((s) => s.unlocked))) ...[
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
                const SizedBox(height: WaqtSpace.x6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x1),
                  child: Text(l.settingsAttribution, style: WaqtText.caption.copyWith(color: t.inkMuted)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Each option previews the resulting Hijri date, so the user can match
  /// the announced date without doing arithmetic.
  Future<void> _pickHijriOffset(BuildContext context, int current) async {
    final l = AppLocalizations.of(context);
    final n = LocaleDigits(Localizations.localeOf(context).toLanguageTag());
    final now = ref.read(placeNowProvider);
    final maghrib = ref.read(prayerStatusProvider)?.today;
    const service = HijriService();
    final picked = await showOptionSheet<int>(
      context,
      title: l.settingsHijriAdjust,
      selected: current,
      options: [
        for (var d = -HijriService.maxOffset; d <= HijriService.maxOffset; d++)
          SheetOption(
            d,
            l.hijriOffset(d),
            hint: l.hijri(service.dateFor(now, maghrib: maghrib?[Waqt.maghrib], offset: d), n.call),
          ),
      ],
    );
    if (picked != null) ref.read(userPrefsProvider.notifier).setHijriOffset(picked);
  }
}

/// Seven taps unlock test mode, the usual Android convention.
class _VersionTile extends ConsumerStatefulWidget {
  const _VersionTile();

  @override
  ConsumerState<_VersionTile> createState() => _VersionTileState();
}

class _VersionTileState extends ConsumerState<_VersionTile> {
  int _taps = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return RowTile(
      title: l.settingsAbout,
      value: l.settingsVersion(AppConfig.version),
      onTap: () {
        if (ref.read(testModeProvider).unlocked || ++_taps < 7) return;
        ref.read(testModeProvider.notifier).unlock();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.testModeUnlocked)));
      },
    );
  }
}

String _authorityHint(AppLocalizations l, HijriAuthority a) => switch (a) {
  HijriAuthority.saudi => l.authoritySaudiHint,
  HijriAuthority.diyanet => l.authorityDiyanetHint,
  HijriAuthority.local => l.authorityLocalHint,
};
