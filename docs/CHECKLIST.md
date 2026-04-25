# 출시 전 체크리스트

## 개발 단계

### 코드 & 빌드
- [x] Core 계산 로직 + 유닛 테스트 (69개 통과)
- [x] 동기부여 멘트 라이브러리 (86개)
- [x] SharedStorage (App Group 공유)
- [x] WidgetSnapshot 빌더
- [x] SwiftUI 뷰: Onboarding / Main / DepositAdjustment / Settings
- [x] Widget Extension: Small / Medium
- [x] xcodegen 프로젝트 설정
- [ ] Xcode 설치 후 `xcodegen generate` 성공
- [ ] Xcode에서 첫 빌드 성공 (no errors)
- [ ] 시뮬레이터에서 실행 성공

### 기능 검증 (시뮬레이터)
- [ ] 첫 실행 → 온보딩 3페이지 + 입력 → 메인 진입
- [ ] 메인 D-Day 계산 정확
- [ ] 월 입금 드래그 조정 → 값 반영
- [ ] 조정 화면 계획/쉬어가기 빠른 버튼 동작
- [ ] 과거 입금 수정 (재조정) 동작
- [ ] What-if 슬라이더 실시간 재계산
- [ ] 설정 저장/불러오기
- [ ] 데이터 초기화 → 온보딩 재노출
- [ ] 다크모드 전환 (⌘⇧A)
- [ ] Small 위젯 홈 화면 추가 & 표시
- [ ] Medium 위젯 홈 화면 추가 & 표시

### 엣지 케이스
- [ ] 목표 금액 0 입력 → 저장 불가 (disable)
- [ ] 월 저축 0 + 수익률 0 → "달성 불가" 표시
- [ ] 이미 달성 (현재 >= 목표) → "🎉 달성!" 표시
- [ ] 월급일 31일 설정 → 2월 처리 확인
- [ ] 수익률 15% 초과 → 경고 멘트

## App Store Connect 준비

### 자산
- [ ] 앱 아이콘 1024×1024 (금색 배경 + "1억" 볼드)
- [ ] 스크린샷 6.7" × 5장
- [ ] (선택) 스크린샷 6.5"

### 메타데이터 (`docs/APP_STORE_META.md` 참고)
- [ ] 앱 이름, 부제
- [ ] 카테고리 (Finance + Productivity)
- [ ] 설명문 (첫 3줄 + 본문)
- [ ] 프로모션 텍스트
- [ ] 키워드 15개
- [ ] What's New
- [ ] Support URL (GitHub Pages)
- [ ] Privacy Policy URL (GitHub Pages에 `PRIVACY_POLICY.md` 배포)
- [ ] App Privacy: Data Not Collected 선택
- [ ] Age Rating: 4+
- [ ] 리뷰 노트 작성 (4.2 방어)

### 인프라
- [ ] Apple Developer Program 가입 완료 ($99)
- [ ] App Store Connect에 앱 레코드 생성
- [ ] 번들 ID `com.westjh.billion-calc` 등록
- [ ] 번들 ID `com.westjh.billion-calc.widget` 등록
- [ ] App Group `group.com.westjh.billion-calc` 등록

## 제출

- [ ] Xcode에서 Archive (⌘⇧B → Product → Archive)
- [ ] Organizer에서 App Store Connect에 업로드
- [ ] TestFlight 빌드 처리 대기 (10~30분)
- [ ] TestFlight 내부 테스트 본인 기기에서 1회 실행
- [ ] App Store Connect에서 빌드 선택 → 심사 제출
- [ ] 심사 대기 (보통 24~48시간)

## 출시 후

- [ ] 승인 알림 확인
- [ ] 앱스토어 URL을 SNS에 공유
- [ ] 크래시 리포트 모니터링 (App Store Connect → Analytics)
- [ ] 1주일 내 사용자 피드백 수집

## v1.1 백로그 (MVP 이후)

- [ ] 월별 입금 히스토리 뷰
- [ ] 과거 달 수정 UI
- [ ] Lock Screen 위젯
- [ ] 중간 선물 타임라인
- [ ] 목표 달성 후 "다음 목표" 제안
- [ ] 영어 로컬라이제이션
- [ ] iCloud 동기화
