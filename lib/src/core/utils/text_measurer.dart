import 'package:flutter/widgets.dart';

/// Utility class for measuring text dimensions.
class TextMeasurer {
  /// Gets the number of lines for text at a given width.
  int getLineCount({
    required String text,
    required TextStyle? style,
    required double maxWidth,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
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
  }) {
    final words = text.split(RegExp(r'\s+'));
    double maxWordWidth = 0;

    for (final word in words) {
      if (word.isEmpty) continue;

      final textPainter = TextPainter(
        text: TextSpan(text: word, style: style),
        textDirection: TextDirection.ltr,
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
  }) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    final width = textPainter.width;
    textPainter.dispose();

    return width;
  }

  /// Gets line metrics for a TextSpan at a given width.
  List<LineMetrics> getLineMetrics({
    required InlineSpan span,
    required double maxWidth,
  }) {
    final textPainter = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(maxWidth: maxWidth);

    final metrics = textPainter.computeLineMetrics();
    textPainter.dispose();

    return metrics;
  }
}
