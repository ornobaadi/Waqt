import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../domain/deeds/deeds.dart';
import '../../domain/prayer/prayer_times_service.dart';
import '../../l10n/app_localizations.dart';
import '../common/labels.dart';

/// How a prayer was kept, told by colour alone, everywhere it appears (the
/// strip, the ring, the week, the year): green prayed on time, amber made
/// up late, sapphire prayed in congregation, the reward multiplied.
abstract final class MarkColors {
  static bool _dark(WaqtTokens t) => ThemeData.estimateBrightnessForColor(t.ground) == Brightness.dark;

  static Color of(WaqtTokens t, SalahMark m) => switch (m) {
    SalahMark.onTime => _dark(t) ? const Color(0xFF5DBE86) : const Color(0xFF2F8A55),
    SalahMark.qada => _dark(t) ? const Color(0xFFE7B547) : const Color(0xFFD09A1E),
    SalahMark.jamaah => _dark(t) ? const Color(0xFF7FA4F4) : const Color(0xFF2950A0),
  };

  /// Text that reads on top of [of].
  static Color on(WaqtTokens t, SalahMark m) => ThemeData.estimateBrightnessForColor(of(t, m)) == Brightness.dark
      ? const Color(0xFFFFFFFF)
      : const Color(0xFF17120A);
}

/// The small sign for how a prayer was kept, worn in a bead's corner so
/// colour is never the only cue: alone, in congregation, or made up late.
IconData markIcon(SalahMark m) => switch (m) {
  SalahMark.onTime => Icons.person_rounded,
  SalahMark.jamaah => Icons.groups_rounded,
  SalahMark.qada => Icons.history_rounded,
};

/// A swatch of a mark's colour with its sign; an outline when not marked.
class SalahSwatch extends StatelessWidget {
  const SalahSwatch({super.key, required this.mark, this.size = 22});
  final SalahMark? mark;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    final m = mark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: m == null ? null : MarkColors.of(t, m),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: m == null ? Border.all(color: t.ink.withValues(alpha: 0.3), width: 1.5) : null,
      ),
      child: m == null ? null : Icon(markIcon(m), size: size * 0.6, color: MarkColors.on(t, m)),
    );
  }
}

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
                leading: SalahSwatch(mark: m, size: 26),
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
