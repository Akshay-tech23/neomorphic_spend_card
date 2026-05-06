import 'package:flutter/material.dart';

/// Data model representing a single spending category.
///
/// Used by [NeomorphicSpendCard] to render category chips and
/// the stacked progress bar.
///
/// Example:
/// ```dart
/// const SpendCategory(
///   label: 'Food',
///   amount: 980,
///   color: Color(0xFFFF6B6B),
///   icon: Icons.restaurant_outlined,
/// )
/// ```
class SpendCategory {
  /// Display label shown in the chip (e.g. "Food").
  final String label;

  /// Amount spent in this category (in the same currency unit as the card).
  final double amount;

  /// Color used for the dot indicator, chip border, and progress bar segment.
  final Color color;

  /// Optional icon displayed inside the chip when [NeomorphicSpendCard.showIcons]
  /// is `true`. Falls back to a colored dot when `null`.
  final IconData? icon;

  const SpendCategory({
    required this.label,
    required this.amount,
    required this.color,
    this.icon,
  });

  /// Creates a copy with overridden fields.
  SpendCategory copyWith({
    String? label,
    double? amount,
    Color? color,
    IconData? icon,
  }) {
    return SpendCategory(
      label: label ?? this.label,
      amount: amount ?? this.amount,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpendCategory &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          amount == other.amount &&
          color == other.color &&
          icon == other.icon;

  @override
  int get hashCode =>
      label.hashCode ^ amount.hashCode ^ color.hashCode ^ icon.hashCode;

  @override
  String toString() =>
      'SpendCategory(label: $label, amount: $amount, color: $color)';
}
