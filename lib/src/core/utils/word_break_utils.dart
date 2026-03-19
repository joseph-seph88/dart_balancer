/// Utilities for preventing character-level line breaks in CJK text.
///
/// Implements CSS `word-break: keep-all` behavior for Korean/CJK text.
class WordBreakUtils {
  /// Unicode Word Joiner - prevents line break between characters
  static const String wordJoiner = '\u2060';

  /// Processes text to prevent mid-word line breaks.
  ///
  /// Inserts Word Joiner (U+2060) between characters within each word,
  /// so Flutter will only break at spaces.
  ///
  /// Example:
  /// "오늘의 앱은" → "오\u2060늘\u2060의 앱\u2060은"
  static String keepAll(String text) {
    if (text.isEmpty) return text;

    final buffer = StringBuffer();
    final words = text.split(' ');

    for (int i = 0; i < words.length; i++) {
      final word = words[i];

      if (word.isNotEmpty) {
        // Insert word joiner between each character in the word
        for (int j = 0; j < word.length; j++) {
          buffer.write(word[j]);
          // Add word joiner after each character except the last
          if (j < word.length - 1) {
            buffer.write(wordJoiner);
          }
        }
      }

      // Add space between words (except after the last word)
      if (i < words.length - 1) {
        buffer.write(' ');
      }
    }

    return buffer.toString();
  }

  /// Removes Word Joiner characters from processed text.
  static String removeWordJoiner(String text) {
    return text.replaceAll(wordJoiner, '');
  }

  /// Checks if text contains Korean characters.
  static bool containsKorean(String text) {
    // Korean Unicode ranges:
    // Hangul Syllables: U+AC00 - U+D7AF
    // Hangul Jamo: U+1100 - U+11FF
    // Hangul Compatibility Jamo: U+3130 - U+318F
    final koreanRegex = RegExp(r'[\uAC00-\uD7AF\u1100-\u11FF\u3130-\u318F]');
    return koreanRegex.hasMatch(text);
  }

  /// Checks if text contains CJK (Chinese, Japanese, Korean) characters.
  static bool containsCJK(String text) {
    // CJK Unicode ranges
    final cjkRegex = RegExp(
      r'[\u4E00-\u9FFF'  // CJK Unified Ideographs (Chinese)
      r'\u3040-\u309F'   // Hiragana (Japanese)
      r'\u30A0-\u30FF'   // Katakana (Japanese)
      r'\uAC00-\uD7AF'   // Hangul Syllables (Korean)
      r'\u1100-\u11FF'   // Hangul Jamo
      r'\u3130-\u318F]'  // Hangul Compatibility Jamo
    );
    return cjkRegex.hasMatch(text);
  }
}
