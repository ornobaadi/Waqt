import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/user/user_prefs.dart';

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

/// Vibrate on each count. Off by default: the count is felt in the words, and
/// only the end of a round is marked.
class CounterHaptics extends Notifier<bool> {
  static const _key = 'counter.haptics.v1';

  @override
  bool build() => ref.read(sharedPrefsProvider).getBool(_key) ?? false;

  void toggle() {
    state = !state;
    ref.read(sharedPrefsProvider).setBool(_key, state);
  }
}

final counterHapticsProvider = NotifierProvider<CounterHaptics, bool>(CounterHaptics.new);

/// A misbaha built around the words, not a number. The phrase sits in a
/// slowly brightening light; each count sends one soft ring outward; the
/// round closes as a thin circle. The whole screen is the button.
class CounterScreen extends ConsumerStatefulWidget {
  const CounterScreen({super.key});

  static const targets = [33, 99, 100];

  @override
  ConsumerState<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends ConsumerState<CounterScreen> with TickerProviderStateMixin {
  final _ripples = <AnimationController>[];

  @override
  void dispose() {
    for (final c in _ripples) {
      c.dispose();
    }
    super.dispose();
  }

  void _count() {
    final done = ref.read(counterProvider.notifier).tap();
    if (done) {
      HapticFeedback.mediumImpact();
    } else if (ref.read(counterHapticsProvider)) {
      HapticFeedback.selectionClick();
    }
    if (MediaQuery.disableAnimationsOf(context)) return;
    final c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    c.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        setState(() => _ripples.remove(c));
        c.dispose();
      }
    });
    setState(() => _ripples.add(c));
    c.forward();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final s = ref.watch(counterProvider);
    final haptics = ref.watch(counterHapticsProvider);
    final n = LocaleDigits(Localizations.localeOf(context).toLanguageTag());
    final reduce = MediaQuery.disableAnimationsOf(context);
    final d = s.dhikr;
    final progress = s.finished ? 1.0 : s.inRound / s.target;

    return Scaffold(
      backgroundColor: t.ground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: t.ink,
        title: TextButton.icon(
          onPressed: () => _pick(context, s, n),
          style: TextButton.styleFrom(foregroundColor: t.ink),
          icon: const Icon(Icons.expand_more_rounded),
          iconAlignment: IconAlignment.end,
          label: Text(
            _routineName(l, s.r),
            style: WaqtText.bodyStrong.copyWith(color: t.ink),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        actions: [
          if (s.free)
            PopupMenuButton<int>(
              tooltip: l.counterTarget,
              initialValue: s.target,
              onSelected: ref.read(counterProvider.notifier).setTarget,
              itemBuilder: (_) => [for (final x in CounterScreen.targets) PopupMenuItem(value: x, child: Text(n(x)))],
              icon: Text('×${n(s.target)}', style: WaqtText.label.copyWith(color: t.ink)),
            ),
          IconButton(
            tooltip: l.counterHaptics,
            onPressed: ref.read(counterHapticsProvider.notifier).toggle,
            icon: Icon(haptics ? Icons.vibration_rounded : Icons.mobile_off_rounded, color: t.inkMuted),
          ),
          IconButton(
            tooltip: l.counterReset,
            onPressed: s.count == 0 && s.step == 0 ? null : ref.read(counterProvider.notifier).reset,
            icon: Icon(Icons.restart_alt_rounded, color: t.inkMuted),
          ),
        ],
      ),
      body: Semantics(
        button: true,
        label: '${d.latin.isEmpty ? l.counterTap : d.latin}, ${n(s.inRound)} / ${n(s.target)}',
        onTap: _count,
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _count,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, box) {
                final size = math.min(box.maxWidth - 2 * WaqtSpace.screen, box.maxHeight * 0.62);
                return Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: SizedBox.square(
                          dimension: size,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(end: progress),
                            duration: reduce ? Duration.zero : const Duration(milliseconds: 420),
                            curve: Curves.easeOutCubic,
                            builder: (context, p, child) => CustomPaint(
                              painter: _LightPainter(
                                progress: p,
                                ripples: List.of(_ripples),
                                ink: t.ink,
                                accent: t.accent,
                                repaint: Listenable.merge(_ripples),
                              ),
                              child: child,
                            ),
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(size * 0.16),
                                child: AnimatedSwitcher(
                                  duration: reduce ? Duration.zero : const Duration(milliseconds: 600),
                                  child: _Words(key: ValueKey(d.id), dhikr: d),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      '${n(s.finished ? s.target : s.inRound)} / ${n(s.target)}',
                      style: WaqtText.title.copyWith(color: t.ink, fontFeatures: const [FontFeature.tabularFigures()]),
                    ),
                    const SizedBox(height: WaqtSpace.x1),
                    Text(
                      s.r.isSet
                          ? l.counterStep(n(s.step + 1), n(s.r.steps.length))
                          : s.round > 1
                          ? l.counterRound(n(s.round))
                          : l.counterTap,
                      style: WaqtText.label.copyWith(color: t.inkMuted),
                    ),
                    const SizedBox(height: WaqtSpace.x8),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  static String _routineName(AppLocalizations l, DhikrRoutine r) =>
      r.id == 'free' ? l.counterFree : (r.isSet ? l.counterAfterSalahName : r.steps.single.latin);

  Future<void> _pick(BuildContext context, CounterState s, LocaleDigits n) async {
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
          padding: const EdgeInsets.only(bottom: WaqtSpace.x4),
          children: [
            for (final (i, r) in dhikrRoutines.indexed)
              ListTile(
                selected: i == s.routine,
                selectedTileColor: t.ink.withValues(alpha: 0.06),
                title: Text(_routineName(l, r), style: WaqtText.bodyStrong.copyWith(color: t.ink)),
                subtitle: r.id == 'free'
                    ? Text(l.counterFreeHint, style: WaqtText.label.copyWith(color: t.inkMuted))
                    : null,
                trailing: r.id == 'free'
                    ? null
                    : Text(
                        r.steps.map((d) => n(d.target)).join(' · '),
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

/// The phrase itself, large, with how it is said beneath.
class _Words extends StatelessWidget {
  const _Words({super.key, required this.dhikr});
  final Dhikr dhikr;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    if (dhikr.arabic == null) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            dhikr.arabic!,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: WaqtText.arabic.copyWith(color: t.ink, fontSize: 44, height: 1.5),
          ),
        ),
        const SizedBox(height: WaqtSpace.x2),
        Text(
          dhikr.latin,
          textAlign: TextAlign.center,
          style: WaqtText.body.copyWith(color: t.inkMuted, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

/// A light that grows as the round fills, the round as a fine circle, and a
/// soft ring for each count.
class _LightPainter extends CustomPainter {
  _LightPainter({
    required this.progress,
    required this.ripples,
    required this.ink,
    required this.accent,
    super.repaint,
  });
  final double progress;
  final List<Animation<double>> ripples;
  final Color ink, accent;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;

    // The light: faint at the start of a round, warm by its end.
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            accent.withValues(alpha: 0.10 + 0.32 * progress),
            accent.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );

    // The round: a hairline track and the part already said.
    final ring = r * 0.86;
    canvas.drawCircle(
      c,
      ring,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = ink.withValues(alpha: 0.12),
    );
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: ring),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..color = ink,
      );
    }

    // One ring per count, rising from the words and fading.
    for (final a in ripples) {
      final e = Curves.easeOut.transform(a.value);
      canvas.drawCircle(
        c,
        ring * (0.45 + 0.55 * e),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = accent.withValues(alpha: (1 - e) * 0.7),
      );
    }
  }

  @override
  bool shouldRepaint(_LightPainter o) =>
      o.progress != progress || o.ripples.length != ripples.length || o.ink != ink || o.accent != accent;
}
