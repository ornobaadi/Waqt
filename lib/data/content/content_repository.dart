import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/test_mode.dart';
import '../../domain/moments/moment.dart';

enum ReviewStatus { draft, checked, approved }

class ContentSource {
  const ContentSource({
    required this.type,
    required this.collection,
    required this.number,
    required this.url,
    this.narrator,
    this.grade,
    this.gradedBy,
  });

  final String type;
  final String collection;
  final String number;
  final String url;
  final String? narrator;
  final String? grade;
  final String? gradedBy;

  bool get isQuran => type == 'quran';
}

/// One reviewed (or, in dev builds only, unreviewed) item. Every field comes
/// from content/*.yaml via tool/content.dart, never from code.
class ContentItem {
  const ContentItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.source,
    required this.status,
    required this.version,
    this.arabic,
    this.transliteration,
    this.translations = const {},
  });

  final String id;
  final String kind;
  final Map<String, String> title;
  final String? arabic;
  final String? transliteration;
  final Map<String, ({String text, String? translator})> translations;
  final ContentSource source;
  final ReviewStatus status;
  final int version;

  bool get approved => status == ReviewStatus.approved;

  String titleFor(String lang) => title[lang] ?? title['en']!;

  static ContentItem fromJson(Map<String, Object?> j) {
    final s = j['source']! as Map<String, Object?>;
    final r = j['review']! as Map<String, Object?>;
    final tr = (j['translations'] as Map<String, Object?>?) ?? const {};
    return ContentItem(
      id: j['id']! as String,
      kind: j['kind']! as String,
      title: (j['title']! as Map<String, Object?>).map((k, v) => MapEntry(k, v! as String)),
      arabic: j['arabic'] as String?,
      transliteration: j['transliteration'] as String?,
      translations: tr.map((k, v) {
        final m = v! as Map<String, Object?>;
        return MapEntry(k, (text: m['text']! as String, translator: m['translator'] as String?));
      }),
      source: ContentSource(
        type: s['type']! as String,
        collection: s['collection']! as String,
        number: s['number']! as String,
        url: s['url']! as String,
        narrator: s['narrator'] as String?,
        grade: s['grade'] as String?,
        gradedBy: s['graded_by'] as String?,
      ),
      status: ReviewStatus.values.byName(r['status']! as String),
      version: j['version']! as int,
    );
  }
}

class ContentBundle {
  ContentBundle._(this.version, this._items, this._moments);

  final String version;
  final Map<String, ContentItem> _items;
  final Map<MomentId, List<String>> _moments;

  int get length => _items.length;

  /// [includeUnreviewed] is for dev builds only. Release builds never show
  /// an item whose review status is not `approved` (PRD §7), even if one
  /// slipped into the bundle.
  static ContentBundle parse(String json, {required bool includeUnreviewed}) {
    final j = jsonDecode(json) as Map<String, Object?>;
    final items = <String, ContentItem>{};
    for (final v in (j['items']! as Map<String, Object?>).values) {
      final item = ContentItem.fromJson(v! as Map<String, Object?>);
      if (includeUnreviewed || item.approved) items[item.id] = item;
    }
    final byName = {for (final m in MomentId.values) m.name: m};
    final moments = <MomentId, List<String>>{};
    for (final MapEntry(:key, :value) in (j['moments']! as Map<String, Object?>).entries) {
      final id = byName[key];
      if (id == null) continue;
      moments[id] = (value! as List<Object?>).cast<String>().where(items.containsKey).toList();
    }
    return ContentBundle._(j['version']! as String, items, moments);
  }

  ContentItem? item(String id) => _items[id];

  Iterable<ContentItem> get items => _items.values;

  /// Moments (in engine order) that have content linked.
  List<MomentId> get moments => [
    for (final m in MomentId.values)
      if ((_moments[m] ?? const []).isNotEmpty) m,
  ];

  /// Items linked to no moment (situational library, Phase 6+).
  List<ContentItem> get unlinked {
    final linked = {for (final ids in _moments.values) ...ids};
    return [
      for (final i in _items.values)
        if (!linked.contains(i.id)) i,
    ];
  }

  List<ContentItem> forMoment(MomentId id) => [for (final i in _moments[id] ?? const <String>[]) _items[i]!];
}

final contentProvider = FutureProvider<ContentBundle>((ref) async {
  final json = await rootBundle.loadString('assets/content/content.json');
  // Unchecked items appear only when test mode asks for them, marked as drafts.
  return ContentBundle.parse(json, includeUnreviewed: ref.watch(testModeProvider.select((s) => s.showUnchecked)));
});

/// Items for a moment; empty while loading or if none are linked.
final momentContentProvider = Provider.family<List<ContentItem>, MomentId>((ref, id) {
  return ref.watch(contentProvider).value?.forMoment(id) ?? const [];
});
