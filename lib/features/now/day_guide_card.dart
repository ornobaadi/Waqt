import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../core/utils/digits.dart';
import '../../data/sources/days.dart';
import '../../data/sources/hadith_db.dart';
import '../../l10n/app_localizations.dart';
import '../duas/library_views.dart';

/// Today's special day as a checklist: each Sunnah, ticked as it is done,
/// opening the hadith it comes from.
class DayGuideCard extends ConsumerStatefulWidget {
  const DayGuideCard({super.key, required this.title, required this.items, required this.day, this.label, this.phase});
  final String title;

  /// Small line above the title; "Today's Sunnah" when null.
  final String? label;
  final List<DayItem> items;

  /// Part of the day ('suhoor', 'day', 'iftar', 'night'): its items come
  /// first, so the folded card shows what matters now.
  final String? phase;

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
    final items = widget.items, day = widget.day;
    ref.watch(dayTicksProvider);
    final done = ref.read(dayTicksProvider.notifier).doneOn(day);
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
          Row(
            children: [
              Text((widget.label ?? l.dayGuideToday).toUpperCase(), style: WaqtText.overline.copyWith(color: t.accent)),
              const Spacer(),
              Text(
                l.checklistProgress(n(count), n(items.length)),
                style: WaqtText.caption.copyWith(color: t.heroInk.withValues(alpha: 0.72)),
              ),
            ],
          ),
          const SizedBox(height: WaqtSpace.x2),
          Text(widget.title, style: WaqtText.title.copyWith(color: t.heroInk)),
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
          const SizedBox(height: WaqtSpace.x2),
          ...() {
            // Now's items first, then any-time ones, then the rest; ticked last.
            int rank(DayItem i) => done.contains(i.id)
                ? 3
                : i.when == widget.phase
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
      label: '${item.title}. ${item.reference}',
      excludeSemantics: true,
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
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
              onTap: () => openDayItem(context, ref, item),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: WaqtSpace.x2, horizontal: WaqtSpace.x1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: WaqtText.bodyStrong.copyWith(
                        color: done ? ink.withValues(alpha: 0.55) : ink,
                        decoration: done ? TextDecoration.lineThrough : null,
                        decorationColor: ink.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [item.reference, if (item.grade != null) item.grade!].join('  ·  '),
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

/// Opens the hadith behind a day item from the bundled collections.
Future<void> openDayItem(BuildContext context, WidgetRef ref, DayItem item) async {
  // Not downloaded yet: offer the library; it opens the hadith once ready.
  if (ref.read(hadithInstallProvider).status != HadithLibrary.ready) {
    final t = WaqtTokens.of(context);
    final ready = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      backgroundColor: t.ground,
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          ref.listen(hadithInstallProvider.select((s) => s.status), (_, s) {
            if (s == HadithLibrary.ready && ctx.mounted) Navigator.pop(ctx, true);
          });
          return const SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(WaqtSpace.screen, 0, WaqtSpace.screen, WaqtSpace.x6),
              child: HadithDownloadCard(inSheet: true),
            ),
          );
        },
      ),
    );
    if (ready != true || !context.mounted) return;
  }
  final db = await ref.read(hadithDbProvider.future);
  final h = await db.byRef(item.collection, item.number);
  if (h != null && context.mounted) await showHadithSheet(context, h);
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
