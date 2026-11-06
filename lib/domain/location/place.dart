enum PlaceSource { gps, manual }

/// A named location. Coordinates drive the maths; the name is for people.
class Place {
  const Place({
    required this.name,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
    this.country,
    this.timeZone,
    this.source = PlaceSource.manual,
  });

  final String name;
  final String countryCode;
  final String? country;
  final double latitude;
  final double longitude;
  final String? timeZone;
  final PlaceSource source;

  Place copyWith({PlaceSource? source, double? latitude, double? longitude}) => Place(
    name: name,
    countryCode: countryCode,
    country: country,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    timeZone: timeZone,
    source: source ?? this.source,
  );

  Map<String, Object?> toJson() => {
    'name': name,
    'cc': countryCode,
    'country': country,
    'lat': latitude,
    'lng': longitude,
    'tz': timeZone,
    'src': source.name,
  };

  static Place? fromJson(Object? j) {
    if (j is! Map) return null;
    final lat = j['lat'], lng = j['lng'], name = j['name'], cc = j['cc'];
    if (lat is! num || lng is! num || name is! String || cc is! String) return null;
    return Place(
      name: name,
      countryCode: cc,
      country: j['country'] as String?,
      latitude: lat.toDouble(),
      longitude: lng.toDouble(),
      timeZone: j['tz'] as String?,
      source: j['src'] == 'gps' ? PlaceSource.gps : PlaceSource.manual,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Place &&
      other.name == name &&
      other.countryCode == countryCode &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.source == source;

  @override
  int get hashCode => Object.hash(name, countryCode, latitude, longitude, source);
}
