import 'package:flutter/widgets.dart';

import '../utils/text_measurer.dart';
import '../algorithms/balance_algorithm.dart';
import '../algorithms/greedy_algorithm.dart';

/// Extension methods for balancing String text.
extension BalancedStringExtension on String {
  /// Calculates the optimal balanced width for this string.
  ///
  /// [style] - Text style for measurement
  /// [maxWidth] - Maximum available width
  /// [ratio] - Balance ratio (0.0 to 1.0, default 1.0)
  /// [algorithm] - Algorithm to use (default: greedy)
  double balancedWidth({
    TextStyle? style,
    required double maxWidth,
    double ratio = 1.0,
    BalanceAlgorithm algorithm = const GreedyAlgorithm(),
  }) {
    return algorithm.calculate(
      text: this,
      style: style,
      maxWidth: maxWidth,
      ratio: ratio.clamp(0.0, 1.0),
    );
  }

  /// Checks if this string would create an orphan (single word on last line).
  bool hasOrphan({
    TextStyle? style,
    required double maxWidth,
  }) {
    final measurer = TextMeasurer();
    final lineCount = measurer.getLineCount(
      text: this,
      style: style,
      maxWidth: maxWidth,
    );

    if (lineCount <= 1) return false;

    // Get last line content
    final words = split(RegExp(r'\s+'));
    if (words.isEmpty) return false;

    final lastWord = words.last;
    final lastWordWidth = measurer.getIntrinsicWidth(
      text: lastWord,
      style: style,
    );

    // Check if last line only contains one word
    final textWithoutLastWord = words.sublist(0, words.length - 1).join(' ');
    final linesWithoutLastWord = measurer.getLineCount(
      text: textWithoutLastWord,
      style: style,
      maxWidth: maxWidth,
    );

    return linesWithoutLastWord == lineCount - 1 && lastWordWidth < maxWidth * 0.3;
  }
}
