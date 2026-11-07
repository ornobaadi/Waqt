/// Every moment the engine knows. Each id later links to reviewed content
/// via `moment_content` (Phase 3); the engine itself carries no text.
enum MomentId {
  // Base prayer-time moments: always one active, lowest priority.
  fajr,
  sunrise,
  dhuhr,
  asr,
  maghrib,
  isha,
  // Refinements.
  morningAdhkar,
  eveningAdhkar,
  duha,
  bedtime,
  lastThird,
  laylatAlQadr,
  taraweeh,
  suhoor,
  iftar,
  jumuah,
  fridayLastHour,
  betweenAdhanIqamah,
  afterSalah,
  restrictedSunrise,
  restrictedZawal,
  restrictedSunset,
}

enum MomentKind {
  /// The waqt itself.
  prayer,

  /// A recommended time for worship or remembrance.
  devotion,

  /// A time in which voluntary prayer is restricted.
  restricted,
}

class TimeWindow {
  TimeWindow(this.start, this.end) : assert(!end.isBefore(start), 'window ends before it starts');

  final DateTime start;
  final DateTime end;

  Duration get length => end.difference(start);

  /// Half-open: `[start, end)`.
  bool contains(DateTime t) => !t.isBefore(start) && t.isBefore(end);

  @override
  bool operator ==(Object other) => other is TimeWindow && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => '[$start – $end)';
}

class Moment {
  const Moment(this.id, this.kind, this.priority, this.window, {this.prayer});

  final MomentId id;
  final MomentKind kind;

  /// Higher wins the hero slot.
  final int priority;
  final TimeWindow window;

  /// For prayer-bound moments (adhan↔iqamah, after salah): which prayer.
  final MomentId? prayer;

  @override
  bool operator ==(Object other) =>
      other is Moment && other.id == id && other.window == window && other.prayer == prayer;

  @override
  int get hashCode => Object.hash(id, window, prayer);

  @override
  String toString() => '${id.name}${prayer == null ? '' : '(${prayer!.name})'} $window';
}

/// What the UI needs, computed once per tick.
class MomentSnapshot {
  const MomentSnapshot({required this.now, required this.active, required this.upcoming, required this.timeline});

  final DateTime now;

  /// Active right now, highest priority first. Never empty once a location
  /// is set: some base prayer moment always covers the present.
  final List<Moment> active;

  /// The next refinements to begin (base prayers excluded; the prayer strip
  /// already shows those). At most two.
  final List<Moment> upcoming;

  /// Every moment of the prayer day (Fajr → next Fajr), by start time.
  final List<Moment> timeline;

  Moment get hero => active.first;

  /// The base waqt moment in progress.
  Moment get waqt => active.lastWhere((m) => m.kind == MomentKind.prayer);
}
