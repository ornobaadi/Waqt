/// Text as the search index sees it. Arabic loses its diacritics and tatweel
/// and has one form of alef, ya and ta marbuta, so "الحمد" finds "الحَمْدُ".
/// Everything that is not a letter or digit becomes a space.
abstract final class SearchText {
  static final _harakat = RegExp('[ؐ-ًؚ-ٰٟۖ-ۭـ]');
  static final _alef = RegExp('[أإآٱ]');
  static final _nonWord = RegExp(r'[^\p{L}\p{N}\s]', unicode: true);
  static final _space = RegExp(r'\s+');

  static String normalize(String? s) {
    if (s == null || s.isEmpty) return '';
    final t = s
        .toLowerCase()
        .replaceAll(_harakat, '')
        .replaceAll(_alef, 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll(_nonWord, ' ');
    return t.trim().split(_space).join(' ');
  }

  /// Words of a query, normalised, in the order typed.
  static List<String> words(String q) => normalize(q).split(' ').where((w) => w.isNotEmpty).toList();
}
