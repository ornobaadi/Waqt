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

  /// Called with a reminder's payload when the user taps it while the app runs.
  void Function(String? payload)? onTap;

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  Future<void> init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    await _syncZone();
    await _plugin.initialize(
      settings: const InitializationSettings(android: AndroidInitializationSettings('@drawable/ic_notification')),
      onDidReceiveNotificationResponse: (r) => onTap?.call(r.payload),
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

  /// The payload of the reminder whose tap launched the app, if one did.
  Future<String?> launchPayload() async {
    await init();
    final d = await _plugin.getNotificationAppLaunchDetails();
    return d?.didNotificationLaunchApp == true ? d?.notificationResponse?.payload : null;
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

  static AndroidNotificationDetails _details(bool sound, String body) => AndroidNotificationDetails(
    sound ? 'moments' : 'moments_silent',
    sound ? 'Moments' : 'Moments (silent)',
    importance: Importance.high,
    priority: Priority.high,
    playSound: sound,
    category: AndroidNotificationCategory.reminder,
    // The whole message, not one truncated line: the why is what makes it worth a tap.
    styleInformation: BigTextStyleInformation(body),
    color: const Color(0xFF0F1436),
  );

  /// Shows one reminder right away, so the user sees what they will get.
  Future<void> showNow({required String title, required String body, required bool sound, String? payload}) async {
    await init();
    await _plugin.show(
      id: 9999,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(android: _details(sound, body)),
      payload: payload,
    );
  }

  /// Replaces everything previously scheduled.
  Future<int> schedule(
    List<PlannedReminder> reminders, {
    required bool sound,
    required String Function(PlannedReminder) title,
    required String Function(PlannedReminder) body,
    required String Function(PlannedReminder) payload,
  }) async {
    await init();
    await _syncZone();
    await _plugin.cancelAll();
    final exact = await _android?.canScheduleExactNotifications() ?? true;
    for (final r in reminders) {
      final text = body(r);
      await _plugin.zonedSchedule(
        id: r.id,
        title: title(r),
        body: text,
        scheduledDate: tz.TZDateTime.from(r.at, tz.local),
        notificationDetails: NotificationDetails(android: _details(sound, text)),
        androidScheduleMode: exact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload(r),
      );
    }
    return reminders.length;
  }
}
