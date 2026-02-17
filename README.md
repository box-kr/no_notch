# NoNotch

macOS 노치가 있는 디스플레이에서 **메뉴바를 노치 없애주는** 경량 유틸리티 앱입니다.

디스플레이 해상도를 노치 높이만큼 줄여 메뉴바가 노치에 가려지지 않도록 합니다.

---

## ✨ 주요 기능

| 기능 | 설명 |
|------|------|
| **노치 우회** | 디스플레이 해상도를 노치 아래 영역에 맞게 자동 변경 |
| **원클릭 토글** | 메뉴바 아이콘 좌클릭으로 즉시 활성화/비활성화 |
| **상태 유지** | 앱 재시작 시 마지막 상태 자동 복원 (`UserDefaults`) |
| **로그인 시 자동 시작** | `SMAppService`를 통한 macOS 네이티브 로그인 항목 등록 |
| **화면 변경 감지** | 외부 모니터 연결/해제 시 자동 재적용 |
| **Buy Me a Coffee** | 3회 토글마다 앱 내 WebView 다이얼로그로 후원 페이지 자동 표시 |
| **다국어 지원** | 한국어 · 일본어 · 중국어 · 영어 (macOS 시스템 언어 자동 감지) |

---

## 🌐 지원 언어

| 언어 | 코드 | 비고 |
|------|------|------|
| 🇰🇷 한국어 | `ko` | |
| 🇯🇵 日本語 | `ja` | |
| 🇨🇳 中文 | `zh` | 간체 |
| 🇺🇸 English | `en` | 기본값 (폴백) |

macOS **시스템 환경설정 > 일반 > 언어 및 지역** 의 기본 언어를 자동으로 감지합니다.  
지원하지 않는 언어일 경우 영어(English)로 표시됩니다.

---

## 🏗️ 프로젝트 구조

```
no_notch/
├── Package.swift                        # Swift Package Manager 설정
├── NoNotch.xcodeproj/                   # Xcode 프로젝트
├── build.sh                             # 커맨드라인 빌드 스크립트
├── README.md
├── Sources/
│   └── NoNotch/
│       ├── main.swift                   # 앱 엔트리포인트
│       ├── AppDelegate.swift            # 메뉴바 UI, 이벤트 처리, 후원 다이얼로그
│       ├── NotchOverlayManager.swift    # 디스플레이 해상도 제어 핵심 로직
│       ├── LaunchAtLoginManager.swift   # 로그인 시 자동 시작 관리
│       ├── Localization.swift           # 다국어 문자열 관리 (ko/ja/zh/en)
│       └── Resources/
│           └── Info.plist               # 앱 번들 메타데이터
└── build/                               # 빌드 산출물 (gitignored)
```

---

## 🛠️ 기술 스택

| 항목 | 상세 |
|------|------|
| **언어** | Swift 5.9 |
| **플랫폼** | macOS 12.0 (Monterey) 이상 |
| **아키텍처** | arm64 (Apple Silicon) |
| **UI 프레임워크** | AppKit (`NSStatusItem`, `NSMenu`, `NSWindow`) |
| **디스플레이 제어** | CoreGraphics (`CGDisplaySetDisplayMode`, `CGDisplayCopyAllDisplayModes`) |
| **웹 뷰** | WebKit (`WKWebView`) — Buy Me a Coffee 다이얼로그 |
| **로그인 관리** | ServiceManagement (`SMAppService`, macOS 13+) |
| **다국어** | `Locale.preferredLanguages` 기반 자체 구현 (`L10n` enum) |
| **패키지 매니저** | Swift Package Manager |
| **번들 ID** | `com.nonotch.app` |
| **앱 타입** | 메뉴바 전용 (`LSUIElement: true`, Dock 아이콘 없음) |

---

## 📦 빌드 방법

### 방법 1: 빌드 스크립트 (권장)

```bash
chmod +x build.sh
./build.sh
```

빌드 완료 후 `build/NoNotch.app` 이 생성됩니다.

### 방법 2: Xcode

