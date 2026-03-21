## 0.2.0

### New Features
- Add `SafeBalancedText` widget: auto-sizing + text balancing combined
- Implement `preventOrphan` for both `BalancedText` and `BalancedRichText`
- Add RTL (right-to-left) text direction support

### Improvements
- `BalancedRichText` now respects `algorithmType` option (greedy/optimal)
- Improve `keepAll` to preserve consecutive spaces
- Optimize cache invalidation in `SafeBalancedText`
- Use `MediaQuery.textScalerOf` for better performance

### Bug Fixes
- Fix infinite loop in `GreedyAlgorithm` when step is too small
- Fix `BalancedRichText` minWidth calculation (was hardcoded 30%)
- Fix cache not invalidating when widget properties change

## 0.1.1

- Fix: dry layout support for IntrinsicWidth, IntrinsicHeight, Showcase widgets
- Replace LayoutBuilder with custom RenderProxyBox to support computeDryLayout

## 0.1.0

- Initial release
- BalancedText widget with ratio control
- BalancedRichText for TextSpan support
- Korean/CJK keepAll (word-break prevention)
- Greedy and Optimal algorithms
