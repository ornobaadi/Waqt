import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_state.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../core/widgets/waqt_widgets.dart';
import '../../data/sources/hadith_db.dart';
import '../../data/sources/days.dart';
import '../../data/sources/hisn.dart';
import '../../domain/occasions/occasions.dart';
import '../common/labels.dart';
import '../now/day_guide_card.dart';
import '../../domain/moments/moment.dart';
import '../../l10n/app_localizations.dart';
import 'library_views.dart';

/// Hisn al-Muslim chapters that fit a moment of the day. Which chapter a
/// moment opens is our choice; every word inside comes from the book.
const momentChapters = <MomentId, List<int>>{
  MomentId.fajr: [1, 12, 13],
  MomentId.morningAdhkar: [27],
  MomentId.eveningAdhkar: [27],
  MomentId.betweenAdhanIqamah: [15],
  MomentId.afterSalah: [25],
  MomentId.bedtime: [28, 29, 30],
  MomentId.lastThird: [32, 129],
  MomentId.iftar: [68, 73],
  MomentId.suhoor: [129],
  MomentId.taraweeh: [32, 33],
  MomentId.laylatAlQadr: [129, 130],
  MomentId.jumuah: [107],
  MomentId.fridayLastHour: [107, 132],
};

enum _Scope { duas, hadith }

/// The library: what fits right now, every situation in Hisn al-Muslim, and a
/// search across the duas and all the hadith collections.
class DuasScreen extends ConsumerStatefulWidget {
  const DuasScreen({super.key});

  @override
  ConsumerState<DuasScreen> createState() => _DuasScreenState();
}

