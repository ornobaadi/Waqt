import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../theme/waqt_theme.dart';

/// A miniature of the sun arc: the app's signature, used as a quiet mark
/// in place of generic icons.
class ArcMark extends StatelessWidget {
  const ArcMark({super.key, this.size = 44, this.progress = 0.62});

  final double size;

  /// 0 = sunrise (start edge), 1 = sunset (end edge).
  final double progress;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size(size, size / 2 + 6),
        painter: _ArcPainter(t.hairline.withValues(alpha: 0.5), t.accent, t.ink, progress, rtl),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter(this.track, this.accent, this.ink, this.progress, this.rtl);
  final Color track, accent, ink;
  final double progress;
  final bool rtl;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.05;
    final r = size.width / 2 - stroke;
    final c = Offset(size.width / 2, size.height - 3);
    final rect = Rect.fromCircle(center: c, radius: r);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, math.pi, math.pi, false, base..color = ink.withValues(alpha: 0.14));
    final sweep = math.pi * progress;
    canvas.drawArc(rect, rtl ? 0 : math.pi, rtl ? -sweep : sweep, false, base..color = accent);
    final a = rtl ? -sweep : math.pi + sweep;
    final sun = c + Offset(math.cos(a) * r, math.sin(a) * r);
    canvas.drawCircle(sun, stroke * 2.4, Paint()..color = accent.withValues(alpha: 0.28));
    canvas.drawCircle(sun, stroke * 1.4, Paint()..color = accent);
    canvas.drawLine(
      Offset(0, c.dy + stroke),
      Offset(size.width, c.dy + stroke),
      Paint()
        ..color = ink.withValues(alpha: 0.18)
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter o) => o.progress != progress || o.accent != accent || o.ink != ink || o.rtl != rtl;
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, required this.body, this.progress = 0.62});
  final String title;
  final String body;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    return Padding(
      padding: const EdgeInsets.all(WaqtSpace.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ArcMark(size: 56, progress: progress),
          const SizedBox(height: WaqtSpace.x6),
          Text(
            title,
            style: WaqtText.title.copyWith(color: t.ink),
            textWidthBasis: TextWidthBasis.longestLine,
          ),
          const SizedBox(height: WaqtSpace.x3),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Text(body, style: WaqtText.body.copyWith(color: t.inkMuted)),
          ),
          const SizedBox(height: WaqtSpace.x12),
        ],
      ),
    );
  }
}

class ScreenTitle extends StatelessWidget {
  const ScreenTitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(WaqtSpace.screen, WaqtSpace.x4, WaqtSpace.screen, WaqtSpace.x4),
    child: Semantics(
      header: true,
      child: Text(text, style: WaqtText.title.copyWith(color: WaqtTokens.of(context).ink)),
    ),
  );
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(WaqtSpace.x1, WaqtSpace.x6, 0, WaqtSpace.x2),
    child: Text(text.toUpperCase(), style: WaqtText.overline.copyWith(color: WaqtTokens.of(context).inkMuted)),
  );
}

/// Rounded group of rows, radius 18, rows inside at 18 − 4 = 14.
class RowGroup extends StatelessWidget {
  const RowGroup({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        items.add(
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
            child: Divider(color: t.hairline),
          ),
        );
      }
      items.add(children[i]);
    }
    return DecoratedBox(
      decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(WaqtRadii.strip)),
      child: Padding(
        padding: const EdgeInsets.all(WaqtSpace.x1),
        child: Column(children: items),
      ),
    );
  }
}

class RowTile extends StatelessWidget {
  const RowTile({super.key, required this.title, this.subtitle, this.value, this.onTap});
  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(WaqtRadii.row),
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
                      Text(title, style: WaqtText.bodyStrong.copyWith(color: t.ink)),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(subtitle!, style: WaqtText.caption.copyWith(color: t.inkMuted)),
                      ],
                    ],
                  ),
                ),
                if (value != null) Text(value!, style: WaqtText.label.copyWith(color: t.inkMuted)),
                if (onTap != null) ...[
                  const SizedBox(width: WaqtSpace.x2),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: t.inkMuted,
                    textDirection: Directionality.of(context),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
