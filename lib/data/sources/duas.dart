import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/moments/moment.dart';

/// A situation to find the words for: waking, travel, the mosque.
class DuaTask {
  const DuaTask(this.id, this.icon, this.titles);
  final String id;

  /// A short icon key: sun, moon, drop, mosque, home, food, travel, heart.
  final String icon;
  final Map<String, String> titles;

  String title(String lang) => titles[lang] ?? titles['en'] ?? id;
}

/// The words to say for one moment, cut out of a HadeethEnc hadith by
/// tool/build_content.py: the Arabic and, where HadeethEnc's translation
/// carries it on its own, the meaning, both unchanged. The "when" label and
/// the transliteration are ours.
class Dua {
  const Dua({
    required this.id,
    required this.task,
    required this.he,
    required this.times,
    required this.when,
    required this.arabic,
    required this.latin,
    required this.meaning,
  });

  final String id;
  final String task;

  /// The HadeethEnc hadith it is taken from, bundled for the full reference.
  final int he;

  /// How many times to say it.
  final int times;
  final Map<String, String> when;
  final String arabic;
  final String latin;

  /// Per language. Missing where HadeethEnc has not translated it on its own;
  /// the Arabic then stands with a note, never another language.
  final Map<String, String> meaning;

  String whenIn(String lang) => when[lang] ?? when['en'] ?? id;
  String? meaningIn(String lang) => lang == 'ar' ? null : meaning[lang];
}

/// Every task and its duas, in order (Hisn al-Muslim's).
class DuaBook {
  DuaBook(this.tasks, this.items);
  final List<DuaTask> tasks;
  final List<Dua> items;

  DuaTask? task(String id) => tasks.where((t) => t.id == id).firstOrNull;
  List<Dua> forTask(String id) => [
    for (final d in items)
      if (d.task == id) d,
  ];

  /// The task that fits a moment of the day, if any.
  static String? taskFor(MomentId m) => switch (m) {
    MomentId.morningAdhkar || MomentId.eveningAdhkar => 'morning_evening',
    MomentId.bedtime => 'sleep',
    MomentId.afterSalah => 'salah',
    MomentId.iftar => 'food',
    _ => null,
  };

  static DuaBook parse(String json) {
    final j = jsonDecode(json) as Map<String, Object?>;
    Map<String, String> strings(Object? v) => {
      for (final MapEntry(:key, :value) in ((v as Map<String, Object?>?) ?? const {}).entries) key: '$value',
    };
    return DuaBook(
      [
        for (final t in j['tasks']! as List<Object?>)
          if (t case final Map<String, Object?> m) DuaTask('${m['id']}', '${m['icon']}', strings(m['title'])),
      ],
      [
        for (final i in j['items']! as List<Object?>)
          if (i case final Map<String, Object?> m)
            Dua(
              id: '${m['id']}',
              task: '${m['task']}',
              he: m['he']! as int,
              times: (m['times'] as int?) ?? 1,
              when: strings(m['when']),
              arabic: '${m['arabic']}',
              latin: '${m['latin']}',
              meaning: strings(m['meaning']),
            ),
      ],
    );
  }
}

final duaBookProvider = FutureProvider<DuaBook>(
  (ref) async => DuaBook.parse(await rootBundle.loadString('assets/sources/duas.json')),
);
