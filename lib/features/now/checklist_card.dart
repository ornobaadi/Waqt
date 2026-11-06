import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../core/utils/digits.dart';
import '../../data/content/content_repository.dart';
import '../../data/user/checklist.dart';
import '../../domain/moments/moment.dart';
import '../../l10n/app_localizations.dart';
import '../common/labels.dart';
import '../duas/dua_sheet.dart';

/// Act depth (PRD principle 3): tick through a moment's Sunnah, 30 seconds.
class ChecklistCard extends ConsumerWidget {
  const ChecklistCard({super.key, required this.moment, required this.items, required this.day});
  final MomentId moment;
  final List<ContentItem> items;

  /// Prayer-day key; ticks reset when it changes.
  final String day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final n = LocaleDigits(Localizations.localeOf(context).toLanguageTag());
    final done = ref.watch(checklistProvider.select((s) => s.doneFor(day, moment)));
    final count = items.where((i) => done.contains(i.id)).length;
    final title = moment == MomentId.bedtime ? l.checklistTitleBedtime : l.checklistTitleJumuah;

    return Container(
      padding: const EdgeInsets.fromLTRB(WaqtSpace.x4, WaqtSpace.x4, WaqtSpace.x4, WaqtSpace.x2),
      decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(WaqtRadii.card)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(title, style: WaqtText.titleSmall.copyWith(color: t.ink)),
                ),
              ),
              SizedBox(
                width: 22,
                height: 22,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: items.isEmpty ? 0 : count / items.length),
                  duration: WaqtMotion.ui,
                  builder: (_, v, _) => CircularProgressIndicator(
                    value: v,
                    strokeWidth: 3,
                    strokeCap: StrokeCap.round,
                    color: t.accent,
                    backgroundColor: t.ink.withValues(alpha: 0.1),
                  ),
                ),
              ),
              const SizedBox(width: WaqtSpace.x2),
              Text(l.checklistProgress(n(count), n(items.length)), style: WaqtText.label.copyWith(color: t.inkMuted)),
            ],
          ),
          const SizedBox(height: WaqtSpace.x2),
          for (final item in items)
            _CheckRow(
              item: item,
              checked: done.contains(item.id),
              onToggle: () {
                HapticFeedback.selectionClick();
                ref.read(checklistProvider.notifier).toggle(day, moment, item.id);
              },
            ),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.item, required this.checked, required this.onToggle});
  final ContentItem item;
  final bool checked;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return Row(
      children: [
        Expanded(
          child: Semantics(
            checked: checked,
            label: '${item.titleFor(lang)}, ${l.reference(item.source)}',
            excludeSemantics: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(WaqtRadii.row),
              onTap: onToggle,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 56),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: WaqtSpace.x2),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: WaqtMotion.fast,
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: checked ? t.ink : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: checked ? t.ink : t.ink.withValues(alpha: 0.3), width: 1.75),
                        ),
                        child: checked ? Icon(Icons.check_rounded, size: 16, color: t.ground) : null,
                      ),
                      const SizedBox(width: WaqtSpace.x3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: WaqtMotion.fast,
                              style: WaqtText.bodyStrong.copyWith(
                                color: checked ? t.inkMuted : t.ink,
                                decoration: checked ? TextDecoration.lineThrough : null,
                                decorationColor: t.inkMuted,
                              ),
                              child: Text(item.titleFor(lang)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.approved
                                  ? l.reference(item.source)
                                  : '${l.reference(item.source)}  ·  ${l.statusDraft}',
                              style: WaqtText.caption.copyWith(color: t.inkMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: l.sheetSource,
          onPressed: () => showDuaSheet(context, item),
          icon: Icon(Icons.info_outline_rounded, size: 20, color: t.inkMuted),
        ),
      ],
    );
  }
}
