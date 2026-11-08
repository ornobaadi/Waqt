import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/app/reminder_links.dart';
import 'package:waqt/domain/notifications/reminder_planner.dart';

void main() {
  final evening = DateTime(2027, 6, 14, 19, 11);

  test('an evening-before reminder is about the next day and opens it in the calendar', () {
    final p = reminderPayload(ReminderTopic.ashura, evening);
    expect(p, 'ashura|2027-06-15');
    expect(routeForPayload(p), '/calendar?day=2027-06-15');
  });

  test('crossing a month end', () {
    expect(reminderPayload(ReminderTopic.arafah, DateTime(2027, 5, 31, 19)), 'arafah|2027-06-01');
  });

  test('a reminder for the moment itself opens Now', () {
    final p = reminderPayload(ReminderTopic.fridayLastHour, DateTime(2027, 6, 18, 17, 20));
    expect(p, 'fridayLastHour|2027-06-18');
    expect(routeForPayload(p), '/now');
    expect(routeForPayload(reminderPayload(ReminderTopic.suhoor, evening)), '/now');
  });

  test('every evening-before topic routes to the calendar', () {
    for (final t in ReminderTopic.values.where((t) => t.kind.moment == null && t != ReminderTopic.jumuah)) {
      expect(routeForPayload(reminderPayload(t, evening)), startsWith('/calendar?day='), reason: t.name);
    }
  });

  test('anything unknown or old opens Now', () {
    expect(routeForPayload(null), '/now');
    expect(routeForPayload('morningAdhkar'), '/now');
    expect(routeForPayload('nonsense|2027-01-01'), '/now');
    expect(routeForPayload('ashura|not-a-date'), '/now');
  });
}
