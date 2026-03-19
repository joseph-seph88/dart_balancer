import 'package:flutter/widgets.dart';
import 'balance_algorithm.dart';
import '../utils/text_measurer.dart';

/// Optimal algorithm using binary search.
///
/// More accurate than greedy but slightly slower.
/// Finds the narrowest width that maintains the same line count.
class OptimalAlgorithm implements BalanceAlgorithm {
  const OptimalAlgorithm();

  @override
  String get name => 'optimal';

  @override
  double calculate({
    required String text,
    required TextStyle? style,
    required double maxWidth,
    required double ratio,
  }) {
    if (text.isEmpty || maxWidth <= 0) return maxWidth;

    final measurer = TextMeasurer();
    final originalLineCount = measurer.getLineCount(
      text: text,
      style: style,
      maxWidth: maxWidth,
    );

    // Single line - no balancing needed
    if (originalLineCount <= 1) return maxWidth;

    final minWidth = measurer.getMinWordWidth(text: text, style: style);

    // Binary search for optimal width
    double left = minWidth;
    double right = maxWidth;
    double bestWidth = maxWidth;

    while (right - left > 1.0) {
      final mid = (left + right) / 2;

      final lineCount = measurer.getLineCount(
        text: text,
        style: style,
        maxWidth: mid,
      );

      if (lineCount <= originalLineCount) {
        bestWidth = mid;
        right = mid;
      } else {
        left = mid;
      }
    }

    // Apply ratio: interpolate between maxWidth and bestWidth
    return maxWidth - ((maxWidth - bestWidth) * ratio);
  }
}
