import 'package:flutter/widgets.dart';

import '../../../balance/domain/entities/balance_config.dart';
import '../../../../core/algorithms/balance_algorithm.dart';
import '../../../../core/utils/word_break_utils.dart';
import '../../domain/usecases/calculate_rich_balance.dart';

/// A rich text widget that automatically balances line lengths.
///
/// Supports TextSpan with mixed styles, making it unique among
/// Flutter text balancing packages.
///
/// Example:
/// ```dart
/// BalancedRichText(
///   TextSpan(
///     children: [
///       TextSpan(text: 'Important ', style: TextStyle(fontWeight: FontWeight.bold)),
///       TextSpan(text: 'announcement here'),
///     ],
///   ),
///   ratio: 0.65,
/// )
/// ```
class BalancedRichText extends StatelessWidget {
  /// The text span to display.
  final InlineSpan text;

  /// Balance ratio (0.0 to 1.0).
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
  final TextAlign textAlign;

  /// Text direction.
  final TextDirection? textDirection;

  /// Whether text should wrap.
  final bool softWrap;

  /// Text overflow behavior.
  final TextOverflow overflow;

  /// Maximum lines to display.
  final int? maxLines;

  /// Locale for text rendering.
  final Locale? locale;

  /// Strut style.
  final StrutStyle? strutStyle;

  /// Text width basis.
  final TextWidthBasis textWidthBasis;

  /// Text height behavior.
  final TextHeightBehavior? textHeightBehavior;

  /// Text scaling behavior.
  final TextScaler textScaler;

  const BalancedRichText(
    this.text, {
    super.key,
    this.ratio = 1.0,
    this.algorithmType = BalanceAlgorithmType.greedy,
    this.preventOrphan = true,
    this.keepAll = true,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.softWrap = true,
    this.overflow = TextOverflow.clip,
    this.maxLines,
    this.locale,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
    this.textScaler = TextScaler.noScaling,
  });

  /// Creates a BalancedRichText from a TextSpan.
  factory BalancedRichText.rich(
    TextSpan textSpan, {
    Key? key,
    double ratio = 1.0,
    BalanceAlgorithmType algorithmType = BalanceAlgorithmType.greedy,
    bool preventOrphan = true,
    bool keepAll = true,
    TextAlign textAlign = TextAlign.start,
    TextDirection? textDirection,
    bool softWrap = true,
    TextOverflow overflow = TextOverflow.clip,
    int? maxLines,
    Locale? locale,
    StrutStyle? strutStyle,
    TextWidthBasis textWidthBasis = TextWidthBasis.parent,
    TextHeightBehavior? textHeightBehavior,
    TextScaler textScaler = TextScaler.noScaling,
  }) {
    return BalancedRichText(
      textSpan,
      key: key,
      ratio: ratio,
      algorithmType: algorithmType,
      preventOrphan: preventOrphan,
      keepAll: keepAll,
      textAlign: textAlign,
      textDirection: textDirection,
      softWrap: softWrap,
      overflow: overflow,
      maxLines: maxLines,
      locale: locale,
      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      textScaler: textScaler,
    );
  }

  /// Process TextSpan to apply keepAll.
  InlineSpan get _processedText {
    if (!keepAll) return text;
    if (text is! TextSpan) return text;

    return _processTextSpan(text as TextSpan);
  }

  TextSpan _processTextSpan(TextSpan span) {
    String? processedText;
    if (span.text != null && WordBreakUtils.containsCJK(span.text!)) {
      processedText = WordBreakUtils.keepAll(span.text!);
    }

    List<InlineSpan>? processedChildren;
    if (span.children != null) {
      processedChildren = span.children!.map((child) {
        if (child is TextSpan) {
          return _processTextSpan(child);
        }
        return child;
      }).toList();
    }

    return TextSpan(
      text: processedText ?? span.text,
      style: span.style,
      children: processedChildren,
      recognizer: span.recognizer,
      mouseCursor: span.mouseCursor,
      onEnter: span.onEnter,
      onExit: span.onExit,
      semanticsLabel: span.semanticsLabel,
      locale: span.locale,
      spellOut: span.spellOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth == double.infinity) {
          return _buildRichText();
        }

        final config = BalanceConfig(
          ratio: ratio,
          algorithmType: algorithmType,
          preventOrphan: preventOrphan,
        );

        final calculator = CalculateRichBalance();
        final result = calculator(
          span: _processedText,
          maxWidth: constraints.maxWidth,
          config: config,
        );

        return SizedBox(
          width: result.optimalWidth,
          child: _buildRichText(),
        );
      },
    );
  }

  Widget _buildRichText() {
    return RichText(
      text: _processedText,
      textAlign: textAlign,
      textDirection: textDirection,
      softWrap: softWrap,
      overflow: overflow,
      maxLines: maxLines,
      locale: locale,
      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      textScaler: textScaler,
    );
  }
}
