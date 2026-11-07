import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../data/content/content_repository.dart';
import '../../data/sources/days.dart';
import '../../domain/moments/moment.dart';
import '../../l10n/app_localizations.dart';
import '../common/labels.dart';
import '../duas/dua_sheet.dart';
import '../duas/library_views.dart';

DateFormat clockFormat(BuildContext context) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  if (MediaQuery.alwaysUse24HourFormatOf(context)) return DateFormat.Hm(locale);
  // Where the day-period is a single letter ("p 5:17"), plain h:mm reads better.
  return DateFormat('a', locale).format(DateTime(2000)).trim().length > 1
      ? DateFormat.jm(locale)
      : DateFormat('h:mm', locale);
}

/// The hero: the highest-priority moment that is more specific than the
/// waqt itself. Content (duas, actions with references) arrives in Phase 3;
/// until then the card names the moment and how long it lasts.
class RightNowCard extends StatelessWidget {
  const RightNowCard({
    super.key,
    required this.moment,
    required this.now,
    this.items = const [],
    this.sourced = const [],
    this.onSourced,
  });
  final Moment moment;
  final DateTime now;

  /// Items tied to a hadith in the bundled collections, shown before any
  /// unreviewed content. Tapping one calls [onSourced].
  final List<DayItem> sourced;
  final void Function(DayItem)? onSourced;

  /// Linked content (reviewed only in release builds). At most three show.
  final List<ContentItem> items;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final w = moment.window;
    final progress = (now.difference(w.start).inSeconds / w.length.inSeconds).clamp(0.0, 1.0);
    final ink = t.heroInk;

    return Semantics(
      container: true,
      label: '${l.rightNow}: ${l.moment(moment)}, ${l.until(clockFormat(context).format(w.end))}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(WaqtSpace.x5, WaqtSpace.x5, WaqtSpace.x5, WaqtSpace.x5),
        decoration: BoxDecoration(
          color: t.heroSurface,
          borderRadius: BorderRadius.circular(WaqtRadii.card),
          boxShadow: t.hero,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(l.rightNow.toUpperCase(), style: WaqtText.overline.copyWith(color: t.accent)),
                const Spacer(),
                Text(
                  l.until(clockFormat(context).format(w.end)),
                  style: WaqtText.caption.copyWith(color: ink.withValues(alpha: 0.72)),
                ),
              ],
            ),
            const SizedBox(height: WaqtSpace.x3),
            Text(l.moment(moment), style: WaqtText.title.copyWith(color: ink)),
            if (moment.kind == MomentKind.restricted) ...[
              const SizedBox(height: WaqtSpace.x3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: ink.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(l.kindRestricted, style: WaqtText.caption.copyWith(color: ink)),
              ),
            ],
            if (sourced.isNotEmpty) ...[
              const SizedBox(height: WaqtSpace.x3),
              for (final i in sourced.take(4)) _SourcedRow(item: i, onTap: () => onSourced?.call(i)),
            ] else if (items.isNotEmpty) ...[
              const SizedBox(height: WaqtSpace.x4),
              for (final item in items.take(3)) _ItemRow(item: item),
            ],
            if (moment.id == MomentId.afterSalah) ...[
              const SizedBox(height: WaqtSpace.x3),
              TextButton.icon(
                onPressed: () => context.push('/counter'),
                style: TextButton.styleFrom(
                  foregroundColor: ink,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(48, 44),
                ),
                icon: Icon(Icons.radio_button_checked_rounded, size: 18, color: t.accent),
                label: Text(
                  l.counterOpen,
                  style: WaqtText.label.copyWith(color: ink, fontWeight: FontWeight.w600),
                ),
              ),
            ],
            const SizedBox(height: WaqtSpace.x5),
            // How much of the window has passed. Honest, glanceable, no copy.
            LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              borderRadius: BorderRadius.circular(2),
              backgroundColor: ink.withValues(alpha: 0.14),
              color: t.accent,
            ),
          ],
        ),
      ),
    );
  }
}

/// What to do now, and the hadith it comes from.
class _SourcedRow extends StatelessWidget {
  const _SourcedRow({required this.item, required this.onTap});
  final DayItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    final ink = t.heroInk;
    return Semantics(
      button: true,
      label: item.title(Localizations.localeOf(context).languageCode),
      excludeSemantics: true,
      // A flat row under a hairline, not a box inside the card: nested
      // rounded boxes never share the card's curve at this inset.
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: WaqtSpace.x3),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: ink.withValues(alpha: 0.12))),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title(Localizations.localeOf(context).languageCode),
                      style: WaqtText.bodyStrong.copyWith(color: ink),
                    ),
                    const SizedBox(height: 2),
                    HeSourceText(
                      id: item.he,
                      style: WaqtText.caption.copyWith(color: t.accent),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: ink.withValues(alpha: 0.4)),
            ],
          ),
        ),
      ),
    );
  }
}

/// One action row: what to do, and where it comes from.
class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});
  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final ink = t.heroInk;
    final lang = Localizations.localeOf(context).languageCode;
    return Semantics(
      label: '${item.titleFor(lang)}. ${l.reference(item.source)}${item.approved ? '' : '. ${l.draftNotice}'}',
      excludeSemantics: true,
      button: true,
      onTap: () => showDuaSheet(context, item),
      child: GestureDetector(
        onTap: () => showDuaSheet(context, item),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: WaqtSpace.x3),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: ink.withValues(alpha: 0.12))),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.titleFor(lang), style: WaqtText.bodyStrong.copyWith(color: ink)),
              const SizedBox(height: WaqtSpace.x2),
              Wrap(
                spacing: WaqtSpace.x2,
                runSpacing: WaqtSpace.x1,
                children: [
                  _Chip(text: l.reference(item.source), fg: ink, border: ink.withValues(alpha: 0.3)),
                  if (!item.approved)
                    _Chip(
                      text: (item.status == ReviewStatus.checked ? l.statusChecked : l.statusDraft).toUpperCase(),
                      fg: const Color(0xFF14110C),
                      fill: t.accent,
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

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.fg, this.border, this.fill});
  final String text;
  final Color fg;
  final Color? border;
  final Color? fill;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
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

class ComingUp extends StatelessWidget {
  const ComingUp({super.key, required this.moments});
  final List<Moment> moments;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final fmt = clockFormat(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: WaqtSpace.x1, bottom: WaqtSpace.x2),
          child: Text(l.comingUp.toUpperCase(), style: WaqtText.overline.copyWith(color: t.inkMuted)),
        ),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < moments.length; i++) ...[
                if (i > 0) const SizedBox(width: WaqtSpace.x2),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(WaqtSpace.x4),
                    decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(WaqtRadii.strip)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: moments[i].kind == MomentKind.restricted ? t.inkMuted : t.accent,
                              ),
                            ),
                            const SizedBox(width: WaqtSpace.x2),
                            Flexible(
                              child: Text(
                                l.startsAt(fmt.format(moments[i].window.start)),
                                style: WaqtText.caption.copyWith(color: t.inkMuted),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: WaqtSpace.x2),
                        Text(
                          l.moment(moments[i]),
                          style: WaqtText.bodyStrong.copyWith(color: t.ink),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (moments.length == 1) const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ],
    );
  }
}
