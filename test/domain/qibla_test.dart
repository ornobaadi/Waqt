import 'package:flutter_test/flutter_test.dart';
import 'package:waqt/domain/qibla/qibla.dart';

void main() {
  test('bearing to the Kaaba matches published values', () {
    expect(qiblaBearing(23.8103, 90.4125), closeTo(277.5, 0.5)); // Dhaka
    expect(qiblaBearing(51.5074, -0.1278), closeTo(119.0, 0.5)); // London
    expect(qiblaBearing(40.7128, -74.0060), closeTo(58.5, 0.5)); // New York
    expect(qiblaBearing(-6.2088, 106.8456), closeTo(295.1, 0.5)); // Jakarta
  });

  test('distance to the Kaaba', () {
    expect(qiblaDistanceKm(51.5074, -0.1278), closeTo(4790, 15));
    expect(qiblaDistanceKm(kaabaLat, kaabaLng), closeTo(0, 0.001));
  });

  test('turn takes the short way round', () {
    expect(turnTo(10, 350), 20);
    expect(turnTo(350, 10), -20);
    expect(turnTo(180, 0), 180);
  });

  test('heading from gravity and field, phone flat', () {
    // Field points north (+y) and down into the earth.
    expect(headingFrom([0, 0, 9.8], [0, 20, -40]), closeTo(0, 0.01));
    // North is to the right of the screen: top of the phone points west.
    expect(headingFrom([0, 0, 9.8], [20, 0, -40]), closeTo(270, 0.01));
    expect(headingFrom([0, 0, 9.8], [-20, 0, -40]), closeTo(90, 0.01));
    expect(headingFrom([0, 0, 0], [0, 20, -40]), isNull);
  });

  test('tilt', () {
    expect(tiltOf([0, 0, 9.8]), closeTo(0, 0.01));
    expect(tiltOf([0, 9.8, 0]), closeTo(90, 0.01));
  });
}
