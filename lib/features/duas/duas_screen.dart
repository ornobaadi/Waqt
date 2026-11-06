import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../core/widgets/waqt_widgets.dart';
import '../../data/content/content_repository.dart';
import '../../l10n/app_localizations.dart';
import '../common/labels.dart';
import 'dua_sheet.dart';

/// Browse by moment, or search by title or reference ("bukhari 2311").
/// Only reviewed content appears in release builds.
class DuasScreen extends ConsumerStatefulWidget {
  const DuasScreen({super.key});

  @override
  ConsumerState<DuasScreen> createState() => _DuasScreenState();
}

class _DuasScreenState extends ConsumerState<DuasScreen> {
  final _search = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matches(ContentItem i, AppLocalizations l, String lang) {
    final q = _q.trim().toLowerCase();
    if (q.isEmpty) return true;
    final hay =
        '${i.titleFor(lang)} ${i.title['en']} ${l.reference(i.source)} ${i.source.collection} ${i.source.number}'
            .toLowerCase();
    return q.split(RegExp(r'\s+')).every(hay.contains);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final bundle = ref.watch(contentProvider).value;

    if (bundle == null || bundle.length == 0) {
      return SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenTitle(l.navDuas),
            Expanded(
              child: EmptyState(title: l.duasEmptyTitle, body: l.duasEmptyBody, progress: 0.85),
            ),
          ],
        ),
      );
    }

    final sections = <(String, List<ContentItem>)>[
      for (final m in bundle.moments) (l.momentId(m), bundle.forMoment(m).where((i) => _matches(i, l, lang)).toList()),
      (l.libraryOther, bundle.unlinked.where((i) => _matches(i, l, lang)).toList()),
    ].where((s) => s.$2.isNotEmpty).toList();

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
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
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.screen),
            sliver: SliverToBoxAdapter(
              child: TextField(
                controller: _search,
                onChanged: (v) => setState(() => _q = v),
                textInputAction: TextInputAction.search,
                style: WaqtText.body.copyWith(color: t.ink),
                cursorColor: t.ink,
                decoration: InputDecoration(
                  hintText: l.librarySearch,
                  hintStyle: WaqtText.body.copyWith(color: t.inkMuted),
                  filled: true,
                  fillColor: t.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x4, vertical: WaqtSpace.x3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(WaqtRadii.row),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.search_rounded, size: 20, color: t.inkMuted),
                ),
              ),
            ),
          ),
          if (sections.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.all(WaqtSpace.screen),
              sliver: SliverToBoxAdapter(
                child: Text(l.libraryNoMatch(_q.trim()), style: WaqtText.body.copyWith(color: t.inkMuted)),
              ),
            ),
          for (final (title, items) in sections) ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, WaqtSpace.x2, WaqtSpace.screen, 0),
              sliver: SliverToBoxAdapter(child: SectionLabel(title)),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.screen),
              sliver: SliverToBoxAdapter(
                child: RowGroup(
                  children: [
                    for (final i in items)
                      RowTile(
                        title: i.titleFor(lang),
                        subtitle: i.approved ? l.reference(i.source) : '${l.reference(i.source)}  ·  ${l.statusDraft}',
                        onTap: () => showDuaSheet(context, i),
                      ),
                  ],
                ),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: WaqtSpace.x12)),
        ],
      ),
    );
  }
}
