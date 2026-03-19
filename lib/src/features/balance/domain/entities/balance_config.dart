import '../../../../core/algorithms/balance_algorithm.dart';
import '../../../../core/algorithms/greedy_algorithm.dart';
import '../../../../core/algorithms/optimal_algorithm.dart';

/// Configuration for text balancing.
class BalanceConfig {
  /// Balance ratio (0.0 to 1.0).
  ///
  /// - 1.0: Maximum balancing (lines as equal as possible)
  /// - 0.5: Medium balancing
  /// - 0.0: No balancing (use original width)
  final double ratio;

  /// Algorithm to use for calculation.
  final BalanceAlgorithmType algorithmType;

  /// Whether to prevent orphan words (single word on last line).
  final bool preventOrphan;

  const BalanceConfig({
    this.ratio = 1.0,
    this.algorithmType = BalanceAlgorithmType.greedy,
    this.preventOrphan = true,
  });

  /// Default configuration.
  static const BalanceConfig defaults = BalanceConfig();

  /// Gets the algorithm instance.
  BalanceAlgorithm get algorithm {
    switch (algorithmType) {
      case BalanceAlgorithmType.greedy:
        return const GreedyAlgorithm();
      case BalanceAlgorithmType.optimal:
        return const OptimalAlgorithm();
    }
  }

  /// Creates a copy with modified values.
  BalanceConfig copyWith({
    double? ratio,
    BalanceAlgorithmType? algorithmType,
    bool? preventOrphan,
  }) {
    return BalanceConfig(
      ratio: ratio ?? this.ratio,
      algorithmType: algorithmType ?? this.algorithmType,
      preventOrphan: preventOrphan ?? this.preventOrphan,
    );
  }
}
