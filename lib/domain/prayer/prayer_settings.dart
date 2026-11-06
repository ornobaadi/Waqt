import 'package:adhan/adhan.dart' as adhan;

/// Calculation authorities. Each maps to an `adhan` method; the angles are
/// shown to users so the choice is transparent.
enum CalcMethod {
  mwl(adhan.CalculationMethod.muslim_world_league, 'Fajr 18° · Isha 17°'),
  isna(adhan.CalculationMethod.north_america, 'Fajr 15° · Isha 15°'),
  egypt(adhan.CalculationMethod.egyptian, 'Fajr 19.5° · Isha 17.5°'),
  karachi(adhan.CalculationMethod.karachi, 'Fajr 18° · Isha 18°'),
  ummAlQura(adhan.CalculationMethod.umm_al_qura, 'Fajr 18.5° · Isha 90 min'),
  dubai(adhan.CalculationMethod.dubai, 'Fajr 18.2° · Isha 18.2°'),
  qatar(adhan.CalculationMethod.qatar, 'Fajr 18° · Isha 90 min'),
  kuwait(adhan.CalculationMethod.kuwait, 'Fajr 18° · Isha 17.5°'),
  singapore(adhan.CalculationMethod.singapore, 'Fajr 20° · Isha 18°'),
  turkey(adhan.CalculationMethod.turkey, 'Fajr 18° · Isha 17°'),
  tehran(adhan.CalculationMethod.tehran, 'Fajr 17.7° · Isha 14°'),
  moonsighting(adhan.CalculationMethod.moon_sighting_committee, 'Fajr 18° · Isha 18°, seasonal');

  const CalcMethod(this.adhanMethod, this.angles);
  final adhan.CalculationMethod adhanMethod;
  final String angles;

  static CalcMethod? byName(Object? n) => values.where((m) => m.name == n).firstOrNull;
}

enum AsrSchool { standard, hanafi }

enum HighLatitudeRule { auto, middleOfNight, seventhOfNight, twilightAngle }

class PrayerSettings {
  const PrayerSettings({required this.method, required this.asr, this.highLatitude = HighLatitudeRule.auto});

  final CalcMethod method;
  final AsrSchool asr;
  final HighLatitudeRule highLatitude;

  /// Sensible regional defaults. Users can always change them; nothing about
  /// the app assumes one region.
  factory PrayerSettings.defaultsFor(String? countryCode) {
    final cc = countryCode?.toUpperCase();
    final method = switch (cc) {
      'SA' || 'BH' || 'OM' || 'YE' => CalcMethod.ummAlQura,
      'AE' => CalcMethod.dubai,
      'QA' => CalcMethod.qatar,
      'KW' => CalcMethod.kuwait,
      'EG' || 'SD' || 'LY' || 'SY' || 'LB' || 'IQ' || 'JO' || 'PS' => CalcMethod.egypt,
      'MY' || 'SG' || 'ID' || 'BN' => CalcMethod.singapore,
      'TR' || 'AZ' => CalcMethod.turkey,
      'IR' => CalcMethod.tehran,
      'PK' || 'IN' || 'BD' || 'AF' || 'NP' || 'LK' => CalcMethod.karachi,
      'US' || 'CA' => CalcMethod.isna,
      'GB' || 'IE' => CalcMethod.moonsighting,
      _ => CalcMethod.mwl,
    };
    const hanafi = {'PK', 'IN', 'BD', 'AF', 'TR', 'UZ', 'KZ', 'TJ', 'KG', 'TM', 'AZ'};
    return PrayerSettings(method: method, asr: hanafi.contains(cc) ? AsrSchool.hanafi : AsrSchool.standard);
  }

  PrayerSettings copyWith({CalcMethod? method, AsrSchool? asr, HighLatitudeRule? highLatitude}) => PrayerSettings(
    method: method ?? this.method,
    asr: asr ?? this.asr,
    highLatitude: highLatitude ?? this.highLatitude,
  );

  adhan.CalculationParameters parametersFor(double latitude) {
    final p = method.adhanMethod.getParameters()
      ..madhab = asr == AsrSchool.hanafi ? adhan.Madhab.hanafi : adhan.Madhab.shafi;
    p.highLatitudeRule = switch (highLatitude) {
      // Same recommendation as the reference Adhan libraries.
      HighLatitudeRule.auto =>
        latitude.abs() > 48 ? adhan.HighLatitudeRule.seventh_of_the_night : adhan.HighLatitudeRule.middle_of_the_night,
      HighLatitudeRule.middleOfNight => adhan.HighLatitudeRule.middle_of_the_night,
      HighLatitudeRule.seventhOfNight => adhan.HighLatitudeRule.seventh_of_the_night,
      HighLatitudeRule.twilightAngle => adhan.HighLatitudeRule.twilight_angle,
    };
    return p;
  }

  Map<String, Object?> toJson() => {'method': method.name, 'asr': asr.name, 'highLat': highLatitude.name};

  static PrayerSettings? fromJson(Object? j) {
    if (j is! Map) return null;
    final m = CalcMethod.byName(j['method']);
    if (m == null) return null;
    return PrayerSettings(
      method: m,
      asr: j['asr'] == 'hanafi' ? AsrSchool.hanafi : AsrSchool.standard,
      highLatitude: HighLatitudeRule.values.where((r) => r.name == j['highLat']).firstOrNull ?? HighLatitudeRule.auto,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PrayerSettings && other.method == method && other.asr == asr && other.highLatitude == highLatitude;

  @override
  int get hashCode => Object.hash(method, asr, highLatitude);
}
