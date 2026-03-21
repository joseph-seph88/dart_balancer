import 'package:flutter/widgets.dart';

/// Result of a rich text balance calculation.
class RichBalanceResult {
  /// The calculated optimal width.
  final double optimalWidth;

  /// Original maximum width.
  final double originalWidth;

  /// Number of lines at optimal width.
  final int lineCount;

  /// The original TextSpan.
  final InlineSpan span;

  /// Whether orphan was prevented.
  final bool orphanPrevented;

  const RichBalanceResult({
    required this.optimalWidth,
    required this.originalWidth,
    required this.lineCount,
    required this.span,
    this.orphanPrevented = false,
  });

  /// The amount of width reduction applied.
  double get widthReduction => originalWidth - optimalWidth;

  /// The reduction as a percentage.
  double get reductionPercent =>
      originalWidth > 0 ? (widthReduction / originalWidth) * 100 : 0;

  @override
  String toString() =>
      'RichBalanceResult(optimal: $optimalWidth, original: $originalWidth, lines: $lineCount)';
}
