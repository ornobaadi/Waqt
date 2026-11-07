import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../data/sources/hisn.dart';
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
    // The first dua of the book, said on waking.
    final dua = ref.watch(hisnProvider).value?.duas.first;

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
                child: dua == null
                    ? const SizedBox(height: 120)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            dua.arabic,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            style: ReadingPrefs.scaled(
                              WaqtText.arabic.copyWith(color: t.ink, fontSize: 24, height: 1.85),
                              rp.arabic,
                            ),
                          ),
                          if (dua.transliteration != null) ...[
                            const SizedBox(height: WaqtSpace.x3),
                            Text(
                              dua.transliteration!,
                              style: ReadingPrefs.scaled(
                                WaqtText.body.copyWith(color: t.inkMuted, fontStyle: FontStyle.italic),
                                rp.transliteration,
                              ),
                            ),
                          ],
                          if (dua.translation != null) ...[
                            const SizedBox(height: WaqtSpace.x3),
                            Text(
                              dua.translation!,
                              style: ReadingPrefs.scaled(WaqtText.body.copyWith(color: t.ink), rp.meaning),
                            ),
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
                  slider(l.readingTransliteration, rp.transliteration, (v) => n.set(transliteration: v)),
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