1. `NoNotch.xcodeproj` 를 Xcode에서 열기
2. Scheme: **NoNotch** 선택
3. `Cmd + B` 빌드 또는 `Cmd + R` 실행

### 방법 3: Swift Package Manager

```bash
swift build
```

---

## 🚀 실행 및 설치

### 실행

```bash
open build/NoNotch.app
```

### Applications 폴더에 설치

```bash
cp -r build/NoNotch.app /Applications/
```

---

## 📖 사용법

### 기본 조작

- **좌클릭**: 노치 바 활성화/비활성화 토글
- **우클릭**: 메뉴 열기

### 메뉴 구성

```
┌─────────────────────────────────┐
│ 노치 바 활성화 / 비활성화        │  ← Enable / Disable Notch Bar
├─────────────────────────────────┤
│ 로그인 시 자동 시작        ✓/✗  │  ← Launch at Login
├─────────────────────────────────┤
│ ☕ Buy Me a Coffee              │
├─────────────────────────────────┤
│ 노치 감지됨 (높이: 32pt)        │  ← Notch detected (height: 32pt)
│ 현재: 3024×1964 → 변경: ...     │  ← Current: 3024×1964 → ...
├─────────────────────────────────┤
│ 종료                       ⌘Q  │  ← Quit
└─────────────────────────────────┘
```

> 💡 메뉴 텍스트는 macOS 시스템 언어에 따라 자동으로 변환됩니다.

### Buy Me a Coffee 다이얼로그

- 메뉴에서 **☕ Buy Me a Coffee** 클릭 시 앱 내 WebView 다이얼로그로 표시
- 노치 바를 **3회 토글**할 때마다 자동으로 다이얼로그 표시

---

## 🔧 핵심 아키텍처

### 모듈별 역할

| 모듈 | 역할 |
|------|------|
| `main.swift` | `NSApplication` 설정, Dock 아이콘 숨김 (`.accessory`) |
| `AppDelegate` | 상태바 아이콘, 좌/우클릭 이벤트, 메뉴 구성, 후원 다이얼로그 |
| `NotchOverlayManager` | 디스플레이 모드 탐색·변경·복원, 화면 변경 감지 (Singleton) |
| `LaunchAtLoginManager` | `SMAppService` 기반 로그인 항목 등록/해제 |
| `L10n` | macOS 시스템 언어 감지, 4개 언어 번역 문자열 제공 |

### 디스플레이 모드 변경 전략 (`NotchOverlayManager`)

노치 아래에 맞는 최적의 디스플레이 모드를 4단계 전략으로 탐색합니다:

1. **정확 일치** — 같은 너비 + (현재 높이 - 노치 높이) 모드
2. **같은 너비 근접** — 같은 너비, targetHeight 이하 중 가장 큰 모드
3. **같은 너비 상위** — 같은 너비, targetHeight보다 크지만 현재보다는 작은 모드
4. **유사 너비** — ±100px 범위의 너비, 가장 큰 해상도

### 다국어 구현 (`Localization.swift`)

```swift
// macOS 시스템 언어 자동 감지
Locale.preferredLanguages.first  // e.g. "ko-KR", "ja-JP", "zh-Hans-CN", "en-US"
→ 앞 2자리 추출 → AppLanguage enum 매칭 → 미지원 시 .en 폴백
```

### 상태 관리

| 키 | 저장소 | 용도 |
|----|--------|------|
| `NoNotch_isEnabled` | `UserDefaults` | 활성화 상태 유지 |
| `NoNotch_launchAtLogin` | `UserDefaults` | 자동 시작 설정 |

---

## ⚠️ 요구 사항

- macOS 12.0 (Monterey) 이상
- Apple Silicon (arm64) Mac
- 노치가 있는 디스플레이 (MacBook Pro 14"/16" 등)
- 화면 녹화/접근성 권한이 필요할 수 있음 (디스플레이 모드 변경 시)

---

## ☕ 후원

이 프로젝트가 유용하다면 커피 한 잔 사주세요!

👉 [Buy Me a Coffee](https://buymeacoffee.com/funbox.kr)

---

## 📄 라이선스

Copyright © 2026. All rights reserved.
