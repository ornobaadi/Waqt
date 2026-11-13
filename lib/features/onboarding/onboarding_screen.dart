import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/app_state.dart';
import '../../app/sync.dart';
import '../../core/config/runtime.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../data/user/notification_prefs.dart';
import '../../data/user/user_prefs.dart';
import '../../domain/notifications/reminder_planner.dart';
import '../../l10n/app_localizations.dart';
import '../../platform/haptics/haptics.dart';
import '../../platform/location/gps.dart';
import '../common/labels.dart';
import '../settings/reminder_preview.dart';

const onboardedKey = 'onboarded.v1';

/// First launch only: someone who already has a place (an older install) is
/// never sent back through it.
bool needsOnboarding(SharedPreferences sp) => !(sp.getBool(onboardedKey) ?? false) && sp.getString('place.v1') == null;

/// The language list, each name in its own script.
const _languages = [
  ('en', 'English', null),
  ('ar', 'العربية', WaqtFonts.arabic),
  ('ur', 'اردو', WaqtFonts.urdu),
  ('bn', 'বাংলা', WaqtFonts.bengali),
  ('id', 'Bahasa Indonesia', null),
  ('tr', 'Türkçe', null),
  ('fr', 'Français', null),
];

/// One look per screen: the sky moves from dawn to sunrise to noon to night.
class _Look {
  const _Look(this.sky, {required this.ink, required this.muted, required this.dark});
  final List<Color> sky;
  final Color ink;
  final Color muted;
  final bool dark;
}

const _paper = Color(0xFFF6F1E6);
const _ink = Color(0xFF1C1814);
const _gold = Color(0xFFE9C46A);

