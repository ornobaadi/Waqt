import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../domain/moments/moment.dart';
import '../../l10n/app_localizations.dart';
import '../common/labels.dart';

DateFormat clockFormat(BuildContext context) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return MediaQuery.alwaysUse24HourFormatOf(context) ? DateFormat.Hm(locale) : DateFormat.jm(locale);
}

/// The hero: the highest-priority moment that is more specific than the
/// waqt itself. Content (duas, actions with references) arrives in Phase 3;
/// until then the card names the moment and how long it lasts.
class RightNowCard extends StatelessWidget {
  const RightNowCard({super.key, required this.moment, required this.now});
  final Moment moment;
  final DateTime now;

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
                            Text(
                              l.startsAt(fmt.format(moments[i].window.start)),
                              style: WaqtText.caption.copyWith(color: t.inkMuted),
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
