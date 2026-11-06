# Waqt

The right dua for the moment you are in, with a verified source for every item. Flutter, offline-first, global.

Read `PRD.md`, `architecture.md`, `design.md` and `phases.md` first.

## Run
```
flutter run --flavor dev     # com.ornobaadi.waqt.dev, debug tools on
flutter run --flavor prod    # com.ornobaadi.waqt
```

## Build
```
flutter build apk --flavor dev --debug          # quick test install
flutter build apk --flavor prod --release --split-per-abi
flutter build appbundle --flavor prod --release  # Play Store
```
Release builds are still signed with the debug key; add a keystore before publishing.

## Screenshots
```
flutter test --tags screenshots --update-goldens
```
PNGs land in `test/screenshots/goldens/` (copies per phase in `docs/screenshots/`).

## Check
```
dart format -l 120 lib test && flutter analyze && flutter test --exclude-tags screenshots
```
