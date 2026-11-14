import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_state.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../core/utils/digits.dart';
import '../../core/widgets/waqt_widgets.dart';
import '../../data/quran/quran.dart';
import '../../data/quran/quran_prefs.dart';
import '../../domain/moments/moment.dart';
import '../../l10n/app_localizations.dart';
import '../duas/library_views.dart';

/// A passage people look for, with the sahih or hasan hadith that says why
/// it is read. Some are tied to a time of day; those come first then.
class QuranPassage {
  const QuranPassage(this.title, this.why, this.at, this.he, {this.end, this.moments = const {}});
  final String Function(AppLocalizations) title;
  final String Function(AppLocalizations) why;
  final AyahRef at;

  /// The last ayah, when the passage is a few ayat of a surah.
  final int? end;

  /// HadeethEnc id, bundled (tool/build_content.py, QURAN_PASSAGES).
  final int he;

  /// Moments it is read in.
  final Set<MomentId> moments;
}

final quranPassages = [
  QuranPassage((l) => l.quranKursi, (l) => l.quranWhyKursi, (surah: 2, ayah: 255), 65059, end: 255),
  QuranPassage(
    (l) => l.quranBaqarahEnd,
    (l) => l.quranWhenNight,
    (surah: 2, ayah: 285),
    6274,
    end: 286,
    moments: {MomentId.maghrib, MomentId.isha, MomentId.bedtime, MomentId.lastThird, MomentId.taraweeh},
  ),
  QuranPassage((l) => l.quranFatihah, (l) => l.quranWhyFatihah, (surah: 1, ayah: 1), 10112),
  QuranPassage(
    (l) => l.quranKahf10,
    (l) => l.quranWhenDajjal,
    (surah: 18, ayah: 1),
    6265,
    end: 10,
    moments: {MomentId.jumuah},
  ),
  QuranPassage((l) => l.quranMulk, (l) => l.quranWhenSleep, (surah: 67, ayah: 1), 6260, moments: {MomentId.bedtime}),
  QuranPassage(
    (l) => l.quranQuls,
    (l) => l.quranWhenMorningEvening,
    (surah: 112, ayah: 1),
    6082,
    moments: {MomentId.morningAdhkar, MomentId.eveningAdhkar, MomentId.fajr, MomentId.sunrise},
  ),
  QuranPassage((l) => l.quranIkhlas, (l) => l.quranWhyIkhlas, (surah: 112, ayah: 1), 65261),
  QuranPassage((l) => l.quranBaqarah, (l) => l.quranWhyBaqarah, (surah: 2, ayah: 1), 6208),
];

/// "Ayah 7 / 286" in the reader's own digits.
String ayahOf(BuildContext context, int ayah, int total) {
  final d = LocaleDigits(Localizations.localeOf(context).toLanguageTag());
  return AppLocalizations.of(context).quranAyahOf(d(ayah), d(total));
}

/// The font for the Arabic text of [q]'s script (surah names stay in Amiri Quran).
String quranFont(Quran q) => q.marksInText ? WaqtFonts.indoPak : WaqtFonts.quran;

/// Line height for the script: IndoPak's marks sit high and low, so its
/// lines need more air than the Uthmani to never touch.
double quranLineHeight(Quran q) => q.marksInText ? 2.35 : 2.05;

/// Words a little apart in IndoPak, whose glyphs are set tight.
double? quranWordSpacing(Quran q, double fontSize) => q.marksInText ? 0.12 * fontSize : null;

