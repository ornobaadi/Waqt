import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../download/downloader.dart';
import 'quran.dart';
import 'quran_prefs.dart';
import 'recitation.dart';

/// The chosen reciter's surahs on the phone, and those downloading now.
class RecitationDownloadsState {
  const RecitationDownloadsState({
    this.done = const {},
    this.running = const {},
    this.queued = const [],
    this.bytes = 0,
    this.blocked = false,
  });

  final Set<int> done;

  /// Surah → 0..1, while it downloads.
  final Map<int, double> running;
  final List<int> queued;
  final int bytes;

  /// Waiting for Wi-Fi (mobile data not allowed).
  final bool blocked;

  RecitationDownloadsState copyWith({
    Set<int>? done,
    Map<int, double>? running,
    List<int>? queued,
    int? bytes,
    bool? blocked,
  }) => RecitationDownloadsState(
    done: done ?? this.done,
    running: running ?? this.running,
    queued: queued ?? this.queued,
    bytes: bytes ?? this.bytes,
    blocked: blocked ?? this.blocked,
  );
}

class RecitationDownloads extends Notifier<RecitationDownloadsState> {
  CancelToken? _cancel;
  bool _busy = false;

  Reciter get _reciter => reciterById(ref.read(quranPrefsProvider).reciter);

  @override
  RecitationDownloadsState build() {
    ref.watch(quranPrefsProvider.select((p) => p.reciter));
    unawaited(refresh());
    return const RecitationDownloadsState();
  }

  Future<void> refresh() async {
    try {
      final q = await ref.read(quranProvider.future);
      final store = await ref.read(recitationStoreProvider.future);
      final r = _reciter;
      state = state.copyWith(done: store.downloaded(q, r), bytes: store.bytes(r));
    } on Object catch (e) {
      debugPrint('recitation downloads: $e');
    }
  }

  /// Queues surahs; they download one at a time.
  void add(Iterable<int> surahs) {
    final more = [
      for (final s in surahs)
        if (!state.done.contains(s) && !state.queued.contains(s) && !state.running.containsKey(s)) s,
    ];
    if (more.isEmpty) return;
    state = state.copyWith(queued: [...state.queued, ...more]);
    unawaited(_run());
  }

  Future<void> _run() async {
    if (_busy) return;
    _busy = true;
    try {
      final q = await ref.read(quranProvider.future);
      final store = await ref.read(recitationStoreProvider.future);
      while (state.queued.isNotEmpty) {
        if (!ref.read(quranPrefsProvider).mobileData) {
          final net = await Connectivity().checkConnectivity();
          final wifi = net.any((c) => c == ConnectivityResult.wifi || c == ConnectivityResult.ethernet);
          if (!wifi) {
            state = state.copyWith(blocked: true);
            return;
          }
        }
        final s = state.queued.first;
        state = state.copyWith(queued: state.queued.skip(1).toList(), running: {s: 0}, blocked: false);
        _cancel = CancelToken();
        try {
          await store.downloadSurah(
            q,
            _reciter,
            s,
            cancel: _cancel,
            onProgress: (d, t) => state = state.copyWith(running: {s: d / t}),
          );
          state = state.copyWith(done: {...state.done, s}, running: const {});
        } on DownloadCancelled {
          state = state.copyWith(running: const {}, queued: const []);
        } on Object catch (e) {
          debugPrint('surah $s download failed: $e');
          state = state.copyWith(running: const {});
        }
      }
    } finally {
      _busy = false;
      await refresh();
    }
  }

  void cancel() {
    _cancel?.cancel();
    state = state.copyWith(queued: const []);
  }

  Future<void> remove(int surah) async {
    final store = await ref.read(recitationStoreProvider.future);
    await store.remove(_reciter, surah);
    await refresh();
  }
}

final recitationDownloadsProvider = NotifierProvider<RecitationDownloads, RecitationDownloadsState>(
  RecitationDownloads.new,
);
