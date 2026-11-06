// Content pipeline CLI.
//
//   dart run tool/content.dart check            # validate, no output
//   dart run tool/content.dart build            # dev bundle (all statuses)
//   dart run tool/content.dart build --release  # approved items only
//
// Reads content/items/*.yaml and content/moments.yaml, writes
// assets/content/content.json. Exit code 1 on any validation error.

import 'dart:io';

import 'src/content_compiler.dart';

void main(List<String> args) {
  final cmd = args.isEmpty ? 'check' : args.first;
  final release = args.contains('--release');
  if (cmd != 'check' && cmd != 'build') {
    stderr.writeln('usage: dart run tool/content.dart check|build [--release]');
    exit(64);
  }

  final dir = Directory('content/items');
  final files = {
    for (final f
        in dir.listSync().whereType<File>().where((f) => f.path.endsWith('.yaml')).toList()
          ..sort((a, b) => a.path.compareTo(b.path)))
      f.uri.pathSegments.last: f.readAsStringSync(),
  };
  final version = File('content/VERSION').readAsStringSync().trim();

  final result = compileContent(
    itemFiles: files,
    momentsYaml: File('content/moments.yaml').readAsStringSync(),
    contentVersion: version,
    release: release,
  );

  for (final e in result.errors) {
    stderr.writeln('✗ $e');
  }
  final s = result.stats;
  stdout.writeln(
    'content v$version: ${s[Status.approved]} approved, ${s[Status.checked]} checked, '
    '${s[Status.draft]} draft${release ? ' (release: approved only)' : ''}',
  );
  if (!result.ok) {
    stderr.writeln('${result.errors.length} error(s).');
    exit(1);
  }
  if (cmd == 'build') {
    final out = File('assets/content/content.json')..createSync(recursive: true);
    out.writeAsStringSync('${result.json}\n');
    stdout.writeln('wrote ${out.path}');
  }
}
