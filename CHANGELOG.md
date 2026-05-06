# Changelog

All notable changes to `neomorphic_spend_card` will be documented here.
This project adheres to [Semantic Versioning](https://semver.org/).

---

## [1.0.0] – 2026-05-06

### Added
- Initial release of `NeomorphicSpendCard`
- Animated arc budget ring with `CustomPainter` and glowing tip dot
- Count-up ticker animation for the spent amount
- Three stat rows: remaining, daily average, usage percentage
- Interactive category chips with tap-to-select and animated state transitions
- Segmented stacked progress bar with animated fill
- Micro-pulse scale animation triggered on mount and on value updates
- Full dark / light neumorphic dual-shadow system via `NeomorphicContainer`
- Standalone `ArcPainter` exported for independent reuse
- `SpendCategory` model with `copyWith`, equality, and `toString`
- `onCategoryTap` callback with haptic feedback support
- `showIcons` flag to display category icons inside chips
- Dart doc comments on all public APIs
- Widget + unit tests covering all public surface area
