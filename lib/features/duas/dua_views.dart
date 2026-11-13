import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_state.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../core/widgets/waqt_widgets.dart';
import '../../data/sources/duas.dart';
import '../../data/sources/hadeethenc.dart';
import '../../data/user/reading_prefs.dart';
import '../../l10n/app_localizations.dart';
import '../common/labels.dart';
import 'library_views.dart';

IconData duaTaskIcon(String key) => switch (key) {
  'sun' => Icons.wb_sunny_outlined,
  'moon' => Icons.bedtime_outlined,
  'drop' => Icons.water_drop_outlined,
  'mosque' => Icons.mosque_outlined,
  'home' => Icons.door_front_door_outlined,
  'food' => Icons.restaurant_outlined,
  'travel' => Icons.luggage_outlined,
  'heart' => Icons.healing_outlined,
  'crescent' => Icons.nightlight_outlined,
  _ => Icons.menu_book_outlined,
};

/// "Duas to say": a search, the task that fits this moment, then every task
/// as a tile with a hint of what is inside.
class SayDuas extends ConsumerStatefulWidget {
  const SayDuas({super.key});

  @override
  ConsumerState<SayDuas> createState() => _SayDuasState();
}

class _SayDuasState extends ConsumerState<SayDuas> {
  final _search = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final book = ref.watch(duaBookProvider).value;
    if (book == null) return const SizedBox.shrink();
    // A string, not the list: the snapshot changes every second.
    final key = ref.watch(
      momentSnapshotProvider.select((s) {
        for (final m in (s?.active ?? const []).reversed) {
          final task = DuaBook.taskFor(m.id);
          if (task != null) return '$task|${l.moment(m)}';
        }
        return '';
      }),
    );
    final now = key.isEmpty ? null : key.split('|');
    final nowTask = now == null ? null : book.task(now[0]);
    final q = _q.trim();
    final found = book.search(q, lang);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: WaqtSpace.x3),
          TextField(
            controller: _search,
            onChanged: (v) => setState(() => _q = v),
            textInputAction: TextInputAction.search,
            style: WaqtText.body.copyWith(color: t.ink),
            cursorColor: t.ink,
            decoration: InputDecoration(
              hintText: l.duasSearchHint,
              hintStyle: WaqtText.body.copyWith(color: t.inkMuted),
              filled: true,
              fillColor: t.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x4, vertical: WaqtSpace.x3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(WaqtSpace.minTouch / 2),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(Icons.search_rounded, size: 20, color: t.inkMuted),
              suffixIcon: q.isEmpty
                  ? null
                  : IconButton(
                      tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                      onPressed: () => setState(() {
                        _search.clear();
                        _q = '';
                      }),
                      icon: Icon(Icons.close_rounded, size: 20, color: t.inkMuted),
                    ),
            ),
          ),
          if (q.isNotEmpty) ...[
            const SizedBox(height: WaqtSpace.x4),
            if (found.isEmpty)
              Text(l.libraryNoMatch(q), style: WaqtText.body.copyWith(color: t.inkMuted))
            else
              RowGroup(
                children: [
                  for (final d in found)
                    _DuaRow(dua: d, onTap: () => context.push('/dua/${d.task}/${book.forTask(d.task).indexOf(d)}')),
                ],
              ),
          ] else ...[
            if (nowTask != null) ...[const SizedBox(height: WaqtSpace.x4), _NowCard(task: nowTask, moment: now![1])],
            SectionLabel(l.duasByTask),
            for (var i = 0; i < book.tasks.length; i += 2)
              Padding(
                padding: const EdgeInsets.only(bottom: WaqtSpace.x3),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _TaskTile(task: book.tasks[i], count: book.forTask(book.tasks[i].id).length),
                      ),
                      const SizedBox(width: WaqtSpace.x3),
                      Expanded(
                        child: i + 1 < book.tasks.length
                            ? _TaskTile(task: book.tasks[i + 1], count: book.forTask(book.tasks[i + 1].id).length)
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// The dark card for the moment you are in, as on Home.
class _NowCard extends StatelessWidget {
  const _NowCard({required this.task, required this.moment});
  final DuaTask task;
  final String moment;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return Material(
      color: t.ink,
      borderRadius: BorderRadius.circular(WaqtRadii.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(WaqtRadii.card),
        onTap: () => context.push('/duas/task/${task.id}'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(WaqtSpace.x5, WaqtSpace.x4, WaqtSpace.x4, WaqtSpace.x4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l.duasRightNow} · $moment'.toUpperCase(),
                      style: WaqtText.overline.copyWith(color: t.ground.withValues(alpha: 0.72)),
                    ),
                    const SizedBox(height: 2),
                    Text(task.title(lang), style: WaqtText.titleSmall.copyWith(color: t.ground)),
                    const SizedBox(height: 2),
                    Text(task.hint(lang), style: WaqtText.label.copyWith(color: t.ground.withValues(alpha: 0.72))),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: t.ground.withValues(alpha: 0.72),
                textDirection: Directionality.of(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A task in the grid: its icon and count, its name, and a hint of what
/// is inside.
class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task, required this.count});
  final DuaTask task;
  final int count;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return Semantics(
      button: true,
      label: '${task.title(lang)}, ${l.duasCount(count)}',
      excludeSemantics: true,
      child: Material(
        color: t.surface,
        borderRadius: BorderRadius.circular(WaqtRadii.strip),
        child: InkWell(
          borderRadius: BorderRadius.circular(WaqtRadii.strip),
          onTap: () => context.push('/duas/task/${task.id}'),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(WaqtSpace.x4, WaqtSpace.x4, WaqtSpace.x3, WaqtSpace.x4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(duaTaskIcon(task.icon), size: 24, color: t.ink),
                    const Spacer(),
                    Text(
                      '$count',
                      style: WaqtText.label.copyWith(
                        color: t.inkMuted,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: WaqtSpace.x6),
                Text(task.title(lang), style: WaqtText.bodyStrong.copyWith(color: t.ink, height: 1.25)),
                const SizedBox(height: 2),
                Text(
                  task.hint(lang),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: WaqtText.caption.copyWith(color: t.inkMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One task: its duas in order, each as its first Arabic line.
class DuaTaskScreen extends ConsumerWidget {
  const DuaTaskScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final book = ref.watch(duaBookProvider).value;
    final task = book?.task(id);
    final duas = book?.forTask(id) ?? const <Dua>[];
    return Scaffold(
      backgroundColor: t.ground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: t.ink,
        title: Text(task?.title(lang) ?? '', style: WaqtText.bodyStrong.copyWith(color: t.ink)),
      ),
      body: book == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(
                WaqtSpace.screen,
                0,
                WaqtSpace.screen,
                // Clear of the floating dock.
                WaqtSpace.x12 + WaqtSpace.x12 + MediaQuery.paddingOf(context).bottom,
              ),
              children: [
                Text(l.duasTaskIntro, style: WaqtText.body.copyWith(color: t.inkMuted)),
                const SizedBox(height: WaqtSpace.x4),
                RowGroup(
                  children: [
                    for (final (i, d) in duas.indexed) _DuaRow(dua: d, onTap: () => context.push('/dua/$id/$i')),
                  ],
                ),
                if (duas.length > 1) ...[
                  const SizedBox(height: WaqtSpace.x5),
                  FilledButton(
                    onPressed: () => context.push('/dua/$id/0'),
                    style: FilledButton.styleFrom(
                      backgroundColor: t.ink,
                      foregroundColor: t.ground,
                      minimumSize: const Size.fromHeight(WaqtSpace.minTouch),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(l.duasGoThrough),
                  ),
                ],
              ],
            ),
    );
  }
}

class _DuaRow extends StatelessWidget {
  const _DuaRow({required this.dua, required this.onTap});
  final Dua dua;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = WaqtTokens.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(WaqtRadii.row),
        child: Padding(
          padding: const EdgeInsets.all(WaqtSpace.x3),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(dua.whenIn(lang), style: WaqtText.bodyStrong.copyWith(color: t.ink)),
                    const SizedBox(height: WaqtSpace.x1),
                    Text(
                      dua.arabic,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                      style: WaqtText.arabic.copyWith(color: t.inkMuted, fontSize: 19, height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: WaqtSpace.x2),
              Icon(Icons.chevron_right_rounded, size: 20, color: t.inkMuted, textDirection: Directionality.of(context)),
            ],
          ),
        ),
      ),
    );
  }
}

/// A task's duas one per page: the words, how to say them, what they mean,
/// and the hadith they come from on request.
class DuaPagerScreen extends ConsumerStatefulWidget {
  const DuaPagerScreen({super.key, required this.task, required this.index});
  final String task;
  final int index;

  @override
  ConsumerState<DuaPagerScreen> createState() => _DuaPagerScreenState();
}

class _DuaPagerScreenState extends ConsumerState<DuaPagerScreen> {
  late final _pages = PageController(initialPage: widget.index);
  late int _page = widget.index;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _go(int i) => _pages.animateToPage(i, duration: WaqtMotion.ui, curve: WaqtMotion.ease);

  /// Arabic, transliteration and meaning grow and shrink together.
  void _resize(double by) {
    double k(double v) => double.parse((v + by).clamp(ReadingPrefs.min, ReadingPrefs.max).toStringAsFixed(1));
    final rp = ref.read(readingPrefsProvider);
    ref
        .read(readingPrefsProvider.notifier)
        .set(arabic: k(rp.arabic), transliteration: k(rp.transliteration), meaning: k(rp.meaning));
  }

  /// The words to share with someone: Arabic, how to say it, the meaning in
  /// this language (when HadeethEnc has it), and where it comes from.
  Future<void> _copy(Dua d, String lang, AppLocalizations l) async {
    final h = ref.read(heBundleProvider).value?[d.he];
    final text = [
      d.arabic,
      d.latin,
      ?d.meaningIn(lang),
      if (h != null) heSource(h, lang),
      'HadeethEnc.com',
    ].join('\n\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.copied)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final book = ref.watch(duaBookProvider).value;
    final duas = book?.forTask(widget.task) ?? const <Dua>[];
    final last = _page >= duas.length - 1;
    final rp = ref.watch(readingPrefsProvider);
    return Scaffold(
      backgroundColor: t.ground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: t.ink,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book?.task(widget.task)?.title(lang) ?? '', style: WaqtText.bodyStrong.copyWith(color: t.ink)),
            if (duas.length > 1)
              Text(
                l.duaPosition(_page + 1, duas.length),
                style: WaqtText.caption.copyWith(color: t.inkMuted, fontFeatures: const [FontFeature.tabularFigures()]),
              ),
          ],
        ),
        actions: [
          if (duas.isNotEmpty) ...[
            IconButton(
              tooltip: l.textSmaller,
              icon: const Icon(Icons.text_decrease_rounded),
              onPressed: rp.arabic <= ReadingPrefs.min ? null : () => _resize(-0.1),
            ),
            IconButton(
              tooltip: l.textLarger,
              icon: const Icon(Icons.text_increase_rounded),
              onPressed: rp.arabic >= ReadingPrefs.max ? null : () => _resize(0.1),
            ),
            IconButton(
              tooltip: l.copyText,
              icon: const Icon(Icons.copy_rounded),
              onPressed: () => _copy(duas[_page.clamp(0, duas.length - 1)], lang, l),
            ),
          ],
        ],
      ),
      body: duas.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
              controller: _pages,
              itemCount: duas.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, i) => DuaPage(dua: duas[i]),
            ),
      bottomNavigationBar: duas.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, WaqtSpace.x2, WaqtSpace.screen, WaqtSpace.x3),
                child: Row(
                  children: [
                    if (_page > 0) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _go(_page - 1),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: t.ink,
                            side: BorderSide(color: t.hairline),
                            minimumSize: const Size.fromHeight(WaqtSpace.minTouch),
                            shape: const StadiumBorder(),
                          ),
                          child: Text(l.duaPrevious),
                        ),
                      ),
                      const SizedBox(width: WaqtSpace.x3),
                    ],
                    Expanded(
                      child: FilledButton(
                        onPressed: last ? () => Navigator.of(context).maybePop() : () => _go(_page + 1),
                        style: FilledButton.styleFrom(
                          backgroundColor: t.ink,
                          foregroundColor: t.ground,
                          minimumSize: const Size.fromHeight(WaqtSpace.minTouch),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(last ? l.duaDone : l.duaNext),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

/// One dua: when to say it, the Arabic, how to say it, its meaning, and
/// its reference with the full hadith a tap away.
class DuaPage extends ConsumerWidget {
  const DuaPage({super.key, required this.dua});
  final Dua dua;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final rp = ref.watch(readingPrefsProvider);
    final lang = Localizations.localeOf(context).languageCode;
    final meaning = dua.meaningIn(lang);
    Widget label(String s) => Padding(
      padding: const EdgeInsets.only(top: WaqtSpace.x6, bottom: WaqtSpace.x2),
      child: Text(s.toUpperCase(), style: WaqtText.overline.copyWith(color: t.inkMuted)),
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(WaqtSpace.screen, WaqtSpace.x2, WaqtSpace.screen, WaqtSpace.x8),
      children: [
        Semantics(
          header: true,
          child: Text(dua.whenIn(lang), style: WaqtText.titleSmall.copyWith(color: t.ink)),
        ),
        const SizedBox(height: WaqtSpace.x2),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x3, vertical: WaqtSpace.x1),
            decoration: BoxDecoration(color: t.accent.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(99)),
            child: Text(
              l.duaSayTimes(dua.times),
              style: WaqtText.caption.copyWith(color: t.ink, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: WaqtSpace.x6),
        SelectableText(
          dua.arabic,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: ReadingPrefs.scaled(WaqtText.arabic.copyWith(color: t.ink, fontSize: 28, height: 1.9), rp.arabic),
        ),
        label(l.duaHowToSay),
        SelectableText(
          dua.latin,
          textDirection: TextDirection.ltr,
          style: ReadingPrefs.scaled(
            WaqtText.body.copyWith(color: t.ink, fontStyle: FontStyle.italic, height: 1.55),
            rp.transliteration,
          ),
        ),
        if (lang != 'ar') ...[
          label(l.duaMeaning),
          if (meaning != null)
            SelectableText(
              meaning,
              style: ReadingPrefs.scaled(WaqtText.body.copyWith(color: t.ink, height: 1.6), rp.meaning),
            )
          else
            Container(
              padding: const EdgeInsets.all(WaqtSpace.x3),
              decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(WaqtRadii.row)),
              child: Text(
                l.duaNoMeaning(languageSelfName[lang] ?? lang),
                style: WaqtText.label.copyWith(color: t.inkMuted),
              ),
            ),
        ],
        label(l.duaReference),
        HeSourceText(
          id: dua.he,
          style: WaqtText.label.copyWith(color: t.ink),
          maxLines: null,
        ),
        const SizedBox(height: WaqtSpace.x2),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: () => openHadith(context, ref, dua.he),
            style: TextButton.styleFrom(
              foregroundColor: t.ink,
              minimumSize: const Size(0, WaqtSpace.minTouch),
              padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x2),
            ),
            icon: const Icon(Icons.menu_book_outlined, size: 18),
            label: Text(l.duaSeeHadith),
          ),
        ),
      ],
    );
  }
}
