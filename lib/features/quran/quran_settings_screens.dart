import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../core/widgets/waqt_widgets.dart';
import '../../data/quran/quran.dart';
import '../../data/quran/quran_prefs.dart';
import '../../data/quran/quran_translation.dart';
import '../../data/quran/recitation.dart';
import '../../data/quran/recitation_downloads.dart';
import '../../data/sources/he_library.dart' show contentLangProvider;
import '../../l10n/app_localizations.dart';
import 'quran_screen.dart' show NumberBadge, quranFont, surahName;

Scaffold _page(BuildContext context, String title, List<Widget> children) {
  final t = WaqtTokens.of(context);
  return Scaffold(
    backgroundColor: t.ground,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: t.ink,
      title: Text(title, style: WaqtText.bodyStrong.copyWith(color: t.ink)),
    ),
    body: ListView(
      padding: EdgeInsets.fromLTRB(
        WaqtSpace.screen,
        0,
        WaqtSpace.screen,
        WaqtSpace.x12 + MediaQuery.paddingOf(context).bottom,
      ),
      children: children,
    ),
  );
}

/// A row with a title, a hint and a switch; the whole row toggles it.
class _SwitchRow extends StatelessWidget {
  const _SwitchRow({required this.title, this.hint, required this.value, required this.onChanged});
  final String title;
  final String? hint;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    return MergeSemantics(
      child: InkWell(
        borderRadius: BorderRadius.circular(WaqtRadii.row),
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x3, vertical: WaqtSpace.x2),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: WaqtText.bodyStrong.copyWith(color: t.ink)),
                    if (hint != null) Text(hint!, style: WaqtText.caption.copyWith(color: t.inkMuted)),
                  ],
                ),
              ),
              Switch(value: value, onChanged: onChanged, activeTrackColor: t.ink, activeThumbColor: t.ground),
            ],
          ),
        ),
      ),
    );
  }
}

