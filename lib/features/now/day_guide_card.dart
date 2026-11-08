import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../core/utils/digits.dart';
import '../../data/sources/days.dart';
import '../../l10n/app_localizations.dart';
import 'collapse.dart';
import '../duas/library_views.dart';
import '../../platform/haptics/haptics.dart';

/// Today's special day as a checklist: each Sunnah, ticked as it is done,
/// opening the hadith it comes from.
class DayGuideCard extends ConsumerStatefulWidget {
  const DayGuideCard({
    super.key,
    required this.title,
    required this.items,
    required this.day,
    this.label,
    this.phase,
    this.morningOver = false,
  });
  final String title;

  /// Small line above the title; "Today's Sunnah" when null.
  final String? label;
  final List<DayItem> items;

  /// Part of the day ('suhoor', 'day', 'iftar', 'night'): its items come
  /// first, so the folded card shows what matters now.
  final String? phase;

  /// Past Dhuhr: morning Sunnahs (the Eid morning, say) that were not done
  /// leave the list instead of lingering as something missed. Done ones stay.
  final bool morningOver;

  /// Civil date key; ticks reset with it.
  final String day;

  @override
  ConsumerState<DayGuideCard> createState() => _DayGuideCardState();
}

class _DayGuideCardState extends ConsumerState<DayGuideCard> {
  /// Folded by default: the three most relevant items still to do.
  bool _open = false;
  static const _folded = 3;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final n = LocaleDigits(Localizations.localeOf(context).toLanguageTag());
    final day = widget.day;
    final foldId = 'guide.${widget.title}';
    final unfolded = !ref.watch(collapsedCardsProvider.select((s) => s.contains(foldId)));
    ref.watch(dayTicksProvider);
    final done = ref.read(dayTicksProvider.notifier).doneOn(day);
    final items = [
      for (final i in widget.items)
        if (!(widget.morningOver && i.when == 'morning' && !done.contains(i.id))) i,
    ];
    if (items.isEmpty) return const SizedBox.shrink();
    final count = items.where((i) => done.contains(i.id)).length;

    return Container(
      padding: const EdgeInsets.fromLTRB(WaqtSpace.x5, WaqtSpace.x5, WaqtSpace.x5, WaqtSpace.x3),
      decoration: BoxDecoration(
        color: t.heroSurface,
        borderRadius: BorderRadius.circular(WaqtRadii.card),
        boxShadow: t.hero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The header folds the card away, or opens it again.
          Semantics(
            button: true,
            expanded: unfolded,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => ref.read(collapsedCardsProvider.notifier).toggle(foldId),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          (widget.label ?? l.dayGuideToday).toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: WaqtText.overline.copyWith(color: t.accent),
                        ),
                      ),
                      Text(
                        l.checklistProgress(n(count), n(items.length)),
                        style: WaqtText.caption.copyWith(color: t.heroInk.withValues(alpha: 0.72)),
                      ),
                      const SizedBox(width: WaqtSpace.x1),
                      FoldChevron(open: unfolded, color: t.heroInk.withValues(alpha: 0.6)),
                    ],
                  ),
                  const SizedBox(height: WaqtSpace.x2),
                  Text(widget.title, style: WaqtText.title.copyWith(color: t.heroInk)),
                ],
              ),
            ),
          ),
          const SizedBox(height: WaqtSpace.x3),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: items.isEmpty ? 0 : count / items.length),
              duration: WaqtMotion.ui,
              builder: (_, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 3,
                backgroundColor: t.heroInk.withValues(alpha: 0.14),
                color: t.accent,
              ),
            ),
          ),
          FoldBody(
            open: unfolded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: WaqtSpace.x2),
                ...() {
                  // Now's items first, then any-time ones, then the rest; ticked last.
                  int rank(DayItem i) => done.contains(i.id)
                      ? 3
                      : i.when == widget.phase || (i.when == 'morning' && widget.phase == 'day')
                      ? 0
                      : i.when == null
                      ? 1
                      : 2;
                  final ordered = [...items]..sort((a, b) => rank(a).compareTo(rank(b)));
                  final shown = _open ? items : ordered.where((i) => !done.contains(i.id)).take(_folded).toList();
                  return [for (final i in shown) _Row(item: i, done: done.contains(i.id), day: day)];
                }(),
                if (items.length > _folded)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: () => setState(() => _open = !_open),
                      style: TextButton.styleFrom(foregroundColor: t.heroInk),
                      icon: Icon(_open ? Icons.expand_less_rounded : Icons.expand_more_rounded, size: 20),
                      label: Text(_open ? l.showLess : l.showAll(items.length)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends ConsumerWidget {
  const _Row({required this.item, required this.done, required this.day});
  final DayItem item;
  final bool done;
  final String day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = WaqtTokens.of(context);
    final l = AppLocalizations.of(context);
    final ink = t.heroInk;
    return Semantics(
      checked: done,
      label: item.title(Localizations.localeOf(context).languageCode),
      excludeSemantics: true,
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Haptics.click();
              ref.read(dayTicksProvider.notifier).toggle(day, item.id);
            },
            icon: AnimatedSwitcher(
              duration: WaqtMotion.ui,
              child: Icon(
                done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                key: ValueKey(done),
                color: done ? t.accent : ink.withValues(alpha: 0.5),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(WaqtRadii.row),
              onTap: () => openHadith(context, ref, item.he),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: WaqtSpace.x2, horizontal: WaqtSpace.x1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title(Localizations.localeOf(context).languageCode),
                      style: WaqtText.bodyStrong.copyWith(
                        color: done ? ink.withValues(alpha: 0.55) : ink,
                        decoration: done ? TextDecoration.lineThrough : null,
                        decorationColor: ink.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 2),
                    HeSourceText(
                      id: item.he,
                      style: WaqtText.caption.copyWith(color: ink.withValues(alpha: 0.62)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: ink.withValues(alpha: 0.4), semanticLabel: l.openSource),
        ],
      ),
    );
  }
}

/// "Sunnah fast today", or after Maghrib "Fast tomorrow", naming the day.
class FastingPill extends StatelessWidget {
  const FastingPill({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x3, vertical: WaqtSpace.x2),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: t.ink.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.nights_stay_outlined, size: 16, color: t.ink),
          const SizedBox(width: WaqtSpace.x2),
          Flexible(
            child: Text(
              text,
              style: WaqtText.label.copyWith(color: t.ink, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
