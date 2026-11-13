import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../data/quran/quran.dart';
import '../data/quran/quran_prefs.dart';
import '../data/quran/recitation.dart';

/// The system's view of the player: lock-screen and notification controls,
/// headset buttons. Backed by just_audio.
class _RecitationHandler extends BaseAudioHandler with SeekHandler {
  _RecitationHandler() {
    player.playbackEventStream.listen(_broadcast, onError: (Object e) => debugPrint('recitation: $e'));
    player.currentIndexStream.listen((i) {
      final q = queue.value;
      if (i != null && i < q.length) mediaItem.add(q[i]);
    });
  }

  final player = AudioPlayer();

  void _broadcast(PlaybackEvent e) {
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (player.playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {MediaAction.seek},
        androidCompactActionIndices: const [0, 1, 2],
        processingState: switch (player.processingState) {
          ProcessingState.idle => AudioProcessingState.idle,
          ProcessingState.loading => AudioProcessingState.loading,
          ProcessingState.buffering => AudioProcessingState.buffering,
          ProcessingState.ready => AudioProcessingState.ready,
          ProcessingState.completed => AudioProcessingState.completed,
        },
        playing: player.playing,
        updatePosition: player.position,
        bufferedPosition: player.bufferedPosition,
        speed: player.speed,
        queueIndex: e.currentIndex,
      ),
    );
  }

  @override
  Future<void> play() => player.play();
  @override
  Future<void> pause() => player.pause();
  @override
  Future<void> seek(Duration position) => player.seek(position);
  @override
  Future<void> skipToNext() => player.seekToNext();
  @override
  Future<void> skipToPrevious() => player.seekToPrevious();
  @override
  Future<void> setSpeed(double speed) => player.setSpeed(speed);
  @override
  Future<void> stop() async {
    await player.stop();
    await super.stop();
  }
}

Future<_RecitationHandler>? _handler;

Future<_RecitationHandler> _start() => _handler ??= AudioService.init(
  builder: _RecitationHandler.new,
  config: const AudioServiceConfig(
    androidNotificationChannelId: 'com.ornobaadi.waqt.recitation',
    androidNotificationChannelName: 'Quran recitation',
    androidNotificationIcon: 'mipmap/ic_launcher',
    // Keep the service in the foreground while paused, so it is not killed
    // and cannot be refused a restart (Android 12+).
    androidStopForegroundOnPause: false,
  ),
);

enum RecitationError { wifiOnly, failed }

/// What is being recited: which surah and ayah (0 = basmala), and whether
/// it is playing.
class Recitation {
  const Recitation({this.surah, this.ayah, this.playing = false, this.loading = false, this.error});
  final int? surah;
  final int? ayah;
  final bool playing;
  final bool loading;
  final RecitationError? error;

  bool get active => surah != null;
  bool isAt(int s, int a) => surah == s && ayah == a;
}

class RecitationNotifier extends Notifier<Recitation> {
  _RecitationHandler? _h;
  List<int> _ayahs = const [];
  final _subs = <StreamSubscription<Object?>>[];

  @override
  Recitation build() {
    ref.onDispose(() {
      for (final s in _subs) {
        s.cancel();
      }
    });
    return const Recitation();
  }

  /// The player's position and length in the current ayah, for the bar.
  Stream<Duration> get position => _h?.player.positionStream ?? const Stream.empty();
  Duration? get duration => _h?.player.duration;

  /// Recites a surah from an ayah, streaming what is not on the phone. On
  /// mobile data without permission to use it, only downloaded surahs play.
  Future<void> play(Quran q, int surah, {int ayah = 1}) async {
    final prefs = ref.read(quranPrefsProvider);
    final reciter = reciterById(prefs.reciter);
    final store = await ref.read(recitationStoreProvider.future);
    final ayahs = recitedAyahs(q, surah);
    final local = store.isDownloaded(q, reciter, surah);
    if (!local && !prefs.mobileData) {
      final net = await Connectivity().checkConnectivity();
      final wifi = net.any((c) => c == ConnectivityResult.wifi || c == ConnectivityResult.ethernet);
      if (!wifi && net.contains(ConnectivityResult.mobile)) {
        state = Recitation(surah: surah, ayah: ayah, error: RecitationError.wifiOnly);
        return;
      }
    }
    state = Recitation(surah: surah, ayah: ayah, loading: true);
    try {
      final h = _h ??= await _start();
      _listen(h);
      _ayahs = ayahs;
      final s = q.surah(surah);
      final items = [
        for (final a in ayahs)
          MediaItem(
            id: '${reciter.id}/$surah/$a',
            title: a == 0 ? s.name : '${s.name} · $a',
            album: reciter.name,
            artist: reciter.name,
            extras: {'surah': surah, 'ayah': a},
          ),
      ];
      h.queue.add(items);
      final sources = <AudioSource>[
        for (final (i, a) in ayahs.indexed)
          if (store.file(reciter, surah, a).existsSync())
            AudioSource.file(store.file(reciter, surah, a).path, tag: items[i])
          else
            AudioSource.uri(reciter.url(a == 0 ? 1 : surah, a == 0 ? 1 : a), tag: items[i]),
      ];
      final start = ayahs.indexOf(ayah).clamp(0, ayahs.length - 1);
      await h.player.setAudioSources(sources, initialIndex: start);
      await h.player.setSpeed(prefs.speed);
      unawaited(h.player.play());
    } on Object catch (e) {
      debugPrint('recitation failed: $e');
      state = Recitation(surah: surah, ayah: ayah, error: RecitationError.failed);
    }
  }

  void _listen(_RecitationHandler h) {
    if (_subs.isNotEmpty) return;
    _subs.add(
      h.player.currentIndexStream.listen((i) {
        if (i == null || i >= _ayahs.length || state.surah == null) return;
        state = Recitation(surah: state.surah, ayah: _ayahs[i], playing: h.player.playing);
      }),
    );
    _subs.add(
      h.player.playerStateStream.listen((p) {
        if (state.surah == null) return;
        if (p.processingState == ProcessingState.completed) {
          state = Recitation(surah: state.surah, ayah: state.ayah);
          return;
        }
        final loading = p.processingState == ProcessingState.loading || p.processingState == ProcessingState.buffering;
        state = Recitation(surah: state.surah, ayah: state.ayah, playing: p.playing, loading: loading && p.playing);
      }),
    );
  }

  Future<void> toggle() async {
    final h = _h;
    if (h == null) return;
    h.player.playing ? await h.pause() : await h.play();
  }

  Future<void> next() async => _h?.skipToNext();
  Future<void> previous() async => _h?.skipToPrevious();

  Future<void> setSpeed(double v) async {
    ref.read(quranPrefsProvider.notifier).update((p) => p.copyWith(speed: v));
    await _h?.setSpeed(v);
  }

  Future<void> stop() async {
    await _h?.stop();
    state = const Recitation();
  }
}

final recitationProvider = NotifierProvider<RecitationNotifier, Recitation>(RecitationNotifier.new);
