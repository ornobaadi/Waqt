import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../data/sources/hadith_db.dart';
import '../../data/sources/hisn.dart';
import '../../data/user/reading_prefs.dart';
import '../../l10n/app_localizations.dart';

/// One chapter of Hisn al-Muslim, read top to bottom.
class HisnChapterScreen extends ConsumerWidget {
  const HisnChapterScreen({super.key, required this.number});
  final int number;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = WaqtTokens.of(context);
    final book = ref.watch(hisnProvider).value;
    final ch = book?.chapter(number);
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      backgroundColor: t.ground,
      appBar: AppBar(
        backgroundColor: t.ground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: t.ink,
        title: Text(
          ch == null ? '' : (ar ? ch.ar : ch.en),
          style: WaqtText.titleSmall.copyWith(color: t.ink),
          maxLines: 2,
        ),
      ),
      body: book == null
          ? const SizedBox()
          : ListView(
              padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, WaqtSpace.x2, WaqtSpace.screen, WaqtSpace.x12),
              children: [
                for (final d in book.inChapter(number)) ...[HisnDuaCard(dua: d), const SizedBox(height: WaqtSpace.x4)],
                _Attribution(text: AppLocalizations.of(context).sourceHisn),
              ],
            ),
    );
  }
}

/// A dua as the book gives it: Arabic, how to say it, what it means, and
/// where it comes from.
class HisnDuaCard extends ConsumerWidget {
  const HisnDuaCard({super.key, required this.dua, this.chapter});
  final HisnDua dua;

  /// Shown in search results, where the situation is not obvious.
  final String? chapter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rp = ref.watch(readingPrefsProvider);
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    return Container(
      padding: const EdgeInsets.all(WaqtSpace.x5),
      decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(WaqtRadii.card)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (chapter != null) ...[
            Text(chapter!.toUpperCase(), style: WaqtText.overline.copyWith(color: t.inkMuted)),
            const SizedBox(height: WaqtSpace.x3),
          ],
          if (dua.context != null && dua.context!.isNotEmpty) ...[
            Text(dua.context!, style: WaqtText.label.copyWith(color: t.inkMuted)),
            const SizedBox(height: WaqtSpace.x3),
          ],
          SelectableText(
            dua.arabic,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: ReadingPrefs.scaled(WaqtText.arabic.copyWith(color: t.ink, fontSize: 24, height: 1.85), rp.arabic),
          ),
          if (dua.transliteration case final tr? when tr.isNotEmpty) ...[
            const SizedBox(height: WaqtSpace.x3),
            Text(
              tr,
              style: WaqtText.body.copyWith(color: t.inkMuted, fontStyle: FontStyle.italic),
            ),
          ],
          if (dua.translation case final en? when en.isNotEmpty) ...[
            const SizedBox(height: WaqtSpace.x3),
            Text(en, style: ReadingPrefs.scaled(WaqtText.body.copyWith(color: t.ink), rp.meaning)),
          ],
          const SizedBox(height: WaqtSpace.x4),
          Divider(height: 1, color: t.hairline),
          const SizedBox(height: WaqtSpace.x3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  [l.hisnNumber(dua.number), if (dua.reference != null) dua.reference!].join('  ·  '),
                  style: WaqtText.caption.copyWith(color: t.inkMuted),
                ),
              ),
              _IconAction(
                icon: Icons.copy_rounded,
                tooltip: l.copyText,
                onTap: () => _copy(context, [dua.arabic, ?dua.translation, ?dua.reference].join('\n\n')),
              ),
              if (dua.url != null)
                _IconAction(
                  icon: Icons.open_in_new_rounded,
                  tooltip: l.openSource,
                  onTap: () => launchUrl(Uri.parse(dua.url!), mode: LaunchMode.externalApplication),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A hadith search result; tap for the whole text.
class HadithTile extends StatelessWidget {
  const HadithTile({super.key, required this.hadith});
  final Hadith hadith;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    final ar = Localizations.localeOf(context).languageCode == 'ar' || hadith.english.isEmpty;
    return Material(
      color: t.surface,
      borderRadius: BorderRadius.circular(WaqtRadii.strip),
      child: InkWell(
        borderRadius: BorderRadius.circular(WaqtRadii.strip),
        onTap: () => showHadithSheet(context, hadith),
        child: Padding(
          padding: const EdgeInsets.all(WaqtSpace.x4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      hadith.reference,
                      style: WaqtText.label.copyWith(color: t.ink, fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (hadith.grade case final g? when g.isNotEmpty) _Grade(g),
                ],
              ),
              const SizedBox(height: WaqtSpace.x2),
              Text(
                ar ? hadith.arabic : hadith.english,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textDirection: ar ? TextDirection.rtl : null,
                style: ar
                    ? WaqtText.arabic.copyWith(color: t.ink, fontSize: 18, height: 1.7)
                    : WaqtText.body.copyWith(color: t.ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showHadithSheet(BuildContext context, Hadith h) {
  final t = WaqtTokens.of(context);
  final l = AppLocalizations.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: t.ground,
    builder: (ctx) => Consumer(
      builder: (ctx, ref, _) {
        final rp = ref.watch(readingPrefsProvider);
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          builder: (ctx, scroll) => ListView(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, 0, WaqtSpace.screen, WaqtSpace.x12),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(h.reference, style: WaqtText.titleSmall.copyWith(color: t.ink)),
                  ),
                  if (h.grade case final g? when g.isNotEmpty) _Grade(g),
                ],
              ),
              const SizedBox(height: WaqtSpace.x5),
              if (h.arabic.isNotEmpty)
                SelectableText(
                  h.arabic,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: ReadingPrefs.scaled(
                    WaqtText.arabic.copyWith(color: t.ink, fontSize: 22, height: 1.9),
                    rp.arabic,
                  ),
                ),
              if (h.english.isNotEmpty) ...[
                const SizedBox(height: WaqtSpace.x5),
                SelectableText(
                  h.english,
                  style: ReadingPrefs.scaled(WaqtText.body.copyWith(color: t.ink, height: 1.55), rp.meaning),
                ),
              ],
              const SizedBox(height: WaqtSpace.x5),
              Wrap(
                spacing: WaqtSpace.x2,
                children: [
                  OutlinedButton.icon(
                    onPressed: () =>
                        _copy(ctx, [h.arabic, h.english, h.reference].where((s) => s.isNotEmpty).join('\n\n')),
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: Text(l.copyText),
                  ),
                  if (h.url != null)
                    OutlinedButton.icon(
                      onPressed: () => launchUrl(Uri.parse(h.url!), mode: LaunchMode.externalApplication),
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: Text(l.openSource),
                    ),
                ],
              ),
              const SizedBox(height: WaqtSpace.x4),
              _Attribution(text: l.sourceHadith),
            ],
          ),
        );
      },
    ),
  );
}

void _copy(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).copied)));
}

