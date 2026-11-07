import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waqt/data/sources/days.dart';
import 'package:waqt/data/sources/hisn.dart';
import 'package:waqt/app/app.dart';
import 'package:waqt/app/app_state.dart';
import 'package:waqt/core/clock/clock.dart';
import 'package:waqt/data/content/content_repository.dart';
import 'package:waqt/data/user/user_prefs.dart';
import 'package:waqt/domain/location/place.dart';

const dhaka = Place(
  name: 'Dhaka',
  countryCode: 'BD',
  country: 'Bangladesh',
  latitude: 23.8103,
  longitude: 90.4125,
  source: PlaceSource.gps,
);

const london = Place(
  name: 'London',
  countryCode: 'GB',
  country: 'United Kingdom',
  latitude: 51.5074,
  longitude: -0.1278,
  timeZone: 'Europe/London',
  source: PlaceSource.manual,
);

bool _fontsLoaded = false;

/// Real fonts instead of the test "Ahem" boxes, so goldens look like the app.
Future<void> loadAppFonts() async {
  if (_fontsLoaded) return;
  _fontsLoaded = true;
  Future<void> load(String family, String path) async {
    final bytes = await File(path).readAsBytes();
    await (FontLoader(family)..addFont(Future.value(ByteData.view(bytes.buffer)))).load();
  }

  await load('SchibstedGrotesk', 'assets/fonts/SchibstedGrotesk.ttf');
  await load('Inter', 'assets/fonts/Inter.ttf');
  await load('NotoNaskhArabic', 'assets/fonts/NotoNaskhArabic.ttf');
  await load('NotoNastaliqUrdu', 'assets/fonts/NotoNastaliqUrdu.ttf');
  await load('NotoSansBengali', 'assets/fonts/NotoSansBengali.ttf');
  // flutter/bin/cache/dart-sdk/bin/dart → flutter/
  final root =
      Platform.environment['FLUTTER_ROOT'] ?? File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.path;
  await load('MaterialIcons', '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
}

class _Locale extends LocaleOverride {
  _Locale(this.locale);
  final Locale? locale;
  @override
  Locale? build() => locale;
}

/// The whole app at a fixed clock with chosen saved prefs.
Future<Widget> app({DateTime? at, Place? place, Locale? locale, bool setupCard = false}) async {
  SharedPreferences.setMockInitialValues({
    if (place != null) 'place.v1': jsonEncode(place.toJson()),
    // Screenshots show the reminder card only when asked to.
    if (!setupCard) 'reminders.setup.v1': true,
  });
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [
      sharedPrefsProvider.overrideWithValue(prefs),
      // Real bundle, read synchronously: asset I/O doesn't complete inside pumps.
      contentProvider.overrideWith(
        (ref) => ContentBundle.parse(File('assets/content/content.json').readAsStringSync(), includeUnreviewed: true),
      ),
      dayGuidesProvider.overrideWith((ref) => DayGuides.parse(File('assets/sources/days.json').readAsStringSync())),
      hisnProvider.overrideWith((ref) => HisnBook.parse(File('assets/sources/hisn.json').readAsStringSync())),
      if (at != null) nowProvider.overrideWith((ref) => Stream.value(at)),
      if (locale != null) localeOverrideProvider.overrideWith(() => _Locale(locale)),
    ],
    child: const WaqtApp(),
  );
}
