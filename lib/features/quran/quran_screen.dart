import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_state.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../core/widgets/waqt_widgets.dart';
import '../../data/quran/quran.dart';
import '../../data/quran/quran_prefs.dart';
import '../../domain/moments/moment.dart';
import '../../l10n/app_localizations.dart';
import '../duas/library_views.dart';

/// A reading the Sunnah ties to a time, with the hadith that ties it.
class QuranForMoment {
  const QuranForMoment(this.title, this.when, this.at, this.he, this.moments);
  final String Function(AppLocalizations) title;
  final String Function(AppLocalizations) when;
  final AyahRef at;

  /// HadeethEnc id, bundled (tool/build_content.py, QURAN_FOR_MOMENT).
  final int he;

  /// Moments it comes first in.
  final Set<MomentId> moments;
}

final quranForMoment = [
  QuranForMoment(
    (l) => l.quranBaqarahEnd,
    (l) => l.quranWhenNight,
    (surah: 2, ayah: 285),
    6274,
    {MomentId.maghrib, MomentId.isha, MomentId.bedtime, MomentId.lastThird, MomentId.taraweeh},
  ),
  QuranForMoment(
    (l) => l.quranQuls,
    (l) => l.quranWhenMorningEvening,
    (surah: 112, ayah: 1),
    6082,
    {MomentId.morningAdhkar, MomentId.eveningAdhkar, MomentId.fajr, MomentId.sunrise},
  ),
  QuranForMoment((l) => l.quranMulk, (l) => l.quranWhenSleep, (surah: 67, ayah: 1), 6260, {MomentId.bedtime}),
  QuranForMoment((l) => l.quranKahf10, (l) => l.quranWhenDajjal, (surah: 18, ayah: 1), 6265, {MomentId.jumuah}),
];

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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final q = ref.watch(quranProvider).value;
    final progress = ref.watch(quranProgressProvider);
    // Names, not the list: the snapshot changes every second.
    final active = ref.watch(momentSnapshotProvider.select((s) => s?.active.map((m) => m.id.name).join(',') ?? ''));
    final now = {for (final n in active.split(',')) ?MomentId.values.asNameMap()[n]};
    final picks = [...quranForMoment]
      ..sort((a, b) => (b.moments.any(now.contains) ? 1 : 0) - (a.moments.any(now.contains) ? 1 : 0));

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
                _pad(_ContinueCard(quran: q, at: progress.last)),
                _pad(SectionLabel(l.quranForNow)),
                _pad(
                  RowGroup(
                    children: [
                      for (final p in picks.take(3))
                        _MomentRow(pick: p, highlight: p.moments.any(now.contains), quran: q),
                    ],
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
                        Text(s.name, style: WaqtText.title.copyWith(color: t.ground)),
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
                          '${l.quranAyahOf(r.ayah, s.ayahs)} · ${l.quranJuz(quran.juzOf(r.surah, r.ayah))}',
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

class _MomentRow extends ConsumerWidget {
  const _MomentRow({required this.pick, required this.highlight, required this.quran});
  final QuranForMoment pick;
  final bool highlight;
  final Quran quran;

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
                    Text(pick.when(l), style: WaqtText.caption.copyWith(color: t.inkMuted)),
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
                    Text(surah.name, style: WaqtText.bodyStrong.copyWith(color: t.ink)),
                    Text(
                      '${surah.english} · ${l.quranAyat(surah.ayahs)} · ${surah.makki ? l.quranMakki : l.quranMadani}',
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
                    Text('${s.name} ${at.surah}:${at.ayah}', style: WaqtText.caption.copyWith(color: t.inkMuted)),
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
            Text('${s.name} ${at.surah}:${at.ayah}', style: WaqtText.bodyStrong.copyWith(color: t.ink)),
            const SizedBox(height: WaqtSpace.x1),
            Text(
              quran.display(at.surah, at.ayah),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.rtl,
              style: TextStyle(fontFamily: WaqtFonts.quran, fontSize: 20, height: 1.8, color: t.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}
