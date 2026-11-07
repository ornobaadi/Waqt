import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../core/utils/digits.dart';
import '../../l10n/app_localizations.dart';
import 'dhikr.dart';

class CounterState {
  const CounterState({this.routine = 0, this.step = 0, this.count = 0, this.freeTarget = 33});
  final int routine;
  final int step;
  final int count;
  final int freeTarget;

  DhikrRoutine get r => dhikrRoutines[routine];
  Dhikr get dhikr => r.steps[step];
  bool get free => dhikr.arabic == null;
  int get target => free ? freeTarget : dhikr.target;

  /// A set runs once through its steps; a single dhikr counts rounds.
  int get inRound => r.isSet ? count : count % target;
  int get round => r.isSet ? 1 : count ~/ target + 1;
  bool get finished => r.isSet && step == r.steps.length - 1 && count >= target;

  CounterState copy({int? routine, int? step, int? count, int? freeTarget}) => CounterState(
    routine: routine ?? this.routine,
    step: step ?? this.step,
    count: count ?? this.count,
    freeTarget: freeTarget ?? this.freeTarget,
  );
}

class CounterNotifier extends Notifier<CounterState> {
  @override
  CounterState build() => const CounterState();

  /// Returns true when this tap completed a round or a step.
  bool tap() {
    final s = state;
    if (s.finished) return false;
    final c = s.count + 1;
    if (s.r.isSet && c >= s.target && s.step < s.r.steps.length - 1) {
      state = s.copy(step: s.step + 1, count: 0);
      return true;
    }
    state = s.copy(count: c);
    return s.r.isSet ? state.finished : state.inRound == 0;
  }

  void reset() => state = state.copy(step: 0, count: 0);
  void setTarget(int t) => state = state.copy(freeTarget: t, count: 0);
  void choose(int routine) => state = CounterState(routine: routine, freeTarget: state.freeTarget);
}

final counterProvider = NotifierProvider<CounterNotifier, CounterState>(CounterNotifier.new);

/// A misbaha: the whole screen is the button, so it works without looking.
/// The chosen dhikr is shown above the beads; tap its name to change it.
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
          if (s.free)
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
                _DhikrHeader(state: s, numbers: n),
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
                                  Text(s.r.isSet ? '/ ${n(s.target)}' : l.counterRound(n(s.round)), style: WaqtText.label.copyWith(color: t.inkMuted)),
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

/// What is being said, and the way to change it.
class _DhikrHeader extends ConsumerWidget {
  const _DhikrHeader({required this.state, required this.numbers});
  final CounterState state;
  final LocaleDigits numbers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final d = state.dhikr;
    return Padding(
      padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, WaqtSpace.x4, WaqtSpace.screen, 0),
      child: Column(
        children: [
          if (d.arabic != null) ...[
            AnimatedSwitcher(
              duration: WaqtMotion.ui,
              child: Text(
                d.arabic!,
                key: ValueKey(d.id),
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: WaqtText.arabic.copyWith(color: t.ink, fontSize: 34),
              ),
            ),
            const SizedBox(height: WaqtSpace.x1),
            Text(
              state.r.isSet
                  ? '${d.latin} · ${l.counterStep(numbers(state.step + 1), numbers(state.r.steps.length))}'
                  : d.latin,
              style: WaqtText.label.copyWith(color: t.inkMuted),
            ),
          ],
          const SizedBox(height: WaqtSpace.x3),
          ActionChip(
            avatar: Icon(Icons.swap_horiz_rounded, size: 18, color: t.ink),
            label: Text(l.counterChoose),
            onPressed: () => _pick(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _pick(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final i = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      backgroundColor: t.ground,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final (i, r) in dhikrRoutines.indexed)
              ListTile(
                selected: i == state.routine,
                title: Text(
                  r.id == 'free' ? l.counterFree : (r.isSet ? l.counterAfterSalah : r.steps.single.latin),
                  style: WaqtText.bodyStrong.copyWith(color: t.ink),
                ),
                subtitle: Text(
                  r.id == 'free'
                      ? l.counterFreeHint
                      : r.steps.map((d) => '${d.arabic} ×${numbers(d.target)}').join('  ·  '),
                  style: WaqtText.label.copyWith(color: t.inkMuted),
                ),
                onTap: () => Navigator.pop(ctx, i),
              ),
          ],
        ),
      ),
    );
    if (i != null) ref.read(counterProvider.notifier).choose(i);
  }
}
