// Compiles reviewed content (YAML) into the bundle the app ships.
// Pure: strings in, result out. Used by tool/content.dart and the tests.

import 'dart:convert';

import 'package:waqt/domain/moments/moment.dart';
import 'package:yaml/yaml.dart';

const schemaVersion = 1;

enum Status { draft, checked, approved }

const kinds = {'dua', 'dhikr', 'action', 'etiquette', 'recitation'};

/// Sunnah.com slugs plus a few collections it doesn't host.
const collections = {
  'quran',
  'bukhari',
  'muslim',
  'abudawud',
  'tirmidhi',
  'nasai',
  'ibnmajah',
  'malik',
  'ahmad',
  'darimi',
  'adab',
  'hakim',
  'ibnhibban',
  'bayhaqi',
  'nasai_kubra',
};

/// Policy (PRD §7): Sunnah claims only from sahih or hasan narrations.
/// Weak narrations are excluded, not labelled.
const allowedGrades = {'sahih', 'hasan'};

const trustedHosts = {'sunnah.com', 'quran.com', 'dorar.net'};

final _id = RegExp(r'^[a-z][a-z0-9_]*$');
final _ayah = RegExp(r'^\d{1,3}:\d{1,3}(-\d{1,3})?$');
final _date = RegExp(r'^\d{4}-\d{2}-\d{2}$');

class Issue {
  Issue(this.file, this.where, this.message);
  final String file, where, message;
  @override
  String toString() => '$file › $where: $message';
}

class CompileResult {
  CompileResult(this.bundle, this.errors, this.stats);
  final Map<String, Object?> bundle;
  final List<Issue> errors;
  final Map<Status, int> stats;
  bool get ok => errors.isEmpty;
  String get json => const JsonEncoder.withIndent(' ').convert(bundle);
}

/// [itemFiles]: file name → YAML with a top-level `items:` list.
/// [momentsYaml]: `moment_id: [item_id, …]`.
/// [release]: only `approved` items (and links to them) are emitted.
CompileResult compileContent({
  required Map<String, String> itemFiles,
  required String momentsYaml,
  required String contentVersion,
  bool release = false,
}) {
  final errors = <Issue>[];
  final items = <String, Map<String, Object?>>{};
  final status = <String, Status>{};
  final stats = {for (final s in Status.values) s: 0};

  for (final MapEntry(key: file, value: text) in itemFiles.entries) {
    Object? doc;
    try {
      doc = loadYaml(text);
    } on YamlException catch (e) {
      errors.add(Issue(file, 'yaml', e.message));
      continue;
    }
    if (doc == null) continue;
    final list = doc is YamlMap ? doc['items'] : null;
    if (list is! YamlList) {
      errors.add(Issue(file, 'root', 'expected a top-level "items:" list'));
      continue;
    }
    for (final (i, raw) in list.indexed) {
      final where = raw is YamlMap && raw['id'] is String ? raw['id'] as String : 'items[$i]';
      void err(String m) => errors.add(Issue(file, where, m));
      if (raw is! YamlMap) {
        err('item must be a map');
        continue;
      }
      final item = _validateItem(raw, err);
      if (item == null) continue;
      final id = item['id']! as String;
      if (items.containsKey(id)) {
        err('duplicate id');
        continue;
      }
      final s = Status.values.byName((item['review']! as Map)['status']! as String);
      status[id] = s;
      stats[s] = stats[s]! + 1;
      if (!release || s == Status.approved) items[id] = item;
    }
  }

  final moments = <String, List<String>>{};
  Object? mdoc;
  try {
    mdoc = loadYaml(momentsYaml);
  } on YamlException catch (e) {
    errors.add(Issue('moments.yaml', 'yaml', e.message));
  }
  final known = {for (final m in MomentId.values) m.name};
  if (mdoc is YamlMap) {
    for (final MapEntry(:key, :value) in mdoc.entries) {
      void err(String m) => errors.add(Issue('moments.yaml', '$key', m));
      if (key is! String || !known.contains(key)) {
        err('unknown moment (expected one of MomentId: ${known.join(', ')})');
        continue;
      }
      if (value is! YamlList || value.any((v) => v is! String)) {
        err('expected a list of item ids');
        continue;
      }
      final ids = value.cast<String>();
      if (ids.toSet().length != ids.length) err('an item is linked twice');
      for (final id in ids) {
        if (!status.containsKey(id)) err('links unknown item "$id"');
      }
      final kept = ids.where(items.containsKey).toList();
      if (kept.isNotEmpty) moments[key] = kept;
    }
  } else if (mdoc != null) {
    errors.add(Issue('moments.yaml', 'root', 'expected a map of moment → item ids'));
  }

  return CompileResult(
    {'schema': schemaVersion, 'version': contentVersion, 'release': release, 'items': items, 'moments': moments},
    errors,
    stats,
  );
}

