import 'package:flutter/material.dart';

/// A reusable neumorphic container widget.
///
/// Applies a dual-shadow depth effect that simulates a physical surface:
/// - **Light mode**: white highlight (top-left) + grey shadow (bottom-right)
/// - **Dark mode**: black shadow (bottom-right) + subtle white glow (top-left)
///
/// The base color should match the scaffold/page background for the
/// neumorphic illusion to work correctly.
///
/// Example:
/// ```dart
/// NeomorphicContainer(
///   color: const Color(0xFFECF0F3),
///   isDark: false,
///   borderRadius: 24,
///   child: Padding(
///     padding: const EdgeInsets.all(20),
///     child: Text('Hello neumorphism'),
///   ),
/// )
/// ```
class NeomorphicContainer extends StatelessWidget {
  /// The surface background color. Should match the page background.
  final Color color;

  /// When `true`, dark-mode shadow values are used.
  final bool isDark;

  /// Corner radius of the card.
  final double borderRadius;

  /// Shadow intensity multiplier (0.5 = subtle, 1.0 = default, 1.5 = bold).
  final double shadowIntensity;

  /// Child widget rendered inside the container.
  final Widget child;

  const NeomorphicContainer({
    super.key,
    required this.color,
    required this.isDark,
    required this.child,
    this.borderRadius = 24,
    this.shadowIntensity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isDark ? _darkShadows : _lightShadows,
      ),
      child: child,
    );
  }

  List<BoxShadow> get _lightShadows => [
        BoxShadow(
          color: Colors.white.withOpacity(0.9 * shadowIntensity),
          offset: Offset(-6 * shadowIntensity, -6 * shadowIntensity),
          blurRadius: 16 * shadowIntensity,
        ),
        BoxShadow(
          color: const Color(0xFFBEBEBE).withOpacity(0.7 * shadowIntensity),
          offset: Offset(6 * shadowIntensity, 6 * shadowIntensity),
          blurRadius: 16 * shadowIntensity,
        ),
      ];

  List<BoxShadow> get _darkShadows => [
        BoxShadow(
          color: Colors.black.withOpacity(0.5 * shadowIntensity),
          offset: Offset(6 * shadowIntensity, 6 * shadowIntensity),
          blurRadius: 16 * shadowIntensity,
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.04 * shadowIntensity),
          offset: Offset(-4 * shadowIntensity, -4 * shadowIntensity),
          blurRadius: 12 * shadowIntensity,
        ),
      ];
}
