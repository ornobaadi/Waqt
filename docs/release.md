# Releasing Waqt

## 1. One-time: create your upload key
Keep the keystore and passwords out of git: `*.jks` and `android/key.properties` are already ignored.

```
keytool -genkey -v -keystore %USERPROFILE%\waqt-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Create `android/key.properties`:
```
storeFile=C:\\Users\\<you>\\waqt-upload.jks
storePassword=<password>
keyAlias=upload
keyPassword=<password>
```
Without this file, release builds are signed with the debug key. That's fine locally, but Play will reject them.
Back up the keystore: Play App Signing keeps your app key, but the upload key is yours.

## 2. Every release
1. Bump `version:` in `pubspec.yaml` (e.g. `1.0.1+2`) **and** `AppConfig.version` in `lib/core/config/flavor.dart`.
2. Approved content only:
   ```
   dart run tool/content.dart build --release
   ```
3. Build the bundle:
   ```
   flutter build appbundle --flavor prod --release
   ```
   Output: `build/app/outputs/bundle/prodRelease/app-prod-release.aab`
4. Restore the dev bundle (drafts visible in dev builds):
   ```
   dart run tool/content.dart build
   ```

## 3. Checks before uploading
- `flutter analyze && flutter test --exclude-tags screenshots` passes
- On a real phone: location, reminders arrive, widget updates, Arabic/Urdu layout
- Battery: Xiaomi/Samsung/Oppo with default settings; reminders still arrive