const _looks = [
  _Look(
    [Color(0xFFCDB8E2), Color(0xFFEBD3DA), Color(0xFFF7E6CF), _paper],
    ink: _ink,
    muted: Color(0xFF4E463C),
    dark: false,
  ),
  _Look(
    [Color(0xFFF4B99A), Color(0xFFF8D3B4), Color(0xFFF8E6CF), _paper],
    ink: _ink,
    muted: Color(0xFF4E463C),
    dark: false,
  ),
  _Look(
    [Color(0xFFF6DA92), Color(0xFFF8E8BE), Color(0xFFF6F1E6), _paper],
    ink: _ink,
    muted: Color(0xFF4E463C),
    dark: false,
  ),
  _Look(
    [Color(0xFF0B0F2C), Color(0xFF161B4A), Color(0xFF1D2357), Color(0xFF232A63)],
    ink: Color(0xFFFBF3E2),
    muted: Color(0xB3FBF3E2),
    dark: true,
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _page = 0;

  void _go(int page) {
    Haptics.click();
    setState(() => _page = page);
  }

  Future<void> _finish() async {
    await ref.read(sharedPrefsProvider).setBool(onboardedKey, true);
    if (mounted) context.go('/now');
  }

  @override
  Widget build(BuildContext context) {
    final look = _looks[_page];
    final pages = [
      _WelcomePage(onNext: () => _go(1)),
      _LanguagePage(onNext: () => _go(2)),
      _LocationPage(onNext: () => _go(3)),
      _RemindersPage(onDone: _finish),
    ];
    return PopScope(
      canPop: _page == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _go(_page - 1);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: (look.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
        ),
        child: Scaffold(
          body: AnimatedContainer(
            duration: WaqtMotion.palette,
            curve: WaqtMotion.ease,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: look.sky,
                stops: const [0, 0.35, 0.68, 1],
              ),
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: look.ink),
              child: AnimatedSwitcher(
                duration: WaqtMotion.ui,
                switchInCurve: WaqtMotion.ease,
                switchOutCurve: WaqtMotion.ease,
                transitionBuilder: (child, a) => FadeTransition(
                  opacity: a,
                  child: SlideTransition(
                    position: Tween(begin: const Offset(0, 0.03), end: Offset.zero).animate(a),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(
                  key: ValueKey(_page),
                  child: _Frame(look: look, step: _page, child: pages[_page]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared by every screen: the step marks on top, the content below, and
/// scrolling only when large text needs it.
class _Frame extends StatelessWidget {
  const _Frame({required this.look, required this.step, required this.child});
  final _Look look;
  final int step;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, box) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: box.maxHeight - 44),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    label: l.onbStep(step + 1, 4),
                    child: Row(
                      children: [
                        for (var i = 0; i < 4; i++) ...[
                          AnimatedContainer(
                            duration: WaqtMotion.ui,
                            curve: WaqtMotion.ease,
                            width: i == step ? 22 : 8,
                            height: 4,
                            decoration: BoxDecoration(
                              color: i == step ? look.ink : look.ink.withValues(alpha: look.dark ? 0.25 : 0.2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                      ],
                    ),
                  ),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

TextStyle _headline(Color ink) => WaqtText.title.copyWith(fontSize: 32, height: 1.1, color: ink);

/// Latin scripts in Instrument Serif italic; Arabic, Urdu and Bangla in their
/// own fonts, upright, since the serif has no glyphs for them.
TextStyle _greeting(String lang) {
  const plum = Color(0xFF6A4E7E);
  return switch (lang) {
    'ar' => WaqtText.arabic.copyWith(fontSize: 26, height: 1.4, color: plum),
    'ur' => const TextStyle(fontFamily: WaqtFonts.urdu, fontSize: 24, height: 1.7, color: plum),
    'bn' => const TextStyle(fontFamily: WaqtFonts.bengali, fontSize: 24, height: 1.4, color: plum),
    _ => const TextStyle(
      fontFamily: WaqtFonts.greeting,
      fontStyle: FontStyle.italic,
      fontSize: 30,
      height: 1.1,
      color: plum,
    ),
  };
}

TextStyle _lede(Color ink) => WaqtText.body.copyWith(fontSize: 16, height: 1.45, color: ink);

class _Button extends StatelessWidget {
  const _Button({
    required this.label,
    required this.onTap,
    required this.fill,
    required this.ink,
    this.icon,
    this.busy = false,
  });
  final String label;
  final VoidCallback? onTap;
  final Color fill;
  final Color ink;
  final IconData? icon;
  final bool busy;

  @override
  Widget build(BuildContext context) => Material(
    color: fill,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x4, vertical: WaqtSpace.x3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (busy)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 10),
                  child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: ink)),
                )
              else if (icon != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 10),
                  child: Icon(icon, size: 19, color: ink),
                ),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: WaqtText.bodyStrong.copyWith(fontSize: 17, color: ink),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _QuietButton extends StatelessWidget {
  const _QuietButton({required this.label, required this.onTap, required this.ink, this.outlined = false});
  final String label;
  final VoidCallback onTap;
  final Color ink;
  final bool outlined;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: outlined ? BorderSide(color: ink.withValues(alpha: 0.18), width: 1.5) : BorderSide.none,
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x4, vertical: WaqtSpace.x2),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: WaqtText.bodyStrong.copyWith(fontSize: 16, color: ink.withValues(alpha: outlined ? 1 : 0.8)),
            ),
          ),
        ),
      ),
    ),
  );
}

// ─── Screens ───────────────────────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final look = _looks[0];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Expanded(child: Center(child: _Moon())),
        // A warm, quiet greeting, like the first line of a letter (board 17).
        Text(l.onbGreeting, style: _greeting(Localizations.localeOf(context).languageCode)),
        const SizedBox(height: WaqtSpace.x2),
        Text(l.onbWelcomeTitle, style: _headline(look.ink).copyWith(fontSize: 38, height: 1.08)),
        const SizedBox(height: WaqtSpace.x3),
        Text(l.onbWelcomeBody, style: _lede(look.muted)),
        const SizedBox(height: WaqtSpace.x8),
        _Button(label: l.onbBegin, onTap: onNext, fill: _ink, ink: _paper),
        const SizedBox(height: WaqtSpace.x3),
        Text(
          l.onbWelcomeNote,
          textAlign: TextAlign.center,
          style: WaqtText.label.copyWith(color: const Color(0xFF6E665A)),
        ),
      ],
    );
  }
}

class _LanguagePage extends ConsumerWidget {
  const _LanguagePage({required this.onNext});
  final VoidCallback onNext;

