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

        print('=== Width: $width (${lineMetrics.length}줄) ===');

        for (int i = 0; i < lineMetrics.length; i++) {
          final metric = lineMetrics[i];

          // 각 줄의 시작/끝 위치 찾기
          final startOffset = textPainter.getPositionForOffset(
            Offset(0, metric.baseline - metric.ascent + 1),
          );
          final endOffset = textPainter.getPositionForOffset(
            Offset(metric.width, metric.baseline - metric.ascent + 1),
          );

          final lineText = testText.substring(
            startOffset.offset.clamp(0, testText.length),
            endOffset.offset.clamp(0, testText.length),
          );

          print('Line ${i + 1}: "$lineText" (width: ${metric.width.toStringAsFixed(1)})');
        }
        print('');

        textPainter.dispose();
      }
    });

    testWidgets('글자 단위 끊김 발생하는지 확인', (tester) async {
      const testText = '오늘의 앱은 누구나 다 볼 수 있고 쓸 수 있어요';
      const style = TextStyle(fontSize: 20);

      // 아주 좁은 너비에서 테스트
      final narrowWidths = [120.0, 100.0, 80.0];

      print('=== 좁은 너비에서 글자 단위 끊김 테스트 ===');
      for (final width in narrowWidths) {
        final textPainter = TextPainter(
          text: const TextSpan(text: testText, style: style),
          textDirection: TextDirection.ltr,
          maxLines: null,
        )..layout(maxWidth: width);

        final lineMetrics = textPainter.computeLineMetrics();
        print('Width $width: ${lineMetrics.length}줄');

        textPainter.dispose();
      }
    });
  });
}
