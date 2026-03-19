import 'package:flutter/widgets.dart';

/// Base interface for text balancing algorithms.
abstract class BalanceAlgorithm {
  /// Calculates the optimal width for balanced text.
  ///
  /// [text] - The text to balance
  /// [style] - Text style for measurement
  /// [maxWidth] - Maximum available width
  /// [ratio] - Balance ratio (0.0 to 1.0)
  ///
  /// Returns the optimal width that produces balanced lines.
  double calculate({
    required String text,
    required TextStyle? style,
    required double maxWidth,
    required double ratio,
  });

  /// Algorithm identifier
  String get name;
}

/// Available balance algorithm types.
enum BalanceAlgorithmType {
  /// Fast greedy algorithm - good for most cases
  greedy,

  /// Binary search for optimal width - more accurate
  optimal,
}
