import '../hijri/hijri_service.dart';
import '../moments/moment.dart';
import '../moments/moment_engine.dart';
import '../occasions/occasions.dart';
import '../prayer/prayer_times_service.dart';

/// How the Reminders screen groups the choices.
enum ReminderGroup { special, friday, ramadan, daily }

/// What a user can ask to be reminded of: the most rewarded moments, never
/// the prayer time itself (an adhan alert can go off mid-salah, and the
/// mosque already calls). On by default: the special days, Fridays and
/// Ramadan. Daily reminders are opt-in so the important ones stand out.
enum ReminderKind {
  // The evening before (after Maghrib), so there is time to plan the fast.
  ramadan(ReminderGroup.special),
  dhulHijjah(ReminderGroup.special),
  eid(ReminderGroup.special),
  ashura(ReminderGroup.special),
  whiteDays(ReminderGroup.special),
  monThu(ReminderGroup.special, onByDefault: false),
  // Every Friday.
  jumuah(ReminderGroup.friday),
  fridayLastHour(ReminderGroup.friday, moment: MomentId.fridayLastHour),
  // In Ramadan.
  suhoor(ReminderGroup.ramadan, moment: MomentId.suhoor),
  iftar(ReminderGroup.ramadan, moment: MomentId.iftar),
  laylatAlQadr(ReminderGroup.ramadan, moment: MomentId.laylatAlQadr),
  // Every day.
  morningAdhkar(ReminderGroup.daily, moment: MomentId.morningAdhkar, onByDefault: false),
  eveningAdhkar(ReminderGroup.daily, moment: MomentId.eveningAdhkar, onByDefault: false),
  lastThird(ReminderGroup.daily, moment: MomentId.lastThird, onByDefault: false),
  bedtime(ReminderGroup.daily, moment: MomentId.bedtime, onByDefault: false);

  const ReminderKind(this.group, {this.moment, this.onByDefault = true});
  final ReminderGroup group;

  /// The moment whose start triggers it; null for the eve and Friday-morning kinds.
  final MomentId? moment;
  final bool onByDefault;

  static final defaults = {
    for (final k in values)
      if (k.onByDefault) k,
  };
}

/// What a reminder is about, which picks its words. One kind can speak of
/// several days: [ReminderKind.eid] is either Eid, [ReminderKind.ashura] is
/// Tasu'a or Ashura.
enum ReminderTopic {
  ramadan(ReminderKind.ramadan),
  dhulHijjah(ReminderKind.dhulHijjah),
  arafah(ReminderKind.dhulHijjah),
  eidFitr(ReminderKind.eid),
  eidAdha(ReminderKind.eid),
  tasua(ReminderKind.ashura),
  ashura(ReminderKind.ashura),
  whiteDays(ReminderKind.whiteDays),
  monday(ReminderKind.monThu),
  thursday(ReminderKind.monThu),
  jumuah(ReminderKind.jumuah),
  fridayLastHour(ReminderKind.fridayLastHour),
  suhoor(ReminderKind.suhoor),
  iftar(ReminderKind.iftar),
  laylatAlQadr(ReminderKind.laylatAlQadr),
  morningAdhkar(ReminderKind.morningAdhkar),
  eveningAdhkar(ReminderKind.eveningAdhkar),
  lastThird(ReminderKind.lastThird),
  bedtime(ReminderKind.bedtime);

  const ReminderTopic(this.kind);
  final ReminderKind kind;

  /// The topic a kind shows when previewed on its own.
  static ReminderTopic sample(ReminderKind k) => switch (k) {
    ReminderKind.dhulHijjah => arafah,
    ReminderKind.eid => eidFitr,
    ReminderKind.monThu => monday,
    _ => values.firstWhere((t) => t.kind == k),
  };
}

class PlannedReminder {
  const PlannedReminder(this.id, this.topic, this.at);
  final int id;
  final ReminderTopic topic;
  final DateTime at;

  ReminderKind get kind => topic.kind;

  @override
  String toString() => '#$id ${topic.name} $at';
}

