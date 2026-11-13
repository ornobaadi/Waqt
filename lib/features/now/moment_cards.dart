import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../core/utils/digits.dart';
import '../../data/content/content_repository.dart';
import '../../data/sources/days.dart';
import '../../data/sources/duas.dart';
import '../../domain/moments/moment.dart';
import '../../l10n/app_localizations.dart';
import '../common/labels.dart';
import '../duas/dua_sheet.dart';
import '../duas/library_views.dart';
import 'collapse.dart';

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
class RightNowCard extends ConsumerWidget {
  const RightNowCard({
    super.key,
    required this.moment,
    required this.now,
    this.items = const [],
    this.sourced = const [],
    this.onSourced,
    this.tabs,
  });
  final Moment moment;

  /// When several moments are happening at once: one tab each, on top.
  final Widget? tabs;
  final DateTime now;

  /// Items tied to a hadith in the bundled collections, shown before any
  /// unreviewed content. Tapping one calls [onSourced].
  final List<DayItem> sourced;
  final void Function(DayItem)? onSourced;

  /// Linked content (reviewed only in release builds). At most three show.
  final List<ContentItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final w = moment.window;
    final foldId = 'moment.${moment.id.name}';
    final open = !ref.watch(collapsedCardsProvider.select((s) => s.contains(foldId)));
    final progress = (now.difference(w.start).inSeconds / w.length.inSeconds).clamp(0.0, 1.0);
    final ink = t.heroInk;

