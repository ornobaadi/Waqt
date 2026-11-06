import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/flavor.dart';
import '../../core/diagnostics/reports.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../data/content/content_repository.dart';
import '../../data/user/user_prefs.dart';
import '../../l10n/app_localizations.dart';
import '../common/labels.dart';

enum Verdict { correct, wrong }

typedef CheckNote = ({Verdict verdict, String note});

/// Every item, drafts included, whatever test mode shows on Home.
final _allContentProvider = FutureProvider<ContentBundle>((ref) async {
  return ContentBundle.parse(await rootBundle.loadString('assets/content/content.json'), includeUnreviewed: true);
});

/// The checker's answers, kept on the phone until sent.
class CheckerNotes extends Notifier<Map<String, CheckNote>> {
  static const _key = 'checker.v1';

  @override
  Map<String, CheckNote> build() {
    final raw = ref.read(sharedPrefsProvider).getString(_key);
    if (raw == null) return {};
    try {
      return (jsonDecode(raw) as Map<String, Object?>).map((k, v) {
        final m = v! as Map<String, Object?>;
        return MapEntry(k, (verdict: Verdict.values.byName(m['v']! as String), note: m['n']! as String));
      });
    } on Object {
      return {};
    }
  }

  void set(String id, Verdict v, String note) {
    state = {...state, id: (verdict: v, note: note)};
    ref
        .read(sharedPrefsProvider)
        .setString(_key, jsonEncode(state.map((k, v) => MapEntry(k, {'v': v.verdict.name, 'n': v.note}))));
  }
}

final checkerNotesProvider = NotifierProvider<CheckerNotes, Map<String, CheckNote>>(CheckerNotes.new);

/// A person opens each reference at its source, confirms or corrects it, and
/// emails the results. Nothing here changes what users see: the YAML is
/// updated from the email, and the item then goes to a scholar.
class CheckerScreen extends ConsumerWidget {
  const CheckerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final bundle = ref.watch(_allContentProvider).value;
    final notes = ref.watch(checkerNotesProvider);
    final items = bundle?.items.where((i) => !i.approved).toList() ?? const <ContentItem>[];
    final done = items.where((i) => notes.containsKey(i.id)).length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: t.ground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: t.ink,
        title: Text(l.checkerTitle, style: WaqtText.titleSmall.copyWith(color: t.ink)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, 0, WaqtSpace.screen, WaqtSpace.x12),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: WaqtSpace.x3, horizontal: WaqtSpace.x1),
            child: Text(l.checkerProgress(done, items.length), style: WaqtText.label.copyWith(color: t.inkMuted)),
          ),
          for (final i in items) ...[
            _ItemCard(item: i, lang: lang, note: notes[i.id]),
            const SizedBox(height: WaqtSpace.x3),
          ],
          const SizedBox(height: WaqtSpace.x3),
          FilledButton(
            onPressed: notes.isEmpty || bundle == null ? null : () => _send(bundle, notes),
            style: FilledButton.styleFrom(
              backgroundColor: t.ink,
              foregroundColor: t.ground,
              minimumSize: const Size.fromHeight(WaqtSpace.minTouch),
              shape: const StadiumBorder(),
            ),
            child: Text(l.checkerSend),
          ),
        ],
      ),
    );
  }

  static Future<void> _send(ContentBundle b, Map<String, CheckNote> notes) {
    final lines = [
      for (final MapEntry(:key, :value) in notes.entries)
        if (b.item(key) case final i?)
          '${value.verdict == Verdict.correct ? 'OK   ' : 'WRONG'} ${i.id} · ${i.source.collection} ${i.source.number}'
              '${value.note.isEmpty ? '' : '\n      ${value.note}'}',
      '',
      'Content ${b.version} · App ${AppConfig.version}',
    ];
    return launchUrl(Reports.issueUri('Reference check', lines.join('\n')), mode: LaunchMode.externalApplication);
  }
}

class _ItemCard extends ConsumerWidget {
  const _ItemCard({required this.item, required this.lang, required this.note});
  final ContentItem item;
  final String lang;
  final CheckNote? note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final v = note?.verdict;
    final text = note?.note ?? '';
    return Container(
      padding: const EdgeInsets.all(WaqtSpace.x4),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(WaqtRadii.strip),
        border: Border.all(
          width: 1.5,
          color: switch (v) {
            Verdict.correct => t.accent,
            Verdict.wrong => t.ink.withValues(alpha: 0.6),
            null => Colors.transparent,
          },
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.titleFor(lang), style: WaqtText.bodyStrong.copyWith(color: t.ink)),
          const SizedBox(height: WaqtSpace.x1),
          Text(l.reference(item.source), style: WaqtText.label.copyWith(color: t.inkMuted)),
          if (text.isNotEmpty) ...[
            const SizedBox(height: WaqtSpace.x2),
            Text(text, style: WaqtText.caption.copyWith(color: t.ink)),
          ],
          const SizedBox(height: WaqtSpace.x3),
          Wrap(
            spacing: WaqtSpace.x2,
            runSpacing: WaqtSpace.x2,
            children: [
              OutlinedButton(
                onPressed: () => launchUrl(Uri.parse(item.source.url), mode: LaunchMode.externalApplication),
                child: Text(l.checkerOpen),
              ),
              FilledButton.tonal(
                onPressed: () => ref.read(checkerNotesProvider.notifier).set(item.id, Verdict.correct, ''),
                child: Text(v == Verdict.correct ? '✓ ${l.checkerCorrect}' : l.checkerCorrect),
              ),
              TextButton(onPressed: () => _wrong(context, ref), child: Text(l.checkerWrong)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _wrong(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final c = TextEditingController(text: note?.note);
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.checkerWrong),
        content: TextField(
          controller: c,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(hintText: l.checkerWrongHint),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, c.text.trim()),
            child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
          ),
        ],
      ),
    );
    c.dispose();
    if (text != null) ref.read(checkerNotesProvider.notifier).set(item.id, Verdict.wrong, text);
  }
}
