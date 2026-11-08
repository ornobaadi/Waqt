import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../core/utils/digits.dart';
import '../../data/user/user_prefs.dart';
import '../../domain/prayer/prayer_settings.dart';
import '../../domain/prayer/prayer_times_service.dart';
import '../../l10n/app_localizations.dart';
import '../common/labels.dart';
import '../now/moment_cards.dart';
import '../../platform/haptics/haptics.dart';

/// Minute-by-minute adjustments, to match a local timetable (an Islamic
/// Foundation's district table, a mosque's board). Each row shows today's
/// resulting time, so the user matches it by eye.
class AdjustScreen extends ConsumerWidget {
  const AdjustScreen({super.key});

  static const _waqt = {
    'fajr': Waqt.fajr,
    'sunrise': Waqt.sunrise,
    'dhuhr': Waqt.dhuhr,
    'asr': Waqt.asr,
    'maghrib': Waqt.maghrib,
    'isha': Waqt.isha,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final n = LocaleDigits(Localizations.localeOf(context).toLanguageTag());
    final settings = ref.watch(prayerSettingsProvider);
    final today = ref.watch(prayerStatusProvider)?.today;
    final fmt = clockFormat(context);

    void set(String key, int v) {
      Haptics.tick();
      final m = {...settings.minutes};
      if (v == 0) {
        m.remove(key);
      } else {
        m[key] = v.clamp(-PrayerSettings.maxMinutes, PrayerSettings.maxMinutes);
      }
      ref.read(userPrefsProvider.notifier).setPrayer(settings.copyWith(minutes: m));
    }

    String signed(int v) => v == 0 ? n(0) : '${v > 0 ? '+' : '−'}${n(v.abs())}';

    return Scaffold(
      backgroundColor: t.ground,
      appBar: AppBar(
        backgroundColor: t.ground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: t.ink,
        title: Text(l.adjustTitle, style: WaqtText.titleSmall.copyWith(color: t.ink)),
        actions: [
          if (settings.minutes.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(userPrefsProvider.notifier).setPrayer(settings.copyWith(minutes: const {})),
              child: Text(l.debugReset),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, 0, WaqtSpace.screen, WaqtSpace.x12),
        children: [
          Text(l.adjustHint, style: WaqtText.body.copyWith(color: t.inkMuted)),
          const SizedBox(height: WaqtSpace.x4),
          Container(
            decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(WaqtRadii.strip)),
            child: Column(
              children: [
                for (final MapEntry(key: k, value: w) in _waqt.entries)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(WaqtSpace.x4, WaqtSpace.x2, WaqtSpace.x1, WaqtSpace.x2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(switch (w) {
                                Waqt.fajr => '${l.waqt(w)} · ${l.ramadanSuhoor}',
                                Waqt.maghrib => '${l.waqt(w)} · ${l.ramadanIftar}',
                                _ => l.waqt(w),
                              }, style: WaqtText.bodyStrong.copyWith(color: t.ink)),
                              if (today != null)
                                Text(fmt.format(today[w]), style: WaqtText.label.copyWith(color: t.inkMuted)),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: l.adjustEarlier,
                          onPressed: () => set(k, (settings.minutes[k] ?? 0) - 1),
                          icon: Icon(Icons.remove_rounded, color: t.ink),
                        ),
                        SizedBox(
                          width: 44,
                          child: Text(
                            signed(settings.minutes[k] ?? 0),
                            textAlign: TextAlign.center,
                            style: WaqtText.bodyStrong.copyWith(color: t.ink),
                          ),
                        ),
                        IconButton(
                          tooltip: l.adjustLater,
                          onPressed: () => set(k, (settings.minutes[k] ?? 0) + 1),
                          icon: Icon(Icons.add_rounded, color: t.ink),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: WaqtSpace.x4),
          Text(l.adjustNote, style: WaqtText.caption.copyWith(color: t.inkMuted)),
        ],
      ),
    );
  }
}
