import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../core/widgets/waqt_widgets.dart';
import '../../data/sources/days.dart';
import '../../data/sources/hadeethenc.dart';
import '../../data/sources/he_library.dart';
import '../../data/user/reading_prefs.dart';
import '../../l10n/app_localizations.dart';

/// Book and grade of a hadith, in the reader's language where HadeethEnc has
/// it, else in Arabic: "সহীহ বুখারী ও মুসলিম · সহীহ".
String heSource(HeHadith h, String lang) {
  final m = h.meta(lang);
  return [m?.attribution, m?.grade].nonNulls.where((s) => s.isNotEmpty).join('  ·  ');
}

/// The source line of a bundled hadith, looked up by id.
class HeSourceText extends ConsumerWidget {
  const HeSourceText({super.key, required this.id, required this.style});
  final int id;
  final TextStyle style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final h = ref.watch(heBundleProvider).value?[id];
    if (h == null) return const SizedBox.shrink();
    return Text(heSource(h, Localizations.localeOf(context).languageCode), style: style);
  }
}

/// The source line of a checklist item: its HadeethEnc source, or the
/// reference of an item that is not on HadeethEnc.
class ItemSourceText extends StatelessWidget {
  const ItemSourceText({super.key, required this.item, required this.style});
  final DayItem item;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final r = item.referenced;
    if (r == null) return HeSourceText(id: item.he, style: style);
    return Text(r.referenceIn(Localizations.localeOf(context).languageCode), style: style);
  }
}

/// Opens what a checklist item points to.
Future<void> openItem(BuildContext context, WidgetRef ref, DayItem item) async {
  final r = item.referenced;
  if (r == null) return openHadith(context, ref, item.he);
  await showReferencedSheet(context, r);
}

/// A dua with its own reference: Arabic, how to say it, what it means,
/// who taught it, and where it is narrated.
Future<void> showReferencedSheet(BuildContext context, ReferencedDua d) {
  final lang = Localizations.localeOf(context).languageCode;
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      final t = WaqtTokens.of(ctx);
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, 0, WaqtSpace.screen, WaqtSpace.x6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(d.contextIn(lang), style: WaqtText.body.copyWith(color: t.inkMuted)),
              const SizedBox(height: WaqtSpace.x5),
              Text(
                d.arabic,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: WaqtText.arabic.copyWith(color: t.ink),
              ),
              const SizedBox(height: WaqtSpace.x3),
              Text(
                d.latin,
                textAlign: TextAlign.center,
                style: WaqtText.body.copyWith(color: t.inkMuted, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: WaqtSpace.x3),
              Text(
                d.meaningIn(lang),
                textAlign: TextAlign.center,
                style: WaqtText.bodyStrong.copyWith(color: t.ink),
              ),
              const SizedBox(height: WaqtSpace.x5),
              Text(
                d.referenceIn(lang),
                textAlign: TextAlign.center,
                style: WaqtText.caption.copyWith(color: t.inkMuted),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Opens a bundled hadith by its HadeethEnc id. Everything Home, the
/// checklists and the counter point to is bundled, so this works offline.
Future<void> openHadith(BuildContext context, WidgetRef ref, int id) async {
  final bundle = await ref.read(heBundleProvider.future);
  final h = bundle[id];
  if (h != null && context.mounted) await showHadithSheet(context, h);
}

/// A search or topic result; tap for the whole hadith.
class HadithTile extends StatelessWidget {
  const HadithTile({super.key, required this.hadith});
  final HeHadith hadith;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final tr = hadith.translation(lang);
    final text = tr?.title ?? tr?.text ?? hadith.arabic?.title ?? hadith.arabic?.text ?? '';
    final rtl = tr == null;
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
              Text(
                text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textDirection: rtl ? TextDirection.rtl : null,
                style: rtl
                    ? WaqtText.arabic.copyWith(color: t.ink, fontSize: 18, height: 1.7)
                    : WaqtText.bodyStrong.copyWith(color: t.ink),
              ),
              const SizedBox(height: WaqtSpace.x2),
              Text(heSource(hadith, lang), style: WaqtText.caption.copyWith(color: t.inkMuted)),
            ],
          ),
        ),
      ),
    );
  }
}

