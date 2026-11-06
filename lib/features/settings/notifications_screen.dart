import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/sync.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../core/utils/digits.dart';
import '../../core/widgets/waqt_widgets.dart';
import '../../data/user/notification_prefs.dart';
import '../../domain/notifications/reminder_planner.dart';
import '../../l10n/app_localizations.dart';
import '../../platform/notifications/notification_service.dart';
import '../common/labels.dart';

final permissionStatusProvider = FutureProvider.autoDispose<PermissionStatus>(
  (ref) => ref.watch(notificationServiceProvider).status(),
);

/// Reminders: permissions first (with the why), then the choices.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Coming back from system settings: re-read what the user changed there.
  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.resumed) ref.invalidate(permissionStatusProvider);
  }

  Future<void> _after(Future<Object?> action) async {
    await action;
    ref.invalidate(permissionStatusProvider);
    await syncNow(ref);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final status = ref.watch(permissionStatusProvider).value;
    final prefs = ref.watch(notificationPrefsProvider);
    final notifier = ref.read(notificationPrefsProvider.notifier);
    final service = ref.read(notificationServiceProvider);
    final last = ref.watch(lastSyncProvider);
    final locale = Localizations.localeOf(context).toLanguageTag();

    Widget toggle(ReminderKind k) => _SwitchRow(
      title: l.momentId(k.moment),
      value: prefs.enabled.contains(k),
      onChanged: (v) => notifier.toggle(k, v),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: t.ground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: t.ink,
        title: Text(l.notifTitle, style: WaqtText.titleSmall.copyWith(color: t.ink)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, 0, WaqtSpace.screen, WaqtSpace.x12),
        children: [
          if (status != null) ...[
            SectionLabel(l.notifStatus),
            RowGroup(
              children: [
                _StatusRow(
                  title: l.notifPermission,
                  ok: status.notifications,
                  okLabel: l.notifAllowed,
                  fixLabel: l.notifAllow,
                  onFix: () => _after(service.requestNotifications()),
                ),
                _StatusRow(
                  title: l.notifExact,
                  hint: l.notifExactHint,
                  ok: status.exact,
                  okLabel: l.notifAllowed,
                  fixLabel: l.notifAllow,
                  onFix: () => _after(service.requestExact()),
                ),
                _StatusRow(
                  title: l.notifBattery,
                  hint: status.battery
                      ? null
                      : status.aggressiveOem && status.manufacturer != null
                      ? l.notifBatteryHintOem(_titleCase(status.manufacturer!))
                      : l.notifBatteryHint,
                  ok: status.battery,
                  okLabel: l.notifBatteryOk,
                  fixLabel: l.notifBatteryFix,
                  onFix: service.openBatterySettings,
                ),
              ],
            ),
          ],
          SectionLabel(l.notifMoments),
          RowGroup(children: [for (final k in ReminderKind.values) toggle(k)]),
          const SizedBox(height: WaqtSpace.x4),
          RowGroup(
            children: [
              _SwitchRow(title: l.notifSound, hint: l.notifSoundHint, value: prefs.sound, onChanged: notifier.setSound),
            ],
          ),
          const SizedBox(height: WaqtSpace.x6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x1),
            child: Text(
              last == null || last.count == 0 || last.until == null
                  ? l.notifNone
                  : l.notifScheduled(LocaleDigits(locale)(last.count), DateFormat.MMMEd(locale).format(last.until!)),
              style: WaqtText.caption.copyWith(color: t.inkMuted),
            ),
          ),
        ],
      ),
    );
  }

  static String _titleCase(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.title,
    required this.ok,
    required this.okLabel,
    required this.fixLabel,
    required this.onFix,
    this.hint,
  });
  final String title;
  final String? hint;
  final bool ok;
  final String okLabel;
  final String fixLabel;
  final VoidCallback onFix;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x3, vertical: WaqtSpace.x2),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: WaqtText.bodyStrong.copyWith(color: t.ink)),
                  if (hint != null) ...[
                    const SizedBox(height: 2),
                    Text(hint!, style: WaqtText.caption.copyWith(color: t.inkMuted)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: WaqtSpace.x3),
            if (ok)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, size: 18, color: t.ink),
                  const SizedBox(width: 6),
                  Text(okLabel, style: WaqtText.label.copyWith(color: t.ink)),
                ],
              )
            else
              FilledButton(
                onPressed: onFix,
                style: FilledButton.styleFrom(
                  backgroundColor: t.ink,
                  foregroundColor: t.ground,
                  minimumSize: const Size(WaqtSpace.minTouch, 40),
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  fixLabel,
                  style: WaqtText.label.copyWith(color: t.ground, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({required this.title, required this.value, required this.onChanged, this.hint});
  final String title;
  final String? hint;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    return MergeSemantics(
      child: InkWell(
        borderRadius: BorderRadius.circular(WaqtRadii.row),
        onTap: () => onChanged(!value),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x3, vertical: WaqtSpace.x2),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: WaqtText.bodyStrong.copyWith(color: t.ink)),
                      if (hint != null) ...[
                        const SizedBox(height: 2),
                        Text(hint!, style: WaqtText.caption.copyWith(color: t.inkMuted)),
                      ],
                    ],
                  ),
                ),
                Switch(
                  value: value,
                  onChanged: onChanged,
                  activeThumbColor: t.ground,
                  activeTrackColor: t.ink,
                  inactiveThumbColor: t.ink.withValues(alpha: 0.55),
                  inactiveTrackColor: t.ink.withValues(alpha: 0.08),
                  trackOutlineColor: WidgetStatePropertyAll(t.ink.withValues(alpha: 0.2)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