/// Surahs matching what was typed: a number ("36"), a name in Tanzil's
/// spelling or a common one ("yasin" finds Yaa-Siin, "kahf" finds Al-Kahf),
/// the English name, or the Arabic. Doubled letters, a final h, "al-" and
/// diacritics are ignored.
List<Surah> findSurahs(Quran q, String query) {
  final raw = query.trim();
  if (raw.isEmpty) return q.surahs;
  final digits = int.tryParse(
    raw.split(':').first.replaceAllMapped(RegExp('[٠-٩]'), (m) => '${m[0]!.codeUnitAt(0) - 0x660}'),
  );
  if (digits != null) return [if (digits >= 1 && digits <= 114) q.surah(digits)];
  // "Al-Faatiha" -> "alfatia"; [bare] also drops a leading "al".
  String latin(String s, {bool bare = false}) {
    var x = s.toLowerCase().replaceAll(RegExp('[^a-z]'), '').replaceAll('ee', 'i').replaceAll('oo', 'u');
    x = x.replaceAllMapped(RegExp(r'(.)\1+'), (m) => m[1]!);
    if (bare && x.startsWith('al') && x.length > 4) x = x.substring(2);
    if (x.endsWith('h')) x = x.substring(0, x.length - 1);
    return x;
  }

  bool latinMatch(String name) {
    final full = latin(raw), bare = latin(raw, bare: true);
    return full.length > 1 && (latin(name).contains(full) || latin(name, bare: true).contains(bare));
  }

  String arabic(String s) =>
      s.replaceAll(RegExp('[\u064B-\u065F\u0670\u06D6-\u06ED]'), '').replaceAll(RegExp('^ال'), '').replaceAll('ـ', '');
  final qa = arabic(raw);
  return [
    for (final s in q.surahs)
      if (latinMatch(s.name) ||
          latinMatch(s.english) ||
          s.names.values.any(
            (n) => latinMatch(n.$1) || n.$1.contains(raw) || n.$2.toLowerCase().contains(raw.toLowerCase()),
          ) ||
          (qa.isNotEmpty && RegExp('[\u0600-\u06FF]').hasMatch(qa) && arabic(s.arabic).contains(qa)))
        s,
  ];
}

/// A surah's name and meaning in the app's language.
String surahName(BuildContext context, Surah s) => s.nameIn(Localizations.localeOf(context).languageCode);
String surahMeaning(BuildContext context, Surah s) => s.meaningIn(Localizations.localeOf(context).languageCode);

void openReader(BuildContext context, AyahRef at) => context.push('/read/${at.surah}?ayah=${at.ayah}');

/// The Quran tab: where you stopped, what the Sunnah ties to this moment,
/// then every surah, juz, and what you saved.
class QuranScreen extends ConsumerStatefulWidget {
  const QuranScreen({super.key});

  @override
  ConsumerState<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends ConsumerState<QuranScreen> {
  var _tab = 0;

  /// Well-known passages: the first few, or all of them.
  static const _shownPassages = 5;
  var _allPassages = false;

  /// Non-null while the surah search is open.
  String? _query;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final q = ref.watch(quranTextProvider);
    final progress = ref.watch(quranProgressProvider);
    // Names, not the list: the snapshot changes every second.
    final active = ref.watch(momentSnapshotProvider.select((s) => s?.active.map((m) => m.id.name).join(',') ?? ''));
    final now = {for (final n in active.split(',')) ?MomentId.values.asNameMap()[n]};
    // The ones for this moment first; the rest keep their order.
    final picks = [
      ...quranPassages.where((p) => p.moments.any(now.contains)),
      ...quranPassages.where((p) => !p.moments.any(now.contains)),
    ];

    return SafeArea(
      bottom: false,
      child: q == null
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(child: ScreenTitle(l.navQuran)),
                      IconButton(
                        tooltip: l.quranSearch,
                        onPressed: () => setState(() => _query = _query == null ? '' : null),
                        icon: Icon(_query == null ? Icons.search_rounded : Icons.close_rounded, color: t.ink),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: WaqtSpace.x3),
                        child: IconButton(
                          tooltip: l.quranSettings,
                          onPressed: () => context.push('/quran/settings'),
                          icon: Icon(Icons.tune_rounded, color: t.ink),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_query case final query?) ...[
                  _pad(
                    Padding(
                      padding: const EdgeInsets.only(bottom: WaqtSpace.x2),
                      child: TextField(
                        autofocus: true,
                        onChanged: (v) => setState(() => _query = v),
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: l.quranSearchHint,
                          prefixIcon: const Icon(Icons.search_rounded),
                          filled: true,
                          fillColor: t.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(WaqtSpace.minTouch / 2),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (findSurahs(q, query) case final found)
                    found.isEmpty
                        ? _pad(
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: WaqtSpace.x6),
                              child: Text(l.quranSearchNone, style: WaqtText.body.copyWith(color: t.inkMuted)),
                            ),
                          )
                        : _list(found.length, (i) => _SurahRow(surah: found[i])),
                ] else ...[
                  _pad(_ContinueCard(quran: q, at: progress.last)),
                  _pad(SectionLabel(l.quranWellKnown)),
                  _pad(
                    RowGroup(
                      children: [
                        for (final p in _allPassages ? picks : picks.take(_shownPassages))
                          _PassageRow(pick: p, highlight: p.moments.any(now.contains), quran: q),
                      ],
                    ),
                  ),
                  _pad(
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton.icon(
                        onPressed: () => setState(() => _allPassages = !_allPassages),
                        style: TextButton.styleFrom(foregroundColor: t.ink),
                        icon: Icon(_allPassages ? Icons.expand_less_rounded : Icons.expand_more_rounded),
                        label: Text(_allPassages ? l.quranShowLess : l.quranShowAll),
                      ),
                    ),
                  ),
                  _pad(
                    Padding(
                      padding: const EdgeInsets.only(top: WaqtSpace.x6, bottom: WaqtSpace.x2),
                      child: PillSwitch(
                        labels: [l.quranTabSurah, l.quranTabJuz, l.quranTabSaved],
                        selected: _tab,
                        onSelect: (i) => setState(() => _tab = i),
                      ),
                    ),
                  ),
                  switch (_tab) {
                    0 => _list(q.surahs.length, (i) => _SurahRow(surah: q.surahs[i])),
                    1 => _list(30, (i) => _JuzRow(quran: q, n: i + 1)),
                    _ =>
                      progress.saved.isEmpty
                          ? _pad(
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: WaqtSpace.x6),
                                child: Text(l.quranSavedEmpty, style: WaqtText.body.copyWith(color: t.inkMuted)),
                              ),
                            )
                          : _list(progress.saved.length, (i) => _SavedRow(quran: q, at: progress.saved[i])),
                  },
                ],
                SliverToBoxAdapter(child: SizedBox(height: WaqtSpace.x12 * 2 + MediaQuery.paddingOf(context).bottom)),
              ],
            ),
    );
  }

  Widget _list(int n, Widget Function(int) row) => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.screen),
    sliver: SliverList.separated(
      itemCount: n,
      itemBuilder: (_, i) => row(i),
      separatorBuilder: (context, _) => Divider(height: 1, color: WaqtTokens.of(context).hairline),
    ),
  );

  static Widget _pad(Widget child) => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.screen),
    sliver: SliverToBoxAdapter(child: child),
  );
}

