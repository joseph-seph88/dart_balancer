import 'package:flutter/widgets.dart';

import '../../../../core/utils/text_measurer.dart';
import '../entities/balance_config.dart';
import '../entities/balance_result.dart';

/// Use case for calculating balanced text width.
class CalculateBalance {
  final TextMeasurer _measurer;

  CalculateBalance({TextMeasurer? measurer})
      : _measurer = measurer ?? TextMeasurer();

  /// Calculates the optimal width for balanced text.
  BalanceResult call({
    required String text,
    required TextStyle? style,
    required double maxWidth,
    BalanceConfig config = BalanceConfig.defaults,
  }) {
    if (text.isEmpty || maxWidth <= 0) {
      return BalanceResult(
        optimalWidth: maxWidth,
        originalWidth: maxWidth,
        lineCount: 0,
      );
    }

    final originalLineCount = _measurer.getLineCount(
      text: text,
      style: style,
      maxWidth: maxWidth,
    );

    // Single line - no balancing needed
    if (originalLineCount <= 1) {
      return BalanceResult(
        optimalWidth: maxWidth,
        originalWidth: maxWidth,
        lineCount: originalLineCount,
      );
    }

    // Calculate optimal width using configured algorithm
    final optimalWidth = config.algorithm.calculate(
      text: text,
      style: style,
      maxWidth: maxWidth,
      ratio: config.ratio.clamp(0.0, 1.0),
    );

    final finalLineCount = _measurer.getLineCount(
      text: text,
      style: style,
      maxWidth: optimalWidth,
    );

    return BalanceResult(
      optimalWidth: optimalWidth,
      originalWidth: maxWidth,
      lineCount: finalLineCount,
      orphanPrevented: config.preventOrphan && originalLineCount > 1,
    );
  }
}