  static String _phoneCode() {
    final code = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return _languages.any((x) => x.$1 == code) ? code : 'en';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final look = _looks[1];
    final phone = _phoneCode();
    final chosen = ref.watch(localeOverrideProvider)?.languageCode ?? phone;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Expanded(child: Center(child: _Tiles())),
        Text(l.onbLanguageTitle, style: _headline(look.ink)),
        const SizedBox(height: WaqtSpace.x2),
        Text(l.onbLanguageBody, style: _lede(look.muted)),
        const SizedBox(height: WaqtSpace.x4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x3),
          decoration: BoxDecoration(
            color: const Color(0xB3FFFBF2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _ink.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: [
              for (final (i, (code, name, font)) in _languages.indexed)
                _LanguageRow(
                  name: name,
                  font: font,
                  note: code == phone ? l.onbPhoneLanguage : null,
                  selected: code == chosen,
                  last: i == _languages.length - 1,
                  onTap: () {
                    Haptics.tick();
                    ref.read(localeOverrideProvider.notifier).set(Locale(code));
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: WaqtSpace.x4),
        _Button(
          label: l.onbContinue,
          fill: _ink,
          ink: _paper,
          onTap: () {
            // Saved even when it matches the phone: the person chose it.
            ref.read(localeOverrideProvider.notifier).set(Locale(chosen));
            onNext();
          },
        ),
      ],
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.name,
    required this.font,
    required this.note,
    required this.selected,
    required this.last,
    required this.onTap,
  });
  final String name;
  final String? font;
  final String? note;
  final bool selected;
  final bool last;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    inMutuallyExclusiveGroup: true,
    child: InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        decoration: BoxDecoration(
          border: last ? null : Border(bottom: BorderSide(color: _ink.withValues(alpha: 0.1))),
        ),
        padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x1, vertical: WaqtSpace.x1),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: WaqtText.bodyStrong.copyWith(fontSize: 16, color: _ink, fontFamily: font, height: 1.3),
              ),
            ),
            if (note != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: WaqtSpace.x2, end: WaqtSpace.x2),
                child: Text(note!, maxLines: 1, style: WaqtText.caption.copyWith(color: const Color(0xFF6E665A))),
              ),
            AnimatedContainer(
              duration: WaqtMotion.fast,
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? _ink : Colors.transparent,
                border: Border.all(color: selected ? _ink : _ink.withValues(alpha: 0.25), width: 1.5),
              ),
              child: selected ? const Icon(Icons.check_rounded, size: 14, color: _paper) : null,
            ),
          ],
        ),
      ),
    ),
  );
}

class _LocationPage extends ConsumerStatefulWidget {
  const _LocationPage({required this.onNext});
  final VoidCallback onNext;

  @override
  ConsumerState<_LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends ConsumerState<_LocationPage> {
  bool _busy = false;
  GpsError? _error;

  Future<void> _locate() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = await locateWithGps(ref);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = err;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final look = _looks[2];
    // A place from GPS or from the city list moves on.
    ref.listen(userPrefsProvider.select((p) => p.place), (_, place) {
      if (place != null) widget.onNext();
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Expanded(child: Center(child: _Globe())),
        Text(l.onbLocationTitle, style: _headline(look.ink)),
        const SizedBox(height: WaqtSpace.x2),
        Text(l.onbLocationBody, style: _lede(look.muted)),
        if (_error != null) ...[
          const SizedBox(height: WaqtSpace.x3),
          Row(
            children: [
              Expanded(
                child: Text(l.gps(_error!), style: WaqtText.label.copyWith(color: const Color(0xFF7A3B1E))),
              ),
              if (_error == GpsError.deniedForever || _error == GpsError.serviceOff)
                TextButton(
                  onPressed: openLocationSettings,
                  style: TextButton.styleFrom(foregroundColor: _ink),
                  child: Text(l.openSettings),
                ),
            ],
          ),
        ],
        const SizedBox(height: WaqtSpace.x8),
        _Button(
          label: _busy ? l.locationLocating : l.locationUseGps,
          icon: Icons.near_me_outlined,
          busy: _busy,
          fill: _ink,
          ink: _paper,
          onTap: _busy ? null : _locate,
        ),
        const SizedBox(height: WaqtSpace.x3),
        _QuietButton(label: l.onbCityInstead, ink: _ink, outlined: true, onTap: () => context.push('/welcome/city')),
      ],
    );
  }
}

