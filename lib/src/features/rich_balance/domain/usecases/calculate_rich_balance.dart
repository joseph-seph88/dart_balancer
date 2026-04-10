import 'package:flutter/widgets.dart';

import '../../../../core/algorithms/balance_algorithm.dart';
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

    // Get plain text for orphan detection
    final plainText = _extractPlainText(span);

    // Calculate optimal width using configured algorithm
    double optimalWidth = _calculateOptimalWidth(
      span: span,
      plainText: plainText,
      maxWidth: maxWidth,
      originalLineCount: originalLineCount,
      ratio: config.ratio.clamp(0.0, 1.0),
      algorithmType: config.algorithmType,
    );

    // Prevent orphan if enabled
    bool orphanPrevented = false;
    if (config.preventOrphan && originalLineCount > 1) {
      final hasOrphan = _measurer.hasOrphanSpan(
        span: span,
        plainText: plainText,
        maxWidth: optimalWidth,
      );

      if (hasOrphan) {
        final minWidth =
            _measurer.getMinWordWidth(text: plainText, style: null);
        double testWidth = optimalWidth;
        const step = 5.0;

        while (testWidth > minWidth) {
          testWidth -= step;
          final newMetrics = _measurer.getLineMetrics(
            span: span,
            maxWidth: testWidth,
          );

          if (newMetrics.length > originalLineCount) {
            break;
          }

          if (!_measurer.hasOrphanSpan(
            span: span,
            plainText: plainText,
            maxWidth: testWidth,
          )) {
            optimalWidth = testWidth;
            orphanPrevented = true;
            break;
          }
        }
      }
    }

    final finalMetrics = _measurer.getLineMetrics(
      span: span,
      maxWidth: optimalWidth,
    );

    return RichBalanceResult(
      optimalWidth: optimalWidth,
      originalWidth: maxWidth,
      lineCount: finalMetrics.length,
      span: span,
      orphanPrevented: orphanPrevented,
    );
  }

  double _calculateOptimalWidth({
    required InlineSpan span,
    required String plainText,
    required double maxWidth,
    required int originalLineCount,
    required double ratio,
    required BalanceAlgorithmType algorithmType,
  }) {
    // Get minimum width from span text
    final minWidth = _measurer.getMinWordWidth(text: plainText, style: null);

    switch (algorithmType) {
      case BalanceAlgorithmType.greedy:
        return _greedySearch(
          span: span,
          maxWidth: maxWidth,
          minWidth: minWidth,
          originalLineCount: originalLineCount,
          ratio: ratio,
        );
      case BalanceAlgorithmType.optimal:
        return _binarySearch(
          span: span,
          maxWidth: maxWidth,
          minWidth: minWidth,
          originalLineCount: originalLineCount,
          ratio: ratio,
        );
    }
  }

  double _greedySearch({
    required InlineSpan span,
    required double maxWidth,
    required double minWidth,
    required int originalLineCount,
    required double ratio,
  }) {
    final step = (maxWidth - minWidth) * 0.05;
    if (step < 1.0) return maxWidth;

    double currentWidth = maxWidth;
    double bestWidth = maxWidth;

    while (currentWidth > minWidth) {
      currentWidth -= step;

      final metrics = _measurer.getLineMetrics(
        span: span,
        maxWidth: currentWidth,
      );

      if (metrics.length > originalLineCount) {
        break;
      }

      bestWidth = currentWidth;
    }

    return maxWidth - ((maxWidth - bestWidth) * ratio);
  }

  double _binarySearch({
    required InlineSpan span,
    required double maxWidth,
    required double minWidth,
    required int originalLineCount,
    required double ratio,
  }) {
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

    return maxWidth - ((maxWidth - bestWidth) * ratio);
  }

  /// Extracts plain text from InlineSpan for minWidth calculation.
  String _extractPlainText(InlineSpan span) {
    final buffer = StringBuffer();
    span.visitChildren((child) {
      if (child is TextSpan && child.text != null) {
        buffer.write(child.text);
      }
      return true;
    });
    // Also include the span's own text if it's a TextSpan
    if (span is TextSpan && span.text != null) {
      return span.text! + buffer.toString();
    }
    return buffer.toString();
  }
}
