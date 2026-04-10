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

### 3가지 Widget 비교 & 선택 가이드

| Widget | 용도 | 특징 |
|--------|------|------|
| **SafeBalancedText** | 제목, 중요 텍스트 | 길이 상관없이 자동으로 폰트 조정 |
| **BalancedText** | 고정 크기 텍스트 | 폰트 크기 고정, 가벼움 |
| **BalancedRichText** | 스타일 섞인 텍스트 | 일부만 bold, 색상 다르게 등 |

### SafeBalancedText (추천)
가장 안전하고 유연합니다. 화면 크기에 관계없이 자동으로 폰트를 조정합니다.

```dart
// 기본 사용
SafeBalancedText(
  '오늘의 앱은 누구나 다 볼 수 있고 쓸 수 있어요',
  style: TextStyle(fontSize: 24),
)

// 더 많은 옵션
SafeBalancedText(
  '긴 제목도 안전하게 처리',
  style: TextStyle(fontSize: 28),
  minFontSize: 14,        // 최소 폰트 크기
  maxLines: 2,            // 최대 2줄까지
  textAlign: TextAlign.center,  // 가운데 정렬
)
```

### BalancedText
폰트 크기가 고정되어야 할 때 사용합니다.

```dart
BalancedText(
  'The quick brown fox jumps over the lazy dog',
  style: TextStyle(fontSize: 20),
  textAlign: TextAlign.center,
)
```

### BalancedRichText
텍스트의 일부만 다른 스타일을 적용해야 할 때 사용합니다.

```dart
BalancedRichText(
  TextSpan(
    children: [
      TextSpan(
        text: '특별 할인: ',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
      TextSpan(
        text: '지금 구매하세요',
        style: TextStyle(fontSize: 20),
      ),
    ],
  ),
  textAlign: TextAlign.center,
)
```

## Parameters

### 공통 파라미터

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `textAlign` | `TextAlign` | `center` | 텍스트 정렬 (center, left, right, justify) |
| `ratio` | `double` | `1.0` | 밸런스 강도 (0.0-1.0) |
| `keepAll` | `bool` | `true` | 단어 단위 줄바꿈 (한국어) |
| `algorithmType` | `BalanceAlgorithmType` | `greedy` | 알고리즘 선택 |

### SafeBalancedText 전용

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `minFontSize` | `double` | `12` | 최소 폰트 크기 |
| `maxLines` | `int` | `2` | 최대 줄 수 |
| `stepGranularity` | `double` | `1` | 폰트 감소 단계 |

## Author

- **Name**: Joseph88
- **Email**: pathetic.sim@gmail.com

## License

MIT License
