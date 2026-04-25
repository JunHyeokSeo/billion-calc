# 1억 계산기 (BillionCalc)

목표 금액 달성까지 남은 D-Day를 계산해주는 iPhone 미니 앱.

## 프로젝트 구조

```
BillionCalc/
├── Package.swift                       # SPM 정의 (Core 라이브러리)
├── project.yml                         # xcodegen 프로젝트 정의
├── Sources/
│   ├── BillionCalcCore/                # 계산 로직·모델·저장소 (iOS·macOS 공용)
│   └── BillionCalcVerify/              # Xcode 없이 CLI로 Core 검증
├── Tests/BillionCalcCoreTests/         # XCTest (Xcode 필요)
├── App/                                # iOS App Target
│   ├── BillionCalcApp.swift
│   ├── AppViewModel.swift
│   ├── AppTheme.swift
│   ├── Views/
│   │   ├── OnboardingView.swift
│   │   ├── MainView.swift
│   │   ├── DepositAdjustmentView.swift
│   │   └── SettingsView.swift
│   └── Resources/
│       ├── Assets.xcassets
│       ├── Info.plist                  # (xcodegen 생성)
│       ├── BillionCalc.entitlements    # (xcodegen 생성)
│       └── PrivacyInfo.xcprivacy
├── Widget/                             # Widget Extension
│   ├── BillionCalcWidgetBundle.swift
│   ├── BillionCalcWidget.swift
│   ├── Info.plist                      # (xcodegen 생성)
│   └── BillionCalcWidget.entitlements  # (xcodegen 생성)
└── docs/
    ├── XCODE_SETUP.md                  # Xcode 세팅 가이드
    ├── PRIVACY_POLICY.md               # 개인정보처리방침 (GitHub Pages용)
    ├── APP_STORE_META.md               # App Store Connect 메타데이터
    └── CHECKLIST.md                    # 출시 전 체크리스트
```

## 빠른 시작

### 1. Core 로직 검증 (Xcode 불필요)

```bash
cd /Users/jun/Documents/dev_project/BillionCalc
swift run BillionCalcVerify
```

모든 테스트가 통과하면 "passed: 69 / failed: 0" 출력.

### 2. iOS 앱 빌드 (Xcode 필요)

```bash
# xcodegen으로 프로젝트 자동 생성
brew install xcodegen
xcodegen generate
open BillionCalc.xcodeproj
```

자세한 내용은 [`docs/XCODE_SETUP.md`](docs/XCODE_SETUP.md) 참고.

## 기술 스택

- Swift 5.9 / Swift Concurrency
- SwiftUI (iOS 17+)
- WidgetKit
- Swift Package Manager (Core 라이브러리 분리)

## 라이선스

Private. 상업 배포 전 문의: westjh@ex-em.com
