import 'package:flutter/widgets.dart';

import '../../../balance/domain/entities/balance_config.dart';
import '../../../balance/domain/usecases/calculate_balance.dart';
import '../../../../core/algorithms/balance_algorithm.dart';
import '../../../../core/utils/text_measurer.dart';
import '../../../../core/utils/word_break_utils.dart';

/// A text widget that balances lines AND prevents overflow by auto-sizing.
///
/// Combines the best of text balancing with auto_size_text functionality.
/// Automatically reduces font size when text overflows while maintaining
/// balanced line lengths.
///
/// Example:
/// ```dart
/// SafeBalancedText(
///   'This is a long title that needs balancing and might overflow',
///   style: TextStyle(fontSize: 24),
///   minFontSize: 12,
///   maxLines: 2,
///   maxTextScaleFactor: 1.3,
/// )
/// ```
class SafeBalancedText extends StatelessWidget {
  /// The text to display.
  final String data;

  /// Text style. The fontSize will be used as the maximum font size.
  final TextStyle? style;

  /// Minimum font size to shrink to. Defaults to 12.
  final double minFontSize;

  /// Maximum lines before shrinking font. Required for auto-sizing.
  final int maxLines;

  /// Step size for font size reduction. Defaults to 1.
  final double stepGranularity;

  /// Maximum text scale factor from system settings.
  /// Set to limit accessibility scaling. Defaults to null (no limit).
  final double? maxTextScaleFactor;

  /// Balance ratio (0.0 to 1.0).
  final double ratio;

  /// Algorithm type to use.
  final BalanceAlgorithmType algorithmType;

  /// Whether to prevent orphan words.
  final bool preventOrphan;

  /// Whether to keep words together (no mid-word breaks).
  final bool keepAll;

  /// Text alignment. Defaults to center.
  final TextAlign textAlign;

  /// Text overflow behavior when even minFontSize doesn't fit.
  final TextOverflow overflow;

  /// Text direction.
  final TextDirection? textDirection;

  /// Locale for text rendering.
  final Locale? locale;

  /// Whether text should wrap.
  final bool softWrap;

  /// Semantic label.
  final String? semanticsLabel;

  const SafeBalancedText(
    this.data, {
    super.key,
    this.style,
    this.minFontSize = 12,
    this.maxLines = 2,
    this.stepGranularity = 1,
    this.maxTextScaleFactor,
    this.ratio = 1.0,
    this.algorithmType = BalanceAlgorithmType.greedy,
    this.preventOrphan = true,
    this.keepAll = true,
    this.textAlign = TextAlign.center,
    this.overflow = TextOverflow.ellipsis,
    this.textDirection,
    this.locale,
    this.softWrap = true,
    this.semanticsLabel,
  });

  String get _processedText {
    if (keepAll && WordBreakUtils.containsCJK(data)) {
      return WordBreakUtils.keepAll(data);
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context).style;
    final resolvedStyle = style ?? defaultStyle;

    return _SafeBalancedTextLayout(
      text: _processedText,
      style: resolvedStyle,
      minFontSize: minFontSize,
      maxLines: maxLines,
      stepGranularity: stepGranularity,
      maxTextScaleFactor: maxTextScaleFactor,
      ratio: ratio,
      algorithmType: algorithmType,
      preventOrphan: preventOrphan,
      textAlign: textAlign,
      overflow: overflow,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      semanticsLabel: semanticsLabel ?? data,
    );
  }
}

class _SafeBalancedTextLayout extends StatefulWidget {
  final String text;
  final TextStyle style;
  final double minFontSize;
  final int maxLines;
  final double stepGranularity;
  final double? maxTextScaleFactor;
  final double ratio;
  final BalanceAlgorithmType algorithmType;
  final bool preventOrphan;
  final TextAlign textAlign;
  final TextOverflow overflow;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool softWrap;
  final String semanticsLabel;

  const _SafeBalancedTextLayout({
    required this.text,
    required this.style,
    required this.minFontSize,
    required this.maxLines,
    required this.stepGranularity,
    required this.maxTextScaleFactor,
    required this.ratio,
    required this.algorithmType,
    required this.preventOrphan,
    required this.textAlign,
    required this.overflow,
    required this.textDirection,
    required this.locale,
    required this.softWrap,
    required this.semanticsLabel,
  });

  @override
  State<_SafeBalancedTextLayout> createState() =>
      _SafeBalancedTextLayoutState();
}

class _SafeBalancedTextLayoutState extends State<_SafeBalancedTextLayout> {
  double? _cachedFontSize;
  double? _cachedOptimalWidth;
  double? _cachedMaxWidth;
  double? _cachedTextScaleValue;

