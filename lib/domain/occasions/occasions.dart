import '../hijri/hijri_service.dart';

/// Day-level occasions from the Hijri date and weekday. Like every rule in
/// the app these are labels only; any text about them comes from reviewed
/// content. Scholar-review notes: docs/moment-rules.md.
enum OccasionId {
  eidAlFitr,
  eidAlAdha,
  arafah,
  tashreeq,
  ashura,
  tasua,
  lastTenNights,
  ramadan,
  firstTenDhulHijjah,
  ayyamAlBid,
  jumuah,
  mondayFast,
  thursdayFast,

  /// The month of Sha'ban: fasting much of it, and not the day or two before Ramadan.
  shaban,
}

const _shaban = 8, _ramadan = 9, _shawwal = 10, _dhulHijjah = 12, _muharram = 1;

/// Most specific first; the header shows the first.
List<OccasionId> occasionsFor(HijriDate h, int weekday) {
  final out = <OccasionId>[];
  final m = h.month, d = h.day;
  final eid = (m == _shawwal && d == 1) || (m == _dhulHijjah && d == 10);
  final tashreeq = m == _dhulHijjah && d >= 11 && d <= 13;

  if (m == _shawwal && d == 1) out.add(OccasionId.eidAlFitr);
  if (m == _dhulHijjah && d == 10) out.add(OccasionId.eidAlAdha);
  if (m == _dhulHijjah && d == 9) out.add(OccasionId.arafah);
  if (tashreeq) out.add(OccasionId.tashreeq);
  if (m == _muharram && d == 10) out.add(OccasionId.ashura);
  if (m == _muharram && d == 9) out.add(OccasionId.tasua);
  if (m == _ramadan && d >= 21) out.add(OccasionId.lastTenNights);
  if (m == _ramadan) out.add(OccasionId.ramadan);
  if (m == _dhulHijjah && d <= 9) out.add(OccasionId.firstTenDhulHijjah);
  // 13 Dhul Hijjah is a day of Tashreeq, not one of the white days.
  if (d >= 13 && d <= 15 && m != _ramadan && !tashreeq) out.add(OccasionId.ayyamAlBid);
  if (weekday == DateTime.friday) out.add(OccasionId.jumuah);
  if (m == _shaban) out.add(OccasionId.shaban);
  // Voluntary-fast markers stay off in Ramadan, on Eid and in Tashreeq.
  if (m != _ramadan && !eid && !tashreeq) {
    if (weekday == DateTime.monday) out.add(OccasionId.mondayFast);
    if (weekday == DateTime.thursday) out.add(OccasionId.thursdayFast);
  }
  return out;
}
