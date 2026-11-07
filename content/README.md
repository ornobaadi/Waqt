# Content: the source of truth

Every word of religious text in Waqt comes from this folder, and nothing else in the app may show any.
`dart run tool/content.dart build` compiles `items/*.yaml` and `moments.yaml` into `assets/content/content.json`.

## Rules (PRD §7)
- **No reference, no item.** Every item has `source.collection`, `source.number` and a `source.url` on sunnah.com, quran.com or dorar.net.
- **Sahih or hasan only.** Weak narrations are excluded, not labelled. The validator rejects any other grade.
- **An LLM may suggest a reference; it is never the source of text.** Arabic, transliteration and translations are copied by a person from the primary source (or a licensed translation) and credited.
- **Release builds show approved items only.** This is enforced twice: by `build --release`, and again in the app.

## Review workflow
| Status | Who | What it means | Required fields |
|---|---|---|---|
| `draft` | anyone | A candidate reference. May be wrong. | id, kind, title.en, source.type/collection/number/url |
| `checked` | trained checker | Every field compared with the primary source. | + arabic, translations.en.text/translator, narrator, grade, graded_by, review.checked_by/checked_on |
| `approved` | qualified scholar | Signed off for users. | + review.approved_by/approved_on |

To promote an item, a person opens `source.url`, corrects the number if needed, pastes the Arabic and a licensed translation, fills in narrator and grading, and sets `status: checked` with their name and the date.
A scholar then reviews it and sets `approved`. Each change goes through a PR so the history is the audit trail.
Bump `version` whenever an item's text changes, and bump `content/VERSION` for every content release.

## Files
- `items/*.yaml`: items, grouped however is convenient. `v1_candidates.yaml` holds the PRD §6 catalogue as references only, all drafts.
- `moments.yaml`: moment id (see `lib/domain/moments/moment.dart`) → ordered item ids.
- `VERSION`: content version shown in the app.

## Commands
```
dart run tool/content.dart check            # validate
dart run tool/content.dart build            # dev bundle: drafts visible in dev builds, marked DRAFT
dart run tool/content.dart build --release  # approved only, for store builds
```

## Open decisions
- English translation and licence (Sahih International? Darussalam? per-language).
- Who the scholar reviewer(s) are and how sign-off is recorded beyond the YAML fields.

## Bundled source texts (`assets/sources/`)
Hisn al-Muslim and the hadith collections are copied from published sources, never written here:
- **open-hadith-data v1.1.0** (https://github.com/Jaguar16/open-hadith-data): structured data CC0 1.0; Arabic and English texts as published on sunnah.com.
- Rebuild with `python tool/import_sources.py <unzipped collections-json>`.
- Which Hisn al-Muslim chapter opens for which moment (`momentChapters` in `lib/features/duas/duas_screen.dart`) is our editorial choice; the text inside is the book's.
- **Special-day guides** (`assets/sources/days.json`): built by `python tool/build_days.py`. Each item is a short label we wrote, tied to one hadith in the bundled database; the build fails if a reference is missing or graded weak (da'if) by the source.
