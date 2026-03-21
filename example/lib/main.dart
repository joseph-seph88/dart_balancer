import 'package:flutter/material.dart';
import 'package:dart_balancer/dart_balancer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dart Balancer Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  double _ratio = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dart Balancer Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ratio slider
            Text('Ratio: ${_ratio.toStringAsFixed(2)}'),
            Slider(
              value: _ratio,
              onChanged: (value) => setState(() => _ratio = value),
            ),
            const SizedBox(height: 32),

            // Comparison section
            const Text(
              'Without Balancing:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              color: Colors.grey.shade200,
              padding: const EdgeInsets.all(16),
              child: const Text(
                'The quick brown fox jumps over the lazy dog near the riverbank',
                style: TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'With BalancedText:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              color: Colors.blue.shade50,
              padding: const EdgeInsets.all(16),
              child: BalancedText(
                'The quick brown fox jumps over the lazy dog near the riverbank',
                style: const TextStyle(fontSize: 24),
                ratio: _ratio,
              ),
            ),
            const SizedBox(height: 32),

            // RichText example
            const Text(
              'BalancedRichText (mixed styles):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              color: Colors.green.shade50,
              padding: const EdgeInsets.all(16),
              child: BalancedRichText(
                TextSpan(
                  style: const TextStyle(fontSize: 20, color: Colors.black),
                  children: [
                    const TextSpan(
                      text: 'Important: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text: 'This announcement contains ',
                    ),
                    TextSpan(
                      text: 'critical information ',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const TextSpan(
                      text: 'that you need to know',
                    ),
                  ],
                ),
                ratio: _ratio,
              ),
            ),
            const SizedBox(height: 32),

            // Korean test
            const Text(
              '한국어 테스트 (Without):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              color: Colors.grey.shade200,
              padding: const EdgeInsets.all(16),
              child: const Text(
                '오늘의 앱은 누구나 다 볼 수 있고 쓸 수 있어요',
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '한국어 테스트 (With BalancedText):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              color: Colors.blue.shade50,
              padding: const EdgeInsets.all(16),
              child: BalancedText(
                '오늘의 앱은 누구나 다 볼 수 있고 쓸 수 있어요',
                style: const TextStyle(fontSize: 20),
                ratio: _ratio,
              ),
            ),
            const SizedBox(height: 32),

            // SafeBalancedText example
            const Text(
              'SafeBalancedText (auto-sizing + balancing):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              color: Colors.red.shade50,
              padding: const EdgeInsets.all(16),
              width: 200,
              child: const SafeBalancedText(
                'This is a very long headline that will shrink to fit within the container while staying balanced',
                style: TextStyle(fontSize: 24),
                minFontSize: 12,
                maxLines: 3,
                maxTextScaleFactor: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Same text without SafeBalancedText:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Container(
              color: Colors.grey.shade200,
              padding: const EdgeInsets.all(16),
              width: 200,
              child: const Text(
                'This is a very long headline that will shrink to fit within the container while staying balanced',
                style: TextStyle(fontSize: 24),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 32),

            // Algorithm comparison
            const Text(
              'Greedy vs Optimal Algorithm:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('Greedy'),
                      Container(
                        color: Colors.orange.shade50,
                        padding: const EdgeInsets.all(12),
                        child: BalancedText(
                          'Flutter text balancing made easy',
                          style: const TextStyle(fontSize: 18),
                          ratio: _ratio,
                          algorithmType: BalanceAlgorithmType.greedy,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      const Text('Optimal'),
                      Container(
                        color: Colors.purple.shade50,
                        padding: const EdgeInsets.all(12),
                        child: BalancedText(
                          'Flutter text balancing made easy',
                          style: const TextStyle(fontSize: 18),
                          ratio: _ratio,
                          algorithmType: BalanceAlgorithmType.optimal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
