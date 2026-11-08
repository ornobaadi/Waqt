import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../core/theme/tokens.dart';
import '../core/theme/waqt_theme.dart';
import '../platform/haptics/haptics.dart';

/// One place in the dock.
class DockItem {
  const DockItem({required this.icon, required this.selectedIcon, required this.label});
  final IconData icon, selectedIcon;
  final String label;
}

/// Material 3 Expressive motion springs.
abstract final class _Springs {
  /// Fast spatial: size and position. Bouncy, settles quickly.
  static final spatial = SpringDescription.withDampingRatio(mass: 1, stiffness: 800, ratio: 0.6);

  /// Fast effects: colour and opacity. No overshoot.
  static final effects = SpringDescription.withDampingRatio(mass: 1, stiffness: 1600, ratio: 1);

  /// Press feedback: a quick squash and spring back.
  static final press = SpringDescription.withDampingRatio(mass: 1, stiffness: 1400, ratio: 0.55);
}

/// A floating dock in the manner of Material 3 Expressive: a capsule that
/// hovers over the content, the selected place grown into a pill with its
/// label, everything moving on springs. Colours follow the moment's palette.
class WaqtDock extends StatelessWidget {
  const WaqtDock({super.key, required this.items, required this.selected, required this.onSelect});

  final List<DockItem> items;
  final int selected;
  final ValueChanged<int> onSelect;

  static const double height = 64;
  static const double margin = 12;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    final dark = ThemeData.estimateBrightnessForColor(t.ground) == Brightness.dark;
    final bg = Color.alphaBlend(t.ink.withValues(alpha: dark ? 0.10 : 0.05), t.ground);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: margin),
        child: Center(
          heightFactor: 1,
          child: AnimatedContainer(
            duration: WaqtMotion.palette,
            curve: WaqtMotion.ease,
            height: height,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(height / 2),
              border: Border.all(color: t.ink.withValues(alpha: dark ? 0.12 : 0.07)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: dark ? 0.35 : 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(color: Colors.black.withValues(alpha: dark ? 0.2 : 0.05), blurRadius: 4),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < items.length; i++)
                  _DockButton(
                    item: items[i],
                    selected: i == selected,
                    onTap: () {
                      if (i != selected) Haptics.tick();
                      onSelect(i);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DockButton extends StatefulWidget {
  const _DockButton({required this.item, required this.selected, required this.onTap});
  final DockItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_DockButton> createState() => _DockButtonState();
}

class _DockButtonState extends State<_DockButton> with TickerProviderStateMixin {
  late final AnimationController _grow = AnimationController.unbounded(vsync: this, value: widget.selected ? 1 : 0);
  late final AnimationController _fade = AnimationController(vsync: this, value: widget.selected ? 1 : 0);
  late final AnimationController _press = AnimationController.unbounded(vsync: this, value: 1);

  @override
  void didUpdateWidget(_DockButton old) {
    super.didUpdateWidget(old);
    if (old.selected == widget.selected) return;
    final to = widget.selected ? 1.0 : 0.0;
    if (MediaQuery.disableAnimationsOf(context)) {
      _grow.value = to;
      _fade.value = to;
      return;
    }
    _grow.animateWith(SpringSimulation(_Springs.spatial, _grow.value, to, _grow.velocity));
    _fade.animateWith(SpringSimulation(_Springs.effects, _fade.value, to, _fade.velocity));
  }

  void _pressTo(double v) {
    if (MediaQuery.disableAnimationsOf(context)) return;
    _press.animateWith(SpringSimulation(_Springs.press, _press.value, v, _press.velocity));
  }

  @override
  void dispose() {
    _grow.dispose();
    _fade.dispose();
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    const collapsed = 52.0;
    final scaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3);
    final style = WaqtText.label.copyWith(fontWeight: FontWeight.w600, height: 1);
    final painter = TextPainter(
      text: TextSpan(text: widget.item.label, style: style),
      textDirection: Directionality.of(context),
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    final labelW = painter.width.clamp(0.0, 140.0);
    painter.dispose();
    final expanded = 16 + 24 + 8 + labelW + 20;

    return Tooltip(
      message: widget.item.label,
      excludeFromSemantics: true,
      child: Semantics(
        button: true,
        selected: widget.selected,
        label: widget.item.label,
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _pressTo(0.88),
          onTapUp: (_) => _pressTo(1),
          onTapCancel: () => _pressTo(1),
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: Listenable.merge([_grow, _fade, _press]),
            builder: (context, _) {
              final g = _grow.value; // overshoots past 1 and below 0: the bounce
              final gc = g.clamp(0.0, 1.0);
              final f = _fade.value.clamp(0.0, 1.0);
              final w = (collapsed + (expanded - collapsed) * g).clamp(collapsed * 0.9, expanded * 1.15);
              final fg = Color.lerp(t.inkMuted, t.ground, f)!;
              return Transform.scale(
                scale: _press.value,
                child: Container(
                  width: w,
                  height: WaqtDock.height - 16,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: t.ink.withValues(alpha: f),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ClipRect(
                    child: OverflowBox(
                      maxWidth: double.infinity,
                      alignment: AlignmentDirectional.centerStart,
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(start: 14 + 2 * gc),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(widget.selected ? widget.item.selectedIcon : widget.item.icon, size: 24, color: fg),
                            SizedBox(width: 8 * gc),
                            Opacity(
                              opacity: f,
                              child: Text(
                                widget.item.label,
                                maxLines: 1,
                                textScaler: scaler,
                                style: style.copyWith(color: fg),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
