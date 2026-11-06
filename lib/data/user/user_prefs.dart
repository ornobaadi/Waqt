import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/hijri/hijri_service.dart';
import '../../domain/location/place.dart';
import '../../domain/prayer/prayer_settings.dart';

class UserPrefs {
  const UserPrefs({this.place, this.prayer, this.hijriOffset = 0});

  final Place? place;

  /// `null` = follow the regional default for [place].
  final PrayerSettings? prayer;
  final int hijriOffset;

  UserPrefs copyWith({Place? place, PrayerSettings? prayer, int? hijriOffset}) => UserPrefs(
    place: place ?? this.place,
    prayer: prayer ?? this.prayer,
    hijriOffset: hijriOffset ?? this.hijriOffset,
  );
}

/// Overridden in main() with the loaded instance.
final sharedPrefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError('override in main'));

class UserPrefsNotifier extends Notifier<UserPrefs> {
  static const _kPlace = 'place.v1', _kPrayer = 'prayer.v1', _kHijri = 'hijriOffset.v1';

  SharedPreferences get _sp => ref.read(sharedPrefsProvider);

  Object? _json(String key) {
    final s = _sp.getString(key);
    if (s == null) return null;
    try {
      return jsonDecode(s);
    } on FormatException {
      return null;
    }
  }

  @override
  UserPrefs build() => UserPrefs(
    place: Place.fromJson(_json(_kPlace)),
    prayer: PrayerSettings.fromJson(_json(_kPrayer)),
    hijriOffset: (_sp.getInt(_kHijri) ?? 0).clamp(-HijriService.maxOffset, HijriService.maxOffset),
  );

  void setPlace(Place p) {
    _sp.setString(_kPlace, jsonEncode(p.toJson()));
    state = state.copyWith(place: p);
  }

  void setPrayer(PrayerSettings s) {
    _sp.setString(_kPrayer, jsonEncode(s.toJson()));
    state = state.copyWith(prayer: s);
  }

  void setHijriOffset(int days) {
    final d = days.clamp(-HijriService.maxOffset, HijriService.maxOffset);
    _sp.setInt(_kHijri, d);
    state = state.copyWith(hijriOffset: d);
  }
}

final userPrefsProvider = NotifierProvider<UserPrefsNotifier, UserPrefs>(UserPrefsNotifier.new);
