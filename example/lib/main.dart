import 'package:flutter/material.dart';
import 'package:neomorphic_spend_card/neomorphic_spend_card.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeomorphicSpendCard Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      home: const DemoScreen(),
    );
  }
}

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  double _spent = 3240;
  int _lastTappedCategory = -1;

  static const _categories = [
    SpendCategory(
      label: 'Food',
      amount: 980,
      color: Color(0xFFFF6B6B),
      icon: Icons.restaurant_outlined,
    ),
    SpendCategory(
      label: 'Transport',
      amount: 540,
      color: Color(0xFF4ECDC4),
      icon: Icons.directions_car_outlined,
    ),
    SpendCategory(
      label: 'Shopping',
      amount: 1200,
      color: Color(0xFFFFE66D),
      icon: Icons.shopping_bag_outlined,
    ),
    SpendCategory(
      label: 'Health',
      amount: 520,
      color: Color(0xFF6BCB77),
      icon: Icons.favorite_outline,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF151928) : const Color(0xFFECF0F3);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Spend Card Demo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card ──────────────────────────────────────────────────────
            NeomorphicSpendCard(
              totalBudget: 5000,
              amountSpent: _spent,
              currency: '\$',
              categories: _categories,
              showIcons: true,
              onCategoryTap: (i) => setState(() => _lastTappedCategory = i),
            ),
            const SizedBox(height: 32),

            // ── Slider ────────────────────────────────────────────────────
            Text(
              'Simulate live spend updates',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Slider(
              value: _spent,
              min: 0,
              max: 5800,
              divisions: 58,
              label: '\$${_spent.toStringAsFixed(0)}',
              onChanged: (v) => setState(() => _spent = v),
            ),
            Center(
              child: Text(
                '\$${_spent.toStringAsFixed(0)} spent of \$5,000',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (_lastTappedCategory >= 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Last tapped: ${_categories[_lastTappedCategory].label}',
                  style:
                      TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
