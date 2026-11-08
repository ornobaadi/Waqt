import '../domain/notifications/reminder_planner.dart';

/// Where tapping a reminder takes you.
///
/// A reminder for the evening before a day (Ashura, Arafah, Eid, the white
/// days...) opens the calendar on that day with its guide; one for a moment
/// happening now (the hour of Friday, suhoor, adhkar...) opens Now, where
/// that moment's card is already showing.

const _aboutTomorrow = {
  ReminderTopic.ramadan,
  ReminderTopic.dhulHijjah,
  ReminderTopic.arafah,
  ReminderTopic.eidFitr,
  ReminderTopic.eidAdha,
  ReminderTopic.tasua,
  ReminderTopic.ashura,
  ReminderTopic.whiteDays,
  ReminderTopic.monday,
  ReminderTopic.thursday,
};

String _ymd(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// "topic|yyyy-mm-dd": the day the reminder is about.
String reminderPayload(ReminderTopic topic, DateTime at) {
  final day = _aboutTomorrow.contains(topic) ? DateTime(at.year, at.month, at.day + 1) : at;
  return '${topic.name}|${_ymd(day)}';
}

/// The route for a tapped reminder's payload; Now for anything unknown.
String routeForPayload(String? payload) {
  if (payload == null) return '/now';
  final [name, ...rest] = payload.split('|');
  final topic = ReminderTopic.values.asNameMap()[name];
  final day = rest.isEmpty ? null : DateTime.tryParse(rest.first);
  if (topic == null || day == null || !_aboutTomorrow.contains(topic)) return '/now';
  return '/calendar?day=${_ymd(day)}';
}
