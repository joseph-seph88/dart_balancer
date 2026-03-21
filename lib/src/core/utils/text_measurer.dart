import 'package:flutter/widgets.dart';

/// Utility class for measuring text dimensions.
class TextMeasurer {
  /// Gets the number of lines for text at a given width.
  int getLineCount({
    required String text,
    required TextStyle? style,
    required double maxWidth,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
      maxLines: null,
    )..layout(maxWidth: maxWidth);

    final lineMetrics = textPainter.computeLineMetrics();
    textPainter.dispose();

    return lineMetrics.length;
  }

  /// Gets the minimum width needed (longest word).
  double getMinWordWidth({
    required String text,
    required TextStyle? style,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    final words = text.split(RegExp(r'\s+'));
    double maxWordWidth = 0;

    for (final word in words) {
      if (word.isEmpty) continue;

      final textPainter = TextPainter(
        text: TextSpan(text: word, style: style),
        textDirection: textDirection,
      )..layout();

      if (textPainter.width > maxWordWidth) {
        maxWordWidth = textPainter.width;
      }
      textPainter.dispose();
    }

    return maxWordWidth;
  }

  /// Gets the total intrinsic width of text (single line).
  double getIntrinsicWidth({
    required String text,
    required TextStyle? style,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
    )..layout();

    final width = textPainter.width;
    textPainter.dispose();

    return width;
  }

  /// Gets line metrics for a TextSpan at a given width.
  List<LineMetrics> getLineMetrics({
    required InlineSpan span,
    required double maxWidth,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    final textPainter = TextPainter(
      text: span,
      textDirection: textDirection,
      maxLines: null,
    )..layout(maxWidth: maxWidth);

    final metrics = textPainter.computeLineMetrics();
    textPainter.dispose();

    return metrics;
  }

  /// Checks if last line has only one word (orphan).
  bool hasOrphan({
    required String text,
    required TextStyle? style,
    required double maxWidth,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: textDirection,
      maxLines: null,
    )..layout(maxWidth: maxWidth);

    final lineMetrics = textPainter.computeLineMetrics();
    if (lineMetrics.length <= 1) {
      textPainter.dispose();
      return false;
    }

    // Get text position at last line start
    final lastLineStart = textPainter.getPositionForOffset(
      Offset(0, lineMetrics.last.baseline - lineMetrics.last.ascent + 1),
    );

    final lastLineText = text.substring(lastLineStart.offset).trim();
    final wordCount =
        lastLineText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

    textPainter.dispose();
    return wordCount == 1;
  }

  /// Checks if last line has only one word (orphan) for InlineSpan.
  bool hasOrphanSpan({
    required InlineSpan span,
    required String plainText,
    required double maxWidth,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    final textPainter = TextPainter(
      text: span,
      textDirection: textDirection,
      maxLines: null,
    )..layout(maxWidth: maxWidth);

    final lineMetrics = textPainter.computeLineMetrics();
    if (lineMetrics.length <= 1) {
      textPainter.dispose();
      return false;
    }

    // Get text position at last line start
    final lastLineStart = textPainter.getPositionForOffset(
      Offset(0, lineMetrics.last.baseline - lineMetrics.last.ascent + 1),
    );

    if (lastLineStart.offset >= plainText.length) {
      textPainter.dispose();
      return false;
    }

    final lastLineText = plainText.substring(lastLineStart.offset).trim();
    final wordCount =
        lastLineText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

    textPainter.dispose();
    return wordCount == 1;
  }
}
