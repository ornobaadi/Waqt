import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/notifications/reminder_planner.dart';

class PermissionStatus {
  const PermissionStatus({required this.notifications, required this.exact, required this.battery, this.manufacturer});
  final bool notifications;
  final bool exact;

  /// True when the app is exempt from battery optimisation.
  final bool battery;
  final String? manufacturer;

  /// OEMs known to kill background alarms aggressively.
  bool get aggressiveOem {
    final m = manufacturer?.toLowerCase() ?? '';
    return const [
      'xiaomi',
      'redmi',
      'poco',
      'oppo',
      'realme',
      'vivo',
      'oneplus',
      'huawei',
      'honor',
      'samsung',
      'tecno',
      'infinix',
    ].any(m.contains);
  }
}

/// Thin wrapper over flutter_local_notifications. All decisions about *what*
/// to schedule live in [ReminderPlanner]; this only talks to the platform.
class NotificationService {
  NotificationService();

  final _plugin = FlutterLocalNotificationsPlugin();
  static const _battery = MethodChannel('waqt/battery');
  bool _ready = false;
  String? _zone;

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  Future<void> init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    await _syncZone();
    await _plugin.initialize(
      settings: const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
    );
    _ready = true;
  }

  /// Device zone can change (travel); re-read before every schedule.
  Future<void> _syncZone() async {
    try {
      final id = (await FlutterTimezone.getLocalTimezone()).identifier;
      if (id != _zone) {
        tz.setLocalLocation(tz.getLocation(id));
        _zone = id;
      }
    } on Object {
      // Unknown zone id: keep UTC offsets correct by falling back to UTC
      // arithmetic. TZDateTime.from below still maps instants exactly.
    }
  }

  Future<PermissionStatus> status() async {
    final a = _android;
    bool battery = true;
    String? maker;
    try {
      battery = await _battery.invokeMethod<bool>('isIgnoring') ?? true;
      maker = await _battery.invokeMethod<String>('manufacturer');
    } on PlatformException {
      // Not Android.
    } on MissingPluginException {
      // Not Android.
    }
    return PermissionStatus(
      notifications: await a?.areNotificationsEnabled() ?? true,
      exact: await a?.canScheduleExactNotifications() ?? true,
      battery: battery,
      manufacturer: maker,
    );
  }

  Future<bool> requestNotifications() async => await _android?.requestNotificationsPermission() ?? true;
  Future<bool> requestExact() async => await _android?.requestExactAlarmsPermission() ?? true;
  Future<void> openBatterySettings() async {
    try {
      await _battery.invokeMethod<bool>('openSettings');
    } on Object {
      // Ignore: not available on this platform.
    }
  }

  static AndroidNotificationDetails _details(ReminderKind k, bool sound) => k.prayer
      ? AndroidNotificationDetails(
          sound ? 'prayer' : 'prayer_silent',
          sound ? 'Prayer times' : 'Prayer times (silent)',
          importance: Importance.high,
          priority: Priority.high,
          playSound: sound,
          category: AndroidNotificationCategory.reminder,
        )
      : const AndroidNotificationDetails(
          'moments',
          'Moments',
          importance: Importance.defaultImportance,
          category: AndroidNotificationCategory.reminder,
        );

  /// Replaces everything previously scheduled.
  Future<int> schedule(
    List<PlannedReminder> reminders, {
    required bool sound,
    required String Function(ReminderKind) title,
    required String Function(PlannedReminder) body,
  }) async {
    await init();
    await _syncZone();
    await _plugin.cancelAll();
    final exact = await _android?.canScheduleExactNotifications() ?? true;
    for (final r in reminders) {
      await _plugin.zonedSchedule(
        id: r.id,
        title: title(r.kind),
        body: body(r),
        scheduledDate: tz.TZDateTime.from(r.at, tz.local),
        notificationDetails: NotificationDetails(android: _details(r.kind, sound)),
        androidScheduleMode: r.kind.prayer && exact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        payload: r.kind.name,
      );
    }
    return reminders.length;
  }
}
