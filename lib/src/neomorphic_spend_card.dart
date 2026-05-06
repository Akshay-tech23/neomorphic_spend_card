import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'arc_painter.dart';
import 'neomorphic_container.dart';
import 'spend_category.dart';

/// A beautiful, animated neumorphic spend overview card for fintech apps.
///
/// ## Features
/// - Animated arc budget ring with a glowing tip dot
/// - Count-up ticker animation for the spent amount
/// - Stat rows: remaining, daily average, usage percentage
/// - Interactive category chips (tap to select/deselect)
/// - Segmented stacked progress bar with animated fill
/// - Micro-pulse scale animation on value update
/// - Full dark / light neumorphic shadow support
///
/// ## Basic usage
/// ```dart
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
///
/// ## Reacting to updates
/// Simply update [amountSpent] in a `setState` call. The card detects the
/// change via [didUpdateWidget] and re-runs all animations automatically.
///
/// ## Theming
/// Pass a [cardColor] that matches your scaffold background for the
/// neumorphic depth illusion to work correctly.
class NeomorphicSpendCard extends StatefulWidget {
  /// Total budget ceiling for the period.
  final double totalBudget;

  /// Amount spent so far. Animates when changed.
  final double amountSpent;

  /// Currency symbol prepended to amounts (default: `\$`).
  final String currency;

  /// Spending categories. Drives both the chip row and the stacked bar.
  final List<SpendCategory> categories;

  /// Override the neumorphic card surface colour.
  /// Defaults to `#ECF0F3` (light) or `#1E2235` (dark).
  final Color? cardColor;

  /// Duration of the arc and ticker animations. Default: 1400 ms.
  final Duration animationDuration;

  /// Whether to trigger the pulse animation when the widget first mounts.
  final bool showPulseOnMount;

  /// Whether to show icons inside category chips. Default: `false`.
  final bool showIcons;

  /// Whether to enable haptic feedback on category chip tap.
  final bool hapticFeedback;

  /// Callback fired when a category chip is tapped.
  /// [index] is `-1` when the selection is cleared.
  final ValueChanged<int>? onCategoryTap;

  const NeomorphicSpendCard({
    super.key,
    required this.totalBudget,
    required this.amountSpent,
    required this.categories,
    this.currency = '\$',
    this.cardColor,
    this.animationDuration = const Duration(milliseconds: 1400),
    this.showPulseOnMount = true,
    this.showIcons = false,
    this.hapticFeedback = true,
    this.onCategoryTap,
  })  : assert(totalBudget > 0, 'totalBudget must be > 0'),
        assert(categories.length > 0, 'Provide at least one category');

  @override
  State<NeomorphicSpendCard> createState() => _NeomorphicSpendCardState();
}

