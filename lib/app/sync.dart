import 'dart:async';
import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/config/runtime.dart';
import '../data/hijri/calendar_sync.dart';
import '../data/user/notification_prefs.dart';
import '../data/user/user_prefs.dart';
import '../domain/moments/moment.dart';
import '../domain/moments/moment_engine.dart';
import '../domain/notifications/reminder_planner.dart';
import '../domain/prayer/prayer_times_service.dart';
import '../domain/time/place_zone.dart';
import '../features/common/labels.dart';
import '../l10n/app_localizations.dart';
import '../platform/notifications/notification_service.dart';
import '../platform/widget/widget_bridge.dart';
import 'app_state.dart';

final notificationServiceProvider = Provider((ref) => NotificationService());

class SyncResult {
  const SyncResult(this.count, this.until);
  final int count;
  final DateTime? until;
}

class LastSync extends Notifier<SyncResult?> {
  @override
  SyncResult? build() => null;
  void set(SyncResult r) => state = r;
}

final lastSyncProvider = NotifierProvider<LastSync, SyncResult?>(LastSync.new);

/// Platform plugins don't exist under `flutter test`.
final bool _platformAvailable = Runtime.hasPlatformPlugins;

/// Keeps reminders and the home-screen widget in step with the app: on
/// launch, on resume (clock, zone or day may have changed), and whenever the
/// place, prayer settings, reminder choices or language change.
class SyncHost extends ConsumerStatefulWidget {
  const SyncHost({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<SyncHost> createState() => _SyncHostState();
}

class _SyncHostState extends ConsumerState<SyncHost> with WidgetsBindingObserver {
  Timer? _debounce;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _schedule());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _schedule();
  }

  void _schedule() {
    // The calendar download needs no platform plugins; it runs everywhere
    // except tests, which have no network.
    if (!Runtime.isTest) {
      unawaited(ref.read(calendarSyncProvider.notifier).refresh());
    }
    if (!_platformAvailable) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _sync);
  }

  Future<void> _sync() async {
    if (_running || !mounted) return;
    _running = true;
    try {
      await syncPlatform(ref);
    } on Object catch (e) {
      debugPrint('sync failed: $e');
    } finally {
      _running = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(userPrefsProvider.select((p) => p.place), (_, _) => _schedule());
    ref.listen(prayerSettingsProvider, (_, _) => _schedule());
    ref.listen(notificationPrefsProvider, (_, _) => _schedule());
    ref.listen(localeOverrideProvider, (_, _) => _schedule());
    return widget.child;
  }
}

AppLocalizations _l10n(WidgetRef ref) {
  final code = ref.read(localeOverrideProvider)?.languageCode ?? PlatformDispatcher.instance.locale.languageCode;
  final supported = AppLocalizations.supportedLocales.map((l) => l.languageCode);
  return lookupAppLocalizations(Locale(supported.contains(code) ? code : 'en'));
}

Future<void> syncPlatform(WidgetRef ref) async {
  final l = _l10n(ref);
  final lang = l.localeName;
  final fmt = PlatformDispatcher.instance.alwaysUse24HourFormat ? DateFormat.Hm(lang) : DateFormat.jm(lang);
  final prefs = ref.read(userPrefsProvider);
  final place = prefs.place;
  final service = ref.read(notificationServiceProvider);
  final bridge = WidgetBridge();

  if (place == null) {
    await bridge.publish(const [], emptyTitle: l.appName, emptyBody: l.widgetEmptyBody);
    return;
  }

  final settings = ref.read(prayerSettingsProvider);
  final svc = ref.read(prayerTimesServiceProvider);
  final now = inZone(DateTime.now(), zoneOf(place));
  DayTimes day(int plus) => svc.forDay(place, DateTime(now.year, now.month, now.day + plus), settings);
  final times = [for (var i = -1; i <= 9; i++) day(i)];
  final days = [for (var i = 0; i + 1 < times.length; i++) PrayerDay(today: times[i], tomorrow: times[i + 1])];

  // Reminders.
  final np = ref.read(notificationPrefsProvider);
  final plan = const ReminderPlanner().plan(now, days, np.enabled);
  final count = await service.schedule(
    plan,
    sound: np.sound,
    title: (k) => l.momentId(k.moment),
    body: (r) => l.reminderBody(fmt.format(r.at), place.name),
  );
  ref.read(lastSyncProvider.notifier).set(SyncResult(count, plan.isEmpty ? null : plan.last.at));

  // Widget: from the current waqt onward.
  final entries = widgetSchedule(
    days: days,
    place: place.name,
    label: l.momentId,
    time: fmt.format,
    palette: (id) => paletteFor(null, id),
  ).where((e) => e.nextAt.isAfter(now)).toList();
  await bridge.publish(entries, emptyTitle: l.appName, emptyBody: l.widgetEmptyBody);
}

/// For callers outside the widget tree's sync cadence (e.g. after granting
/// a permission): re-plan right away.
Future<void> syncNow(WidgetRef ref) async {
  if (!_platformAvailable) return;
  try {
    await syncPlatform(ref);
  } on Object catch (e) {
    debugPrint('sync failed: $e');
  }
}

/// Exposed for tests: which moment ids map to reminder kinds.
Set<MomentId> get reminderMoments => {for (final k in ReminderKind.values) k.moment};