class _DuasScreenState extends ConsumerState<DuasScreen> {
  final _search = TextEditingController();
  String _q = '';
  _Scope _scope = _Scope.duas;
  Timer? _debounce;
  Future<List<Hadith>>? _hadith;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onQuery(String v) {
    setState(() => _q = v);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _runHadith);
  }

  void _runHadith() {
    if (!mounted || _scope != _Scope.hadith) return;
    if (ref.read(hadithInstallProvider).status != HadithLibrary.ready) return;
    final q = _q.trim();
    setState(() => _hadith = q.isEmpty ? null : ref.read(hadithDbProvider.future).then((db) => db.search(q)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final book = ref.watch(hisnProvider).value;
    ref.listen(hadithInstallProvider.select((s) => s.status), (_, s) {
      if (s == HadithLibrary.ready) _runHadith();
    });
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    final q = _q.trim();

    String name(HisnChapter c) => ar ? c.ar : c.en;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(child: ScreenTitle(l.navDuas)),
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: WaqtSpace.x3),
                  child: IconButton(
                    tooltip: l.counterOpen,
                    onPressed: () => context.push('/counter'),
                    icon: Icon(Icons.radio_button_checked_rounded, color: t.ink),
                  ),
                ),
              ],
            ),
          ),
          _pad(
            TextField(
              controller: _search,
              onChanged: _onQuery,
              textInputAction: TextInputAction.search,
              style: WaqtText.body.copyWith(color: t.ink),
              cursorColor: t.ink,
              decoration: InputDecoration(
                hintText: l.librarySearchAll,
                hintStyle: WaqtText.body.copyWith(color: t.inkMuted),
                filled: true,
                fillColor: t.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x4, vertical: WaqtSpace.x3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(WaqtRadii.row),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search_rounded, size: 20, color: t.inkMuted),
                suffixIcon: q.isEmpty
                    ? null
                    : IconButton(
                        tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                        onPressed: () {
                          _search.clear();
                          _onQuery('');
                        },
                        icon: Icon(Icons.close_rounded, size: 20, color: t.inkMuted),
                      ),
              ),
            ),
          ),
          if (q.isNotEmpty) ...[
            _pad(
              Padding(
                padding: const EdgeInsets.only(top: WaqtSpace.x3),
                child: SegmentedButton<_Scope>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(value: _Scope.duas, label: Text(l.scopeDuas)),
                    ButtonSegment(value: _Scope.hadith, label: Text(l.scopeHadith)),
                  ],
                  selected: {_scope},
                  onSelectionChanged: (s) {
                    setState(() => _scope = s.first);
                    _runHadith();
                  },
                ),
              ),
            ),
            if (_scope == _Scope.duas && book != null) ..._duaResults(context, book, q, name),
            if (_scope == _Scope.hadith) ..._hadithResults(context, q),
          ] else if (book != null) ...[
            ..._forNow(context, book, name),
            _pad(SectionLabel(l.librarySituations)),
            // Built lazily: only the rows on screen exist, so scrolling the
            // 132 situations stays smooth.
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.screen),
              sliver: SliverList.builder(
                itemCount: book.chapters.length,
                itemBuilder: (context, i) {
                  final c = book.chapters[i];
                  final last = i == book.chapters.length - 1;
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: t.surface,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(i == 0 ? WaqtRadii.strip : 0),
                        bottom: Radius.circular(last ? WaqtRadii.strip : 0),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        WaqtSpace.x1,
                        i == 0 ? WaqtSpace.x1 : 0,
                        WaqtSpace.x1,
                        last ? WaqtSpace.x1 : 0,
                      ),
                      child: RowTile(
                        title: name(c),
                        value: '${book.inChapter(c.number).length}',
                        onTap: () => context.push('/duas/hisn/${c.number}'),
                      ),
                    ),
                  );
                },
              ),
            ),
            _pad(
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x1, vertical: WaqtSpace.x4),
                child: Text(l.sourceHisn, style: WaqtText.caption.copyWith(color: t.inkMuted)),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: WaqtSpace.x12)),
        ],
      ),
    );
  }

  /// Chapters for whatever is happening now, most specific first.
  List<Widget> _forNow(BuildContext context, HisnBook book, String Function(HisnChapter) name) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    // Select a string, not a list: a new list every clock tick would rebuild
    // the whole library each second and make scrolling stutter.
    final key = ref.watch(momentSnapshotProvider.select((s) => s?.active.map((m) => m.id.name).join(',') ?? ''));
    final active = [for (final n in key.split(',')) ?MomentId.values.asNameMap()[n]];
    final chapters = <int>{for (final id in active.reversed) ...?momentChapters[id]}
        .map(book.chapter)
        .nonNulls
        .toList();
    // Today's special-day Sunnah, sourced, as a short list under the chapters.
    final occasions = ref.watch(occasionsProvider.select((o) => o.list.map((x) => x.name).join(',')));
    final guides = ref.watch(dayGuidesProvider).value;
    final occList = [for (final n in occasions.split(',')) ?OccasionId.values.asNameMap()[n]];
    final featured = guides?.featured(occList);
    final today = featured == null ? const <DayItem>[] : guides!.itemsFor(featured, occList);
    if (chapters.isEmpty && today.isEmpty) return const [];
    return [
      if (today.isNotEmpty) ...[
        _pad(SectionLabel(l.occasion(featured!, ramadanDay: ''))),
        _pad(
          RowGroup(
            children: [
              for (final i in today.take(4))
                RowTile(title: i.title, subtitle: i.reference, onTap: () => openDayItem(context, ref, i)),
            ],
          ),
        ),
      ],
      if (chapters.isNotEmpty) ...[
        _pad(SectionLabel(l.libraryForNow)),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.screen),
              itemCount: chapters.length,
              separatorBuilder: (_, _) => const SizedBox(width: WaqtSpace.x3),
              itemBuilder: (context, i) {
                final c = chapters[i];
                return SizedBox(
                  width: 220,
                  child: Material(
                    color: t.heroSurface,
                    borderRadius: BorderRadius.circular(WaqtRadii.strip),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(WaqtRadii.strip),
                      onTap: () => context.push('/duas/hisn/${c.number}'),
                      child: Padding(
                        padding: const EdgeInsets.all(WaqtSpace.x4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                name(c),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: WaqtText.bodyStrong.copyWith(color: t.heroInk),
                              ),
                            ),
                            Text(
                              l.duaCount(book.inChapter(c.number).length),
                              style: WaqtText.caption.copyWith(color: t.heroInk.withValues(alpha: 0.7)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    ];
  }

  List<Widget> _duaResults(BuildContext context, HisnBook book, String q, String Function(HisnChapter) name) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final r = book.search(q);
    if (r.chapters.isEmpty && r.duas.isEmpty) {
      return [_pad(_Note(l.libraryNoMatch(q)))];
    }
    return [
      if (r.chapters.isNotEmpty) ...[
        _pad(SectionLabel(l.librarySituations)),
        _pad(
          RowGroup(
            children: [
              for (final c in r.chapters) RowTile(title: name(c), onTap: () => context.push('/duas/hisn/${c.number}')),
            ],
          ),
        ),
      ],
      if (r.duas.isNotEmpty) ...[
        _pad(SectionLabel(l.duaCount(r.duas.length))),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.screen),
          sliver: SliverList.separated(
            itemCount: r.duas.length,
            separatorBuilder: (_, _) => const SizedBox(height: WaqtSpace.x3),
            itemBuilder: (context, i) {
              final d = r.duas[i];
              final c = book.chapter(d.chapter);
              return HisnDuaCard(dua: d, chapter: c == null ? null : name(c));
            },
          ),
        ),
      ],
      _pad(
        Padding(
          padding: const EdgeInsets.only(top: WaqtSpace.x4),
          child: Text(l.sourceHisn, style: WaqtText.caption.copyWith(color: t.inkMuted)),
        ),
      ),
    ];
  }

  List<Widget> _hadithResults(BuildContext context, String q) {
    final l = AppLocalizations.of(context);
    if (ref.watch(hadithInstallProvider.select((s) => s.status)) != HadithLibrary.ready) {
      return [
        _pad(
          const Padding(
            padding: EdgeInsets.only(top: WaqtSpace.x4),
            child: HadithDownloadCard(),
          ),
        ),
      ];
    }
    final progress = ref.watch(hadithIndexProgressProvider);
    return [
      SliverToBoxAdapter(
        child: FutureBuilder<List<Hadith>>(
          future: _hadith,
          builder: (context, snap) {
            final list = snap.data;
            if (snap.hasError) {
              // The hadith database needs the phone's SQLite (not in a browser).
              return Padding(padding: const EdgeInsets.all(WaqtSpace.screen), child: _Note(l.hadithUnavailable));
            }
            if (list == null) {
              // First search only: the index is being built.
              return Padding(
                padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, WaqtSpace.x6, WaqtSpace.screen, 0),
                child: Column(
                  children: [
                    LinearProgressIndicator(value: progress),
                    if (progress != null) ...[const SizedBox(height: WaqtSpace.x3), _Note(l.libraryPreparing)],
                  ],
                ),
              );
            }
            if (list.isEmpty) {
              return Padding(padding: const EdgeInsets.all(WaqtSpace.screen), child: _Note(l.libraryNoMatch(q)));
            }
            return Padding(
              padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, WaqtSpace.x4, WaqtSpace.screen, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final h in list) ...[HadithTile(hadith: h), const SizedBox(height: WaqtSpace.x3)],
                  _Note(list.length >= 60 ? l.libraryRefine : l.sourceHadith),
                ],
              ),
            );
          },
        ),
      ),
    ];
  }

  static Widget _pad(Widget child) => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.screen),
    sliver: SliverToBoxAdapter(child: child),
  );
}

class _Note extends StatelessWidget {
  const _Note(this.text);
  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: WaqtText.body.copyWith(color: WaqtTokens.of(context).inkMuted));
}
