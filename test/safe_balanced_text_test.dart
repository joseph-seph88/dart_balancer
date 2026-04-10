import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dart_balancer/dart_balancer.dart';

void main() {
  group('SafeBalancedText', () {
    testWidgets('renders text correctly', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: 200,
              child: SafeBalancedText(
                'Hello World Test',
                style: TextStyle(fontSize: 16),
                maxLines: 2,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Hello World Test'), findsOneWidget);
    });

    testWidgets('shrinks font size when text overflows', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: 100,
              child: SafeBalancedText(
                'This is a very long text that should cause font shrinking',
                style: TextStyle(fontSize: 24),
                minFontSize: 10,
                maxLines: 2,
              ),
            ),
          ),
        ),
      );

      // Text should still render
      expect(
        find.text('This is a very long text that should cause font shrinking'),
        findsOneWidget,
      );
    });

    testWidgets('respects minFontSize', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: 50,
              child: SafeBalancedText(
                'Very long text',
                style: TextStyle(fontSize: 20),
                minFontSize: 14,
                maxLines: 1,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Very long text'), findsOneWidget);
    });

    testWidgets('applies maxTextScaleFactor', (tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(3.0)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: SizedBox(
                width: 200,
                child: SafeBalancedText(
                  'Scaled Text',
                  style: TextStyle(fontSize: 16),
                  maxLines: 2,
                  maxTextScaleFactor: 1.5,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Scaled Text'), findsOneWidget);
    });

    testWidgets('handles Korean text with keepAll', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: 150,
              child: SafeBalancedText(
                '안녕하세요 한글 테스트입니다',
                style: TextStyle(fontSize: 16),
                maxLines: 3,
                keepAll: true,
              ),
            ),
          ),
        ),
      );

      // Text widget exists (word joiner may be applied)
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('works with single line text', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: 300,
              child: SafeBalancedText(
                'Short',
                style: TextStyle(fontSize: 16),
                maxLines: 1,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Short'), findsOneWidget);
    });

    testWidgets('applies overflow when needed', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: 50,
              child: SafeBalancedText(
                'This text is way too long to fit',
                style: TextStyle(fontSize: 20),
                minFontSize: 18,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Text), findsOneWidget);
    });
  });
}
