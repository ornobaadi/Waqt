import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../app/app_state.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../data/quran/quran.dart';
import '../../data/quran/quran_prefs.dart';
import '../../data/quran/quran_translation.dart';
import '../../data/quran/recitation.dart';
import '../../data/quran/recitation_downloads.dart';
import '../../data/sources/he_library.dart' show contentLangProvider;
import '../../data/user/deeds_store.dart';
import '../../domain/deeds/deeds.dart';
import '../../l10n/app_localizations.dart';
import '../../platform/quran_audio.dart';
import 'quran_screen.dart' show quranFont, quranWordSpacing;

/// One surah: its heading and basmala, then each ayah with its translation
/// beneath. Remembers where you are; recites on request.
class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key, required this.surah, this.ayah = 1});
  final int surah;
  final int ayah;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  final _list = ItemScrollController();
  final _positions = ItemPositionsListener.create();
  late int _surah = widget.surah;
  late int _visible = widget.ayah;

  /// Where you had stopped when the reader opened: marked "You stopped here".
  AyahRef? _stopped;
  bool _awake = false;

  @override
  void initState() {
    super.initState();
    final last = ref.read(quranProgressProvider).last;
    if (last != null && last.surah == widget.surah && last.ayah > 1) _stopped = last;
    _positions.itemPositions.addListener(_onScroll);
    if (ref.read(quranPrefsProvider).keepAwake) _wake(true);
  }

  @override
  void dispose() {
    _positions.itemPositions.removeListener(_onScroll);
    if (_awake) _wake(false);
    super.dispose();
  }

  void _wake(bool on) {
    _awake = on;
    unawaited(WakelockPlus.toggle(enable: on).catchError((Object _) {}));
  }

  /// Item 0 is the heading; item i is ayah i.
  void _onScroll() {
    final shown = _positions.itemPositions.value.where((p) => p.itemTrailingEdge > 0.15 && p.itemLeadingEdge < 1);
    if (shown.isEmpty) return;
    final first = shown.map((p) => p.index).reduce((a, b) => a < b ? a : b).clamp(1, 1 << 20);
    if (first == _visible) return;
    setState(() => _visible = first);
    ref.read(quranProgressProvider.notifier).read((surah: _surah, ayah: first));
    _logRead(first);
  }

  /// Ayat read today, on Today's Quran row. Each ayah counts once per visit.
  final _counted = <String>{};
  void _logRead(int ayah) {
    if (!_counted.add('$_surah:$ayah')) return;
    final start = ref.read(momentSnapshotProvider)?.timeline.first.window.start ?? DateTime.now();
    final day = DeedStats.dayKey(start);
    final deeds = ref.read(deedsProvider.notifier);
    deeds.setHabit(day, quranHabit, (deeds.day(day).habits[quranHabit] ?? 0) + 1);
  }

  void _jump(int ayah, {bool animate = true}) {
    if (!_list.isAttached) return;
    final i = ayah.clamp(1, 1 << 20);
    animate
        ? _list.scrollTo(index: i, duration: WaqtMotion.ui, curve: WaqtMotion.ease, alignment: 0.08)
        : _list.jumpTo(index: i, alignment: 0.08);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final q = ref.watch(quranTextProvider);
    final prefs = ref.watch(quranPrefsProvider);
    final rec = ref.watch(recitationProvider);
    final lang = ref.watch(contentLangProvider);
    final hasTranslation = quranTranslations.containsKey(lang);
    final tr = hasTranslation && prefs.translation ? ref.watch(surahTranslationProvider(_surah)).value : null;

    ref.listen(recitationProvider, (prev, next) {
      if (!prefs.follow || next.surah != _surah || next.ayah == null || next.ayah == prev?.ayah) return;
      _jump(next.ayah == 0 ? 1 : next.ayah!);
    });
    ref.listen(recitationProvider.select((r) => r.error), (_, e) {
      if (e == null) return;
      ScaffoldMessenger.maybeOf(context)
          ?.showSnackBar(SnackBar(content: Text(e == RecitationError.wifiOnly ? l.quranWifiOnly : l.quranPlayFailed)));
    });

    if (q == null) {
      return Scaffold(
        backgroundColor: t.ground,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final s = q.surah(_surah);
    final playingHere = rec.active && rec.surah == _surah;

    return Scaffold(
      backgroundColor: t.ground,
      appBar: AppBar(
        backgroundColor: t.ground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: t.ink,
        centerTitle: true,
        title: Text('${s.n} · ${lang == 'ar' ? s.arabic : s.name}', style: WaqtText.bodyStrong.copyWith(color: t.ink)),
        actions: [
          IconButton(
            tooltip: l.quranSettings,
            onPressed: () => context.push('/quran/settings'),
            icon: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'A',
                    style: WaqtText.label.copyWith(color: t.ink, fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: 'A',
                    style: WaqtText.titleSmall.copyWith(color: t.ink),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ScrollablePositionedList.builder(
        itemScrollController: _list,
        itemPositionsListener: _positions,
        initialScrollIndex: widget.ayah > 1 ? widget.ayah.clamp(1, s.ayahs) : 0,
        initialAlignment: widget.ayah > 1 ? 0.08 : 0,
        padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, 0, WaqtSpace.screen, 180),
        itemCount: s.ayahs + 2,
        itemBuilder: (context, i) {
          if (i == 0) return _Heading(quran: q, surah: s, offerTranslation: hasTranslation && prefs.translation);
          if (i == s.ayahs + 1) return _Sources(next: _surah < 114 ? q.surah(_surah + 1) : null, onNext: _nextSurah);
          final at = (surah: _surah, ayah: i);
          return _Ayah(
            quran: q,
            at: at,
            translation: tr?[i],
            scale: prefs.arabicScale,
            reciting: playingHere && rec.ayah == i,
            stopped: _stopped == at,
            saved: ref.watch(quranProgressProvider.select((p) => p.isSaved(at))),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(WaqtSpace.x3, 0, WaqtSpace.x3, WaqtSpace.x3),
          child: AnimatedSwitcher(
            duration: WaqtMotion.ui,
            child: playingHere
                ? _PlayerPanel(quran: q, surah: s)
                : _Toolbar(
                    ayah: _visible,
                    total: s.ayahs,
                    onPrev: () => _jump(_visible - 1),
                    onNext: () => _jump(_visible + 1),
                    onListen: () => ref.read(recitationProvider.notifier).play(q, _surah, ayah: _visible),
                    showTranslation: hasTranslation,
                  ),
          ),
        ),
      ),
    );
  }

  void _nextSurah() {
    if (_surah >= 114) return;
    setState(() {
      _surah++;
      _visible = 1;
      _stopped = null;
    });
    _jump(0, animate: false);
    ref.read(quranProgressProvider.notifier).read((surah: _surah, ayah: 1));
  }
}

class _Heading extends ConsumerWidget {
  const _Heading({required this.quran, required this.surah, required this.offerTranslation});
  final Quran quran;
  final Surah surah;
  final bool offerTranslation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final basmala = quran.basmalaOf(surah.n);
    final install = ref.watch(quranTranslationInstallProvider);
    // Arabic readers get the Arabic name once, not an English one beside it.
    final arabicUi = Localizations.localeOf(context).languageCode == 'ar';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: WaqtSpace.x2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    arabicUi ? surah.arabic : surah.english,
                    style: arabicUi
                        ? TextStyle(fontFamily: WaqtFonts.quran, fontSize: 30, height: 1.3, color: t.ink)
                        : WaqtText.title.copyWith(color: t.ink),
                  ),
                  Text(
                    '${l.quranAyat(surah.ayahs)} · ${surah.makki ? l.quranMakki : l.quranMadani} · '
                    '${l.quranJuz(quran.juzOf(surah.n, 1))}',
                    style: WaqtText.label.copyWith(color: t.inkMuted),
                  ),
                ],
              ),
            ),
            if (!arabicUi)
              Text(
                surah.arabic,
                textDirection: TextDirection.rtl,
                style: TextStyle(fontFamily: WaqtFonts.quran, fontSize: 30, height: 1.3, color: t.ink),
              ),
          ],
        ),
        const SizedBox(height: WaqtSpace.x3),
        Divider(height: 1, color: t.hairline),
        if (offerTranslation && install.status != QuranTranslationStatus.ready) ...[
          const SizedBox(height: WaqtSpace.x4),
          const TranslationDownloadCard(),
        ],
        if (basmala != null) ...[
          const SizedBox(height: WaqtSpace.x4),
          Text(
            basmala,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: quranFont(quran),
              fontSize: 26,
              wordSpacing: quranWordSpacing(quran, 26),
              height: 1.9,
              color: t.ink,
            ),
          ),
          const SizedBox(height: WaqtSpace.x2),
          Divider(height: 1, color: t.hairline),
        ],
      ],
    );
  }
}