/// Board 09: how the Quran reads and sounds.
class QuranSettingsScreen extends ConsumerWidget {
  const QuranSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final p = ref.watch(quranPrefsProvider);
    final set = ref.read(quranPrefsProvider.notifier).update;
    final q = ref.watch(quranTextProvider);
    final lang = ref.watch(contentLangProvider);
    final info = quranTranslations[lang];
    final install = ref.watch(quranTranslationInstallProvider);
    final downloads = ref.watch(recitationDownloadsProvider);
    return _page(context, l.quranSettings, [
      // A live preview of the size.
      Container(
        margin: const EdgeInsets.only(top: WaqtSpace.x2),
        padding: const EdgeInsets.all(WaqtSpace.x4),
        decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(WaqtRadii.card)),
        child: Text(
          q == null ? '' : q.marked(1, 1),
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontFamily: q == null ? WaqtFonts.quran : quranFont(q),
            fontSize: 27 * p.arabicScale,
            height: 1.9,
            color: t.ink,
          ),
        ),
      ),
      SectionLabel(l.quranReading),
      RowGroup(
        children: [
          Padding(
            padding: const EdgeInsets.all(WaqtSpace.x3),
            child: Row(
              children: [
                Expanded(
                  child: Text(l.quranScript, style: WaqtText.bodyStrong.copyWith(color: t.ink)),
                ),
                SizedBox(
                  width: 220,
                  child: PillSwitch(
                    labels: [l.quranUthmani, l.quranIndoPak],
                    selected: p.indoPak ? 1 : 0,
                    onSelect: (i) => set((x) => x.copyWith(indoPak: i == 1)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(WaqtSpace.x3, WaqtSpace.x3, WaqtSpace.x3, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.quranArabicSize, style: WaqtText.bodyStrong.copyWith(color: t.ink)),
                // Small A to big A, as on board 09: which way is bigger, at a glance.
                Row(
                  children: [
                    ExcludeSemantics(
                      child: Text('A', style: WaqtText.label.copyWith(color: t.inkMuted)),
                    ),
                    Expanded(
                      child: Slider(
                        value: p.arabicScale,
                        min: 0.8,
                        max: 1.8,
                        divisions: 10,
                        label: '${(p.arabicScale * 100).round()}%',
                        semanticFormatterCallback: (v) => '${(v * 100).round()}%',
                        activeColor: t.ink,
                        onChanged: (v) => set((x) => x.copyWith(arabicScale: v)),
                      ),
                    ),
                    ExcludeSemantics(
                      child: Text('A', style: WaqtText.titleSmall.copyWith(color: t.ink, fontSize: 24)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (info != null)
            _SwitchRow(
              title: l.quranShowTranslation,
              hint: install.status == QuranTranslationStatus.ready
                  ? info.translator
                  : l.quranTranslationBody(info.translator),
              value: p.translation,
              onChanged: (v) => set((x) => x.copyWith(translation: v)),
            ),
          _SwitchRow(
            title: l.quranTranslit,
            hint: l.quranTranslitHint,
            value: p.transliteration,
            onChanged: (v) => set((x) => x.copyWith(transliteration: v)),
          ),
          _SwitchRow(
            title: l.quranFollow,
            hint: l.quranFollowHint,
            value: p.follow,
            onChanged: (v) => set((x) => x.copyWith(follow: v)),
          ),
          _SwitchRow(
            title: l.quranKeepAwake,
            hint: l.quranKeepAwakeHint,
            value: p.keepAwake,
            onChanged: (v) => set((x) => x.copyWith(keepAwake: v)),
          ),
        ],
      ),
      if (info != null && install.status != QuranTranslationStatus.ready) ...[
        const SizedBox(height: WaqtSpace.x3),
        _TranslationButton(status: install.status, progress: install.progress),
      ],
      SectionLabel(l.quranListening),
      RowGroup(
        children: [
          RowTile(
            title: l.quranReciter,
            value: reciterById(p.reciter).name,
            onTap: () => context.push('/quran/reciters'),
          ),
          RowTile(
            title: l.quranDownloads,
            subtitle: l.quranStored(downloads.done.length, _size(downloads.bytes)),
            onTap: () => context.push('/quran/downloads'),
          ),
          _SwitchRow(
            title: l.quranMobileData,
            hint: l.quranMobileDataHint,
            value: p.mobileData,
            onChanged: (v) => set((x) => x.copyWith(mobileData: v)),
          ),
        ],
      ),
      const SizedBox(height: WaqtSpace.x5),
      Text(l.quranTextSource, style: WaqtText.caption.copyWith(color: t.inkMuted)),
      Text(l.quranIndoPakSource, style: WaqtText.caption.copyWith(color: t.inkMuted)),
      Text(l.quranTranslitSource, style: WaqtText.caption.copyWith(color: t.inkMuted)),
      Text(l.quranAudioSource, style: WaqtText.caption.copyWith(color: t.inkMuted)),
    ]);
  }
}

class _TranslationButton extends ConsumerWidget {
  const _TranslationButton({required this.status, required this.progress});
  final QuranTranslationStatus status;
  final double progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    if (status == QuranTranslationStatus.downloading) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: LinearProgressIndicator(value: progress, minHeight: 6, color: t.ink),
      );
    }
    return FilledButton.icon(
      onPressed: () => ref.read(quranTranslationInstallProvider.notifier).download(),
      style: FilledButton.styleFrom(
        backgroundColor: t.ink,
        foregroundColor: t.ground,
        minimumSize: const Size.fromHeight(WaqtSpace.minTouch),
        shape: const StadiumBorder(),
      ),
      icon: const Icon(Icons.download_rounded),
      label: Text(status == QuranTranslationStatus.failed ? l.hadithLibraryRetry : l.quranTranslationDownload),
    );
  }
}

String _size(int bytes) => bytes < 1 << 20
    ? '${(bytes / 1024).round()} KB'
    : bytes < 1 << 30
    ? '${(bytes / (1 << 20)).toStringAsFixed(bytes < 10 << 20 ? 1 : 0)} MB'
    : '${(bytes / (1 << 30)).toStringAsFixed(1)} GB';

/// Board 07: pick a voice, after hearing it.
class RecitersScreen extends ConsumerStatefulWidget {
  const RecitersScreen({super.key});

  @override
  ConsumerState<RecitersScreen> createState() => _RecitersScreenState();
}

class _RecitersScreenState extends ConsumerState<RecitersScreen> {
  AudioPlayer? _sample;
  String? _playing;

  @override
  void dispose() {
    unawaited(_sample?.dispose());
    super.dispose();
  }

  Future<void> _toggleSample(Reciter r) async {
    final p = _sample ??= AudioPlayer();
    if (_playing == r.id) {
      await p.stop();
      setState(() => _playing = null);
      return;
    }
    setState(() => _playing = r.id);
    try {
      await p.setUrl(r.url(1, 1).toString());
      await p.play();
    } on Object {
      // Offline: nothing to hear.
    }
    if (mounted && _playing == r.id) setState(() => _playing = null);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final chosen = ref.watch(quranPrefsProvider.select((p) => p.reciter));
    return _page(context, l.quranChooseReciter, [
      Text(l.quranReciterIntro, style: WaqtText.body.copyWith(color: t.inkMuted)),
      const SizedBox(height: WaqtSpace.x4),
      RowGroup(
        children: [
          for (final r in reciters)
            Semantics(
              selected: r.id == chosen,
              child: InkWell(
                borderRadius: BorderRadius.circular(WaqtRadii.row),
                onTap: () => ref.read(quranPrefsProvider.notifier).update((p) => p.copyWith(reciter: r.id)),
                child: Padding(
                  padding: const EdgeInsets.all(WaqtSpace.x3),
                  child: Row(
                    children: [
                      Icon(
                        r.id == chosen ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                        color: t.ink,
                      ),
                      const SizedBox(width: WaqtSpace.x3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.name, style: WaqtText.bodyStrong.copyWith(color: t.ink)),
                            Text(
                              r.arabic,
                              textDirection: TextDirection.rtl,
                              style: WaqtText.label.copyWith(color: t.inkMuted),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: l.quranListen,
                        onPressed: () => _toggleSample(r),
                        icon: Icon(
                          _playing == r.id ? Icons.stop_circle_outlined : Icons.play_circle_outline_rounded,
                          color: t.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      SectionLabel(l.quranListening),
      RowGroup(
        children: [
          RowTile(
            title: l.quranDownloads,
            subtitle: l.quranDownloadsHint,
            onTap: () => context.push('/quran/downloads'),
          ),
          _SwitchRow(
            title: l.quranMobileData,
            hint: l.quranMobileDataHint,
            value: ref.watch(quranPrefsProvider.select((p) => p.mobileData)),
            onChanged: (v) => ref.read(quranPrefsProvider.notifier).update((p) => p.copyWith(mobileData: v)),
          ),
        ],
      ),
      const SizedBox(height: WaqtSpace.x5),
      Text(l.quranAudioSource, style: WaqtText.caption.copyWith(color: t.inkMuted)),
    ]);
  }
}

/// Board 08: the chosen reciter's surahs on this phone.
class RecitationDownloadsScreen extends ConsumerWidget {
  const RecitationDownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final q = ref.watch(quranProvider).value;
    final d = ref.watch(recitationDownloadsProvider);
    final dl = ref.read(recitationDownloadsProvider.notifier);
    final reciter = reciterById(ref.watch(quranPrefsProvider.select((p) => p.reciter)));
    final busy = d.running.isNotEmpty || d.queued.isNotEmpty;
    return _page(context, l.quranDownloads, [
      RowGroup(
        children: [
          RowTile(title: l.quranReciter, value: reciter.name, onTap: () => context.push('/quran/reciters')),
          RowTile(title: l.quranOnPhone, value: l.quranStored(d.done.length, _size(d.bytes))),
        ],
      ),
      const SizedBox(height: WaqtSpace.x3),
      if (busy)
        OutlinedButton.icon(
          onPressed: dl.cancel,
          style: OutlinedButton.styleFrom(
            foregroundColor: t.ink,
            side: BorderSide(color: t.hairline),
            minimumSize: const Size.fromHeight(WaqtSpace.minTouch),
            shape: const StadiumBorder(),
          ),
          icon: const Icon(Icons.close_rounded),
          label: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        )
      else if (d.done.length < 114)
        FilledButton.icon(
          onPressed: () => dl.add([for (var s = 1; s <= 114; s++) s]),
          style: FilledButton.styleFrom(
            backgroundColor: t.ink,
            foregroundColor: t.ground,
            minimumSize: const Size.fromHeight(WaqtSpace.minTouch),
            shape: const StadiumBorder(),
          ),
          icon: const Icon(Icons.download_rounded),
          label: Text(l.quranDownloadAll),
        ),
      if (d.blocked) ...[
        const SizedBox(height: WaqtSpace.x2),
        Text(l.quranWaitingWifi, style: WaqtText.label.copyWith(color: t.ink)),
      ],
      const SizedBox(height: WaqtSpace.x3),
      Text(l.quranDownloadsNote, style: WaqtText.caption.copyWith(color: t.inkMuted)),
      const SizedBox(height: WaqtSpace.x4),
      if (q != null)
        for (final s in q.surahs) ...[
          _DownloadRow(
            surah: s,
            done: d.done.contains(s.n),
            progress: d.running[s.n],
            queued: d.queued.contains(s.n),
            onDownload: () => dl.add([s.n]),
            onRemove: () => dl.remove(s.n),
          ),
          Divider(height: 1, color: t.hairline),
        ],
    ]);
  }
}

class _DownloadRow extends StatelessWidget {
  const _DownloadRow({
    required this.surah,
    required this.done,
    required this.progress,
    required this.queued,
    required this.onDownload,
    required this.onRemove,
  });

  final Surah surah;
  final bool done;
  final double? progress;
  final bool queued;
  final VoidCallback onDownload;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final status = progress != null
        ? '${(progress! * 100).round()}%'
        : done
        ? l.quranDownloaded
        : queued
        ? '…'
        : l.quranStreamsOnline;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 60),
      child: Row(
        children: [
          NumberBadge(surah.n),
          const SizedBox(width: WaqtSpace.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(surahName(context, surah), style: WaqtText.bodyStrong.copyWith(color: t.ink)),
                Text(status, style: WaqtText.caption.copyWith(color: t.inkMuted)),
                if (progress != null) ...[
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(value: progress, minHeight: 3, color: t.ink),
                  ),
                ],
              ],
            ),
          ),
          if (done)
            IconButton(
              tooltip: l.quranRemove,
              onPressed: onRemove,
              icon: Icon(Icons.delete_outline_rounded, color: t.inkMuted),
            )
          else if (progress == null && !queued)
            IconButton(
              tooltip: l.quranDownload,
              onPressed: onDownload,
              icon: Icon(Icons.download_rounded, color: t.ink),
            ),
        ],
      ),
    );
  }
}
