/// Result of a text balance calculation.
class BalanceResult {
  /// The calculated optimal width.
  final double optimalWidth;

  /// Original maximum width.
  final double originalWidth;

  /// Number of lines at optimal width.
  final int lineCount;

  /// Whether orphan was prevented.
  final bool orphanPrevented;

  const BalanceResult({
    required this.optimalWidth,
    required this.originalWidth,
    required this.lineCount,
    this.orphanPrevented = false,
  });

  /// The amount of width reduction applied.
  double get widthReduction => originalWidth - optimalWidth;

  /// The reduction as a percentage.
  double get reductionPercent =>
      originalWidth > 0 ? (widthReduction / originalWidth) * 100 : 0;

  @override
  String toString() =>
      'BalanceResult(optimal: $optimalWidth, original: $originalWidth, lines: $lineCount)';
}
