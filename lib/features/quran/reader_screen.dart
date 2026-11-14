import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../app/app_state.dart';
import '../../core/theme/tokens.dart';
import '../../platform/haptics/haptics.dart';
import '../../core/utils/digits.dart';
import '../../core/theme/waqt_theme.dart';
import '../../data/quran/quran.dart';
import '../../data/quran/quran_prefs.dart';
import '../../data/quran/quran_translation.dart';
import '../../data/sources/he_library.dart' show contentLangProvider;
import '../../data/user/deeds_store.dart';
import '../../domain/deeds/deeds.dart';
import '../../l10n/app_localizations.dart';
import '../../platform/quran_audio.dart';
import 'recitation_bar.dart';
import 'quran_screen.dart' show quranFont, quranLineHeight, quranWordSpacing, surahName;

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
    final translit = prefs.transliteration ? ref.watch(transliterationProvider).value : null;

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
        title: Text('${s.n} · ${s.nameIn(lang)}', style: WaqtText.bodyStrong.copyWith(color: t.ink)),
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
            translit: prefs.transliteration ? translit?.of(at.surah, at.ayah) : null,
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
                ? const RecitationBar()
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
                    arabicUi ? surah.arabic : surahName(context, surah),
                    style: arabicUi
                        ? TextStyle(fontFamily: WaqtFonts.quran, fontSize: 30, height: 1.3, color: t.ink)
                        : WaqtText.title.copyWith(color: t.ink),
                  ),
                  Text(
                    [
                      if (!arabicUi) surah.meaningIn(Localizations.localeOf(context).languageCode),
                      l.quranAyat(surah.ayahs),
                      surah.makki ? l.quranMakki : l.quranMadani,
                      l.quranJuz(quran.juzOf(surah.n, 1)),
                    ].where((x) => x.isNotEmpty).join(' · '),
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
              height: quranLineHeight(quran),
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

/// A translation as the translator wrote it, made easy to read: their own
/// ayah number at the start is left off (the reader shows it), and the
/// footnote marks ([2], [১]) become small raised numbers, so a sentence reads
/// through. The notes themselves open from the ayah's sheet.
List<InlineSpan> translationSpans(String text, Color muted) {
  const digits = '0-9\u09E6-\u09EF\u0660-\u0669\u06F0-\u06F9';
  var s = text.replaceFirst(RegExp('^\\s*[(（][$digits]+[)）]\\s*'), '');
  // "[২] ," -> "[২]," : the space belonged before the mark, not the comma.
  s = s.replaceAllMapped(RegExp('(\\[[$digits]+\\])\\s+([,،;.।؛])'), (m) => '${m[1]}${m[2]}');
  final mark = RegExp('\\s?\\[([$digits]+)\\]');
  final out = <InlineSpan>[];
  var at = 0;
  for (final m in mark.allMatches(s)) {
    if (m.start > at) out.add(TextSpan(text: s.substring(at, m.start)));
    out.add(
      WidgetSpan(
        alignment: PlaceholderAlignment.top,
        child: Padding(
          padding: const EdgeInsets.only(left: 1, right: 2),
          child: Text(
            m[1]!,
            style: TextStyle(fontSize: 10, height: 1, color: muted, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
    at = m.end;
  }
  if (at < s.length) out.add(TextSpan(text: s.substring(at)));
  return out;
}

/// One ayah, everything a reader needs in order: its number and what you
/// can do with it (listen from here, save, the translator's notes, more),
/// the Arabic large and clear, how to say it in Latin letters, and what it
/// means in your language.
class _Ayah extends ConsumerWidget {
  const _Ayah({
    required this.quran,
    required this.at,
    required this.translation,
    required this.translit,
    required this.scale,
    required this.reciting,
    required this.stopped,
    required this.saved,
  });

  final Quran quran;
  final AyahRef at;
  final AyahTranslation? translation;
  final String? translit;
  final double scale;
  final bool reciting;
  final bool stopped;
  final bool saved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final tag = Localizations.localeOf(context).toLanguageTag();
    final label = reciting ? l.quranRecitingNow : (stopped ? l.quranStoppedHere : null);
    final notes = translation?.notes;
    final hasNotes = notes != null && notes.isNotEmpty;
    final tool = IconButton.styleFrom(
      foregroundColor: t.inkMuted,
      minimumSize: const Size(40, 40),
      fixedSize: const Size(40, 40),
      padding: EdgeInsets.zero,
    );

    final header = Row(
      children: [
        // The ayah's number in a small ring, the same in every language.
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: reciting ? t.ink : Colors.transparent,
            border: Border.all(color: reciting ? t.ink : t.ink.withValues(alpha: 0.25), width: 1.5),
          ),
          child: Text(
            LocaleDigits(tag)(at.ayah),
            style: WaqtText.caption.copyWith(
              color: reciting ? t.ground : t.ink,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const Spacer(),
        IconButton(
          tooltip: l.quranPlayHere,
          style: tool,
          onPressed: () => ref.read(recitationProvider.notifier).play(quran, at.surah, ayah: at.ayah),
          icon: const Icon(Icons.play_circle_outline_rounded, size: 22),
        ),
        IconButton(
          tooltip: saved ? l.quranUnsave : l.quranSave,
          style: tool,
          isSelected: saved,
          selectedIcon: Icon(Icons.bookmark_rounded, size: 22, color: t.ink),
          onPressed: () {
            Haptics.tick();
            ref.read(quranProgressProvider.notifier).toggleSaved(at);
          },
          icon: const Icon(Icons.bookmark_border_rounded, size: 22),
        ),
        if (hasNotes)
          IconButton(
            tooltip: l.quranTranslatorNotes,
            style: tool,
            onPressed: () => _notes(context, notes),
            icon: const Icon(Icons.sticky_note_2_outlined, size: 21),
          ),
        IconButton(
          tooltip: l.quranMore,
          style: tool,
          onPressed: () => _actions(context, ref),
          icon: const Icon(Icons.more_horiz_rounded, size: 22),
        ),
      ],
    );

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(top: WaqtSpace.x2),
            child: Row(
              children: [
                if (reciting) ...[Icon(Icons.graphic_eq_rounded, size: 16, color: t.ink), const SizedBox(width: 6)],
                Expanded(
                  child: Text(
                    label,
                    style: WaqtText.caption.copyWith(color: t.ink, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: WaqtSpace.x4),
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
            fontSize: 28 * scale,
            wordSpacing: quranWordSpacing(quran, 28 * scale),
            height: quranLineHeight(quran),
            color: t.ink,
          ),
        ),
        if (translit case final tl?) ...[
          const SizedBox(height: WaqtSpace.x3),
          Text(
            tl,
            textDirection: TextDirection.ltr,
            style: WaqtText.body.copyWith(
              color: t.inkMuted,
              fontStyle: FontStyle.italic,
              height: 1.55,
              fontSize: 16 * (0.85 + 0.15 * scale),
            ),
          ),
        ],
        if (translation case final tr? when tr.text.isNotEmpty) ...[
          const SizedBox(height: WaqtSpace.x3),
          Text.rich(
            TextSpan(children: translationSpans(tr.text, t.inkMuted)),
            style: WaqtText.body.copyWith(color: t.ink.withValues(alpha: 0.88), height: 1.6, fontSize: 16.5),
          ),
        ],
      ],
    );

    return Semantics(
      container: true,
      child: GestureDetector(
        key: ValueKey('ayah-${at.surah}:${at.ayah}'),
        behavior: HitTestBehavior.opaque,
        onLongPress: () => _actions(context, ref),
        child: AnimatedContainer(
          duration: WaqtMotion.ui,
          curve: WaqtMotion.ease,
          margin: const EdgeInsets.symmetric(vertical: WaqtSpace.x2),
          padding: const EdgeInsets.fromLTRB(WaqtSpace.x4, WaqtSpace.x3, WaqtSpace.x4, WaqtSpace.x5),
          decoration: BoxDecoration(
            color: reciting
                ? t.accent.withValues(alpha: 0.28)
                : stopped
                ? t.surface
                : Color.alphaBlend(t.surface.withValues(alpha: 0.55), t.ground),
            borderRadius: BorderRadius.circular(WaqtRadii.card),
            border: Border.all(color: reciting ? t.accent.withValues(alpha: 0.6) : t.hairline),
          ),
          child: body,
        ),
      ),
    );
  }

  Future<void> _notes(BuildContext context, String notes) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final s = quran.surah(at.surah);
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: t.ground,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        maxChildSize: 0.9,
        builder: (ctx, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, 0, WaqtSpace.screen, WaqtSpace.x8),
          children: [
            Text(l.quranTranslatorNotes, style: WaqtText.titleSmall.copyWith(color: t.ink)),
            Text(
              '${surahName(context, s)} ${at.surah}:${at.ayah}',
              style: WaqtText.caption.copyWith(color: t.inkMuted),
            ),
            const SizedBox(height: WaqtSpace.x4),
            SelectableText(notes, style: WaqtText.body.copyWith(color: t.ink, height: 1.6)),
          ],
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
              Text(
                '${surahName(context, s)} ${at.surah}:${at.ayah}',
                style: WaqtText.titleSmall.copyWith(color: t.ink),
              ),
              const SizedBox(height: WaqtSpace.x3),
              _action(
                ctx,
                saved ? Icons.bookmark_remove_outlined : Icons.bookmark_add_outlined,
                saved ? l.quranUnsave : l.quranSave,
                () => ref.read(quranProgressProvider.notifier).toggleSaved(at),
              ),
              _action(ctx, Icons.play_arrow_rounded, l.quranPlayFrom, () {
                ref.read(recitationProvider.notifier).play(quran, at.surah, ayah: at.ayah);
              }),
              _action(ctx, Icons.copy_rounded, l.copyText, () {
                Clipboard.setData(
                  ClipboardData(
                    text: [
                      quran.ayah(at.surah, at.ayah),
                      ?translit,
                      if (translation?.text case final tr? when tr.isNotEmpty) tr,
                      '${surahName(context, s)} ${at.surah}:${at.ayah}',
                    ].join('\n\n'),
                  ),
                );
              }),
              if (translation?.notes case final n? when n.isNotEmpty)
                _action(ctx, Icons.sticky_note_2_outlined, l.quranTranslatorNotes, () => _notes(context, n)),
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
              child: Text('${n.n} · ${surahName(context, n)}  →'),
            ),
          const SizedBox(height: WaqtSpace.x4),
          Text(
            ref.watch(quranTextProvider)?.marksInText ?? false ? l.quranIndoPakSource : l.quranTextSource,
            style: style,
          ),
          Text(l.quranTranslitSource, style: style),
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
        decoration: _calm(t, 30),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: l.quranPrevAyah,
              onPressed: ayah > 1 ? onPrev : null,
              color: t.ink,
              disabledColor: t.ink.withValues(alpha: 0.25),
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
                    color: t.ink,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: l.quranNextAyah,
              onPressed: ayah < total ? onNext : null,
              color: t.ink,
              disabledColor: t.ink.withValues(alpha: 0.25),
              icon: Icon(Icons.chevron_right_rounded, textDirection: Directionality.of(context)),
            ),
            if (showTranslation)
              IconButton(
                tooltip: on ? l.quranTranslationOn : l.quranTranslationOff,
                isSelected: on,
                onPressed: () => ref.read(quranPrefsProvider.notifier).update((p) => p.copyWith(translation: !on)),
                color: t.ink.withValues(alpha: 0.4),
                selectedIcon: Icon(Icons.translate_rounded, color: t.ink),
                icon: const Icon(Icons.translate_rounded),
              ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 2),
              child: FilledButton.icon(
                onPressed: onListen,
                style: FilledButton.styleFrom(
                  backgroundColor: t.accent.withValues(alpha: 0.32),
                  foregroundColor: t.ink,
                  elevation: 0,
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

BoxDecoration _calm(WaqtTokens t, double radius) => recitationSurface(t, radius);
