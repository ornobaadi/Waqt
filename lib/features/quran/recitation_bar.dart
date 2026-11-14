import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/waqt_theme.dart';
import '../../data/quran/quran.dart';
import '../../data/quran/quran_prefs.dart';
import '../../data/quran/recitation.dart';
import '../../data/quran/recitation_downloads.dart';
import '../../l10n/app_localizations.dart';
import '../../platform/quran_audio.dart';
import 'quran_screen.dart' show openReader, surahName;

/// The recitation player as one calm row: play or pause, what is playing,
/// and a few controls. In the reader it also skips ayat and holds speed,
/// downloads and stop in a menu; everywhere else ([mini]) it shows what is
/// playing, opens the reader on tap, and closes with ×.
class RecitationBar extends ConsumerWidget {
  const RecitationBar({super.key, this.mini = false});
  final bool mini;

  static const _speeds = [0.75, 1.0, 1.25, 1.5];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = WaqtTokens.of(context);
    final rec = ref.watch(recitationProvider);
    final q = ref.watch(quranProvider).value;
    if (!rec.active || q == null || rec.surah == null) return const SizedBox.shrink();
    final surah = q.surah(rec.surah!);
    final player = ref.read(recitationProvider.notifier);
    final prefs = ref.watch(quranPrefsProvider);
    final reciter = reciterById(prefs.reciter);
    final local = ref.watch(recitationDownloadsProvider.select((d) => d.done.contains(surah.n)));
    final a = rec.ayah ?? 0;
    // In the reader the surah is in the header already: the ayah is enough.
    final title = a == 0
        ? surahName(context, surah)
        : mini
        ? '${surahName(context, surah)} · ${l.quranAyahOf(a, surah.ayahs)}'
        : l.quranAyahOf(a, surah.ayahs);

    return Container(
      height: 64,
      clipBehavior: Clip.antiAlias,
      decoration: recitationSurface(t),
      child: Stack(
        children: [
          Row(
            children: [
              const SizedBox(width: 8),
              IconButton.filled(
                tooltip: rec.playing ? l.quranPause : l.quranPlay,
                onPressed: player.toggle,
                style: IconButton.styleFrom(
                  backgroundColor: t.ink,
                  foregroundColor: t.ground,
                  fixedSize: const Size(48, 48),
                ),
                icon: rec.loading
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: t.ground))
                    : Icon(rec.playing ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 28),
              ),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(WaqtRadii.row),
                  onTap: mini
                      ? () => openReader(context, (surah: surah.n, ayah: a == 0 ? 1 : a))
                      : () => context.push('/quran/reciters'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: WaqtSpace.x3, vertical: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: WaqtText.bodyStrong.copyWith(
                            color: t.ink,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        Text(
                          reciter.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: WaqtText.caption.copyWith(color: t.inkMuted),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (mini)
                IconButton(
                  tooltip: l.quranStop,
                  onPressed: player.stop,
                  color: t.inkMuted,
                  icon: const Icon(Icons.close_rounded),
                )
              else ...[
                IconButton(
                  tooltip: l.quranPrevAyah,
                  onPressed: player.previous,
                  color: t.ink,
                  icon: const Icon(Icons.skip_previous_rounded),
                ),
                IconButton(
                  tooltip: l.quranNextAyah,
                  onPressed: player.next,
                  color: t.ink,
                  icon: const Icon(Icons.skip_next_rounded),
                ),
                PopupMenuButton<String>(
                  tooltip: l.quranMore,
                  icon: Icon(Icons.more_vert_rounded, color: t.ink),
                  color: Color.alphaBlend(t.surface, t.ground),
                  onSelected: (v) {
                    if (v == 'stop') {
                      player.stop();
                    } else if (v == 'downloads') {
                      context.push('/quran/downloads');
                    } else {
                      player.setSpeed(double.parse(v));
                    }
                  },
                  itemBuilder: (_) => [
                    for (final s in _speeds)
                      CheckedPopupMenuItem(
                        value: '$s',
                        checked: prefs.speed == s,
                        child: Text('${l.quranSpeed} ${s == s.roundToDouble() ? s.toInt() : s}×'),
                      ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'downloads',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(local ? Icons.download_done_rounded : Icons.wifi_rounded),
                        title: Text(local ? l.quranOnPhone : l.quranStreaming),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'stop',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.stop_rounded),
                        title: Text(l.quranStop),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
              ],
            ],
          ),
          // How far into this ayah: a thin line along the bottom edge.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: StreamBuilder<Duration>(
              stream: player.position,
              builder: (context, snap) {
                final len = player.duration ?? Duration.zero;
                final pos = snap.data ?? Duration.zero;
                final v = len.inMilliseconds == 0 ? 0.0 : (pos.inMilliseconds / len.inMilliseconds).clamp(0.0, 1.0);
                return LinearProgressIndicator(
                  value: rec.loading ? null : v,
                  minHeight: 2,
                  color: t.accent,
                  backgroundColor: Colors.transparent,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// The reader's floating bars and the player: the page's own raised surface
/// with a hairline and a soft shadow, so they sit on the page without
/// pulling the eye.
BoxDecoration recitationSurface(WaqtTokens t, [double radius = 32]) => BoxDecoration(
  color: Color.alphaBlend(t.surface, t.ground),
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: t.hairline),
  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 24, offset: const Offset(0, 8))],
);
