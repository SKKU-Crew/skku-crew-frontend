# SKKU Crew — 프론트엔드

SWE3002-42 Team 7 SKKU Crew 웹(Flutter Web) 프론트엔드.
[`skku-crew-backend`](https://github.com/SKKU-Crew/skku-crew-backend) REST API(`http://localhost:8080`)랑 연결되어 동작하고, 서버가 꺼져 있을 때도 내장 시드 데이터로 동작한다.

## 실행

1. 백엔드 먼저 실행:
```powershell
cd ..\skku-crew-backend
.\gradlew.bat bootRun
```

2. 프론트 실행:
```powershell
flutter pub get
flutter run -d chrome --web-port 5000
```

다른 백엔드 주소(ngrok 등)에 붙일 때:
```powershell
flutter run -d chrome --web-port 5000 --dart-define=API_BASE_URL=https://xxxx.ngrok-free.app
```

참고:
- Dart 패키지 이름 규칙 때문에 `pubspec.yaml` 안의 `name`은 `skku_crew`로 유지함
- 테스트 / 분석: `flutter analyze`, `flutter test`
- 계정 전환: 상단 프로필 버튼 또는 설정 → 로그아웃해서 `/login` 화면에서 다른 계정 선택

## 라우트 경로 (MCP 링크 참고용)

`skku-crew-backend`의 MCP 도구 응답에 웹 링크 달 때 아래 경로 쓰면 됨.

| 경로 | 화면 | 설명 |
|---|---|---|
| `/` | SCR-04 | 홈 (맞춤 공고, 마감 임박) |
| `/login` | SCR-01 | 로그인 |
| `/signup` | SCR-02 | 개인회원 가입 |
| `/org/signup` | SCR-03 | 단체회원 가입 · 인증 신청 |
| `/explore` | SCR-05 | 활동 탐색 |
| `/postings/new` | SCR-11 | 공고 작성 |
| `/postings/{id}` | SCR-06 | 공고 상세 |
| `/postings/{id}/apply` | SCR-07 | 지원서 작성 (초안 불러오기 포함) |
| `/postings/{id}/applicants` | SCR-12 | 지원자 목록 |
| `/postings/{id}/announce` | SCR-14 | 결과 발표 |
| `/applications/{id}` | SCR-13 | 지원서 검토 |
| `/me/applications` | SCR-08 | 내 활동 (지원 현황, 내 공고, 관심) |
| `/me/profile` | SCR-09 | 내 프로필 |
| `/me/profile/edit` | SCR-10 | 프로필 편집 |
| `/org/dashboard` | SCR-15 | 단체 대시보드 |
| `/orgs/{orgId}` | SCR-16 | 조직 페이지 |
| `/external` | SCR-17 | 외부 활동 |
| `/notifications` | SCR-18 | 알림 |
| `/admin` | SCR-19 | 관리자 콘솔 |
| `/settings/ai` | SCR-20 | AI 연결 설정 |
| `/oauth/authorize` | SCR-21 | AI 연결 권한 동의 |

## 구조

```text
lib/
├── main.dart               진입점 (초기 로그인: 김민준 #1)
├── app.dart                테마, 라우팅
├── core/
│   ├── constants/          색상, 백엔드 Codes.java 대응 enum
│   ├── utils/              KST 날짜·D-Day 포맷, 입력 검증
│   └── widgets/            반응형 쉘, 공고 카드, 스냅샷 뷰, 공통 위젯
├── domain/models/          DTO (Dtos.java 대응)
├── data/
│   ├── services/           REST API 클라이언트, 로컬 시드 엔진
│   └── state/              전역 상태 (AppController)
└── ui/screens/             SCR-01 ~ SCR-21 화면들
```