String? _str(YamlMap m, String k) {
  final v = m[k];
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

Map<String, Object?>? _validateItem(YamlMap m, void Function(String) err) {
  final before = <String>[];
  void e(String msg) {
    before.add(msg);
    err(msg);
  }

  final id = _str(m, 'id');
  if (id == null || !_id.hasMatch(id)) e('id must be snake_case');

  final kind = _str(m, 'kind');
  if (!kinds.contains(kind)) e('kind must be one of ${kinds.join('|')}');

  final title = m['title'];
  final titleEn = title is YamlMap ? _str(title, 'en') : null;
  if (titleEn == null) e('title.en is required');

  final version = m['version'];
  if (version is! int || version < 1) e('version must be a positive integer');

  // Source.
  final src = m['source'];
  if (src is! YamlMap) {
    e('source is required');
    return null;
  }
  final type = _str(src, 'type');
  final collection = _str(src, 'collection');
  final number = _str(src, 'number');
  final url = _str(src, 'url');
  final grade = _str(src, 'grade');
  final narrator = _str(src, 'narrator');
  final gradedBy = _str(src, 'graded_by');

  if (type != 'quran' && type != 'hadith') e('source.type must be quran|hadith');
  if (!collections.contains(collection)) e('source.collection "$collection" is not a known collection');
  if (type == 'quran' && collection != 'quran') e('a quran source must use collection: quran');
  if (type == 'hadith' && collection == 'quran') e('a hadith source cannot use collection: quran');
  if (number == null) e('source.number is required');
  if (type == 'quran' && number != null && !_ayah.hasMatch(number)) e('quran number must look like 18:1 or 18:1-10');
  if (url == null) {
    e('source.url is required');
  } else {
    final host = Uri.tryParse(url)?.host.replaceFirst('www.', '');
    if (!trustedHosts.contains(host)) e('source.url host must be one of ${trustedHosts.join(', ')}');
  }
  if (type == 'hadith' && grade != null && !allowedGrades.contains(grade)) {
    e('grade "$grade" is not allowed: only ${allowedGrades.join('/')} (weak narrations are excluded)');
  }
  if (type == 'quran' && grade != null) e('quran sources take no grade');

  // Review.
  final review = m['review'];
  if (review is! YamlMap) {
    e('review is required');
    return null;
  }
  final st = _str(review, 'status');
  if (!Status.values.any((s) => s.name == st)) {
    e('review.status must be draft|checked|approved');
    return null;
  }
  final s = Status.values.byName(st!);

  final arabic = _str(m, 'arabic');
  final tr = m['translations'];
  final en = tr is YamlMap && tr['en'] is YamlMap ? tr['en'] as YamlMap : null;
  final enText = en == null ? null : _str(en, 'text');
  final enBy = en == null ? null : _str(en, 'translator');

  if (s.index >= Status.checked.index) {
    // Checked = a human compared every field against the primary source.
    if (arabic == null) e('checked items need arabic');
    if (enText == null || enBy == null) e('checked items need translations.en.text and .translator');
    if (type == 'hadith') {
      if (narrator == null) e('checked hadith need source.narrator');
      if (grade == null || gradedBy == null) e('checked hadith need source.grade and source.graded_by');
    }
    if (_str(review, 'checked_by') == null) e('checked items need review.checked_by');
    if (!_date.hasMatch(_str(review, 'checked_on') ?? '')) e('review.checked_on must be YYYY-MM-DD');
  }
  if (s == Status.approved) {
    if (_str(review, 'approved_by') == null) e('approved items need review.approved_by (the scholar)');
    if (!_date.hasMatch(_str(review, 'approved_on') ?? '')) e('review.approved_on must be YYYY-MM-DD');
  }
  if (before.isNotEmpty) return null;

  final translations = <String, Object?>{};
  if (tr is YamlMap) {
    for (final MapEntry(:key, :value) in tr.entries) {
      if (value is YamlMap && _str(value, 'text') != null) {
        translations['$key'] = {'text': _str(value, 'text'), 'translator': _str(value, 'translator')};
      }
    }
  }

  return {
    'id': id,
    'kind': kind,
    'title': {for (final MapEntry(:key, :value) in (title as YamlMap).entries) '$key': '$value'},
    'arabic': arabic,
    'transliteration': _str(m, 'transliteration'),
    'translations': translations,
    'source': {
      'type': type,
      'collection': collection,
      'number': number,
      'narrator': narrator,
      'grade': grade,
      'graded_by': gradedBy,
      'url': url,
    },
    'review': {
      'status': st,
      'checked_by': _str(review, 'checked_by'),
      'checked_on': _str(review, 'checked_on'),
      'approved_by': _str(review, 'approved_by'),
      'approved_on': _str(review, 'approved_on'),
      'notes': _str(review, 'notes'),
    },
    'version': version,
  };
}
