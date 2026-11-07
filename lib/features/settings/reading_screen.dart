import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../data/sources/hadeethenc.dart';
import '../../data/user/reading_prefs.dart';
import '../../l10n/app_localizations.dart';

/// Arabic, transliteration and meaning, each sized on its own, previewed on a
/// real dua so the result is exactly what the library will show.
class ReadingScreen extends ConsumerWidget {
  const ReadingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final rp = ref.watch(readingPrefsProvider);
    final n = ref.read(readingPrefsProvider.notifier);
    // The master supplication for forgiveness, as HadeethEnc gives it.
    final h = ref.watch(heBundleProvider).value?[5503];
    final lang = Localizations.localeOf(context).languageCode;

    Widget slider(String label, double v, ValueChanged<double> on) => Padding(
      padding: const EdgeInsets.only(top: WaqtSpace.x3),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: WaqtText.bodyStrong.copyWith(color: t.ink)),
          ),
          Text('A', style: WaqtText.caption.copyWith(color: t.inkMuted)),
          Expanded(
            child: Slider(
              value: v,
              min: ReadingPrefs.min,
              max: ReadingPrefs.max,
              divisions: 10,
              label: '${(v * 100).round()}%',
              activeColor: t.ink,
              onChanged: on,
            ),
          ),
          Text('A', style: WaqtText.titleSmall.copyWith(color: t.inkMuted)),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: t.ground,
      appBar: AppBar(
        backgroundColor: t.ground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: t.ink,
        title: Text(l.readingTitle, style: WaqtText.titleSmall.copyWith(color: t.ink)),
        actions: [TextButton(onPressed: n.reset, child: Text(l.debugReset))],
      ),
      body: Column(
        children: [
          // Preview stays in view while the sliders move.
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, WaqtSpace.x2, WaqtSpace.screen, WaqtSpace.x4),
              child: Container(
                padding: const EdgeInsets.all(WaqtSpace.x5),
                decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(WaqtRadii.card)),
                child: h == null
                    ? const SizedBox(height: 120)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            h.arabic?.text ?? '',
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            style: ReadingPrefs.scaled(
                              WaqtText.arabic.copyWith(color: t.ink, fontSize: 24, height: 1.85),
                              rp.arabic,
                            ),
                          ),
                          if (h.translation(lang) case final tr?) ...[
                            const SizedBox(height: WaqtSpace.x3),
                            Text(tr.text, style: ReadingPrefs.scaled(WaqtText.body.copyWith(color: t.ink), rp.meaning)),
                          ],
                        ],
                      ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, 0, WaqtSpace.x2, WaqtSpace.x4),
              child: Column(
                children: [
                  slider(l.readingArabic, rp.arabic, (v) => n.set(arabic: v)),
                  slider(l.readingMeaning, rp.meaning, (v) => n.set(meaning: v)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
