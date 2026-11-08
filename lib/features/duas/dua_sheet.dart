import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/diagnostics/reports.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../data/content/content_repository.dart';
import '../../data/user/reading_prefs.dart';
import '../../l10n/app_localizations.dart';
import '../common/labels.dart';

/// Learn depth (PRD principle 3): the full text, and where it comes from.
Future<void> showDuaSheet(BuildContext context, ContentItem item) {
  final t = WaqtTokens.of(context);
  return showModalBottomSheet<void>(
    useRootNavigator: true,
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: t.ground,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(WaqtRadii.card))),
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, controller) => DuaDetail(item: item, controller: controller),
    ),
  );
}

class DuaDetail extends ConsumerWidget {
  const DuaDetail({super.key, required this.item, this.controller});
  final ContentItem item;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rp = ref.watch(readingPrefsProvider);
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final translation = item.translations[lang] ?? item.translations['en'];
    final s = item.source;
    final host = Uri.tryParse(s.url)?.host.replaceFirst('www.', '') ?? s.url;

    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, 0, WaqtSpace.screen, WaqtSpace.x8),
      children: [
        Wrap(
          spacing: WaqtSpace.x2,
          runSpacing: WaqtSpace.x2,
          children: [
            _Badge(text: l.reference(s), fg: t.ink, border: t.hairline),
            _StatusBadge(status: item.status),
          ],
        ),
        const SizedBox(height: WaqtSpace.x4),
        Text(item.titleFor(lang), style: WaqtText.title.copyWith(color: t.ink)),
        const SizedBox(height: WaqtSpace.x5),
        if (item.arabic != null) ...[
          Container(
            padding: const EdgeInsets.all(WaqtSpace.x5),
            decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(WaqtRadii.strip)),
            child: Text(
              item.arabic!,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: ReadingPrefs.scaled(WaqtText.arabic.copyWith(color: t.ink), rp.arabic),
            ),
          ),
          if (item.transliteration != null) ...[
            const SizedBox(height: WaqtSpace.x4),
            Text(
              item.transliteration!,
              style: ReadingPrefs.scaled(
                WaqtText.body.copyWith(color: t.inkMuted, fontStyle: FontStyle.italic),
                rp.transliteration,
              ),
            ),
          ],
          if (translation != null) ...[
            const SizedBox(height: WaqtSpace.x4),
            Text(
              translation.text,
              style: ReadingPrefs.scaled(WaqtText.body.copyWith(color: t.ink, height: 1.55), rp.meaning),
            ),
            if (translation.translator != null) ...[
              const SizedBox(height: WaqtSpace.x2),
              Text('— ${translation.translator}', style: WaqtText.caption.copyWith(color: t.inkMuted)),
            ],
          ],
        ] else
          Container(
            padding: const EdgeInsets.all(WaqtSpace.x5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(WaqtRadii.strip),
              border: Border.all(color: t.ink.withValues(alpha: 0.16)),
            ),
            child: Text(l.sheetTextPending, style: WaqtText.body.copyWith(color: t.inkMuted)),
          ),
        const SizedBox(height: WaqtSpace.x6),
        Text(l.sheetSource.toUpperCase(), style: WaqtText.overline.copyWith(color: t.inkMuted)),
        const SizedBox(height: WaqtSpace.x2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x4, vertical: WaqtSpace.x2),
          decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(WaqtRadii.strip)),
          child: Column(
            children: [
              _Field(label: l.sheetSource, value: l.reference(s)),
              if (s.narrator != null) _Field(label: l.sheetNarrator, value: s.narrator!),
              if (s.grade != null)
                _Field(
                  label: l.sheetGrade,
                  value: [
                    switch (s.grade) {
                      'sahih' => l.gradeSahih,
                      'hasan' => l.gradeHasan,
                      _ => s.grade!,
                    },
                    if (s.gradedBy != null) s.gradedBy!,
                  ].join(' · '),
                ),
              if (translation?.translator != null) _Field(label: l.sheetTranslation, value: translation!.translator!),
              _Field(label: l.sheetReview, value: _review(l), last: true),
            ],
          ),
        ),
        const SizedBox(height: WaqtSpace.x4),
        SizedBox(
          height: WaqtSpace.minTouch,
          child: OutlinedButton.icon(
            onPressed: () => launchUrl(Uri.parse(s.url), mode: LaunchMode.externalApplication),
            icon: Icon(Icons.open_in_new_rounded, size: 18, color: t.ink),
            label: Text(
              l.sheetOpen(host),
              style: WaqtText.label.copyWith(color: t.ink, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              shape: const StadiumBorder(),
              side: BorderSide(color: t.ink.withValues(alpha: 0.25)),
            ),
          ),
        ),
        const SizedBox(height: WaqtSpace.x2),
        Center(
          child: TextButton.icon(
            onPressed: () => Reports.reportContent(item),
            style: TextButton.styleFrom(foregroundColor: t.inkMuted, minimumSize: const Size(48, 48)),
            icon: Icon(Icons.flag_outlined, size: 18, color: t.inkMuted),
            label: Text(l.reportContent, style: WaqtText.label.copyWith(color: t.inkMuted)),
          ),
        ),
      ],
    );
  }

  String _review(AppLocalizations l) {
    // Names are recorded in content YAML; Phase 3 bundle carries status only
    // to the app, which is all users need to judge trust.
    return switch (item.status) {
      ReviewStatus.approved => l.statusApproved,
      ReviewStatus.checked => l.statusChecked,
      ReviewStatus.draft => l.draftNotice,
    };
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value, this.last = false});
  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: WaqtSpace.x3),
      decoration: BoxDecoration(
        border: last ? null : Border(bottom: BorderSide(color: t.hairline)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(label, style: WaqtText.label.copyWith(color: t.inkMuted)),
          ),
          Expanded(
            child: Text(
              value,
              style: WaqtText.label.copyWith(color: t.ink, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.fg, this.border, this.fill});
  final String text;
  final Color fg;
  final Color? border;
  final Color? fill;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: fill,
      border: border == null ? null : Border.all(color: border!),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      text,
      style: WaqtText.caption.copyWith(color: fg, fontWeight: FontWeight.w600),
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final ReviewStatus status;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    return switch (status) {
      ReviewStatus.approved => _Badge(text: l.statusApproved, fg: t.ground, fill: t.ink),
      ReviewStatus.checked => _Badge(text: l.statusChecked.toUpperCase(), fg: const Color(0xFF14110C), fill: t.accent),
      ReviewStatus.draft => _Badge(text: l.statusDraft.toUpperCase(), fg: const Color(0xFF14110C), fill: t.accent),
    };
  }
}
