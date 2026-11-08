import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../theme/waqt_theme.dart';

class SheetOption<T> {
  const SheetOption(this.value, this.label, {this.hint});
  final T value;
  final String label;
  final String? hint;
}

/// Single-choice bottom sheet. Selection is shown with a filled check in the
/// accent, not by colour alone.
Future<T?> showOptionSheet<T>(
  BuildContext context, {
  required String title,
  required List<SheetOption<T>> options,
  required T selected,
}) {
  final t = WaqtTokens.of(context);
  return showModalBottomSheet<T>(
    useRootNavigator: true,
    context: context,
    isScrollControlled: true,
    backgroundColor: t.ground,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(WaqtRadii.card))),
    builder: (sheet) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(sheet).height * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, 0, WaqtSpace.screen, WaqtSpace.x3),
              child: Text(title, style: WaqtText.titleSmall.copyWith(color: t.ink)),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(WaqtSpace.x3, 0, WaqtSpace.x3, WaqtSpace.x4),
                children: [
                  for (final o in options)
                    _OptionRow(option: o, selected: o.value == selected, onTap: () => Navigator.of(sheet).pop(o.value)),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _OptionRow<T> extends StatelessWidget {
  const _OptionRow({required this.option, required this.selected, required this.onTap});
  final SheetOption<T> option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? t.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(WaqtRadii.row),
        child: InkWell(
          borderRadius: BorderRadius.circular(WaqtRadii.row),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x3, vertical: WaqtSpace.x3),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(option.label, style: WaqtText.bodyStrong.copyWith(color: t.ink)),
                        if (option.hint != null) ...[
                          const SizedBox(height: 2),
                          Text(option.hint!, style: WaqtText.caption.copyWith(color: t.inkMuted)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: WaqtSpace.x3),
                  AnimatedSwitcher(
                    duration: WaqtMotion.fast,
                    child: selected
                        ? Container(
                            key: const ValueKey(true),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(color: t.ink, shape: BoxShape.circle),
                            child: Icon(Icons.check_rounded, size: 15, color: t.ground),
                          )
                        : Container(
                            key: const ValueKey(false),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: t.ink.withValues(alpha: 0.25), width: 1.5),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
