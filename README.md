# dart_balancer

Flutter 텍스트 밸런싱 패키지. 줄 길이를 균등하게 만들고, 한국어 단어 끊김을 방지합니다.

Inspired by [react-wrap-balancer](https://react-wrap-balancer.vercel.app/)

## Features

- **Ratio Control** - 밸런스 강도 조절 (0.0 ~ 1.0)
- **RichText Support** - TextSpan 혼합 스타일 지원
- **Korean/CJK keepAll** - 한국어 단어 중간 끊김 방지
- **Multiple Algorithms** - Greedy(빠름) / Optimal(정확) 선택

## Installation

```yaml
dependencies:
  dart_balancer: ^0.1.0
```

## Usage

### Basic

```dart
import 'package:dart_balancer/dart_balancer.dart';

BalancedText(
  '오늘의 앱은 누구나 다 볼 수 있고 쓸 수 있어요',
  style: TextStyle(fontSize: 20),
)
```

### With Ratio

```dart
BalancedText(
  'The quick brown fox jumps over the lazy dog',
  ratio: 0.65,
)
```

### RichText

```dart
BalancedRichText(
  TextSpan(
    children: [
      TextSpan(text: '중요: ', style: TextStyle(fontWeight: FontWeight.bold)),
      TextSpan(text: '공지사항입니다'),
    ],
  ),
)
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `ratio` | `double` | `1.0` | 밸런스 강도 (0.0-1.0) |
| `keepAll` | `bool` | `true` | 단어 단위 줄바꿈 (한국어) |
| `algorithmType` | `BalanceAlgorithmType` | `greedy` | 알고리즘 선택 |

## Author

- **Name**: Joseph88
- **Email**: pathetic.sim@gmail.com

## License

MIT License
