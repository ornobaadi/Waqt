# Waqt

The right dua for the moment you are in, with a verified source for every item. Flutter, offline-first, global.

Read `PRD.md`, `architecture.md`, `design.md` and `phases.md` first.
Releasing: `docs/release.md`. Content workflow: `content/README.md`. Scholar review: `docs/moment-rules.md`.

## Build
```
flutter build apk --profile         # Waqt Dev: debug tools, drafts visible, installs beside release
flutter build apk --release         # Waqt: production APK
flutter build appbundle --release   # Play Store bundle
```
Outputs: `build/app/outputs/flutter-apk/app-profile.apk`, `app-release.apk`, and `build/app/outputs/bundle/release/app-release.aab`.
Release builds hide unreviewed content automatically. Without `android/key.properties` they are signed with the debug key (see `docs/release.md`).

To run on a connected phone: `flutter run --profile`.

## Screenshots
```
flutter test --tags screenshots --update-goldens
```
PNGs land in `test/screenshots/goldens/` (copies per phase in `docs/screenshots/`).

## Check
```
dart format -l 120 lib test && flutter analyze && flutter test --exclude-tags screenshots
```