  @override
  void didUpdateWidget(covariant _SafeBalancedTextLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.style != widget.style ||
        oldWidget.maxLines != widget.maxLines ||
        oldWidget.minFontSize != widget.minFontSize ||
        oldWidget.ratio != widget.ratio ||
        oldWidget.stepGranularity != widget.stepGranularity ||
        oldWidget.algorithmType != widget.algorithmType ||
        oldWidget.preventOrphan != widget.preventOrphan) {
      _invalidateCache();
    }
  }

  void _invalidateCache() {
    _cachedFontSize = null;
    _cachedOptimalWidth = null;
    _cachedMaxWidth = null;
    _cachedTextScaleValue = null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        if (maxWidth == double.infinity) {
          return _buildText(widget.style, maxWidth);
        }

        // Apply maxTextScaleFactor
        TextScaler textScaler = MediaQuery.textScalerOf(context);
        if (widget.maxTextScaleFactor != null) {
          final currentScale = textScaler.scale(1.0);
          if (currentScale > widget.maxTextScaleFactor!) {
            textScaler = TextScaler.linear(widget.maxTextScaleFactor!);
          }
        }
        final textScaleValue = textScaler.scale(1.0);

        // Check cache
        if (_cachedFontSize != null &&
            _cachedMaxWidth == maxWidth &&
            _cachedTextScaleValue == textScaleValue) {
          return _buildBalancedText(
            _cachedFontSize!,
            _cachedOptimalWidth!,
            textScaler,
          );
        }

        // Calculate optimal font size
        final result = _calculateOptimalFontSize(
          maxWidth: maxWidth,
          textScaler: textScaler,
        );

        _cachedFontSize = result.fontSize;
        _cachedOptimalWidth = result.optimalWidth;
        _cachedMaxWidth = maxWidth;
        _cachedTextScaleValue = textScaleValue;

        return _buildBalancedText(
          result.fontSize,
          result.optimalWidth,
          textScaler,
        );
      },
    );
  }

  _SizeResult _calculateOptimalFontSize({
    required double maxWidth,
    required TextScaler textScaler,
  }) {
    final baseFontSize = widget.style.fontSize ?? 14;
    final measurer = TextMeasurer();
    final calculator = CalculateBalance();

    double currentFontSize = baseFontSize;

    while (currentFontSize >= widget.minFontSize) {
      final scaledStyle = widget.style.copyWith(fontSize: currentFontSize);
      final effectiveStyle = scaledStyle.copyWith(
        fontSize: textScaler.scale(currentFontSize),
      );

      // Calculate balanced width first
      final config = BalanceConfig(
        ratio: widget.ratio,
        algorithmType: widget.algorithmType,
        preventOrphan: widget.preventOrphan,
      );

      final balanceResult = calculator(
        text: widget.text,
        style: effectiveStyle,
        maxWidth: maxWidth,
        config: config,
      );

      final optimalWidth = balanceResult.optimalWidth;

      // Check if text fits within maxLines at this font size and width
      final lineCount = measurer.getLineCount(
        text: widget.text,
        style: effectiveStyle,
        maxWidth: optimalWidth,
      );

      if (lineCount <= widget.maxLines) {
        return _SizeResult(
          fontSize: currentFontSize,
          optimalWidth: optimalWidth,
        );
      }

      currentFontSize -= widget.stepGranularity;
    }

    // Minimum font size reached, use it anyway
    final minScaledStyle = widget.style.copyWith(fontSize: widget.minFontSize);
    final effectiveMinStyle = minScaledStyle.copyWith(
      fontSize: textScaler.scale(widget.minFontSize),
    );

    final config = BalanceConfig(
      ratio: widget.ratio,
      algorithmType: widget.algorithmType,
      preventOrphan: widget.preventOrphan,
    );

    final balanceResult = calculator(
      text: widget.text,
      style: effectiveMinStyle,
      maxWidth: maxWidth,
      config: config,
    );

    return _SizeResult(
      fontSize: widget.minFontSize,
      optimalWidth: balanceResult.optimalWidth,
    );
  }

  Widget _buildBalancedText(
    double fontSize,
    double optimalWidth,
    TextScaler textScaler,
  ) {
    final scaledStyle = widget.style.copyWith(fontSize: fontSize);

    return SizedBox(
      width: optimalWidth,
      child: Text(
        widget.text,
        style: scaledStyle,
        textAlign: widget.textAlign,
        maxLines: widget.maxLines,
        overflow: widget.overflow,
        textDirection: widget.textDirection,
        locale: widget.locale,
        softWrap: widget.softWrap,
        textScaler: textScaler,
        semanticsLabel: widget.semanticsLabel,
      ),
    );
  }

  Widget _buildText(TextStyle style, double width) {
    return Text(
      widget.text,
      style: style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      textDirection: widget.textDirection,
      locale: widget.locale,
      softWrap: widget.softWrap,
      semanticsLabel: widget.semanticsLabel,
    );
  }
}

class _SizeResult {
  final double fontSize;
  final double optimalWidth;

  const _SizeResult({
    required this.fontSize,
    required this.optimalWidth,
  });
}
