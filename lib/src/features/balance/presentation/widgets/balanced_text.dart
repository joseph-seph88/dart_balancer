import 'package:flutter/widgets.dart';

import '../../domain/entities/balance_config.dart';
import '../../domain/usecases/calculate_balance.dart';
import '../../../../core/algorithms/balance_algorithm.dart';
import '../../../../core/utils/word_break_utils.dart';

/// A text widget that automatically balances line lengths.
///
/// Similar to react-wrap-balancer, this widget adjusts the width
/// to create more visually balanced text lines.
///
/// Example:
/// ```dart
/// BalancedText(
///   'This is a long title that needs balancing',
///   style: TextStyle(fontSize: 24),
///   ratio: 0.65,
/// )
/// ```
class BalancedText extends StatelessWidget {
  /// The text to display.
  final String data;

  /// Text style.
  final TextStyle? style;

  /// Balance ratio (0.0 to 1.0).
  ///
  /// - 1.0: Maximum balancing
  /// - 0.0: No balancing
  final double ratio;

  /// Algorithm type to use.
  final BalanceAlgorithmType algorithmType;

  /// Whether to prevent orphan words.
  final bool preventOrphan;

  /// Whether to keep words together (no mid-word breaks).
  ///
  /// Similar to CSS `word-break: keep-all`.
  /// Recommended for Korean/CJK text.
  final bool keepAll;

  /// Text alignment.
  final TextAlign? textAlign;

  /// Maximum lines to display.
  final int? maxLines;

  /// Text overflow behavior.
  final TextOverflow? overflow;

  /// Text direction.
  final TextDirection? textDirection;

  /// Locale for text rendering.
  final Locale? locale;

  /// Whether text should wrap.
  final bool? softWrap;

  /// Text scaling behavior.
  final TextScaler? textScaler;

  /// Semantic label.
  final String? semanticsLabel;

  const BalancedText(
    this.data, {
    super.key,
    this.style,
    this.ratio = 1.0,
    this.algorithmType = BalanceAlgorithmType.greedy,
    this.preventOrphan = true,
    this.keepAll = true,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.textScaler,
    this.semanticsLabel,
  });

  /// Processed text with word joiner for keepAll mode.
  String get _processedText {
    if (keepAll && WordBreakUtils.containsCJK(data)) {
      return WordBreakUtils.keepAll(data);
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth == double.infinity) {
          // Unbounded width - just render normally
          return _buildText(constraints.maxWidth);
        }

        final config = BalanceConfig(
          ratio: ratio,
          algorithmType: algorithmType,
          preventOrphan: preventOrphan,
        );

        final calculator = CalculateBalance();
        final result = calculator(
          text: _processedText,
          style: _resolveStyle(context),
          maxWidth: constraints.maxWidth,
          config: config,
        );

        return SizedBox(
          width: result.optimalWidth,
          child: _buildText(result.optimalWidth),
        );
      },
    );
  }

  TextStyle? _resolveStyle(BuildContext context) {
    return style ?? DefaultTextStyle.of(context).style;
  }

  Widget _buildText(double width) {
    return Text(
      _processedText,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      textScaler: textScaler,
      semanticsLabel: semanticsLabel ?? data, // Use original for accessibility
    );
  }
}