class _RemindersPage extends ConsumerWidget {
  const _RemindersPage({required this.onDone});
  final Future<void> Function() onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final look = _looks[3];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Expanded(child: Center(child: _Bell())),
        // The very notification this person could get, in a day card so it
        // reads like the phone's own.
        Theme(
          data: buildWaqtTheme(MomentPalette.dhuhr),
          child: const ReminderPreview(topic: ReminderTopic.arafah, brief: true),
        ),
        const SizedBox(height: WaqtSpace.x6),
        Text(l.onbRemindersTitle, style: _headline(look.ink)),
        const SizedBox(height: WaqtSpace.x2),
        Text(l.onbRemindersBody, style: _lede(look.muted)),
        const SizedBox(height: WaqtSpace.x8),
        _Button(
          label: l.onbRemindersOn,
          fill: _gold,
          ink: const Color(0xFF14110C),
          onTap: () async {
            ref.read(notificationPrefsProvider.notifier)
              ..enableRecommended()
              ..dismissSetup();
            if (Runtime.hasPlatformPlugins) await ref.read(notificationServiceProvider).requestNotifications();
            await onDone();
            unawaited(syncNow(ref));
          },
        ),
        const SizedBox(height: WaqtSpace.x2),
        _QuietButton(
          label: l.onbLater,
          ink: look.ink,
          onTap: () {
            ref.read(notificationPrefsProvider.notifier).dismissSetup();
            onDone();
          },
        ),
      ],
    );
  }
}

// ─── The objects ───────────────────────────────────────────────────────────
// Lit from the top left, with a soft core shadow on the far side and a
// cast shadow below, so each reads as a solid thing in the sky.

/// A repeating 0→1 phase. Still under tests and with reduced motion.
class _Loop extends StatefulWidget {
  const _Loop({required this.period, required this.builder});
  final Duration period;
  final Widget Function(BuildContext, double) builder;

  @override
  State<_Loop> createState() => _LoopState();
}

class _LoopState extends State<_Loop> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: widget.period);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = Runtime.isTest || MediaQuery.disableAnimationsOf(context);
    if (still) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: _c, builder: (c, _) => widget.builder(c, _c.value));
}

double _wave(double v) => math.sin(v * 2 * math.pi);

Widget _glow(double size, Color c) => IgnorePointer(
  child: Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(colors: [c, c.withValues(alpha: 0)], stops: const [0, 0.7]),
    ),
  ),
);

Widget _star(double size, Color c) => Container(
  width: size,
  height: size,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: c,
    boxShadow: [BoxShadow(color: c.withValues(alpha: 0.8), blurRadius: size * 1.4, spreadRadius: size * 0.3)],
  ),
);

Widget _castShadow(double w, Color c) => SizedBox(
  width: w,
  height: w * 0.14,
  child: OverflowBox(
    maxHeight: w,
    child: Transform.scale(
      scaleY: 0.14,
      child: Container(
        width: w,
        height: w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [c, c.withValues(alpha: 0)], stops: const [0, 0.7]),
        ),
      ),
    ),
  ),
);

/// Core shadow over a lit body: clear near the light, dark on the far side.
BoxDecoration _shade(Color c, {BoxShape shape = BoxShape.circle, BorderRadius? radius}) => BoxDecoration(
  shape: shape,
  borderRadius: radius,
  gradient: RadialGradient(
    center: const Alignment(-0.4, -0.5),
    radius: 1.1,
    colors: [c.withValues(alpha: 0), c.withValues(alpha: 0), c],
    stops: const [0, 0.5, 1],
  ),
);

