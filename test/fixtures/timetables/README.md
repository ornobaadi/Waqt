# Official prayer timetables

One CSV per authority/city, copied by hand from the official PDF or site. Header:

```
city,lat,lng,tz,method,asr,date,fajr,sunrise,dhuhr,asr_time,maghrib,isha,source
Istanbul,41.0082,28.9784,Europe/Istanbul,turkey,standard,2026-12-01,06:21,07:56,12:57,15:18,17:39,19:08,https://namazvakitleri.diyanet.gov.tr
```

- `method`: a `CalcMethod` name (`mwl`, `isna`, `egypt`, `karachi`, `ummAlQura`, `dubai`, `qatar`, `kuwait`, `singapore`, `turkey`, `tehran`, `moonsighting`).
- `asr`: `standard` or `hanafi`. Times are local wall-clock `HH:mm`.
- Leave a time empty if the table doesn't give it.

Run `flutter test test/domain/official_timetables_test.dart`. Differences over 2 minutes fail and are printed.
Some authorities add safety minutes (ihtiyat) on purpose; note that in `source` and record it in `docs/moment-rules.md`.
