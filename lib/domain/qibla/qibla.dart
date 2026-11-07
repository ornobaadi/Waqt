import 'dart:math' as math;

/// The Kaaba, Makkah.
const kaabaLat = 21.422487;
const kaabaLng = 39.826206;

double _rad(double d) => d * math.pi / 180;
double _deg(double r) => r * 180 / math.pi;

/// Great-circle bearing from the place to the Kaaba, degrees clockwise from
/// true north, 0 ≤ b < 360.
double qiblaBearing(double lat, double lng) {
  final p1 = _rad(lat), p2 = _rad(kaabaLat), dl = _rad(kaabaLng - lng);
  final y = math.sin(dl) * math.cos(p2);
  final x = math.cos(p1) * math.sin(p2) - math.sin(p1) * math.cos(p2) * math.cos(dl);
  return (_deg(math.atan2(y, x)) + 360) % 360;
}

/// Great-circle distance to the Kaaba in kilometres (haversine).
double qiblaDistanceKm(double lat, double lng) {
  final p1 = _rad(lat), p2 = _rad(kaabaLat);
  final dp = p2 - p1, dl = _rad(kaabaLng - lng);
  final a = math.pow(math.sin(dp / 2), 2) + math.cos(p1) * math.cos(p2) * math.pow(math.sin(dl / 2), 2);
  return 6371.0088 * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}

/// Signed turn from [heading] to [bearing]: positive = turn right
/// (clockwise), in (−180, 180].
double turnTo(double bearing, double heading) {
  final d = (bearing - heading) % 360;
  return d > 180 ? d - 360 : d;
}

/// Tilt-compensated compass heading (degrees from magnetic north, clockwise)
/// from gravity [g] and the geomagnetic field [m], both in the device frame
/// (x right, y up the screen, z out of the screen), as Android's
/// SensorManager.getRotationMatrix + getOrientation. Null when the phone is in
/// free fall or the field is parallel to gravity.
double? headingFrom(List<double> g, List<double> m) {
  final (ax, ay, az) = (g[0], g[1], g[2]);
  final (ex, ey, ez) = (m[0], m[1], m[2]);
  var hx = ey * az - ez * ay, hy = ez * ax - ex * az, hz = ex * ay - ey * ax;
  final normH = math.sqrt(hx * hx + hy * hy + hz * hz);
  final normA = math.sqrt(ax * ax + ay * ay + az * az);
  if (normH < 0.1 || normA < 0.1) return null;
  hx /= normH;
  hy /= normH;
  hz /= normH;
  final (nx, ny, nz) = (ax / normA, ay / normA, az / normA);
  final my = nz * hx - nx * hz;
  return (_deg(math.atan2(hy, my)) + 360) % 360;
}

/// How far the screen is from lying flat, in degrees (0 = flat, face up).
double tiltOf(List<double> g) {
  final n = math.sqrt(g[0] * g[0] + g[1] * g[1] + g[2] * g[2]);
  if (n == 0) return 0;
  return _deg(math.acos((g[2] / n).clamp(-1.0, 1.0)));
}
