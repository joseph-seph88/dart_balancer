import 'package:flutter/widgets.dart';
import 'balance_algorithm.dart';
import '../utils/text_measurer.dart';

/// Greedy algorithm for text balancing.
///
/// Fast algorithm that reduces width incrementally until
/// the line count increases, then backs off.
class GreedyAlgorithm implements BalanceAlgorithm {
  const GreedyAlgorithm();

  @override
  String get name => 'greedy';

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

    // Calculate target width based on ratio
    // ratio 1.0 = try to make lines as equal as possible
    // ratio 0.0 = no balancing (use original width)
    final minWidth = measurer.getMinWordWidth(text: text, style: style);
    final step = (maxWidth - minWidth) * 0.05; // 5% steps

    // Prevent infinite loop when step is too small
    if (step < 1.0) return maxWidth;

    double currentWidth = maxWidth;
    double bestWidth = maxWidth;

    while (currentWidth > minWidth) {
      currentWidth -= step;

      final newLineCount = measurer.getLineCount(
        text: text,
        style: style,
        maxWidth: currentWidth,
      );

      // If line count increased, we've gone too far
      if (newLineCount > originalLineCount) {
        break;
      }

      bestWidth = currentWidth;
    }

    // Apply ratio: interpolate between maxWidth and bestWidth
    return maxWidth - ((maxWidth - bestWidth) * ratio);
  }
}
