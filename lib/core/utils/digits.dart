import 'package:intl/intl.dart';

/// Formats integers with the same digit set `DateFormat` uses for [locale]
/// (e.g. Arabic-Indic for `ar`), so every number on screen matches the clock.
class LocaleDigits {
  LocaleDigits(String locale) : _zero = DateFormat('d', locale).format(DateTime(2000, 1, 10)).codeUnitAt(1);

  final int _zero;

  String call(int n, {int pad = 1}) {
    final s = n.toString().padLeft(pad, '0');
    if (_zero == 0x30) return s;
    return String.fromCharCodes(s.codeUnits.map((c) => c >= 0x30 && c <= 0x39 ? _zero + c - 0x30 : c));
  }
}
