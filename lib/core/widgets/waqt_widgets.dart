import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../theme/waqt_theme.dart';

/// The Waqt mark: a believer in sujood under the crescent, the same drawing
/// as the app icon (tool/brand/waqt_icon.py). Ink for the figure and floor,
/// the moment's accent for the crescent.
class WaqtMark extends StatelessWidget {
  const WaqtMark({super.key, this.size = 64});

  /// Width; the mark is a little wider than tall.
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    return ExcludeSemantics(
      child: CustomPaint(size: Size(size, size * _MarkPainter.aspect), painter: _MarkPainter(t.ink, t.accent)),
    );
  }
}

class _MarkPainter extends CustomPainter {
  _MarkPainter(this.ink, this.accent);
  final Color ink, accent;

  // The icon scene's artwork box (256-unit canvas).
  static const _left = 36.0, _top = 38.0, _w = 184.0, _h = 172.0;
  static const aspect = _h / _w;

  /// Body and arm as one outline, in the figure's 640-unit box (floor at 600).
  static const _body =
      'M96 600 L300 600 C328 600 342 582 338 558 C334 530 318 500 314 474 C312 456 330 446 352 452 '
      'L388 468 C384 500 388 530 398 550 C406 566 418 578 428 588 C434 596 440 600 450 600 L484 600 '
      'C494 600 496 586 486 584 L456 580 C448 576 444 566 446 556 C450 528 458 500 470 474 '
      'C478 452 468 436 448 426 L322 324 C276 292 206 296 186 346 C172 382 178 428 198 462 '
      'C210 486 206 520 172 530 L118 534 C90 536 76 556 80 580 C82 594 88 600 96 600 Z';

  static Path _parse(String d) {
    final p = Path();
    final tok = d.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    var i = 0;
    double n() => double.parse(tok[i++]);
    var cmd = 'M';
    while (i < tok.length) {
      final s = tok[i];
      if (RegExp(r'^[MLCZ]').hasMatch(s)) {
        cmd = s[0];
        if (s.length > 1) {
          tok[i] = s.substring(1);
        } else {
          i++;
        }
        if (cmd == 'Z') {
          p.close();
          continue;
        }
      }
      switch (cmd) {
        case 'M':
          p.moveTo(n(), n());
        case 'L':
          p.lineTo(n(), n());
        case 'C':
          p.cubicTo(n(), n(), n(), n(), n(), n());
      }
    }
    return p;
  }

  static final Path _figure = _parse(_body);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / _w);
    canvas.translate(-_left, -_top);
    final fill = Paint()..color = ink;

    // Floor.
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(36, 204, 184, 5), const Radius.circular(2.5)),
      Paint()..color = ink.withValues(alpha: 0.75),
    );

    // Figure: sujood(cx 122, floor 204, 186 wide) from the icon.
    const k = 186 / 640;
    canvas.save();
    canvas.translate(122 - 320 * k, 204 - 600 * k);
    canvas.scale(k);
    final head = Path()..addOval(Rect.fromCircle(center: const Offset(560, 538), radius: 62));
    final gap = Path()..addOval(Rect.fromCircle(center: const Offset(560, 538), radius: 82));
    canvas.drawPath(Path.combine(PathOperation.difference, _figure, gap), fill);
    canvas.drawPath(head, fill);
    canvas.restore();

    // Crescent.
    const r = 18.0;
    final disc = Path()..addOval(Rect.fromCircle(center: const Offset(186, 58), radius: r));
    final bite = Path()
      ..addOval(Rect.fromCircle(center: const Offset(186 + 0.36 * r, 58 - 0.36 * r * 0.45), radius: 0.84 * r));
    canvas.drawPath(Path.combine(PathOperation.difference, disc, bite), Paint()..color = accent);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MarkPainter o) => o.ink != ink || o.accent != accent;
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    return Padding(
      padding: const EdgeInsets.all(WaqtSpace.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const WaqtMark(size: 72),
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
