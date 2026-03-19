import 'package:flutter/widgets.dart';

import '../../../../core/utils/text_measurer.dart';
import '../../../balance/domain/entities/balance_config.dart';
import '../entities/rich_balance_result.dart';

/// Use case for calculating balanced rich text width.
class CalculateRichBalance {
  final TextMeasurer _measurer;

  CalculateRichBalance({TextMeasurer? measurer})
      : _measurer = measurer ?? TextMeasurer();

  /// Calculates the optimal width for balanced rich text.
  RichBalanceResult call({
    required InlineSpan span,
    required double maxWidth,
    BalanceConfig config = BalanceConfig.defaults,
  }) {
    if (maxWidth <= 0) {
      return RichBalanceResult(
        optimalWidth: maxWidth,
        originalWidth: maxWidth,
        lineCount: 0,
        span: span,
      );
    }

    final originalMetrics = _measurer.getLineMetrics(
      span: span,
      maxWidth: maxWidth,
    );
    final originalLineCount = originalMetrics.length;

    // Single line - no balancing needed
    if (originalLineCount <= 1) {
      return RichBalanceResult(
        optimalWidth: maxWidth,
        originalWidth: maxWidth,
        lineCount: originalLineCount,
        span: span,
      );
    }

    // Binary search for optimal width
    final optimalWidth = _findOptimalWidth(
      span: span,
      maxWidth: maxWidth,
      originalLineCount: originalLineCount,
      ratio: config.ratio.clamp(0.0, 1.0),
    );

    final finalMetrics = _measurer.getLineMetrics(
      span: span,
      maxWidth: optimalWidth,
    );

    return RichBalanceResult(
      optimalWidth: optimalWidth,
      originalWidth: maxWidth,
      lineCount: finalMetrics.length,
      span: span,
    );
  }

  double _findOptimalWidth({
    required InlineSpan span,
    required double maxWidth,
    required int originalLineCount,
    required double ratio,
  }) {
    // Get minimum width (approximate based on first segment)
    final minWidth = maxWidth * 0.3;

    double left = minWidth;
    double right = maxWidth;
    double bestWidth = maxWidth;

    while (right - left > 1.0) {
      final mid = (left + right) / 2;

      final metrics = _measurer.getLineMetrics(
        span: span,
        maxWidth: mid,
      );

      if (metrics.length <= originalLineCount) {
        bestWidth = mid;
        right = mid;
      } else {
        left = mid;
      }
    }

    // Apply ratio
    return maxWidth - ((maxWidth - bestWidth) * ratio);
  }
}
