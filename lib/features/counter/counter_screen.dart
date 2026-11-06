import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../core/utils/digits.dart';
import '../../l10n/app_localizations.dart';

class CounterState {
  const CounterState({this.count = 0, this.target = 33});
  final int count;
  final int target;
  int get inRound => count % target;
  int get round => count ~/ target + 1;
}

class CounterNotifier extends Notifier<CounterState> {
  @override
  CounterState build() => const CounterState();

  /// Returns true when this tap completed a round.
  bool tap() {
    state = CounterState(count: state.count + 1, target: state.target);
    return state.inRound == 0;
  }

  void reset() => state = CounterState(target: state.target);
  void setTarget(int t) => state = CounterState(target: t);
}

final counterProvider = NotifierProvider<CounterNotifier, CounterState>(CounterNotifier.new);

/// A misbaha: the whole screen is the button, so it works without looking.
/// It counts; what to say is the user's (and, later, reviewed content's).
class CounterScreen extends ConsumerWidget {
  const CounterScreen({super.key});

  static const targets = [33, 99, 100];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final s = ref.watch(counterProvider);
    final n = LocaleDigits(Localizations.localeOf(context).toLanguageTag());
    final reduce = MediaQuery.disableAnimationsOf(context);

    void onTap() {
      final done = ref.read(counterProvider.notifier).tap();
      done ? HapticFeedback.heavyImpact() : HapticFeedback.selectionClick();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: t.ground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: t.ink,
        title: Text(l.counterTitle, style: WaqtText.titleSmall.copyWith(color: t.ink)),
        actions: [
          PopupMenuButton<int>(
            tooltip: l.counterTarget,
            initialValue: s.target,
            onSelected: ref.read(counterProvider.notifier).setTarget,
            itemBuilder: (_) => [for (final x in targets) PopupMenuItem(value: x, child: Text(n(x)))],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x3),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: t.ink.withValues(alpha: 0.2)),
                  ),
                  child: Text('× ${n(s.target)}', style: WaqtText.label.copyWith(color: t.ink)),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: l.counterReset,
            onPressed: s.count == 0 ? null : ref.read(counterProvider.notifier).reset,
            icon: Icon(Icons.restart_alt_rounded, color: s.count == 0 ? t.inkMuted : t.ink),
          ),
        ],
      ),
      body: Semantics(
        button: true,
        label: l.counterTap,
        value: n(s.count),
        onTap: onTap,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(WaqtSpace.x6),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(end: s.inRound.toDouble()),
                          duration: reduce ? Duration.zero : const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          builder: (context, v, _) => CustomPaint(
                            painter: _BeadsPainter(
                              beads: s.target > 40 ? 33 : s.target,
                              progress: v / s.target,
                              ink: t.ink,
                              accent: t.accent,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(n(s.inRound), style: WaqtText.clock.copyWith(color: t.ink)),
                                  const SizedBox(height: WaqtSpace.x1),
                                  Text(l.counterRound(n(s.round)), style: WaqtText.label.copyWith(color: t.inkMuted)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: WaqtSpace.x8),
                  child: Text(l.counterTap, style: WaqtText.label.copyWith(color: t.inkMuted)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A ring of beads; counted beads fill in, the next one is lit.
class _BeadsPainter extends CustomPainter {
  _BeadsPainter({required this.beads, required this.progress, required this.ink, required this.accent});
  final int beads;
  final double progress;
  final Color ink, accent;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 10;
    final bead = math.min(9.0, math.pi * r / beads * 0.62);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = ink.withValues(alpha: 0.10),
    );
    final filled = progress * beads;
    for (var i = 0; i < beads; i++) {
      final a = -math.pi / 2 + 2 * math.pi * i / beads;
      final p = c + Offset(math.cos(a), math.sin(a)) * r;
      final on = i < filled.floor();
      final next = i == filled.floor();
      if (next) {
        canvas.drawCircle(p, bead + 5, Paint()..color = accent.withValues(alpha: 0.3));
      }
      canvas.drawCircle(
        p,
        next ? bead + 1.5 : bead,
        Paint()..color = on ? ink : (next ? accent : ink.withValues(alpha: 0.14)),
      );
    }
  }

  @override
  bool shouldRepaint(_BeadsPainter o) => o.progress != progress || o.beads != beads || o.ink != ink;
}