class _Moon extends StatelessWidget {
  const _Moon();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 260,
    height: 250,
    child: _Loop(
      period: const Duration(seconds: 6),
      builder: (context, v) => Stack(
        alignment: Alignment.center,
        children: [
          _glow(240, const Color(0xE6FFF0D2)),
          const PositionedDirectional(start: 34, top: 18, child: _Twinkle(size: 10)),
          const PositionedDirectional(end: 44, top: 4, child: _Twinkle(size: 6)),
          const PositionedDirectional(end: 26, bottom: 46, child: _Twinkle(size: 8)),
          Positioned(bottom: 6, child: _castShadow(150, const Color(0x47502E6E))),
          Transform.translate(
            offset: Offset(0, -5 + 5 * _wave(v)),
            child: Container(
              width: 170,
              height: 170,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Color(0x735A3C78), blurRadius: 50, offset: Offset(0, 30), spreadRadius: -10),
                ],
              ),
              child: ClipOval(
                child: Stack(
                  children: [
                    // The unlit part of the disc, then the lit crescent on top.
                    const Positioned.fill(child: ColoredBox(color: Color(0xEB7A5C96))),
                    Positioned(
                      left: -44,
                      top: -18,
                      width: 170,
                      height: 170,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: Alignment(-0.1, -0.1),
                            radius: 0.8,
                            colors: [Color(0xFFFFFBF1), Color(0xFFF7E3B4), Color(0xFFE3B862), Color(0xFFB98A36)],
                            stops: [0, 0.34, 0.7, 1],
                          ),
                          boxShadow: [BoxShadow(color: Color(0x99E3B862), blurRadius: 16)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _Twinkle extends StatelessWidget {
  const _Twinkle({required this.size, this.color = const Color(0xFFFFF8E6)});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => _star(size, color);
}

class _Tiles extends StatelessWidget {
  const _Tiles();

  Widget _tile(double size, String glyph, List<Color> body, Color ink, Color shade, {String? font, double? fs}) =>
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.17),
          gradient: RadialGradient(center: const Alignment(-0.4, -0.5), radius: 1.2, colors: body),
          boxShadow: [BoxShadow(color: shade, blurRadius: 30, offset: const Offset(0, 22), spreadRadius: -12)],
        ),
        foregroundDecoration: _shade(
          const Color(0x47502E10),
          shape: BoxShape.rectangle,
          radius: BorderRadius.circular(size * 0.17),
        ),
        alignment: Alignment.center,
        child: Text(
          glyph,
          textDirection: TextDirection.ltr,
          style: TextStyle(
            fontFamily: font ?? WaqtFonts.display,
            fontSize: fs ?? size * 0.5,
            fontWeight: FontWeight.w800,
            color: ink,
            height: 1.1,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 280,
    height: 190,
    child: _Loop(
      period: const Duration(seconds: 7),
      builder: (context, v) {
        double rad(double deg) => deg * math.pi / 180;
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _glow(240, const Color(0xE6FFECCD)),
              Positioned(bottom: 2, child: _castShadow(210, const Color(0x40784620))),
              Positioned(
                left: 22,
                top: 58,
                child: Transform.translate(
                  offset: Offset(0, -4.5 + 4.5 * _wave(v)),
                  child: Transform.rotate(
                    angle: rad(-12 + _wave(v)),
                    child: _tile(
                      84,
                      'A',
                      const [Color(0xFFFFFBF1), Color(0xFFF2DDB4), Color(0xFFD4AE6C)],
                      const Color(0xFF5A3F18),
                      const Color(0x808C5028),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 92,
                top: 20,
                child: Transform.translate(
                  offset: Offset(0, -6 + 6 * _wave(v + 0.3)),
                  child: Transform.rotate(
                    angle: rad(4 + _wave(v + 0.3)),
                    child: _tile(
                      96,
                      'ع',
                      const [Color(0xFF4A4038), Color(0xFF24201B), Color(0xFF110E0B)],
                      _gold,
                      const Color(0x8C5A3214),
                      font: WaqtFonts.arabic,
                      fs: 46,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 22,
                top: 62,
                child: Transform.translate(
                  offset: Offset(0, -3.5 + 3.5 * _wave(v + 0.6)),
                  child: Transform.rotate(
                    angle: rad(14 - _wave(v + 0.6)),
                    child: _tile(
                      80,
                      'অ',
                      const [Color(0xFFFFF2D6), Color(0xFFEFC37A), Color(0xFFC08A38)],
                      const Color(0xFF4A3212),
                      const Color(0x808C5028),
                      font: WaqtFonts.bengali,
                      fs: 38,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

class _Globe extends StatelessWidget {
  const _Globe();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 260,
    height: 300,
    child: _Loop(
      period: const Duration(seconds: 5),
      builder: (context, v) {
        final lift = -6 + 6 * _wave(v);
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: 96,
              child: Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: Alignment(-0.36, -0.44),
                    radius: 0.9,
                    colors: [Color(0xFFFFF6DD), Color(0xFFF1D18A), Color(0xFFD8A54A), Color(0xFFA97526)],
                    stops: [0, 0.3, 0.66, 1],
                  ),
                  boxShadow: [
                    BoxShadow(color: Color(0x808C5F1E), blurRadius: 50, offset: Offset(0, 34), spreadRadius: -16),
                  ],
                ),
                foregroundDecoration: _shade(const Color(0x73602E08)),
                child: const ClipOval(child: CustomPaint(painter: _GridPainter())),
              ),
            ),
            // The pin's shadow on the globe shrinks as it lifts.
            Positioned(
              top: 128,
              child: Transform.scale(scale: 1 + lift / 40, child: _castShadow(52, const Color(0x5C3C280A))),
            ),
            Positioned(
              top: 14 + lift,
              child: Transform.rotate(
                angle: -math.pi / 4,
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(44),
                      topRight: Radius.circular(44),
                      bottomRight: Radius.circular(44),
                      bottomLeft: Radius.circular(4),
                    ),
                    gradient: RadialGradient(
                      center: Alignment(-0.4, -0.44),
                      colors: [Color(0xFF5A4E43), Color(0xFF2A231C), Color(0xFF14100C)],
                      stops: [0, 0.5, 1],
                    ),
                    boxShadow: [
                      BoxShadow(color: Color(0x733C280A), blurRadius: 30, offset: Offset(16, 20), spreadRadius: -10),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: Alignment(-0.3, -0.4),
                        colors: [Color(0xFFFFF4D2), _gold, Color(0xFFB8892C)],
                        stops: [0, 0.55, 1],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

/// Latitude and longitude lines, curved as on a sphere.
class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0x66FFFAEB);
    final w = size.width, h = size.height;
    for (final y in [0.26, 0.5, 0.74]) {
      final bow = (y - 0.5) * 0.3 * h;
      canvas.drawPath(
        Path()
          ..moveTo(0, y * h)
          ..quadraticBezierTo(w / 2, y * h + bow.abs() * 0.6 + 6, w, y * h),
        p,
      );
    }
    canvas.drawOval(Rect.fromLTWH(w * 0.28, -h * 0.06, w * 0.5, h * 1.12), p);
    canvas.drawLine(Offset(w * 0.53, -4), Offset(w * 0.53, h + 4), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _Bell extends StatelessWidget {
  const _Bell();

  /// Still for most of the loop, then a short, settling ring.
  static double _swing(double v) {
    if (v < 0.8) return 0;
    final k = (v - 0.8) / 0.2;
    return math.sin(k * math.pi * 4) * (1 - k) * 0.17;
  }

  static const _brass = RadialGradient(
    center: Alignment(-0.3, -0.4),
    colors: [Color(0xFFFFF4D2), Color(0xFFD9A84A), Color(0xFF8E6420)],
    stops: [0, 0.6, 1],
  );

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 260,
    height: 210,
    child: _Loop(
      period: const Duration(seconds: 4),
      builder: (context, v) => Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(top: 0, child: _glow(220, const Color(0x59E9C46A))),
          const PositionedDirectional(start: 20, top: 20, child: _Twinkle(size: 4, color: Color(0xFFFBF3E2))),
          const PositionedDirectional(end: 30, top: 54, child: _Twinkle(size: 5, color: Color(0xFFFBF3E2))),
          const PositionedDirectional(start: 60, top: 180, child: _Twinkle(size: 3, color: Color(0xFFFBF3E2))),
          Positioned(
            top: 18,
            child: Transform.rotate(
              angle: _swing(v),
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 150,
                height: 182,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: _brass),
                    ),
                    Positioned(
                      top: 150,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(shape: BoxShape.circle, gradient: _brass),
                      ),
                    ),
                    Positioned(
                      top: 14,
                      left: 10,
                      right: 10,
                      child: Container(
                        height: 130,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(65), bottom: Radius.circular(18)),
                          gradient: RadialGradient(
                            center: Alignment(-0.36, -0.52),
                            radius: 0.95,
                            colors: [Color(0xFFFFF6DA), Color(0xFFF0CD78), Color(0xFFD29E3E), Color(0xFF94661F)],
                            stops: [0, 0.3, 0.64, 1],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x8C000000),
                              blurRadius: 40,
                              offset: Offset(0, 30),
                              spreadRadius: -12,
                            ),
                          ],
                        ),
                        foregroundDecoration: _shade(
                          const Color(0x735A370A),
                          shape: BoxShape.rectangle,
                          radius: const BorderRadius.vertical(top: Radius.circular(65), bottom: Radius.circular(18)),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 132,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 22,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(11),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFF3D489), Color(0xFFB98A36)],
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x80000000),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                              spreadRadius: -6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