class _NeomorphicSpendCardState extends State<NeomorphicSpendCard>
    with TickerProviderStateMixin {
  // ── Controllers ────────────────────────────────────────────────────────────
  late AnimationController _arcController;
  late AnimationController _countController;
  late AnimationController _pulseController;

  // ── Animations ─────────────────────────────────────────────────────────────
  late Animation<double> _arcAnimation;
  late Animation<double> _countAnimation;
  late Animation<double> _pulseAnimation;

  // ── State ──────────────────────────────────────────────────────────────────
  int _selectedCategory = -1;
  bool _isPulsing = false;

  // ── Computed ───────────────────────────────────────────────────────────────
  double get _spendRatio =>
      (widget.amountSpent / widget.totalBudget).clamp(0.0, 1.0);

  Color get _statusColor {
    if (_spendRatio < 0.60) return const Color(0xFF4ECDC4); // teal  – healthy
    if (_spendRatio < 0.85) return const Color(0xFFFFBE3C); // amber – caution
    return const Color(0xFFFF6B6B); //  red   – danger
  }

  String get _statusLabel {
    if (_spendRatio < 0.60) return 'On Track';
    if (_spendRatio < 0.85) return 'Caution';
    return 'Overspending';
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _arcController.forward();
    _countController.forward();
    if (widget.showPulseOnMount) {
      Future.delayed(const Duration(milliseconds: 300), _triggerPulse);
    }
  }

  void _setupAnimations() {
    _arcController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _countController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _arcAnimation = CurvedAnimation(
      parent: _arcController,
      curve: Curves.easeOutCubic,
    );
    _countAnimation = CurvedAnimation(
      parent: _countController,
      curve: Curves.easeOutCubic,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(NeomorphicSpendCard old) {
    super.didUpdateWidget(old);
    if (old.amountSpent != widget.amountSpent) {
      _arcController.forward(from: 0);
      _countController.forward(from: 0);
      _triggerPulse();
    }
  }

  @override
  void dispose() {
    _arcController.dispose();
    _countController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _triggerPulse() {
    if (!mounted) return;
    setState(() => _isPulsing = true);
    _pulseController.forward().then((_) {
      _pulseController.reverse().then((_) {
        if (mounted) setState(() => _isPulsing = false);
      });
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = widget.cardColor ??
        (isDark ? const Color(0xFF1E2235) : const Color(0xFFECF0F3));

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) => Transform.scale(
        scale: _isPulsing ? _pulseAnimation.value : 1.0,
        child: child,
      ),
      child: NeomorphicContainer(
        color: baseColor,
        isDark: isDark,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                totalBudget: widget.totalBudget,
                currency: widget.currency,
                statusColor: _statusColor,
                statusLabel: _statusLabel,
              ),
              const SizedBox(height: 28),
              _RingAndStats(
                arcAnimation: _arcAnimation,
                countAnimation: _countAnimation,
                spendRatio: _spendRatio,
                amountSpent: widget.amountSpent,
                totalBudget: widget.totalBudget,
                currency: widget.currency,
                statusColor: _statusColor,
                isDark: isDark,
              ),
              const SizedBox(height: 28),
              _CategoryChips(
                categories: widget.categories,
                selectedIndex: _selectedCategory,
                showIcons: widget.showIcons,
                currency: widget.currency,
                isDark: isDark,
                onTap: (index) {
                  if (widget.hapticFeedback) {
                    HapticFeedback.lightImpact();
                  }
                  final next = _selectedCategory == index ? -1 : index;
                  setState(() => _selectedCategory = next);
                  widget.onCategoryTap?.call(next);
                },
              ),
              const SizedBox(height: 20),
              _ProgressBar(
                categories: widget.categories,
                arcAnimation: _arcAnimation,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets (private — kept in the same file for single-file import UX)
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final double totalBudget;
  final String currency;
  final Color statusColor;
  final String statusLabel;

  const _Header({
    required this.totalBudget,
    required this.currency,
    required this.statusColor,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Budget',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$currency${_fmt(totalBudget)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        _StatusBadge(color: statusColor, label: statusLabel),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final Color color;
  final String label;
  const _StatusBadge({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingAndStats extends StatelessWidget {
  final Animation<double> arcAnimation;
  final Animation<double> countAnimation;
  final double spendRatio;
  final double amountSpent;
  final double totalBudget;
  final String currency;
  final Color statusColor;
  final bool isDark;

  const _RingAndStats({
    required this.arcAnimation,
    required this.countAnimation,
    required this.spendRatio,
    required this.amountSpent,
    required this.totalBudget,
    required this.currency,
    required this.statusColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedBuilder(
          animation: arcAnimation,
          builder: (_, __) => SizedBox(
            width: 130,
            height: 130,
            child: CustomPaint(
              painter: ArcPainter(
                progress: arcAnimation.value * spendRatio,
                arcColor: statusColor,
                trackColor: isDark
                    ? Colors.white.withOpacity(0.07)
                    : Colors.black.withOpacity(0.07),
              ),
              child: Center(
                child: AnimatedBuilder(
                  animation: countAnimation,
                  builder: (_, __) {
                    final display = amountSpent * countAnimation.value;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currency,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        Text(
                          _fmt(display),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          'spent',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatRow(
                label: 'Remaining',
                value: '$currency${_fmt(totalBudget - amountSpent)}',
                color: const Color(0xFF4ECDC4),
                icon: Icons.savings_outlined,
              ),
              const SizedBox(height: 14),
              _StatRow(
                label: 'Daily avg',
                value: '$currency${_fmt(amountSpent / 30)}',
                color: const Color(0xFF9B8FFF),
                icon: Icons.today_outlined,
              ),
              const SizedBox(height: 14),
              _StatRow(
                label: 'Used',
                value: '${(spendRatio * 100).toStringAsFixed(0)}%',
                color: statusColor,
                icon: Icons.pie_chart_outline,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            Text(value,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final List<SpendCategory> categories;
  final int selectedIndex;
  final bool showIcons;
  final String currency;
  final bool isDark;
  final ValueChanged<int> onTap;

  const _CategoryChips({
    required this.categories,
    required this.selectedIndex,
    required this.showIcons,
    required this.currency,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(categories.length, (i) {
            final cat = categories[i];
            final selected = selectedIndex == i;
            return GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: selected
                      ? cat.color.withOpacity(0.18)
                      : (isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? cat.color : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showIcons && cat.icon != null) ...[
                      Icon(cat.icon, size: 13, color: cat.color),
                      const SizedBox(width: 5),
                    ] else ...[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: cat.color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      cat.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? cat.color : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$currency${_fmt(cat.amount)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: selected
                            ? cat.color.withOpacity(0.8)
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final List<SpendCategory> categories;
  final Animation<double> arcAnimation;

  const _ProgressBar({
    required this.categories,
    required this.arcAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final total = categories.fold(0.0, (s, c) => s + c.amount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spend breakdown',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: arcAnimation,
          builder: (_, __) => ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: categories.map((cat) {
                  final flex =
                      ((cat.amount / total) * arcAnimation.value * 1000)
                          .round();
                  return Expanded(
                    flex: flex.clamp(0, 1000),
                    child: Container(color: cat.color),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Shared formatting helper ─────────────────────────────────────────────────

String _fmt(double amount) {
  if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}k';
  return amount.toStringAsFixed(0);
}
