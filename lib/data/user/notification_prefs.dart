import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/notifications/reminder_planner.dart';
import 'user_prefs.dart';

class NotificationPrefs {
  const NotificationPrefs({required this.enabled, this.sound = true, this.setupDismissed = false});

  final Set<ReminderKind> enabled;

  /// Prayer reminders play the default notification sound. An adhan
  /// recording will be offered once a licensed one is bundled (Phase 6).
  final bool sound;

  /// The one-time "set up reminders" card on Now was dismissed or completed.
  final bool setupDismissed;

  NotificationPrefs copyWith({Set<ReminderKind>? enabled, bool? sound, bool? setupDismissed}) => NotificationPrefs(
    enabled: enabled ?? this.enabled,
    sound: sound ?? this.sound,
    setupDismissed: setupDismissed ?? this.setupDismissed,
  );

  @override
  bool operator ==(Object other) =>
      other is NotificationPrefs &&
      other.sound == sound &&
      other.setupDismissed == setupDismissed &&
      other.enabled.length == enabled.length &&
      other.enabled.containsAll(enabled);

  @override
  int get hashCode => Object.hash(sound, setupDismissed, Object.hashAllUnordered(enabled));
}

class NotificationPrefsNotifier extends Notifier<NotificationPrefs> {
  static const _kEnabled = 'reminders.enabled.v1', _kSound = 'reminders.sound.v1', _kSetup = 'reminders.setup.v1';

  @override
  NotificationPrefs build() {
    final sp = ref.read(sharedPrefsProvider);
    final names = sp.getStringList(_kEnabled);
    return NotificationPrefs(
      enabled: names == null
          ? ReminderKind.defaults
          : {for (final n in names) ...ReminderKind.values.where((k) => k.name == n)},
      sound: sp.getBool(_kSound) ?? true,
      setupDismissed: sp.getBool(_kSetup) ?? false,
    );
  }

  void toggle(ReminderKind k, bool on) {
    final s = {...state.enabled};
    on ? s.add(k) : s.remove(k);
    ref.read(sharedPrefsProvider).setStringList(_kEnabled, [for (final k in s) k.name]);
    state = state.copyWith(enabled: s);
  }

  void setSound(bool on) {
    ref.read(sharedPrefsProvider).setBool(_kSound, on);
    state = state.copyWith(sound: on);
  }

  void dismissSetup() {
    ref.read(sharedPrefsProvider).setBool(_kSetup, true);
    state = state.copyWith(setupDismissed: true);
  }
}

final notificationPrefsProvider = NotifierProvider<NotificationPrefsNotifier, NotificationPrefs>(
  NotificationPrefsNotifier.new,
);
