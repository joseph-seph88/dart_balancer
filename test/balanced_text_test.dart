import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dart_balancer/dart_balancer.dart';

void main() {
  group('BalancedText', () {
    testWidgets('renders text correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BalancedText('Hello World'),
          ),
        ),
      );

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('applies ratio parameter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: BalancedText(
                'This is a long text that should be balanced',
                ratio: 0.5,
              ),
            ),
          ),
        ),
      );

      expect(find.text('This is a long text that should be balanced'),
          findsOneWidget);
    });

    testWidgets('works with different algorithms', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SizedBox(
                  width: 200,
                  child: BalancedText(
                    'Test text for algorithm',
                    algorithmType: BalanceAlgorithmType.greedy,
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: BalancedText(
                    'Test text for algorithm',
                    algorithmType: BalanceAlgorithmType.optimal,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Test text for algorithm'), findsNWidgets(2));
    });
  });

  group('BalancedRichText', () {
    testWidgets('renders rich text correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BalancedRichText(
              const TextSpan(
                text: 'Hello ',
                children: [
                  TextSpan(
                    text: 'World',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(RichText), findsOneWidget);
    });
  });

  group('BalanceConfig', () {
    test('has correct defaults', () {
      const config = BalanceConfig();

      expect(config.ratio, 1.0);
      expect(config.algorithmType, BalanceAlgorithmType.greedy);
      expect(config.preventOrphan, true);
    });

    test('copyWith works correctly', () {
      const config = BalanceConfig();
      final modified = config.copyWith(ratio: 0.5);

      expect(modified.ratio, 0.5);
      expect(modified.algorithmType, BalanceAlgorithmType.greedy);
    });
  });

  group('BalanceResult', () {
    test('calculates width reduction correctly', () {
      const result = BalanceResult(
        optimalWidth: 80,
        originalWidth: 100,
        lineCount: 2,
      );

      expect(result.widthReduction, 20);
      expect(result.reductionPercent, 20);
    });
  });

  group('Dry Layout Support', () {
    testWidgets('BalancedText works with IntrinsicWidth', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: IntrinsicWidth(
                child: BalancedText(
                  '이것은 IntrinsicWidth 테스트입니다',
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(BalancedText), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('BalancedRichText works with IntrinsicWidth', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: IntrinsicWidth(
                child: BalancedRichText(
                  const TextSpan(text: 'IntrinsicWidth 테스트'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(BalancedRichText), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('BalancedText works with IntrinsicHeight', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                child: IntrinsicHeight(
                  child: BalancedText(
                    '이것은 IntrinsicHeight 테스트입니다',
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(BalancedText), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('BalancedText works inside Row with IntrinsicWidth',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IntrinsicWidth(
                  child: BalancedText('테스트 텍스트'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(BalancedText), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