/// Pure: prayer days (with Hijri dates) + preferences → the reminders to schedule.
///
/// Uses fixed horizons instead of a daily background job: Android keeps
/// scheduled alarms across reboots (the plugin re-arms them), and every app
/// open re-plans. Daily reminders look a week ahead; the rarer special days
/// look a month ahead, so Ashura is not missed by someone who opens the app
/// once a fortnight.
class ReminderPlanner {
  const ReminderPlanner({
    this.engine = const MomentEngine(),
    this.horizon = const Duration(days: 7),
    this.specialHorizon = const Duration(days: 31),
  });

  final MomentEngine engine;
  final Duration horizon;
  final Duration specialHorizon;

  /// Android caps pending alarms per app at 500; stay far below it.
  static const maxReminders = 120;

  /// The eve reminder comes a little after Maghrib: the new Islamic day has
  /// begun, the prayer is done, and there is the evening to plan the fast.
  static const eveDelay = Duration(minutes: 25);

  /// Friday morning: once the sun is up and the day has started.
  static const jumuahDelay = Duration(minutes: 40);

  List<PlannedReminder> plan(DateTime now, List<PrayerDay> days, Set<ReminderKind> enabled) {
    if (enabled.isEmpty) return const [];
    final byMoment = {for (final k in enabled) ?k.moment: k};
    final out = <PlannedReminder>[];
    final seen = <(ReminderTopic, DateTime)>{};

    void add(ReminderTopic topic, DateTime at) {
      final limit = now.add(topic.kind.group == ReminderGroup.daily ? horizon : specialHorizon);
      if (!at.isAfter(now) || at.isAfter(limit)) return;
      if (seen.add((topic, at))) out.add(PlannedReminder(0, topic, at));
    }

    for (final day in days) {
      for (final m in engine.timelineFor(day)) {
        final kind = byMoment[m.id];
        if (kind == null || m.prayer != null) continue;
        add(ReminderTopic.values.firstWhere((t) => t.kind == kind), m.window.start);
      }
      if (enabled.contains(ReminderKind.jumuah) && day.today.date.weekday == DateTime.friday) {
        add(ReminderTopic.jumuah, day.today[Waqt.sunrise].add(jumuahDelay));
      }
      final h = day.hijriNext;
      if (h != null) {
        final topic = eveTopic(h, day.tomorrow.date.weekday, enabled);
        if (topic != null) add(topic, day.today[Waqt.maghrib].add(eveDelay));
      }
    }
    out.sort((a, b) => a.at.compareTo(b.at));
    return [for (final (i, r) in out.take(maxReminders).indexed) PlannedReminder(i + 1, r.topic, r.at)];
  }

  /// What to say on the evening before [tomorrow], most important first, at most one.
  static ReminderTopic? eveTopic(HijriDate tomorrow, int weekday, Set<ReminderKind> enabled) {
    final m = tomorrow.month, d = tomorrow.day;
    final occ = occasionsFor(tomorrow, weekday);
    final candidates = [
      if (m == 9 && d == 1) ReminderTopic.ramadan,
      if (occ.contains(OccasionId.eidAlFitr)) ReminderTopic.eidFitr,
      if (occ.contains(OccasionId.eidAlAdha)) ReminderTopic.eidAdha,
      if (occ.contains(OccasionId.arafah)) ReminderTopic.arafah,
      if (m == 12 && d == 1) ReminderTopic.dhulHijjah,
      if (occ.contains(OccasionId.tasua)) ReminderTopic.tasua,
      if (occ.contains(OccasionId.ashura)) ReminderTopic.ashura,
      // The white days are three; one reminder, before the first.
      if (d == 13 && occ.contains(OccasionId.ayyamAlBid)) ReminderTopic.whiteDays,
      if (occ.contains(OccasionId.mondayFast)) ReminderTopic.monday,
      if (occ.contains(OccasionId.thursdayFast)) ReminderTopic.thursday,
    ];
    return candidates.where((t) => enabled.contains(t.kind)).firstOrNull;
  }
}
