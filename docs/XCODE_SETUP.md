# Xcode 프로젝트 세팅 가이드

이 문서는 `BillionCalc` iOS 앱을 Xcode에서 빌드·실행 가능하게 만드는 단계별 가이드입니다. `xcodegen`을 쓰는 **권장 자동 방식**과 **수동 방식** 둘 다 포함합니다.

---

## 전제 조건

- [ ] **Xcode 15+** 설치 (App Store에서, 약 15GB)
- [ ] **Apple Developer Program** 가입 ($99/년, 앱스토어 출시 필수)
- [ ] **Homebrew** 설치 (xcodegen 방식 사용 시)
- [ ] **Command Line Tools** — Xcode 설치 후 `xcode-select --install`

Xcode 설치 완료 후 다음 명령으로 Xcode 툴체인이 활성화되었는지 확인:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
xcodebuild -version    # Xcode 15+ 표시돼야 함
```

---

## 방식 A — xcodegen 자동 생성 (권장)

### 1. xcodegen 설치

```bash
brew install xcodegen
```

### 2. 프로젝트 생성

```bash
cd /Users/jun/Documents/dev_project/BillionCalc
xcodegen generate
```

성공하면 `BillionCalc.xcodeproj`가 생성됩니다.

### 3. Xcode에서 열기

```bash
open BillionCalc.xcodeproj
```

### 4. 팀(Team) 설정

Xcode에서:

1. 좌측 네비게이터 최상단 `BillionCalc` 프로젝트 클릭
2. **TARGETS** → `BillionCalc` 선택
3. **Signing & Capabilities** 탭
4. **Team** 드롭다운에서 본인 Apple Developer 계정 선택
5. **TARGETS** → `BillionCalcWidget` 에도 동일하게 적용

### 5. App Group 확인

두 타겟 모두 **Signing & Capabilities**에 `App Groups`이 활성화되고 `group.com.westjh.billion-calc`가 체크되어 있어야 합니다. xcodegen이 자동 생성하지만 Xcode에서 한 번 더 확인.

### 6. 빌드 & 실행

- 상단 툴바에서 스킴을 `BillionCalc`로, 디바이스를 `iPhone 15 Pro` 시뮬레이터로 선택
- `⌘R`

---

## 방식 B — Xcode 수동 프로젝트 생성 (xcodegen 없이)

### 1. 새 iOS App 프로젝트 만들기

Xcode → File → New → Project...

- Platform: **iOS**
- Template: **App**
- Product Name: `BillionCalc`
- Team: 본인 Developer 계정
- Organization Identifier: `com.westjh`
- Interface: **SwiftUI**
- Language: **Swift**
- Storage: **None**
- 위치: `/Users/jun/Documents/dev_project/BillionCalc` (덮어쓰지 말고 하위 폴더로)

> **주의**: Xcode 생성 폴더와 기존 `App/`, `Widget/` 폴더를 병합해야 합니다. 충돌 시 기존 폴더를 임시 백업해뒀다가 Xcode가 만든 `BillionCalcApp.swift` 등을 지우고 기존 파일을 덮어쓰세요.

### 2. 기존 소스 파일 추가

Finder에서 `App/` 폴더 내 모든 `.swift` 파일을 Xcode 프로젝트 네비게이터로 드래그.

- **Copy items if needed**: 체크 해제 (이미 올바른 위치에 있음)
- **Add to targets**: `BillionCalc`만 체크

### 3. Swift Package 추가 (BillionCalcCore)

File → Add Package Dependencies... → **Add Local...** → `/Users/jun/Documents/dev_project/BillionCalc` 선택

`BillionCalcCore` 라이브러리를 `BillionCalc` 타겟에 추가.

### 4. Widget Extension 추가

File → New → Target... → **Widget Extension**

- Product Name: `BillionCalcWidget`
- Include Configuration Intent: **체크 해제**
- Bundle Identifier: `com.westjh.billion-calc.widget` 로 수정

Xcode가 생성한 템플릿 파일들을 삭제하고 `Widget/` 폴더의 파일을 드래그하여 `BillionCalcWidget` 타겟에 추가.

`BillionCalcCore` 패키지를 `BillionCalcWidget` 타겟에도 연결.

### 5. App Group 설정

각 타겟 (`BillionCalc`, `BillionCalcWidget`) 에서:

- Signing & Capabilities → `+ Capability` → **App Groups**
- `group.com.westjh.billion-calc` 체크 (없으면 새로 만들기)

### 6. Assets.xcassets / PrivacyInfo.xcprivacy 추가

`App/Resources/` 폴더의 파일들을 `BillionCalc` 타겟 리소스로 드래그.

### 7. 빌드 & 실행

`⌘R`

---

## 트러블슈팅

### 빌드 에러: "No such module 'BillionCalcCore'"

`BillionCalcCore` 패키지가 타겟에 연결되지 않은 경우. 각 타겟 → General → Frameworks, Libraries, and Embedded Content 에서 `BillionCalcCore` 추가.

### 위젯이 홈 화면에서 안 보임

- 시뮬레이터 / 기기에서 앱을 **한 번 실행**했는지 확인
- 홈 화면 길게 누르기 → + 버튼 → "1억 계산기" 검색
- 그래도 안 보이면: 시뮬레이터 재부팅 (`⌘K`)

### Code signing 오류

- 번들 ID가 이미 다른 팀에서 사용 중인 경우, 다음으로 변경:
  `com.westjh.billion-calc` → `com.{yourname}.billion-calc`

### "A signed resource has been added, modified, or deleted"

Derived Data 정리: `⌘⇧K` (Clean Build Folder) 후 재빌드.

---

## 첫 실행 후 검증 체크리스트

- [ ] 온보딩 3페이지 스와이프 + 입력 → 시작하기 작동
- [ ] 메인 화면에 D-Day 숫자 표시
- [ ] 진행률 바 정상 표시
- [ ] "이번 달 입금 확인" 배너 → 드래그 조정 시트 열림
- [ ] 드래그로 숫자 변경 + 확인 후 메인 현재 금액 업데이트
- [ ] 설정에서 값 수정 시 메인 화면 반영
- [ ] 다크모드 전환 시 색상 정상 (`⌘⇧A` 시뮬레이터)
- [ ] 시뮬레이터 홈 화면에 Small 위젯 추가됨
- [ ] 시뮬레이터 홈 화면에 Medium 위젯 추가됨
- [ ] 시뮬레이터 앱 종료 후 재실행 → 데이터 유지
- [ ] 설정 → 모든 데이터 초기화 → 온보딩 재노출
