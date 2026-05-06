import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neomorphic_spend_card/neomorphic_spend_card.dart';

void main() {
  // ── SpendCategory model tests ──────────────────────────────────────────────
  group('SpendCategory', () {
    const cat = SpendCategory(
      label: 'Food',
      amount: 980,
      color: Color(0xFFFF6B6B),
    );

    test('copyWith overrides fields correctly', () {
      final copy = cat.copyWith(label: 'Travel', amount: 500);
      expect(copy.label, 'Travel');
      expect(copy.amount, 500);
      expect(copy.color, cat.color);
    });

    test('equality holds for identical instances', () {
      const cat2 = SpendCategory(
        label: 'Food',
        amount: 980,
        color: Color(0xFFFF6B6B),
      );
      expect(cat, equals(cat2));
    });

    test('toString contains label', () {
      expect(cat.toString(), contains('Food'));
    });
  });

  // ── Widget render tests ────────────────────────────────────────────────────
  group('NeomorphicSpendCard widget', () {
    const categories = [
      SpendCategory(label: 'Food', amount: 500, color: Color(0xFFFF6B6B)),
      SpendCategory(label: 'Transport', amount: 300, color: Color(0xFF4ECDC4)),
    ];

    Widget buildCard({double spent = 800, String currency = '\$'}) {
      return MaterialApp(
        home: Scaffold(
          body: NeomorphicSpendCard(
            totalBudget: 2000,
            amountSpent: spent,
            categories: categories,
            currency: currency,
            showPulseOnMount: false,
          ),
        ),
      );
    }

    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(buildCard());
      await tester.pumpAndSettle();
      expect(find.byType(NeomorphicSpendCard), findsOneWidget);
    });

    testWidgets('shows Monthly Budget label', (tester) async {
      await tester.pumpWidget(buildCard());
      await tester.pumpAndSettle();
      expect(find.text('Monthly Budget'), findsOneWidget);
    });

    testWidgets('shows category labels', (tester) async {
      await tester.pumpWidget(buildCard());
      await tester.pumpAndSettle();
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
    });

    testWidgets('shows On Track status when spend is low', (tester) async {
      await tester.pumpWidget(buildCard(spent: 100));
      await tester.pumpAndSettle();
      expect(find.text('On Track'), findsOneWidget);
    });

    testWidgets('shows Overspending status when over budget', (tester) async {
      await tester.pumpWidget(buildCard(spent: 1900));
      await tester.pumpAndSettle();
      expect(find.text('Overspending'), findsOneWidget);
    });

    testWidgets('tapping category chip calls onCategoryTap', (tester) async {
      int? tappedIndex;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeomorphicSpendCard(
              totalBudget: 2000,
              amountSpent: 800,
              categories: categories,
              showPulseOnMount: false,
              hapticFeedback: false,
              onCategoryTap: (i) => tappedIndex = i,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();
      expect(tappedIndex, 0);
    });

    testWidgets('custom currency symbol is displayed', (tester) async {
      await tester.pumpWidget(buildCard(currency: '€'));
      await tester.pumpAndSettle();
      expect(find.textContaining('€'), findsWidgets);
    });
  });

  // ── ArcPainter tests ───────────────────────────────────────────────────────
  group('ArcPainter', () {
    test('shouldRepaint returns true when progress changes', () {
      const p1 = ArcPainter(
        progress: 0.5,
        arcColor: Colors.teal,
        trackColor: Colors.grey,
      );
      const p2 = ArcPainter(
        progress: 0.8,
        arcColor: Colors.teal,
        trackColor: Colors.grey,
      );
      expect(p1.shouldRepaint(p2), isTrue);
    });

    test('shouldRepaint returns false when nothing changes', () {
      const p1 = ArcPainter(
        progress: 0.5,
        arcColor: Colors.teal,
        trackColor: Colors.grey,
      );
      const p2 = ArcPainter(
        progress: 0.5,
        arcColor: Colors.teal,
        trackColor: Colors.grey,
      );
      expect(p1.shouldRepaint(p2), isFalse);
    });
  });
}
