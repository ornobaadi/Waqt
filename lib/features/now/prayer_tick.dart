import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../data/user/deeds_store.dart';
import '../../domain/deeds/deeds.dart';
import '../../domain/prayer/prayer_times_service.dart';
import '../../l10n/app_localizations.dart';
import '../../platform/haptics/haptics.dart';
import '../common/labels.dart';

/// The ring under a prayer. One tap: prayed (on time while its time lasts,
/// made up after). Tap again to clear. Long-press for the detail. Before its
/// time comes there is nothing to tick, so nothing is drawn.
class PrayerTick extends ConsumerWidget {
  const PrayerTick({
    super.key,
    required this.prayer,
    required this.day,
    required this.mark,
    required this.started,
    required this.ended,
  });

  final Waqt prayer;
  final String day;
  final SalahMark? mark;
  final bool started, ended;

  static const double size = 26;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!started) return const SizedBox(height: size + 8);
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final deeds = ref.read(deedsProvider.notifier);

    void set(SalahMark? m) {
      if (m == null) {
        Haptics.tick();
      } else {
        Haptics.click();
      }
      deeds.markSalah(day, prayer, m);
    }

    return Semantics(
      button: true,
      checked: mark != null,
      label: '${l.waqt(prayer)}: ${markLabel(l, mark)}',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => set(mark != null ? null : (ended ? SalahMark.qada : SalahMark.onTime)),
        onLongPress: () async {
          Haptics.tick();
          final picked = await showSalahSheet(context, prayer, mark);
          if (picked != null) set(picked.$1);
        },
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: AnimatedSwitcher(
            duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 380),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
            child: SalahMarkDot(key: ValueKey(mark), mark: mark, size: size, ink: t.ink, accent: t.accent),
          ),
        ),
      ),
    );
  }
}

/// A prayer's mark as a small round badge: hollow when not marked.
class SalahMarkDot extends StatelessWidget {
  const SalahMarkDot({super.key, required this.mark, required this.size, required this.ink, required this.accent});
  final SalahMark? mark;
  final double size;
  final Color ink, accent;

  @override
  Widget build(BuildContext context) {
    final m = mark;
    if (m == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ink.withValues(alpha: 0.28), width: 1.6),
        ),
      );
    }
    // Made up later is shown quieter than on time: kept, not celebrated less.
    final fill = m == SalahMark.qada ? ink.withValues(alpha: 0.55) : accent;
    final onFill = ThemeData.estimateBrightnessForColor(fill) == Brightness.dark
        ? const Color(0xFFFBF3E2)
        : const Color(0xFF14110C);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: fill),
      child: Icon(markIcon(m), size: size * 0.62, color: onFill),
    );
  }
}

IconData markIcon(SalahMark m) => switch (m) {
  SalahMark.onTime => Icons.check_rounded,
  SalahMark.jamaah => Icons.groups_rounded,
  SalahMark.qada => Icons.history_rounded,
};

String markLabel(AppLocalizations l, SalahMark? m) => switch (m) {
  null => l.deedNotPrayed,
  SalahMark.onTime => l.deedOnTime,
  SalahMark.jamaah => l.deedJamaah,
  SalahMark.qada => l.deedQada,
};

/// The detail for one prayer. Returns the choice (its mark, null = clear),
/// or null when dismissed.
Future<(SalahMark?,)?> showSalahSheet(BuildContext context, Waqt prayer, SalahMark? current) {
  final l = AppLocalizations.of(context);
  final t = WaqtTokens.of(context);
  return showModalBottomSheet<(SalahMark?,)>(
    useRootNavigator: true,
    context: context,
    backgroundColor: t.ground,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, 0, WaqtSpace.screen, WaqtSpace.x5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.waqt(prayer), style: WaqtText.titleSmall.copyWith(color: t.ink)),
            const SizedBox(height: WaqtSpace.x3),
            for (final m in <SalahMark?>[SalahMark.onTime, SalahMark.jamaah, SalahMark.qada, null])
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: SalahMarkDot(mark: m, size: 30, ink: t.ink, accent: t.accent),
                title: Text(markLabel(l, m), style: WaqtText.body.copyWith(color: t.ink)),
                trailing: m == current ? Icon(Icons.check_rounded, color: t.ink) : null,
                onTap: () => Navigator.pop(context, (m,)),
              ),
          ],
        ),
      ),
    ),
  );
}
