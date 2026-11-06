import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/app_state.dart';
import '../../core/clock/clock.dart';
import '../../core/config/flavor.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../core/widgets/waqt_widgets.dart';
import '../common/labels.dart';
import '../../l10n/app_localizations.dart';

/// QA tools: fake clock + moment palette preview. Dev flavor / debug only.
class DeveloperScreen extends ConsumerWidget {
  const DeveloperScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = ref.watch(nowProvider).value ?? DateTime.now();
    final faked = ref.watch(fakeClockProvider) != null;
    final clock = ref.read(fakeClockProvider.notifier);
    final palette = ref.watch(paletteOverrideProvider);
    final timeline = ref.watch(momentSnapshotProvider.select((s) => s?.timeline));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: t.ground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: t.ink,
        title: Text(l.debugTitle, style: WaqtText.titleSmall.copyWith(color: t.ink)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, 0, WaqtSpace.screen, WaqtSpace.x12),
        children: [
          SectionLabel(l.debugClock),
          Container(
            padding: const EdgeInsets.all(WaqtSpace.x4),
            decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(WaqtRadii.strip)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  faked ? l.debugClockFaked : l.debugClockReal,
                  style: WaqtText.overline.copyWith(color: faked ? t.ink : t.inkMuted),
                ),
                const SizedBox(height: WaqtSpace.x2),
                Text(DateFormat.Hms(locale).format(now), style: WaqtText.title.copyWith(color: t.ink)),
                Text(DateFormat.yMMMEd(locale).format(now), style: WaqtText.label.copyWith(color: t.inkMuted)),
                const SizedBox(height: WaqtSpace.x4),
                Wrap(
                  spacing: WaqtSpace.x2,
                  runSpacing: WaqtSpace.x2,
                  children: [
                    _Chip('−1h', () => clock.shift(const Duration(hours: -1))),
                    _Chip('+1h', () => clock.shift(const Duration(hours: 1))),
                    _Chip('+15m', () => clock.shift(const Duration(minutes: 15))),
                    _Chip('+1d', () => clock.shift(const Duration(days: 1))),
                    _Chip(l.debugPickDate, () => _pickDate(context, ref, now)),
                    _Chip(l.debugPickTime, () => _pickTime(context, ref, now)),
                    if (faked) _Chip(l.debugReset, clock.reset, strong: true),
                  ],
                ),
              ],
            ),
          ),
          if (timeline != null) ...[
            SectionLabel(l.debugJump),
            Wrap(
              spacing: WaqtSpace.x2,
              runSpacing: WaqtSpace.x2,
              children: [
                for (final m in timeline)
                  // One minute in, so the moment is clearly active.
                  _Chip(l.moment(m), () => clock.jumpTo(m.window.start.add(const Duration(minutes: 1)))),
              ],
            ),
          ],
          SectionLabel(l.debugPalette),
          Wrap(
            spacing: WaqtSpace.x3,
            runSpacing: WaqtSpace.x3,
            children: [
              _Swatch(
                label: l.debugPaletteAuto,
                palette: MomentPalette.dhuhr,
                selected: palette == null,
                onTap: () => ref.read(paletteOverrideProvider.notifier).set(null),
                auto: true,
              ),
              for (final p in MomentPalette.values)
                _Swatch(
                  label: _name(l, p),
                  palette: p,
                  selected: palette == p,
                  onTap: () => ref.read(paletteOverrideProvider.notifier).set(p),
                ),
            ],
          ),
          SectionLabel(l.debugBuild),
          RowGroup(
            children: [
              RowTile(title: 'Flavor', value: AppConfig.flavor.name),
              const RowTile(title: 'Application ID', value: 'com.ornobaadi.waqt'),
            ],
          ),
        ],
      ),
    );
  }

  static String _name(AppLocalizations l, MomentPalette p) => switch (p) {
    MomentPalette.fajr => l.prayerFajr,
    MomentPalette.dhuhr => l.prayerDhuhr,
    MomentPalette.asr => l.prayerAsr,
    MomentPalette.maghrib => l.prayerMaghrib,
    MomentPalette.night => l.momentNight,
    MomentPalette.bedtime => l.momentBedtime,
  };

  Future<void> _pickDate(BuildContext context, WidgetRef ref, DateTime now) async {
    final d = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d == null) return;
    ref.read(fakeClockProvider.notifier).jumpTo(DateTime(d.year, d.month, d.day, now.hour, now.minute, now.second));
  }

  Future<void> _pickTime(BuildContext context, WidgetRef ref, DateTime now) async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(now));
    if (t == null) return;
    ref.read(fakeClockProvider.notifier).jumpTo(DateTime(now.year, now.month, now.day, t.hour, t.minute));
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label, this.onTap, {this.strong = false});
  final String label;
  final VoidCallback onTap;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    return Material(
      color: strong ? t.ink : t.ground,
      shape: StadiumBorder(side: BorderSide(color: t.hairline)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: WaqtSpace.minTouch, minWidth: WaqtSpace.minTouch),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x4),
            child: Center(
              widthFactor: 1,
              child: Text(label, style: WaqtText.label.copyWith(color: strong ? t.ground : t.ink)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows each palette as it actually renders: ground, ink line, accent dot.
class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.label,
    required this.palette,
    required this.selected,
    required this.onTap,
    this.auto = false,
  });
  final String label;
  final MomentPalette palette;
  final bool selected;
  final bool auto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 96,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: WaqtMotion.ui,
                curve: WaqtMotion.ease,
                width: double.infinity,
                height: 72,
                padding: const EdgeInsets.all(WaqtSpace.x3),
                decoration: BoxDecoration(
                  color: palette.ground,
                  borderRadius: BorderRadius.circular(WaqtRadii.row),
                  border: Border.all(color: selected ? t.ink : t.hairline, width: selected ? 2 : 1),
                ),
                child: auto
                    ? Center(
                        child: Text('A', style: WaqtText.titleSmall.copyWith(color: palette.ink)),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(color: palette.accent, shape: BoxShape.circle),
                          ),
                          const Spacer(),
                          Container(
                            height: 4,
                            width: 44,
                            decoration: BoxDecoration(color: palette.ink, borderRadius: BorderRadius.circular(2)),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 4,
                            width: 28,
                            decoration: BoxDecoration(
                              color: palette.ink.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: WaqtSpace.x2),
              ExcludeSemantics(
                child: Text(label, style: WaqtText.caption.copyWith(color: selected ? t.ink : t.inkMuted)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
