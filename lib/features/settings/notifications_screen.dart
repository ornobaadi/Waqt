import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/app_state.dart';
import '../../app/reminder_links.dart';
import '../../app/sync.dart';
import '../../core/config/runtime.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../core/utils/digits.dart';
import '../../core/widgets/waqt_widgets.dart';
import '../../data/user/notification_prefs.dart';
import '../../domain/notifications/reminder_planner.dart';
import '../../l10n/app_localizations.dart';
import '../../platform/notifications/notification_service.dart';
import 'reminder_preview.dart';

final permissionStatusProvider = FutureProvider.autoDispose<PermissionStatus>(
  (ref) => ref.watch(notificationServiceProvider).status(),
);

/// Reminders. When they are off, it makes the case and shows what they look
/// like; when on, it shows the next ones this phone will actually get. Then
/// the choices, grouped, each with when it comes and a preview.
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

  /// One tap: the recommended set, the permission, and a fresh schedule.
  Future<void> _turnOn() async {
    ref.read(notificationPrefsProvider.notifier).enableRecommended();
    if (Runtime.hasPlatformPlugins) await ref.read(notificationServiceProvider).requestNotifications();
    ref.invalidate(permissionStatusProvider);
    await syncNow(ref);
  }

  Future<void> _test(ReminderTopic topic, DateTime? at) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (Runtime.hasPlatformPlugins) {
      await ref
          .read(notificationServiceProvider)
          .showNow(
            title: l.remTitle(topic.name),
            body: l.remBody(topic.name),
            sound: ref.read(notificationPrefsProvider).sound,
            payload: reminderPayload(topic, at ?? DateTime.now()),
          );
    }
    messenger.showSnackBar(SnackBar(content: Text(l.remTestSent)));
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
    final upcoming = ref.watch(upcomingRemindersProvider);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final off = prefs.enabled.isEmpty || (status != null && !status.notifications);
    final allOk = status == null || (status.notifications && status.exact && status.battery);

    Widget statusGroup(PermissionStatus status) => RowGroup(
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
    );

    String groupName(ReminderGroup g) => switch (g) {
      ReminderGroup.special => l.remGroupSpecial,
      ReminderGroup.friday => l.remGroupFriday,
      ReminderGroup.ramadan => l.remGroupRamadan,
      ReminderGroup.daily => l.remGroupDaily,
    };

    return Scaffold(
      backgroundColor: t.ground,
      appBar: AppBar(
        backgroundColor: t.ground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: t.ink,
        title: Text(l.notifTitle, style: WaqtText.titleSmall.copyWith(color: t.ink)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, 0, WaqtSpace.screen, WaqtSpace.x12),
        children: [
          if (off) ...[
            // The case for reminders, and what they look like.
            const SizedBox(height: WaqtSpace.x2),
            Text(l.remHeroTitle, style: WaqtText.title.copyWith(color: t.ink)),
            const SizedBox(height: WaqtSpace.x2),
            Text(l.remHeroBody, style: WaqtText.body.copyWith(color: t.inkMuted)),
            const SizedBox(height: WaqtSpace.x5),
            const ReminderPreview(topic: ReminderTopic.arafah, compact: true),
            const SizedBox(height: WaqtSpace.x3),
            const ReminderPreview(topic: ReminderTopic.fridayLastHour, compact: true),
            const SizedBox(height: WaqtSpace.x5),
            FilledButton.icon(
              onPressed: _turnOn,
              icon: const Icon(Icons.notifications_active_outlined),
              label: Text(l.remTurnOn),
              style: FilledButton.styleFrom(
                backgroundColor: t.ink,
                foregroundColor: t.ground,
                minimumSize: const Size.fromHeight(52),
                shape: const StadiumBorder(),
                textStyle: WaqtText.bodyStrong,
              ),
            ),
          ] else ...[
            SectionLabel(l.remComingUp),
            if (upcoming.isEmpty)
              Text(l.remNothingSoon, style: WaqtText.label.copyWith(color: t.inkMuted))
            else
              for (final r in upcoming.take(3)) ...[
                ReminderPreview(topic: r.topic, at: r.at),
                const SizedBox(height: WaqtSpace.x3),
              ],
          ],
          // Something blocking delivery: say so before the choices.
          if (status != null && !allOk && !off) ...[SectionLabel(l.notifStatus), statusGroup(status)],
          for (final g in ReminderGroup.values) ...[
            SectionLabel(groupName(g)),
            RowGroup(
              children: [
                for (final k in ReminderKind.values.where((k) => k.group == g))
                  _SwitchRow(
                    title: l.remKind(k.name),
                    hint: l.remWhen(k.name),
                    value: prefs.enabled.contains(k),
                    onChanged: (v) => notifier.toggle(k, v),
                    onPreview: () => showReminderPreview(context, k),
                    previewLabel: l.remPreview,
                  ),
              ],
            ),
            if (g == ReminderGroup.daily)
              Padding(
                padding: const EdgeInsets.fromLTRB(WaqtSpace.x1, WaqtSpace.x2, WaqtSpace.x1, 0),
                child: Text(l.remDailyNote, style: WaqtText.caption.copyWith(color: t.inkMuted)),
              ),
          ],
          const SizedBox(height: WaqtSpace.x4),
          RowGroup(
            children: [
              _SwitchRow(title: l.notifSound, hint: l.notifSoundHint, value: prefs.sound, onChanged: notifier.setSound),
              RowTile(
                title: l.remTest,
                onTap: () => _test(upcoming.firstOrNull?.topic ?? ReminderTopic.jumuah, upcoming.firstOrNull?.at),
              ),
            ],
          ),
          if (status != null && (allOk || off)) ...[SectionLabel(l.notifStatus), statusGroup(status)],
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
  const _SwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
    this.hint,
    this.onPreview,
    this.previewLabel,
  });
  final String title;
  final String? hint;
  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onPreview;
  final String? previewLabel;

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
            padding: const EdgeInsetsDirectional.fromSTEB(WaqtSpace.x3, WaqtSpace.x2, WaqtSpace.x2, WaqtSpace.x2),
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
                if (onPreview != null)
                  IconButton(
                    tooltip: previewLabel,
                    onPressed: onPreview,
                    icon: Icon(Icons.visibility_outlined, size: 20, color: t.inkMuted),
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
