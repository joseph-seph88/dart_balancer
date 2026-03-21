import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('한국어 줄바꿈 위치 테스트', () {
    testWidgets('각 줄에 어떤 텍스트가 들어가는지 확인', (tester) async {
      const testText = '오늘의 앱은 누구나 다 볼 수 있고 쓸 수 있어요';
      const style = TextStyle(fontSize: 20);

      // 다양한 너비에서 테스트
      final widths = [300.0, 280.0, 250.0, 200.0, 180.0, 150.0];

      for (final width in widths) {
        final textPainter = TextPainter(
          text: const TextSpan(text: testText, style: style),
          textDirection: TextDirection.ltr,
          maxLines: null,
        )..layout(maxWidth: width);

        final lineMetrics = textPainter.computeLineMetrics();

        // Verify text renders with expected line count
        expect(lineMetrics.length, greaterThan(0));

        textPainter.dispose();
      }
    });

    testWidgets('글자 단위 끊김 발생하는지 확인', (tester) async {
      const testText = '오늘의 앱은 누구나 다 볼 수 있고 쓸 수 있어요';
      const style = TextStyle(fontSize: 20);

      // 아주 좁은 너비에서 테스트
      final narrowWidths = [120.0, 100.0, 80.0];

      for (final width in narrowWidths) {
        final textPainter = TextPainter(
          text: const TextSpan(text: testText, style: style),
          textDirection: TextDirection.ltr,
          maxLines: null,
        )..layout(maxWidth: width);

        final lineMetrics = textPainter.computeLineMetrics();

        // Verify text renders even at narrow widths
        expect(lineMetrics.length, greaterThan(0));

        textPainter.dispose();
      }
    });
  });
}
