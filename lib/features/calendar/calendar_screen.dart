import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/app_state.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../core/utils/digits.dart';
import '../../data/sources/days.dart';
import '../../domain/hijri/hijri_service.dart';
import '../../domain/occasions/occasions.dart';
import '../../l10n/app_localizations.dart';
import '../common/labels.dart';
import '../duas/library_views.dart';

/// A Hijri month at a glance: each day with its Gregorian date, a dot on
/// days with a guide, a ring on days the Sunnah is to fast. Tap a day for
/// what it holds.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  ({int year, int month})? _shown;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final n = LocaleDigits(locale);
    final today = ref.watch(occasionsProvider).date;
    final offset = ref.watch(hijriOffsetProvider);
    final guides = ref.watch(dayGuidesProvider).value;
    final shown = _shown ?? (year: today.year, month: today.month);
    final month = ref.watch(hijriServiceProvider).monthOf(shown.year, shown.month, offset: offset);
    final length = month.days;

    // The civil date that carries Hijri day d of the shown month.
    DateTime civil(int d) => DateTime(month.start.year, month.start.month, month.start.day + d - 1);

    final first = civil(1);
    // Weeks start on the locale's first day.
    final firstDow = MaterialLocalizations.of(context).firstDayOfWeekIndex; // 0 = Sunday
    final lead = (first.weekday % 7 - firstDow) % 7;
    final dowNames = [for (var i = 0; i < 7; i++) DateFormat.E(locale).dateSymbols.NARROWWEEKDAYS[(firstDow + i) % 7]];

    void move(int by) {
      var m = shown.month + by, y = shown.year;
      if (m < 1) (m, y) = (12, y - 1);
      if (m > 12) (m, y) = (1, y + 1);
      setState(() => _shown = (year: y, month: m));
    }

    return Scaffold(
      backgroundColor: t.ground,
      appBar: AppBar(
        backgroundColor: t.ground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: t.ink,
        title: Text(l.calendarTitle, style: WaqtText.titleSmall.copyWith(color: t.ink)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, 0, WaqtSpace.screen, WaqtSpace.x12),
        children: [
          Row(
            children: [
              IconButton(
                tooltip: MaterialLocalizations.of(context).previousMonthTooltip,
                onPressed: () => move(-1),
                icon: Icon(Icons.chevron_left_rounded, color: t.ink),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${l.hijriMonth(shown.month)} ${n(shown.year)}',
                      style: WaqtText.titleSmall.copyWith(color: t.ink),
                    ),
                    Text(
                      '${DateFormat.yMMMd(locale).format(first)} – ${DateFormat.yMMMd(locale).format(civil(length))}',
                      style: WaqtText.caption.copyWith(color: t.inkMuted),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: MaterialLocalizations.of(context).nextMonthTooltip,
                onPressed: () => move(1),
                icon: Icon(Icons.chevron_right_rounded, color: t.ink),
              ),
            ],
          ),
          const SizedBox(height: WaqtSpace.x4),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.78,
            children: [
              for (final d in dowNames)
                Center(
                  child: Text(d, style: WaqtText.caption.copyWith(color: t.inkMuted)),
                ),
              for (var i = 0; i < lead; i++) const SizedBox(),
              for (var d = 1; d <= length; d++)
                _Day(
                  hijriDay: d,
                  civil: civil(d),
                  isToday: shown.year == today.year && shown.month == today.month && d == today.day,
                  occasions: occasionsFor(HijriDate(shown.year, shown.month, d), civil(d).weekday),
                  guides: guides,
                  numbers: n,
                ),
            ],
          ),
          const SizedBox(height: WaqtSpace.x4),
          Row(
            children: [
              _Legend(dot: true, label: l.calendarLegendGuide),
              const SizedBox(width: WaqtSpace.x4),
              _Legend(dot: false, label: l.calendarLegendFast),
            ],
          ),
          const SizedBox(height: WaqtSpace.x3),
          Text(l.calendarNote, style: WaqtText.caption.copyWith(color: t.inkMuted)),
        ],
      ),
    );
  }
}

class _Day extends ConsumerWidget {
  const _Day({
    required this.hijriDay,
    required this.civil,
    required this.isToday,
    required this.occasions,
    required this.guides,
    required this.numbers,
  });
  final int hijriDay;
  final DateTime civil;
  final bool isToday;
  final List<OccasionId> occasions;
  final DayGuides? guides;
  final LocaleDigits numbers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = WaqtTokens.of(context);
    // Weekly fasts would put a ring on every Monday and Thursday; the grid
    // marks only the days that come once a year or once a month.
    final marked = occasions.where((o) => o != OccasionId.mondayFast && o != OccasionId.thursdayFast);
    final guided = guides != null && marked.any((o) => o != OccasionId.jumuah && guides!.forOccasion(o).isNotEmpty);
    final fast = guides != null && marked.any(guides!.fasts.contains);
    return InkWell(
      borderRadius: BorderRadius.circular(WaqtRadii.row),
      onTap: occasions.isEmpty || guides == null ? null : () => _open(context, ref),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isToday ? t.ink : null,
          borderRadius: BorderRadius.circular(WaqtRadii.row),
          border: fast && !isToday ? Border.all(color: t.accent, width: 2) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(numbers(hijriDay), style: WaqtText.bodyStrong.copyWith(color: isToday ? t.ground : t.ink)),
            Text(
              numbers(civil.day),
              style: WaqtText.caption.copyWith(color: isToday ? t.ground.withValues(alpha: 0.7) : t.inkMuted),
            ),
            const SizedBox(height: 2),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(shape: BoxShape.circle, color: guided ? t.accent : Colors.transparent),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final g = guides!;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: t.ground,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        builder: (ctx, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, 0, WaqtSpace.screen, WaqtSpace.x12),
          children: [
            Text(DateFormat.yMMMMEEEEd(locale).format(civil), style: WaqtText.titleSmall.copyWith(color: t.ink)),
            const SizedBox(height: WaqtSpace.x3),
            for (final o in occasions) ...[
              Padding(
                padding: const EdgeInsets.only(top: WaqtSpace.x4, bottom: WaqtSpace.x1),
                child: Text(
                  l.occasion(o, ramadanDay: numbers(hijriDay)).toUpperCase(),
                  style: WaqtText.overline.copyWith(color: t.inkMuted),
                ),
              ),
              for (final i in g.forOccasion(o))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    i.title(Localizations.localeOf(ctx).languageCode),
                    style: WaqtText.bodyStrong.copyWith(color: t.ink),
                  ),
                  subtitle: HeSourceText(
                    id: i.he,
                    style: WaqtText.caption.copyWith(color: t.inkMuted),
                  ),
                  trailing: Icon(Icons.chevron_right_rounded, color: t.inkMuted),
                  onTap: () => openHadith(ctx, ref, i.he),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.dot, required this.label});
  final bool dot;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: dot ? 6 : 14,
          height: dot ? 6 : 14,
          decoration: dot
              ? BoxDecoration(shape: BoxShape.circle, color: t.accent)
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: t.accent, width: 2),
                ),
        ),
        const SizedBox(width: WaqtSpace.x2),
        Text(label, style: WaqtText.caption.copyWith(color: t.inkMuted)),
      ],
    );
  }
}