/// Offers the translation for the reader's language: once, then offline.
class TranslationDownloadCard extends ConsumerWidget {
  const TranslationDownloadCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final info = quranTranslations[ref.watch(contentLangProvider)];
    final s = ref.watch(quranTranslationInstallProvider);
    if (info == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(WaqtSpace.x4),
      decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(WaqtRadii.strip)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.quranShowTranslation, style: WaqtText.bodyStrong.copyWith(color: t.ink)),
          const SizedBox(height: WaqtSpace.x1),
          Text(l.quranTranslationBody(info.translator), style: WaqtText.label.copyWith(color: t.inkMuted)),
          const SizedBox(height: WaqtSpace.x3),
          if (s.status == QuranTranslationStatus.downloading) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(value: s.progress, minHeight: 6, color: t.ink),
            ),
            const SizedBox(height: WaqtSpace.x2),
            Text(
              l.hadithLibraryProgress((s.progress * 100).round()),
              style: WaqtText.caption.copyWith(color: t.inkMuted),
            ),
          ] else ...[
            if (s.status == QuranTranslationStatus.failed) ...[
              Text(l.hadithLibraryFailed, style: WaqtText.label.copyWith(color: t.ink)),
              const SizedBox(height: WaqtSpace.x2),
            ],
            FilledButton.icon(
              onPressed: s.status == QuranTranslationStatus.checking
                  ? null
                  : () => ref.read(quranTranslationInstallProvider.notifier).download(),
              style: FilledButton.styleFrom(
                backgroundColor: t.ink,
                foregroundColor: t.ground,
                minimumSize: const Size.fromHeight(WaqtSpace.minTouch),
                shape: const StadiumBorder(),
              ),
              icon: const Icon(Icons.download_rounded),
              label: Text(
                s.status == QuranTranslationStatus.failed ? l.hadithLibraryRetry : l.quranTranslationDownload,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Ayah extends ConsumerWidget {
  const _Ayah({
    required this.quran,
    required this.at,
    required this.translation,
    required this.scale,
    required this.reciting,
    required this.stopped,
    required this.saved,
  });

  final Quran quran;
  final AyahRef at;
  final AyahTranslation? translation;
  final double scale;
  final bool reciting;
  final bool stopped;
  final bool saved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final marked = reciting || stopped;
    final label = reciting ? l.quranRecitingNow : (stopped ? l.quranStoppedHere : null);
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null || saved)
          Row(
            children: [
              if (reciting) ...[Icon(Icons.graphic_eq_rounded, size: 16, color: t.ink), const SizedBox(width: 6)],
              if (label != null)
                Expanded(
                  child: Text(
                    label,
                    style: WaqtText.caption.copyWith(color: t.ink, fontWeight: FontWeight.w700),
                  ),
                )
              else
                const Spacer(),
              if (saved) Icon(Icons.bookmark_rounded, size: 18, color: t.ink),
            ],
          ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: quran.display(at.surah, at.ayah)),
              if (!quran.marksInText)
                TextSpan(
                  text: ' ۝${arabicDigits(at.ayah)}',
                  style: TextStyle(color: t.inkMuted),
                ),
            ],
          ),
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: quranFont(quran),
            fontSize: 27 * scale,
            wordSpacing: quranWordSpacing(quran, 27 * scale),
            height: 1.95,
            color: t.ink,
          ),
        ),
        if (translation case final tr? when tr.text.isNotEmpty) ...[
          const SizedBox(height: WaqtSpace.x1),
          Text(
            '${at.ayah} · ${tr.text}',
            style: WaqtText.body.copyWith(color: t.ink.withValues(alpha: 0.82), height: 1.5),
          ),
        ],
      ],
    );
    return Semantics(
      button: true,
      child: InkWell(
        key: ValueKey('ayah-${at.surah}:${at.ayah}'),
        borderRadius: BorderRadius.circular(WaqtRadii.strip),
        onTap: () => _actions(context, ref),
        child: marked
            ? Container(
                margin: const EdgeInsets.symmetric(vertical: WaqtSpace.x2),
                padding: const EdgeInsets.fromLTRB(WaqtSpace.x3, WaqtSpace.x2, WaqtSpace.x3, WaqtSpace.x3),
                decoration: BoxDecoration(
                  color: reciting ? t.accent.withValues(alpha: 0.45) : t.surface,
                  borderRadius: BorderRadius.circular(WaqtRadii.strip),
                ),
                child: body,
              )
            : DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: t.hairline)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: WaqtSpace.x3),
                  child: body,
                ),
              ),
      ),
    );
  }

  Future<void> _actions(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final s = quran.surah(at.surah);
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: t.ground,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, 0, WaqtSpace.screen, WaqtSpace.x4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('${s.name} ${at.surah}:${at.ayah}', style: WaqtText.titleSmall.copyWith(color: t.ink)),
              const SizedBox(height: WaqtSpace.x3),
              _action(
                ctx,
                saved ? Icons.bookmark_remove_outlined : Icons.bookmark_add_outlined,
                saved ? l.quranUnsave : l.quranSave,
                () {
                  ref.read(quranProgressProvider.notifier).toggleSaved(at);
                },
              ),
              _action(ctx, Icons.play_arrow_rounded, l.quranPlayFrom, () {
                ref.read(recitationProvider.notifier).play(quran, at.surah, ayah: at.ayah);
              }),
              _action(ctx, Icons.copy_rounded, l.copyText, () {
                Clipboard.setData(
                  ClipboardData(
                    text: [
                      quran.ayah(at.surah, at.ayah),
                      if (translation?.text case final tr? when tr.isNotEmpty) tr,
                      '${s.name} ${at.surah}:${at.ayah}',
                    ].join('\n\n'),
                  ),
                );
              }),
              if (translation?.notes case final n? when n.isNotEmpty) ...[
                const SizedBox(height: WaqtSpace.x3),
                Text(l.quranNotes.toUpperCase(), style: WaqtText.overline.copyWith(color: t.inkMuted)),
                const SizedBox(height: WaqtSpace.x2),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: SingleChildScrollView(
                    child: Text(n, style: WaqtText.label.copyWith(color: t.inkMuted, height: 1.5)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _action(BuildContext ctx, IconData icon, String label, VoidCallback onTap) {
    final t = WaqtTokens.of(ctx);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minTileHeight: WaqtSpace.minTouch,
      leading: Icon(icon, color: t.ink),
      title: Text(label, style: WaqtText.bodyStrong.copyWith(color: t.ink)),
      onTap: () {
        Navigator.of(ctx).pop();
        onTap();
      },
    );
  }
}

/// The end of a surah: the next one, and where the words come from.
class _Sources extends ConsumerWidget {
  const _Sources({required this.next, required this.onNext});
  final Surah? next;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final tr = ref.watch(quranTranslationProvider).value;
    final style = WaqtText.caption.copyWith(color: t.inkMuted);
    return Padding(
      padding: const EdgeInsets.only(top: WaqtSpace.x6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (next case final n?)
            OutlinedButton(
              onPressed: onNext,
              style: OutlinedButton.styleFrom(
                foregroundColor: t.ink,
                side: BorderSide(color: t.hairline),
                minimumSize: const Size.fromHeight(WaqtSpace.minTouch),
                shape: const StadiumBorder(),
              ),
              child: Text('${n.n} · ${n.name}  →'),
            ),
          const SizedBox(height: WaqtSpace.x4),
          Text(
            ref.watch(quranTextProvider)?.marksInText ?? false ? l.quranIndoPakSource : l.quranTextSource,
            style: style,
          ),
          if (tr != null) Text(l.quranTranslationSource(tr.info.translator, tr.version ?? '–'), style: style),
        ],
      ),
    );
  }
}

