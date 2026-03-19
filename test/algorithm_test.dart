import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dart_balancer/dart_balancer.dart';

void main() {
  group('Algorithm Debug Test', () {
    testWidgets('한국어 텍스트 밸런싱 테스트', (tester) async {
      const testText = '오늘의 앱은 누구나 다 볼 수 있고 쓸 수 있어요';
      const style = TextStyle(fontSize: 20);

      // 다양한 너비에서 테스트
      final widths = [400.0, 350.0, 300.0, 250.0, 200.0];

      for (final width in widths) {
        final measurer = TextMeasurer();

        // 원본 줄 수
        final originalLines = measurer.getLineCount(
          text: testText,
          style: style,
          maxWidth: width,
        );

        // 밸런싱 후 너비
        final algorithm = const OptimalAlgorithm();
        final balancedWidth = algorithm.calculate(
          text: testText,
          style: style,
          maxWidth: width,
          ratio: 1.0,
        );

        // 밸런싱 후 줄 수
        final balancedLines = measurer.getLineCount(
          text: testText,
          style: style,
          maxWidth: balancedWidth,
        );

        print('=== Width: $width ===');
        print('Original lines: $originalLines');
        print('Balanced width: $balancedWidth');
        print('Balanced lines: $balancedLines');
        print('Width reduction: ${width - balancedWidth}');
        print('');
      }
    });

    testWidgets('영어 텍스트 밸런싱 테스트', (tester) async {
      const testText = 'The quick brown fox jumps over the lazy dog near the river';
      const style = TextStyle(fontSize: 20);

      final widths = [400.0, 350.0, 300.0, 250.0];

      for (final width in widths) {
        final measurer = TextMeasurer();

        final originalLines = measurer.getLineCount(
          text: testText,
          style: style,
          maxWidth: width,
        );

        final algorithm = const OptimalAlgorithm();
        final balancedWidth = algorithm.calculate(
          text: testText,
          style: style,
          maxWidth: width,
          ratio: 1.0,
        );

        final balancedLines = measurer.getLineCount(
          text: testText,
          style: style,
          maxWidth: balancedWidth,
        );

        print('=== Width: $width ===');
        print('Original lines: $originalLines');
        print('Balanced width: $balancedWidth');
        print('Balanced lines: $balancedLines');
        print('Width reduction: ${width - balancedWidth}');
        print('');
      }
    });
  });
}
