/// A beautiful, animated neumorphic spend overview card for Flutter fintech apps.
///
/// ## Features
/// - Animated arc budget ring with glowing tip
/// - Live spend ticker count-up animation
/// - Category breakdown chips (tap to highlight)
/// - Stacked category progress bar
/// - Micro-pulse shimmer on value update
/// - Full dark / light neumorphic shadow system
///
/// ## Quick start
/// ```dart
/// import 'package:neomorphic_spend_card/neomorphic_spend_card.dart';
///
/// NeomorphicSpendCard(
///   totalBudget: 5000,
///   amountSpent: 3240,
///   currency: '\$',
///   categories: [
///     SpendCategory(label: 'Food',      amount: 980,  color: Color(0xFFFF6B6B)),
///     SpendCategory(label: 'Transport', amount: 540,  color: Color(0xFF4ECDC4)),
///     SpendCategory(label: 'Shopping',  amount: 1200, color: Color(0xFFFFE66D)),
///     SpendCategory(label: 'Health',    amount: 520,  color: Color(0xFF6BCB77)),
///   ],
/// )
/// ```
library neomorphic_spend_card;

export 'src/neomorphic_spend_card.dart';
export 'src/spend_category.dart';
export 'src/neomorphic_container.dart';
export 'src/arc_painter.dart';
