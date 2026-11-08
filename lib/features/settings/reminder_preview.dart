import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../core/widgets/waqt_widgets.dart';
import '../../domain/notifications/reminder_planner.dart';
import '../../l10n/app_localizations.dart';

/// A reminder drawn the way Android shows it, so people see exactly what
/// they will get before they turn it on.
class ReminderPreview extends StatelessWidget {
  const ReminderPreview({super.key, required this.topic, this.at, this.compact = false});

  final ReminderTopic topic;

  /// When it will arrive; null shows "now".
  final DateTime? at;

  /// Two lines of body instead of the full text.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final when = at == null
        ? l.remNow
        : '${DateFormat.MMMEd(locale).format(at!)} · ${(MediaQuery.alwaysUse24HourFormatOf(context) ? DateFormat.Hm(locale) : DateFormat.jm(locale)).format(at!)}';

    // Like Android: a light card on light themes (a black slab swallowed the
    // icon and felt heavy on the day palettes), the dark one at night.
    final light = t.ground.computeLuminance() > 0.4;
    final card = light ? Color.alphaBlend(Colors.white.withValues(alpha: 0.82), t.ground) : t.heroSurface;
    final ink = light ? t.ink : t.heroInk;

    return Semantics(
      container: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(WaqtSpace.x4, WaqtSpace.x3, WaqtSpace.x4, WaqtSpace.x4),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(WaqtRadii.strip + 2),
          border: light ? Border.all(color: t.hairline) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: light ? 0.06 : 0.10),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(color: const Color(0xFF0F1436), borderRadius: BorderRadius.circular(6)),
                  child: const WaqtMark(size: 16, ink: Color(0xFFFBF3E2), accent: Color(0xFFE9C46A)),
                ),
                const SizedBox(width: WaqtSpace.x2),
                Flexible(
                  child: Text(
                    '${l.appName} · $when',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: WaqtText.caption.copyWith(color: ink.withValues(alpha: 0.6)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: WaqtSpace.x2),
            Text(l.remTitle(topic.name), style: WaqtText.bodyStrong.copyWith(color: ink)),
            const SizedBox(height: 2),
            Text(
              l.remBody(topic.name),
              maxLines: compact ? 2 : null,
              overflow: compact ? TextOverflow.ellipsis : null,
              style: WaqtText.label.copyWith(color: ink.withValues(alpha: 0.75), height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

/// A sheet showing one kind's reminder, and when it comes.
Future<void> showReminderPreview(BuildContext context, ReminderKind kind) {
  final l = AppLocalizations.of(context);
  final t = WaqtTokens.of(context);
  return showModalBottomSheet<void>(
    useRootNavigator: true,
    context: context,
    backgroundColor: t.ground,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, 0, WaqtSpace.screen, WaqtSpace.x6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.remKind(kind.name), style: WaqtText.titleSmall.copyWith(color: t.ink)),
            const SizedBox(height: WaqtSpace.x1),
            Text(l.remWhen(kind.name), style: WaqtText.label.copyWith(color: t.inkMuted)),
            const SizedBox(height: WaqtSpace.x5),
            ReminderPreview(topic: ReminderTopic.sample(kind)),
          ],
        ),
      ),
    ),
  );
}
