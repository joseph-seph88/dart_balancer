import 'package:flutter/rendering.dart';
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
    final resolvedStyle = _resolveStyle(context);
    return _BalancedTextLayout(
      text: _processedText,
      style: resolvedStyle,
      ratio: ratio,
      algorithmType: algorithmType,
      preventOrphan: preventOrphan,
      child: _buildText(double.infinity),
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

/// Internal widget that handles balanced text layout with dry layout support.
class _BalancedTextLayout extends SingleChildRenderObjectWidget {
  final String text;
  final TextStyle? style;
  final double ratio;
  final BalanceAlgorithmType algorithmType;
  final bool preventOrphan;

  const _BalancedTextLayout({
    required this.text,
    required this.style,
    required this.ratio,
    required this.algorithmType,
    required this.preventOrphan,
    required Widget child,
  }) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderBalancedText(
      text: text,
      style: style,
      ratio: ratio,
      algorithmType: algorithmType,
      preventOrphan: preventOrphan,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderBalancedText renderObject) {
    renderObject
      ..text = text
      ..style = style
      ..ratio = ratio
      ..algorithmType = algorithmType
      ..preventOrphan = preventOrphan;
  }
}

/// Custom RenderBox that supports computeDryLayout for balanced text.
class _RenderBalancedText extends RenderProxyBox {
  _RenderBalancedText({
    required String text,
    required TextStyle? style,
    required double ratio,
    required BalanceAlgorithmType algorithmType,
    required bool preventOrphan,
  })  : _text = text,
        _style = style,
        _ratio = ratio,
        _algorithmType = algorithmType,
        _preventOrphan = preventOrphan;

  String _text;
  set text(String value) {
    if (_text == value) return;
    _text = value;
    _cachedOptimalWidth = null;
    markNeedsLayout();
  }

  TextStyle? _style;
  set style(TextStyle? value) {
    if (_style == value) return;
    _style = value;
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

    final calculator = CalculateBalance();
    final result = calculator(
      text: _text,
      style: _style,
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