    return Semantics(
      container: true,
      label: '${l.rightNow}: ${l.moment(moment)}, ${l.until(clockFormat(context).format(w.end))}',
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
            if (tabs case final tabs?) ...[tabs, const SizedBox(height: WaqtSpace.x4)],
            // The header folds the card away, or opens it again.
            Semantics(
              button: true,
              expanded: open,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => ref.read(collapsedCardsProvider.notifier).toggle(foldId),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l.rightNow,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: WaqtText.label.copyWith(color: t.accent, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Text(
                          l.until(clockFormat(context).format(w.end)),
                          style: WaqtText.caption.copyWith(color: ink.withValues(alpha: 0.72)),
                        ),
                        const SizedBox(width: WaqtSpace.x1),
                        FoldChevron(open: open, color: ink.withValues(alpha: 0.6)),
                      ],
                    ),
                    const SizedBox(height: WaqtSpace.x3),
                    // With tabs, the selected tab already names the moment (board 01).
                    if (tabs == null) ...[
                      Text(l.moment(moment), style: WaqtText.title.copyWith(color: ink, fontSize: 24)),
                      const SizedBox(height: WaqtSpace.x3),
                    ],
                    // How much of the window has passed, right under its name.
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 2,
                      borderRadius: BorderRadius.circular(1),
                      backgroundColor: ink.withValues(alpha: 0.12),
                      color: t.accent,
                    ),
                  ],
                ),
              ),
            ),
            FoldBody(
              open: open,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    for (final (k, i) in sourced.take(4).indexed)
                      _SourcedRow(item: i, first: k == 0, onTap: () => onSourced?.call(i)),
                  ] else if (items.isNotEmpty) ...[
                    const SizedBox(height: WaqtSpace.x4),
                    for (final item in items.take(3)) _ItemRow(item: item),
                  ],
                  // The words themselves, one per page: what to say right now.
                  if (DuaBook.taskFor(moment.id) case final task?)
                    if (ref.watch(duaBookProvider).value?.forTask(task).length case final n? when n > 0) ...[
                      const SizedBox(height: WaqtSpace.x3),
                      FilledButton.icon(
                        onPressed: () => context.push('/dua/$task/0'),
                        style: FilledButton.styleFrom(
                          backgroundColor: t.accent,
                          foregroundColor: t.heroSurface,
                          minimumSize: const Size(48, WaqtSpace.minTouch),
                          shape: const StadiumBorder(),
                        ),
                        icon: const Icon(Icons.record_voice_over_outlined, size: 18),
                        label: Text(
                          '${l.momentSayDuas} · ${LocaleDigits(Localizations.localeOf(context).toLanguageTag())(n)}',
                          style: WaqtText.label.copyWith(fontWeight: FontWeight.w700, color: t.heroSurface),
                        ),
                      ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Several moments at once (the last hour of Friday inside "After Asr"):
/// one card with a tab for each, newest first, instead of a stack of cards.
class RightNowTabs extends StatefulWidget {
  const RightNowTabs({super.key, required this.moments, required this.now, required this.sourced, this.onSourced});
  final List<Moment> moments;
  final DateTime now;
  final List<DayItem> Function(Moment) sourced;
  final void Function(DayItem)? onSourced;

  @override
  State<RightNowTabs> createState() => _RightNowTabsState();
}

class _RightNowTabsState extends State<RightNowTabs> {
  MomentId? _picked;

  @override
  Widget build(BuildContext context) {
    final ms = widget.moments;
    final i = ms.indexWhere((m) => m.id == _picked).clamp(0, ms.length - 1);
    final m = ms[i];
    return RightNowCard(
      moment: m,
      now: widget.now,
      sourced: widget.sourced(m),
      onSourced: widget.onSourced,
      tabs: ms.length < 2
          ? null
          : _MomentTabs(moments: ms, selected: i, onSelect: (k) => setState(() => _picked = ms[k].id)),
    );
  }
}

class _MomentTabs extends StatelessWidget {
  const _MomentTabs({required this.moments, required this.selected, required this.onSelect});
  final List<Moment> moments;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final ink = t.heroInk;
    // One line of chips that scrolls sideways: names never wrap, and any
    // number of moments fits without a heavy boxed bar.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (k, m) in moments.indexed) ...[
            if (k > 0) const SizedBox(width: WaqtSpace.x2),
            Semantics(
              selected: k == selected,
              button: true,
              child: Material(
                color: k == selected ? ink : Colors.transparent,
                shape: StadiumBorder(side: BorderSide(color: k == selected ? ink : ink.withValues(alpha: 0.28))),
                child: InkWell(
                  customBorder: const StadiumBorder(),
                  onTap: () => onSelect(k),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 40),
                    padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x4),
                    alignment: Alignment.center,
                    child: Text(
                      l.moment(m),
                      maxLines: 1,
                      style: WaqtText.label.copyWith(
                        color: k == selected ? t.heroSurface : ink.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// What to do now, and the hadith it comes from.
class _SourcedRow extends StatelessWidget {
  const _SourcedRow({required this.item, required this.onTap, this.first = false});
  final DayItem item;
  final bool first;
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
            border: first ? null : Border(top: BorderSide(color: ink.withValues(alpha: 0.12))),
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
                    ItemSourceText(
                      item: item,
                      style: WaqtText.caption.copyWith(color: t.accent),
                    ),
                  ],
                ),
              ),
              ItemTrailing(item: item, color: ink.withValues(alpha: 0.55)),
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

/// What comes next, as a timeline: a line runs down the start edge, one
/// dot per moment (the next one filled), its time at the end and how long
/// until it underneath.
class ComingUp extends StatelessWidget {
  const ComingUp({super.key, required this.moments, required this.now});
  final List<Moment> moments;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final fmt = clockFormat(context);
    final n = LocaleDigits(Localizations.localeOf(context).toLanguageTag());
    String until(DateTime at) {
      final d = at.difference(now);
      final h = d.inHours, m = d.inMinutes % 60;
      return l.comingIn(h > 0 ? l.durHm(n(h), n(m)) : l.durM(n(m < 1 ? 1 : m)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: WaqtSpace.x1, bottom: WaqtSpace.x3),
          child: Text(l.comingUpTitle, style: WaqtText.titleSmall.copyWith(color: t.ink)),
        ),
        for (var i = 0; i < moments.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 24,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      if (i < moments.length - 1)
                        Positioned(
                          top: 10,
                          bottom: 0,
                          child: Container(width: 2, color: t.ink.withValues(alpha: 0.14)),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == 0 ? t.ink : t.ground,
                            border: Border.all(color: t.ink.withValues(alpha: i == 0 ? 1 : 0.4), width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: WaqtSpace.x3),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: i < moments.length - 1 ? WaqtSpace.x5 : 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(l.moment(moments[i]), style: WaqtText.bodyStrong.copyWith(color: t.ink)),
                            ),
                            const SizedBox(width: WaqtSpace.x2),
                            Text(
                              fmt.format(moments[i].window.start),
                              style: WaqtText.bodyStrong.copyWith(color: t.ink, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(until(moments[i].window.start), style: WaqtText.label.copyWith(color: t.inkMuted)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