/// The dark card: where you stopped, how far through the surah, Resume.
class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.quran, required this.at});
  final Quran quran;
  final AyahRef? at;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final r = at ?? (surah: 1, ayah: 1);
    final s = quran.surah(r.surah);
    final soft = t.ground.withValues(alpha: 0.72);
    return Material(
      color: t.ink,
      borderRadius: BorderRadius.circular(WaqtRadii.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(WaqtRadii.card),
        onTap: () => openReader(context, r),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(WaqtSpace.x5, WaqtSpace.x4, WaqtSpace.x5, WaqtSpace.x4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (at == null ? l.quranStart : l.quranContinue).toUpperCase(),
                          style: WaqtText.overline.copyWith(color: soft),
                        ),
                        const SizedBox(height: 2),
                        Text(surahName(context, s), style: WaqtText.title.copyWith(color: t.ground)),
                      ],
                    ),
                  ),
                  Text(
                    s.arabic,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontFamily: WaqtFonts.quran, fontSize: 30, height: 1.3, color: t.ground),
                  ),
                ],
              ),
              const SizedBox(height: WaqtSpace.x4),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${ayahOf(context, r.ayah, s.ayahs)} · ${l.quranJuz(quran.juzOf(r.surah, r.ayah))}',
                          style: WaqtText.label.copyWith(
                            color: soft,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(height: WaqtSpace.x2),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: r.ayah / s.ayahs,
                            minHeight: 3,
                            color: t.accent,
                            backgroundColor: t.ground.withValues(alpha: 0.16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: WaqtSpace.x4),
                  FilledButton(
                    onPressed: () => openReader(context, r),
                    style: FilledButton.styleFrom(
                      backgroundColor: t.ground,
                      foregroundColor: t.ink,
                      minimumSize: const Size(0, 44),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(at == null ? l.quranOpen : l.quranResume),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PassageRow extends ConsumerWidget {
  const _PassageRow({required this.pick, required this.highlight, required this.quran});
  final QuranPassage pick;
  final bool highlight;
  final Quran quran;

  /// "2:255" or "18:1–10", for passages that are a few ayat of a surah.
  String? _place(BuildContext context) {
    final end = pick.end;
    if (end == null) return null;
    final d = LocaleDigits(Localizations.localeOf(context).toLanguageTag());
    final at = pick.at;
    return end == at.ayah ? '${d(at.surah)}:${d(at.ayah)}' : '${d(at.surah)}:${d(at.ayah)}–${d(end)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(WaqtRadii.row),
        onTap: () => openReader(context, pick.at),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(WaqtSpace.x3, WaqtSpace.x3, 0, WaqtSpace.x3),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: WaqtSpace.x2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(pick.title(l), style: WaqtText.bodyStrong.copyWith(color: t.ink)),
                        if (highlight)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x2, vertical: 1),
                            decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(99)),
                            child: Text(
                              l.duasRightNow,
                              style: WaqtText.caption.copyWith(
                                // Readable on the accent in every palette.
                                color: ThemeData.estimateBrightnessForColor(t.accent) == Brightness.dark
                                    ? Colors.white
                                    : const Color(0xFF1E1810),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [?_place(context), pick.why(l)].join(' · '),
                      style: WaqtText.caption.copyWith(color: t.inkMuted),
                    ),
                    HeSourceText(
                      id: pick.he,
                      style: WaqtText.caption.copyWith(color: t.inkMuted),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l.quranWhy,
                onPressed: () => openHadith(context, ref, pick.he),
                icon: Icon(Icons.info_outline_rounded, size: 20, color: t.inkMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A round number badge, 34 across, for surah and juz rows.
class NumberBadge extends StatelessWidget {
  const NumberBadge(this.n, {super.key});
  final int n;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: t.ink.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Text(
        '$n',
        style: WaqtText.label.copyWith(
          color: t.ink,
          fontWeight: FontWeight.w600,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _SurahRow extends StatelessWidget {
  const _SurahRow({required this.surah});
  final Surah surah;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    return InkWell(
      onTap: () => openReader(context, (surah: surah.n, ayah: 1)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x1, vertical: WaqtSpace.x2),
          child: Row(
            children: [
              NumberBadge(surah.n),
              const SizedBox(width: WaqtSpace.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(surahName(context, surah), style: WaqtText.bodyStrong.copyWith(color: t.ink)),
                    Text(
                      [
                        surahMeaning(context, surah),
                        l.quranAyat(surah.ayahs),
                        surah.makki ? l.quranMakki : l.quranMadani,
                      ].where((x) => x.isNotEmpty).join(' · '),
                      style: WaqtText.caption.copyWith(color: t.inkMuted),
                    ),
                  ],
                ),
              ),
              Text(
                surah.arabic,
                textDirection: TextDirection.rtl,
                style: TextStyle(fontFamily: WaqtFonts.quran, fontSize: 22, color: t.ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JuzRow extends StatelessWidget {
  const _JuzRow({required this.quran, required this.n});
  final Quran quran;
  final int n;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final at = quran.juz[n - 1];
    final s = quran.surah(at.surah);
    return InkWell(
      onTap: () => openReader(context, at),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x1, vertical: WaqtSpace.x2),
          child: Row(
            children: [
              NumberBadge(n),
              const SizedBox(width: WaqtSpace.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.quranJuz(n), style: WaqtText.bodyStrong.copyWith(color: t.ink)),
                    Text(
                      '${surahName(context, s)} ${at.surah}:${at.ayah}',
                      style: WaqtText.caption.copyWith(color: t.inkMuted),
                    ),
                  ],
                ),
              ),
              Text(
                s.arabic,
                textDirection: TextDirection.rtl,
                style: TextStyle(fontFamily: WaqtFonts.quran, fontSize: 20, color: t.inkMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedRow extends StatelessWidget {
  const _SavedRow({required this.quran, required this.at});
  final Quran quran;
  final AyahRef at;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    final s = quran.surah(at.surah);
    return InkWell(
      onTap: () => openReader(context, at),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x1, vertical: WaqtSpace.x3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('${surahName(context, s)} ${at.surah}:${at.ayah}', style: WaqtText.bodyStrong.copyWith(color: t.ink)),
            const SizedBox(height: WaqtSpace.x1),
            Text(
              quran.display(at.surah, at.ayah),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.rtl,
              style: TextStyle(fontFamily: quranFont(quran), fontSize: 20, height: 1.8, color: t.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}
