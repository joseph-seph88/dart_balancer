import 'package:flutter/rendering.dart';
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

  /// Text alignment. Defaults to center.
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
    this.textAlign = TextAlign.center,
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
    TextAlign textAlign = TextAlign.center,
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
    return _BalancedRichTextLayout(
      span: _processedText,
      ratio: ratio,
      algorithmType: algorithmType,
      preventOrphan: preventOrphan,
      child: _buildRichText(),
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

/// Internal widget that handles balanced rich text layout with dry layout support.
class _BalancedRichTextLayout extends SingleChildRenderObjectWidget {
  final InlineSpan span;
  final double ratio;
  final BalanceAlgorithmType algorithmType;
  final bool preventOrphan;

  const _BalancedRichTextLayout({
    required this.span,
    required this.ratio,
    required this.algorithmType,
    required this.preventOrphan,
    required Widget child,
  }) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderBalancedRichText(
      span: span,
      ratio: ratio,
      algorithmType: algorithmType,
      preventOrphan: preventOrphan,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderBalancedRichText renderObject) {
    renderObject
      ..span = span
      ..ratio = ratio
      ..algorithmType = algorithmType
      ..preventOrphan = preventOrphan;
  }
}

/// Custom RenderBox that supports computeDryLayout for balanced rich text.
class _RenderBalancedRichText extends RenderProxyBox {
  _RenderBalancedRichText({
    required InlineSpan span,
    required double ratio,
    required BalanceAlgorithmType algorithmType,
    required bool preventOrphan,
  })  : _span = span,
        _ratio = ratio,
        _algorithmType = algorithmType,
        _preventOrphan = preventOrphan;

  InlineSpan _span;
  set span(InlineSpan value) {
    if (_span == value) return;
    _span = value;
    _cachedOptimalWidth = null;
    markNeedsLayout();
  }

  double _ratio;
  set ratio(double value) {
    if (_ratio == value) return;
    _ratio = value;
    _cachedOptimalWidth = null;
    markNeedsLayout();
  }

  BalanceAlgorithmType _algorithmType;
  set algorithmType(BalanceAlgorithmType value) {
    if (_algorithmType == value) return;
    _algorithmType = value;
    _cachedOptimalWidth = null;
    markNeedsLayout();
  }

  bool _preventOrphan;
  set preventOrphan(bool value) {
    if (_preventOrphan == value) return;
    _preventOrphan = value;
    _cachedOptimalWidth = null;
    markNeedsLayout();
  }

  double? _cachedOptimalWidth;
  double? _cachedMaxWidth;

  double _calculateOptimalWidth(double maxWidth) {
    if (_cachedOptimalWidth != null && _cachedMaxWidth == maxWidth) {
      return _cachedOptimalWidth!;
    }

    if (maxWidth == double.infinity) {
      return maxWidth;
    }

    final config = BalanceConfig(
      ratio: _ratio,
      algorithmType: _algorithmType,
      preventOrphan: _preventOrphan,
    );

    final calculator = CalculateRichBalance();
    final result = calculator(
      span: _span,
      maxWidth: maxWidth,
      config: config,
    );

    _cachedOptimalWidth = result.optimalWidth;
    _cachedMaxWidth = maxWidth;
    return result.optimalWidth;
  }

  @override
  void performLayout() {
    final maxWidth = constraints.maxWidth;
    final optimalWidth = _calculateOptimalWidth(maxWidth);

    // Respect parent's minWidth constraint
    final effectiveWidth = optimalWidth.clamp(
      constraints.minWidth,
      constraints.maxWidth,
    );

    final childConstraints = BoxConstraints(
      minWidth: 0,
      maxWidth: effectiveWidth,
      minHeight: constraints.minHeight,
      maxHeight: constraints.maxHeight,
    );

    child!.layout(childConstraints, parentUsesSize: true);
    // Ensure size meets parent constraints
    size = constraints.constrain(child!.size);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final maxWidth = constraints.maxWidth;
    final optimalWidth = _calculateOptimalWidth(maxWidth);

    final effectiveWidth = optimalWidth.clamp(
      constraints.minWidth,
      constraints.maxWidth,
    );

    final childConstraints = BoxConstraints(
      minWidth: 0,
      maxWidth: effectiveWidth,
      minHeight: constraints.minHeight,
      maxHeight: constraints.maxHeight,
    );

    final childSize = child!.getDryLayout(childConstraints);
    return constraints.constrain(childSize);
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return child!.getMinIntrinsicWidth(height);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return child!.getMaxIntrinsicWidth(height);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    final optimalWidth = _calculateOptimalWidth(width);
    return child!.getMinIntrinsicHeight(optimalWidth);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    final optimalWidth = _calculateOptimalWidth(width);
    return child!.getMaxIntrinsicHeight(optimalWidth);
  }
}
