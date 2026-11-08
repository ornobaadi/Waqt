# Publish Waqt on Google Play: checklist

All text and answers to paste are in `docs/play-store-listing.md`. Signing and builds: `docs/release.md`.

## 1. Build the release (on your PC)
1. One-time: create the upload key and `android/key.properties` (`docs/release.md` §1). Back the keystore up somewhere safe.
2. Build:
   ```
   flutter build appbundle --release
   ```
   Upload `build/app/outputs/bundle/release/app-release.aab`.

## 2. Create the app in Play Console
- Name `Waqt: Prayer Times, Dua, Qibla`, language English (United States), App, Free.
- Accept the declarations (Developer Program Policies, US export laws).

## 3. Set up your app (Dashboard → "Set up your app")
- [ ] App access: no restrictions
- [ ] Ads: no ads
- [ ] Content rating questionnaire
- [ ] Target audience: 13+
- [ ] News app: no
- [ ] Data safety form
- [ ] Government app: no
- [ ] Financial features: none
- [ ] Health: no
- [ ] Privacy policy URL
- [ ] Store listing: name, short and full description, icon, feature graphic, 2–8 phone screenshots, category, contact email
- [ ] (Optional) Translated listings for ar, ur, bn, id, tr, fr

## 4. Test, then release
New personal developer accounts must run a **closed test with at least 12 testers for 14 days** before production access.
1. Testing → Closed testing → create a track, add testers (email list or Google Group), upload the AAB, roll out.
2. Share the opt-in link; keep 12+ testers opted in for 14 days.
3. Then apply for production access and promote the release.

Organisation accounts can go straight to Production (or start with Internal testing to check the install).

## 5. Before you press "Roll out"
- [ ] `pubspec.yaml` version and `AppConfig.version` match (now `0.1.0+1`, beta)
- [ ] Release built with your upload key, not the debug key
- [ ] Installed the release build on a phone: icon, splash, reminders, widget, Qibla
- [ ] Moment content you want shown in release is marked `approved` (release builds hide drafts)
