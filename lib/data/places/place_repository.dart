import 'dart:math' as math;

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/location/place.dart';

class _City {
  _City(this.name, this.ascii, this.cc, this.lat, this.lng, this.pop, this.tz) : key = _fold(ascii);
  final String name, ascii, cc, tz, key;
  final double lat, lng;
  final int pop;
}

/// Matches the start of any later word: "york" finds New York, "ist" doesn't find Bristol.
bool _wordStarts(String name, String q) => name.split(RegExp(r'[\s\-]+')).skip(1).any((w) => _fold(w).startsWith(q));

String _fold(String s) => s.toLowerCase().replaceAll(RegExp(r"[\s\-'’.]"), '');

/// Offline city index (GeoNames, CC BY 4.0). Lets us name a GPS fix and pick
/// a city by hand without any network or reverse-geocoding service.
class PlaceRepository {
  PlaceRepository._(this._cities, this._countries);

  final List<_City> _cities; // sorted by population, descending
  final Map<String, String> _countries;

  static Future<PlaceRepository> load() async {
    final cities = await rootBundle.loadString('assets/data/cities.tsv');
    final countries = await rootBundle.loadString('assets/data/countries.tsv');
    return parse(cities, countries);
  }

  static PlaceRepository parse(String citiesTsv, String countriesTsv) {
    final cities = <_City>[];
    for (final line in citiesTsv.split('\n')) {
      if (line.isEmpty || line.startsWith('#')) continue;
      final f = line.split('\t');
      if (f.length < 7) continue;
      cities.add(_City(f[0], f[1], f[2], double.parse(f[3]), double.parse(f[4]), int.parse(f[5]), f[6]));
    }
    final countries = <String, String>{};
    for (final line in countriesTsv.split('\n')) {
      if (line.isEmpty || line.startsWith('#')) continue;
      final f = line.split('\t');
      if (f.length >= 2) countries[f[0]] = f[1].trim();
    }
    return PlaceRepository._(cities, countries);
  }

  String? countryName(String cc) => _countries[cc];

  Place _place(_City c, {PlaceSource source = PlaceSource.manual}) => Place(
    name: c.name,
    countryCode: c.cc,
    country: _countries[c.cc],
    latitude: c.lat,
    longitude: c.lng,
    timeZone: c.tz,
    source: source,
  );

  /// Prefix matches first, then substring; larger cities first within each.
  List<Place> search(String query, {int limit = 40}) {
    final q = _fold(query.trim());
    if (q.isEmpty) return const [];
    final prefix = <_City>[], contains = <_City>[];
    for (final c in _cities) {
      final nameKey = _fold(c.name);
      final country = _fold(_countries[c.cc] ?? '');
      if (c.key.startsWith(q) || nameKey.startsWith(q)) {
        prefix.add(c);
      } else if (_wordStarts(c.name, q) || country.startsWith(q)) {
        contains.add(c);
      }
      if (prefix.length >= limit) break;
    }
    return [...prefix, ...contains].take(limit).map(_place).toList();
  }

  /// Nearest known city, keeping the exact fix as coordinates.
  Place nearest(double lat, double lng) {
    _City? best;
    var bestD = double.infinity;
    for (final c in _cities) {
      final d = _haversine(lat, lng, c.lat, c.lng);
      if (d < bestD) {
        bestD = d;
        best = c;
      }
    }
    return _place(best!, source: PlaceSource.gps).copyWith(latitude: lat, longitude: lng);
  }

  static double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    double rad(double d) => d * math.pi / 180;
    final dLat = rad(lat2 - lat1), dLon = rad(lon2 - lon1);
    final a =
        math.pow(math.sin(dLat / 2), 2) + math.cos(rad(lat1)) * math.cos(rad(lat2)) * math.pow(math.sin(dLon / 2), 2);
    return 2 * r * math.asin(math.sqrt(a));
  }
}

final placeRepositoryProvider = FutureProvider<PlaceRepository>((ref) => PlaceRepository.load());
