import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dart_balancer/dart_balancer.dart';

void main() {
  group('keepAll 테스트', () {
    test('WordBreakUtils.keepAll이 Word Joiner를 삽입하는지', () {
      const input = '오늘의 앱은';
      final result = WordBreakUtils.keepAll(input);

      // "오늘의" 내부에 word joiner가 있어야 함
      expect(result.contains(WordBreakUtils.wordJoiner), true);

      // 공백은 유지되어야 함
      expect(result.contains(' '), true);

      // Word joiner 제거하면 원본과 같아야 함
      expect(WordBreakUtils.removeWordJoiner(result), input);
    });

    test('한국어 감지 테스트', () {
      expect(WordBreakUtils.containsKorean('안녕하세요'), true);
      expect(WordBreakUtils.containsKorean('Hello'), false);
      expect(WordBreakUtils.containsKorean('Hello 안녕'), true);
    });

    testWidgets('keepAll 적용 시 줄바꿈 위치 테스트', (tester) async {
      const testText = '오늘의 앱은 누구나 다 볼 수 있고 쓸 수 있어요';
      const style = TextStyle(fontSize: 20);

      // keepAll 적용된 텍스트
      final processedText = WordBreakUtils.keepAll(testText);

      final widths = [250.0, 200.0, 180.0];

      for (final width in widths) {
        final textPainter = TextPainter(
          text: TextSpan(text: processedText, style: style),
          textDirection: TextDirection.ltr,
          maxLines: null,
        )..layout(maxWidth: width);

        final lineMetrics = textPainter.computeLineMetrics();

        // ignore: avoid_print
        print('=== keepAll Width: $width (${lineMetrics.length}줄) ===');

        for (int i = 0; i < lineMetrics.length; i++) {
          final metric = lineMetrics[i];
          final startOffset = textPainter.getPositionForOffset(
            Offset(0, metric.baseline - metric.ascent + 1),
          );
          final endOffset = textPainter.getPositionForOffset(
            Offset(metric.width, metric.baseline - metric.ascent + 1),
          );

          final lineText = processedText.substring(
            startOffset.offset.clamp(0, processedText.length),
            endOffset.offset.clamp(0, processedText.length),
          );

          // Word joiner 제거해서 출력
          final cleanText = WordBreakUtils.removeWordJoiner(lineText);
          // ignore: avoid_print
          print('Line ${i + 1}: "$cleanText"');
        }
        // ignore: avoid_print
        print('');

        textPainter.dispose();
      }
    });

    testWidgets('keepAll 미적용 vs 적용 비교', (tester) async {
      const testText = '오늘의 앱은 누구나 다 볼 수 있고 쓸 수 있어요';
      const style = TextStyle(fontSize: 20);
      const width = 250.0;

      // 미적용
      final painter1 = TextPainter(
        text: const TextSpan(text: testText, style: style),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: width);

      // 적용
      final processedText = WordBreakUtils.keepAll(testText);
      final painter2 = TextPainter(
        text: TextSpan(text: processedText, style: style),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: width);

      // ignore: avoid_print
      print('=== 비교 (Width: $width) ===');
      // ignore: avoid_print
      print('미적용: ${painter1.computeLineMetrics().length}줄');
      // ignore: avoid_print
      print('keepAll 적용: ${painter2.computeLineMetrics().length}줄');

      painter1.dispose();
      painter2.dispose();
    });
  });
}