/// The whole hadith: Arabic, the translation in the reader's language, its
/// book and grade, and HadeethEnc's explanation, all unchanged and credited.
/// Where HadeethEnc has not translated it into this language yet, the
/// Arabic stands alone with a note; no other language is shown in its place.
Future<void> showHadithSheet(BuildContext context, HeHadith h) {
  final t = WaqtTokens.of(context);
  final l = AppLocalizations.of(context);
  return showModalBottomSheet<void>(
    useRootNavigator: true,
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: t.ground,
    builder: (ctx) => Consumer(
      builder: (ctx, ref, _) {
        final rp = ref.watch(readingPrefsProvider);
        final retrieved = ref.watch(heBundleProvider).value?.retrieved ?? '';
        final lang = Localizations.localeOf(ctx).languageCode;
        final ar = h.arabic;
        final tr = h.translation(lang);
        final meta = h.meta(lang);
        final meaning = ReadingPrefs.scaled(WaqtText.body.copyWith(color: t.ink, height: 1.6), rp.meaning);
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
                    child: Text(
                      meta?.attribution ?? '',
                      style: WaqtText.label.copyWith(color: t.inkMuted, fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (meta?.grade case final g? when g.isNotEmpty) _Grade(g),
                ],
              ),
              const SizedBox(height: WaqtSpace.x5),
              if (ar != null && ar.text.isNotEmpty)
                SelectableText(
                  ar.text,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: ReadingPrefs.scaled(
                    WaqtText.arabic.copyWith(color: t.ink, fontSize: 22, height: 1.9),
                    rp.arabic,
                  ),
                ),
              if (tr != null) ...[
                const SizedBox(height: WaqtSpace.x5),
                SelectableText(tr.text, style: meaning),
              ] else if (lang != 'ar') ...[
                const SizedBox(height: WaqtSpace.x4),
                _Note(l.heNotTranslated(languageSelfName[lang] ?? lang)),
              ],
              if (meta?.explanation case final x? when x.isNotEmpty) ...[
                const SizedBox(height: WaqtSpace.x6),
                Text(l.sheetExplanation.toUpperCase(), style: WaqtText.overline.copyWith(color: t.inkMuted)),
                const SizedBox(height: WaqtSpace.x2),
                SelectableText(
                  x,
                  textDirection: identical(meta, ar) ? TextDirection.rtl : null,
                  style: meaning.copyWith(color: t.inkMuted),
                ),
              ],
              const SizedBox(height: WaqtSpace.x5),
              Wrap(
                spacing: WaqtSpace.x2,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _copy(
                      ctx,
                      [ar?.text, tr?.text, meta?.attribution].nonNulls.where((s) => s.isNotEmpty).join('\n\n'),
                    ),
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: Text(l.copyText),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => launchUrl(h.page(lang), mode: LaunchMode.externalApplication),
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: Text(l.openHadeethEnc),
                  ),
                ],
              ),
              const SizedBox(height: WaqtSpace.x4),
              _Attribution(text: l.sourceHadeethEnc(retrieved)),
            ],
          ),
        );
      },
    ),
  );
}

/// Each language's name for itself, for "not yet in বাংলা".
const languageSelfName = {
  'en': 'English',
  'ur': 'اردو',
  'bn': 'বাংলা',
  'id': 'Bahasa Indonesia',
  'tr': 'Türkçe',
  'fr': 'français',
};

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

class _Note extends StatelessWidget {
  const _Note(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    return Container(
      padding: const EdgeInsets.all(WaqtSpace.x3),
      decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(WaqtRadii.row)),
      child: Text(text, style: WaqtText.label.copyWith(color: t.inkMuted)),
    );
  }
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

/// One HadeethEnc topic: its subtopics, then its hadiths.
class TopicScreen extends ConsumerWidget {
  const TopicScreen({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = WaqtTokens.of(context);
    final lib = ref.watch(heLibraryProvider).value;
    final topic = lib?.topic(id);
    return Scaffold(
      backgroundColor: t.ground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: t.ink,
        title: Text(topic?.title ?? '', style: WaqtText.bodyStrong.copyWith(color: t.ink)),
      ),
      body: lib == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder(
              future: lib.inTopic(id),
              builder: (context, snap) {
                final subs = lib.children(id);
                final hadiths = snap.data ?? const <HeHadith>[];
                return ListView(
                  padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, 0, WaqtSpace.screen, WaqtSpace.x12),
                  children: [
                    if (subs.isNotEmpty)
                      RowGroup(
                        children: [
                          for (final s in subs)
                            RowTile(title: s.title, onTap: () => Navigator.of(context).push(_route(s.id))),
                        ],
                      ),
                    for (final h in hadiths)
                      Padding(
                        padding: const EdgeInsets.only(top: WaqtSpace.x3),
                        child: HadithTile(hadith: h),
                      ),
                  ],
                );
              },
            ),
    );
  }

  static Route<void> _route(int id) => MaterialPageRoute(builder: (_) => TopicScreen(id: id));
}

/// Offers the library in the reader's language: one button, progress while
/// downloading, a retry if it failed.
class HadithDownloadCard extends ConsumerWidget {
  const HadithDownloadCard({super.key, this.inSheet = false});

  /// In a bottom sheet the sheet is the surface: no second card inside it.
  final bool inSheet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final s = ref.watch(hadithInstallProvider);
    final busy = s.status == HadithLibrary.downloading || s.status == HadithLibrary.checking;
    return Container(
      padding: inSheet ? EdgeInsets.zero : const EdgeInsets.all(WaqtSpace.x5),
      decoration: inSheet ? null : BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(WaqtRadii.card)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
              label: Text(s.status == HadithLibrary.failed ? l.hadithLibraryRetry : l.hadithLibraryDownload('3–5')),
            ),
          ],
          const SizedBox(height: WaqtSpace.x3),
          Text(l.hadithLibraryNote, style: WaqtText.caption.copyWith(color: t.inkMuted)),
        ],
      ),
    );
  }
}