/// Board 04's floating bar: step through ayat, start the recitation, and
/// show or hide the translation.
class _Toolbar extends ConsumerWidget {
  const _Toolbar({
    required this.ayah,
    required this.total,
    required this.onPrev,
    required this.onNext,
    required this.onListen,
    required this.showTranslation,
  });

  final int ayah;
  final int total;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onListen;
  final bool showTranslation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final on = ref.watch(quranPrefsProvider.select((p) => p.translation));
    return Center(
      heightFactor: 1,
      child: Container(
        height: 60,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: t.ink,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: t.ink.withValues(alpha: 0.25), blurRadius: 30, offset: const Offset(0, 10))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: l.quranPrevAyah,
              onPressed: ayah > 1 ? onPrev : null,
              color: t.ground,
              disabledColor: t.ground.withValues(alpha: 0.3),
              icon: Icon(Icons.chevron_left_rounded, textDirection: Directionality.of(context)),
            ),
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 88),
                child: Text(
                  l.quranAyahOf(ayah, total),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: WaqtText.label.copyWith(
                    color: t.ground,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: l.quranNextAyah,
              onPressed: ayah < total ? onNext : null,
              color: t.ground,
              disabledColor: t.ground.withValues(alpha: 0.3),
              icon: Icon(Icons.chevron_right_rounded, textDirection: Directionality.of(context)),
            ),
            if (showTranslation)
              IconButton(
                tooltip: on ? l.quranTranslationOn : l.quranTranslationOff,
                isSelected: on,
                onPressed: () => ref.read(quranPrefsProvider.notifier).update((p) => p.copyWith(translation: !on)),
                color: t.ground.withValues(alpha: 0.5),
                selectedIcon: Icon(Icons.translate_rounded, color: t.ground),
                icon: const Icon(Icons.translate_rounded),
              ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 2),
              child: FilledButton.icon(
                onPressed: onListen,
                style: FilledButton.styleFrom(
                  backgroundColor: t.ground,
                  foregroundColor: t.ink,
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x4),
                  shape: const StadiumBorder(),
                ),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(l.quranListen),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Board 06's player: reciter, streaming or on the phone, progress through
/// the ayah, and the controls.
class _PlayerPanel extends ConsumerWidget {
  const _PlayerPanel({required this.quran, required this.surah});
  final Quran quran;
  final Surah surah;

  static const _speeds = [0.75, 1.0, 1.25, 1.5];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final rec = ref.watch(recitationProvider);
    final player = ref.read(recitationProvider.notifier);
    final prefs = ref.watch(quranPrefsProvider);
    final reciter = reciterById(prefs.reciter);
    final local = ref.watch(recitationDownloadsProvider.select((d) => d.done.contains(surah.n)));
    final soft = t.ground.withValues(alpha: 0.72);
    final speed = prefs.speed;
    String fmt(Duration d) => '${d.inMinutes}:${'${d.inSeconds % 60}'.padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.fromLTRB(WaqtSpace.x4, WaqtSpace.x3, WaqtSpace.x4, WaqtSpace.x2),
      decoration: BoxDecoration(
        color: t.ink,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: t.ink.withValues(alpha: 0.25), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => context.push('/quran/reciters'),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 44),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.quranReciter, style: WaqtText.caption.copyWith(color: soft)),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                reciter.name,
                                overflow: TextOverflow.ellipsis,
                                style: WaqtText.bodyStrong.copyWith(color: t.ground),
                              ),
                            ),
                            Icon(Icons.expand_more_rounded, size: 18, color: soft),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push('/quran/downloads'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: t.ground,
                  side: BorderSide(color: t.ground.withValues(alpha: 0.3)),
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x3),
                  shape: const StadiumBorder(),
                ),
                icon: Icon(local ? Icons.download_done_rounded : Icons.wifi_rounded, size: 16),
                label: Text(local ? l.quranOnPhone : l.quranStreaming, style: WaqtText.label),
              ),
            ],
          ),
          const SizedBox(height: WaqtSpace.x2),
          StreamBuilder<Duration>(
            stream: player.position,
            builder: (context, snap) {
              final pos = snap.data ?? Duration.zero;
              final len = player.duration ?? Duration.zero;
              final v = len.inMilliseconds == 0 ? 0.0 : (pos.inMilliseconds / len.inMilliseconds).clamp(0.0, 1.0);
              final a = rec.ayah ?? 0;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: rec.loading ? null : v,
                      minHeight: 4,
                      color: t.accent,
                      backgroundColor: t.ground.withValues(alpha: 0.16),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        a == 0 ? surah.name : l.quranAyahOf(a, surah.ayahs),
                        style: WaqtText.caption.copyWith(color: soft),
                      ),
                      const Spacer(),
                      Text(
                        '${fmt(pos)} / ${fmt(len)}',
                        style: WaqtText.caption.copyWith(
                          color: soft,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => player.setSpeed(_speeds[(_speeds.indexOf(speed) + 1) % _speeds.length]),
                style: TextButton.styleFrom(foregroundColor: t.ground, minimumSize: const Size(48, 48)),
                child: Semantics(
                  label: l.quranSpeed,
                  child: Text(
                    '${speed == speed.roundToDouble() ? speed.toInt() : speed}×',
                    style: WaqtText.label.copyWith(color: t.ground, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              IconButton(
                tooltip: l.quranPrevAyah,
                onPressed: player.previous,
                color: t.ground,
                icon: const Icon(Icons.skip_previous_rounded),
              ),
              IconButton.filled(
                tooltip: rec.playing ? l.quranPause : l.quranPlay,
                onPressed: player.toggle,
                style: IconButton.styleFrom(
                  backgroundColor: t.ground,
                  foregroundColor: t.ink,
                  minimumSize: const Size(56, 56),
                ),
                icon: Icon(rec.playing ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 30),
              ),
              IconButton(
                tooltip: l.quranNextAyah,
                onPressed: player.next,
                color: t.ground,
                icon: const Icon(Icons.skip_next_rounded),
              ),
              IconButton(
                tooltip: l.quranStop,
                onPressed: player.stop,
                color: t.ground,
                icon: const Icon(Icons.stop_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
