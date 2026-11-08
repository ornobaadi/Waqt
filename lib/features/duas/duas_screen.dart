import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_state.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../core/widgets/waqt_widgets.dart';
import '../../data/sources/days.dart';
import '../../data/sources/hadeethenc.dart';
import '../../data/sources/he_library.dart';
import '../../domain/moments/moment.dart';
import '../../domain/occasions/occasions.dart';
import '../../l10n/app_localizations.dart';
import '../common/labels.dart';
import 'library_views.dart';

/// HadeethEnc's topic of duas and remembrance ("فقه الأدعية والأذكار").
const duasTopic = 268;

/// The library: what fits right now, today's Sunnah, then HadeethEnc's
/// topics and a search, all in the reader's language.
class DuasScreen extends ConsumerStatefulWidget {
  const DuasScreen({super.key});

  @override
  ConsumerState<DuasScreen> createState() => _DuasScreenState();
}

class _DuasScreenState extends ConsumerState<DuasScreen> {
  final _search = TextEditingController();
  String _q = '';
  Timer? _debounce;
  Future<List<HeHadith>>? _results;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onQuery(String v) {
    setState(() => _q = v);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _run);
  }

  void _run() {
    if (!mounted || ref.read(hadithInstallProvider).status != HadithLibrary.ready) return;
    final q = _q.trim();
    setState(() => _results = q.isEmpty ? null : ref.read(heLibraryProvider.future).then((lib) => lib.search(q)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    ref.listen(hadithInstallProvider.select((s) => s.status), (_, s) {
      if (s == HadithLibrary.ready) _run();
    });
    final ready = ref.watch(hadithInstallProvider.select((s) => s.status == HadithLibrary.ready));
    final lib = ref.watch(heLibraryProvider).value;
    final q = _q.trim();

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
          if (q.isNotEmpty)
            ..._searchResults(context, q, ready)
          else ...[
            ..._forNow(context),
            if (!ready)
              _pad(
                const Padding(
                  padding: EdgeInsets.only(top: WaqtSpace.x6),
                  child: HadithDownloadCard(),
                ),
              )
            else if (lib != null) ...[
              _pad(SectionLabel(lib.topic(duasTopic)?.title ?? l.scopeDuas)),
              _pad(
                RowGroup(
                  children: [
                    for (final s in lib.children(duasTopic))
                      RowTile(title: s.title, onTap: () => context.push('/duas/topic/${s.id}')),
                  ],
                ),
              ),
              _pad(SectionLabel(l.libraryAllTopics)),
              _pad(
                RowGroup(
                  children: [
                    for (final s in lib.children(0))
                      RowTile(title: s.title, onTap: () => context.push('/duas/topic/${s.id}')),
                  ],
                ),
              ),
            ],
          ],
          SliverToBoxAdapter(child: SizedBox(height: WaqtSpace.x12 + MediaQuery.paddingOf(context).bottom)),
        ],
      ),
    );
  }

  /// The Sunnah of this moment and of today, from the bundled hadiths: there
  /// even before the library is downloaded.
  List<Widget> _forNow(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final guides = ref.watch(dayGuidesProvider).value;
    if (guides == null) return const [];
    // Select strings, not lists: a new list every clock tick would rebuild
    // the whole library each second and make scrolling stutter.
    final key = ref.watch(momentSnapshotProvider.select((s) => s?.active.map((m) => m.id.name).join(',') ?? ''));
    final active = [for (final n in key.split(',')) ?MomentId.values.asNameMap()[n]];
    final seen = <int>{};
    final now = [
      for (final id in active.reversed)
        for (final i in guides.forMoment(id))
          if (seen.add(i.he)) i,
    ];
    final occasions = ref.watch(occasionsProvider.select((o) => o.list.map((x) => x.name).join(',')));
    final occList = [for (final n in occasions.split(',')) ?OccasionId.values.asNameMap()[n]];
    final featured = guides.featured(occList);
    final today = featured == null ? const <DayItem>[] : guides.itemsFor(featured, occList);
    Widget row(DayItem i) => RowTile(title: i.title(lang), subtitle: null, onTap: () => openHadith(context, ref, i.he));
    final sub = WaqtText.caption.copyWith(color: t.inkMuted);
    return [
      if (now.isNotEmpty) ...[
        _pad(SectionLabel(l.libraryForNow)),
        _pad(
          RowGroup(
            children: [for (final i in now.take(4)) _Sourced(item: i, style: sub, row: row)],
          ),
        ),
      ],
      if (today.isNotEmpty) ...[
        _pad(SectionLabel(l.occasion(featured!, ramadanDay: ''))),
        _pad(
          RowGroup(
            children: [for (final i in today.take(4)) _Sourced(item: i, style: sub, row: row)],
          ),
        ),
      ],
    ];
  }

  List<Widget> _searchResults(BuildContext context, String q, bool ready) {
    final l = AppLocalizations.of(context);
    if (!ready) {
      return [
        _pad(
          const Padding(
            padding: EdgeInsets.only(top: WaqtSpace.x4),
            child: HadithDownloadCard(),
          ),
        ),
      ];
    }
    return [
      SliverToBoxAdapter(
        child: FutureBuilder<List<HeHadith>>(
          future: _results,
          builder: (context, snap) {
            final list = snap.data;
            if (snap.hasError) {
              return Padding(padding: const EdgeInsets.all(WaqtSpace.screen), child: _Note(l.hadithUnavailable));
            }
            if (list == null) {
              return const Padding(
                padding: EdgeInsets.fromLTRB(WaqtSpace.screen, WaqtSpace.x6, WaqtSpace.screen, 0),
                child: LinearProgressIndicator(),
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

/// A sourced row: our label, with the hadith's book and grade beneath.
class _Sourced extends StatelessWidget {
  const _Sourced({required this.item, required this.style, required this.row});
  final DayItem item;
  final TextStyle style;
  final Widget Function(DayItem) row;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      row(item),
      Padding(
        padding: const EdgeInsetsDirectional.only(start: WaqtSpace.x4, end: WaqtSpace.x4, bottom: WaqtSpace.x2),
        child: HeSourceText(id: item.he, style: style),
      ),
    ],
  );
}

class _Note extends StatelessWidget {
  const _Note(this.text);
  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: WaqtText.body.copyWith(color: WaqtTokens.of(context).inkMuted));
}
