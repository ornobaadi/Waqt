import 'dart:async';
import 'dart:io';

/// Lets a running [download] be stopped; the partial file is kept so the next
/// try resumes where it stopped.
class CancelToken {
  bool _cancelled = false;
  bool get cancelled => _cancelled;
  void cancel() => _cancelled = true;
}

class DownloadCancelled implements Exception {
  const DownloadCancelled();
}

/// Downloads [url] to [dest]: written to `dest.part` first and renamed when
/// complete, so a half file never looks finished. Resumes a `.part` left by an
/// earlier try with an HTTP Range request when the server allows it.
/// [onProgress] gets received and total bytes (total 0 when unknown).
Future<File> download(
  Uri url,
  File dest, {
  void Function(int received, int total)? onProgress,
  CancelToken? cancel,
  HttpClient? client,
}) async {
  await dest.parent.create(recursive: true);
  final part = File('${dest.path}.part');
  final own = client == null;
  final http = client ?? (HttpClient()..connectionTimeout = const Duration(seconds: 20));
  try {
    var have = part.existsSync() ? part.lengthSync() : 0;
    final req = await http.getUrl(url);
    req.headers.set(HttpHeaders.userAgentHeader, 'Waqt');
    if (have > 0) req.headers.set(HttpHeaders.rangeHeader, 'bytes=$have-');
    final res = await req.close();
    if (res.statusCode == HttpStatus.requestedRangeNotSatisfiable && have > 0) {
      // Already whole.
      await res.drain<void>();
      return await part.rename(dest.path);
    }
    if (res.statusCode != HttpStatus.ok && res.statusCode != HttpStatus.partialContent) {
      await res.drain<void>();
      throw HttpException('HTTP ${res.statusCode}', uri: url);
    }
    if (res.statusCode == HttpStatus.ok) have = 0; // the server ignored the range: start over
    final total = res.contentLength > 0 ? res.contentLength + have : 0;
    final sink = part.openWrite(mode: have > 0 ? FileMode.append : FileMode.write);
    var got = have;
    try {
      await for (final chunk in res) {
        if (cancel?.cancelled ?? false) throw const DownloadCancelled();
        sink.add(chunk);
        got += chunk.length;
        onProgress?.call(got, total);
      }
    } finally {
      await sink.close();
    }
    if (total > 0 && got < total) throw HttpException('incomplete: $got of $total', uri: url);
    if (dest.existsSync()) await dest.delete();
    return await part.rename(dest.path);
  } finally {
    if (own) http.close();
  }
}
