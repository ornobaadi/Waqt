import 'dart:async';

import 'package:geolocator/geolocator.dart';

enum GpsError { serviceOff, denied, deniedForever, timeout, unknown }

class GpsException implements Exception {
  const GpsException(this.error);
  final GpsError error;
}

/// One coarse fix. City-level accuracy is all prayer times need, and it is
/// kinder to privacy and battery. The fix never leaves the device.
Future<({double lat, double lng})> currentFix() async {
  if (!await Geolocator.isLocationServiceEnabled()) throw const GpsException(GpsError.serviceOff);
  var perm = await Geolocator.checkPermission();
  if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
  if (perm == LocationPermission.denied) throw const GpsException(GpsError.denied);
  if (perm == LocationPermission.deniedForever) throw const GpsException(GpsError.deniedForever);
  try {
    final p = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.low, timeLimit: Duration(seconds: 20)),
    );
    return (lat: p.latitude, lng: p.longitude);
  } on TimeoutException {
    final last = await Geolocator.getLastKnownPosition();
    if (last != null) return (lat: last.latitude, lng: last.longitude);
    throw const GpsException(GpsError.timeout);
  } on Exception {
    throw const GpsException(GpsError.unknown);
  }
}

Future<void> openLocationSettings() => Geolocator.openAppSettings();