class _Grade extends StatelessWidget {
  const _Grade(this.grade);
  final String grade;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: t.accent.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(99)),
      child: Text(
        grade,
        style: WaqtText.caption.copyWith(color: t.ink, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.tooltip, required this.onTap});
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onTap,
    visualDensity: VisualDensity.compact,
    icon: Icon(icon, size: 18, color: WaqtTokens.of(context).inkMuted),
  );
}

class _Attribution extends StatelessWidget {
  const _Attribution({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x1, vertical: WaqtSpace.x2),
    child: Text(text, style: WaqtText.caption.copyWith(color: WaqtTokens.of(context).inkMuted)),
  );
}

/// Offers the hadith library: what it is, its size, one button. Shows
/// progress while downloading and a retry if it failed.
class HadithDownloadCard extends ConsumerWidget {
  const HadithDownloadCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final s = ref.watch(hadithInstallProvider);
    final mb = (HadithDb.downloadBytes / 1e6).toStringAsFixed(0);
    final busy = s.status == HadithLibrary.downloading || s.status == HadithLibrary.checking;
    return Container(
      padding: const EdgeInsets.all(WaqtSpace.x5),
      decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(WaqtRadii.card)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_rounded, color: t.ink),
              const SizedBox(width: WaqtSpace.x2),
              Expanded(
                child: Text(l.hadithLibraryTitle, style: WaqtText.titleSmall.copyWith(color: t.ink)),
              ),
            ],
          ),
          const SizedBox(height: WaqtSpace.x2),
          Text(l.hadithLibraryBody, style: WaqtText.body.copyWith(color: t.inkMuted)),
          const SizedBox(height: WaqtSpace.x4),
          if (s.status == HadithLibrary.downloading) ...[
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
            if (s.status == HadithLibrary.failed) ...[
              Text(l.hadithLibraryFailed, style: WaqtText.label.copyWith(color: t.ink)),
              const SizedBox(height: WaqtSpace.x2),
            ],
            FilledButton.icon(
              onPressed: busy ? null : () => ref.read(hadithInstallProvider.notifier).download(),
              style: FilledButton.styleFrom(
                backgroundColor: t.ink,
                foregroundColor: t.ground,
                minimumSize: const Size.fromHeight(WaqtSpace.minTouch),
                shape: const StadiumBorder(),
              ),
              icon: const Icon(Icons.download_rounded),
              label: Text(s.status == HadithLibrary.failed ? l.hadithLibraryRetry : l.hadithLibraryDownload(mb)),
            ),
          ],
          const SizedBox(height: WaqtSpace.x3),
          Text(l.hadithLibraryNote, style: WaqtText.caption.copyWith(color: t.inkMuted)),
        ],
      ),
    );
  }
}
