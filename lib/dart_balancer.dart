/// A Flutter text balancing package with ratio control,
/// orphan prevention, and RichText support.
///
/// Inspired by react-wrap-balancer.
library;

// Core - Algorithms
export 'src/core/algorithms/balance_algorithm.dart';
export 'src/core/algorithms/greedy_algorithm.dart';
export 'src/core/algorithms/optimal_algorithm.dart';

// Core - Utils
export 'src/core/utils/text_measurer.dart';
export 'src/core/utils/word_break_utils.dart';

// Core - Extensions
export 'src/core/extensions/string_extensions.dart';

// Features - Balance
export 'src/features/balance/domain/entities/balance_result.dart';
export 'src/features/balance/domain/entities/balance_config.dart';
export 'src/features/balance/domain/usecases/calculate_balance.dart';
export 'src/features/balance/presentation/widgets/balanced_text.dart';

// Features - Rich Balance
export 'src/features/rich_balance/domain/entities/rich_balance_result.dart';
export 'src/features/rich_balance/domain/usecases/calculate_rich_balance.dart';
export 'src/features/rich_balance/presentation/widgets/balanced_rich_text.dart';
