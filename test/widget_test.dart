import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skku_crew/app.dart';
import 'package:skku_crew/core/constants/codes.dart';
import 'package:skku_crew/data/services/skku_api_client.dart';
import 'package:skku_crew/data/state/app_controller.dart';
import 'package:skku_crew/domain/models/api_models.dart';

void main() {
  group('SKKU Crew 백엔드 연동 및 시연 비즈니스 규칙 테스트', () {
    late SkkuApiClient api;

    setUp(() {
      api = SkkuApiClient(forceFallbackOnly: true);
    });

    test('시연 핵심 시나리오: 김민준 지원 -> 박지호 검토·조기마감·결과발표 -> 연락처 공개 및 활동이력 추가', () async {
      // 1. 김민준(1) 로그인
      final minjunLogin = await api.demoLogin(1);
      expect(minjunLogin.member.name, '김민준');
      expect(minjunLogin.member.profileCompleteness, 90);

      // 2. 공고 106에는 GPT(MCP)가 저장한 답변 초안이 존재함
      final form106 = await api.getApplicationForm(106);
      expect(form106.draft?.exists, isTrue);
      expect(form106.draft?.source, DraftSource.MCP);

      // 3. 공고 101 지원 시 요청 연락처(KAKAO_ID) 미동의면 409 REQUESTED_CONTACT_MISSING
      await expectLater(
        () => api.submitApplication(101, {
          'share': {'bio': true, 'skills': true},
          'contacts': <Map<String, dynamic>>[],
          'answers': [
            {'questionId': 1001, 'value': '지원 동기입니다.'},
            {'questionId': 1002, 'value': '가능'},
          ],
          'agreeToProvide': true,
        }),
        throwsA(
          isA<ApiException>()
              .having((e) => e.code, 'code', 'REQUESTED_CONTACT_MISSING'),
        ),
      );

      // 4. 정상 지원 제출
      final applyRes = await api.submitApplication(101, {
        'share': {
          'bio': true,
          'skills': true,
          'majorsSecondary': true,
          'experienceIds': [21, 22],
          'portfolioLinkIds': [31],
          'portfolioFileIds': <int>[],
        },
        'contacts': [
          {'type': 'KAKAO_ID', 'consent': true},
        ],
        'answers': [
          {'questionId': 1001, 'value': '교통 혼잡도 시각화 프로젝트 경험을 살리고 싶습니다.'},
          {'questionId': 1002, 'value': '가능'},
          {'questionId': 1003, 'value': 'Python, SQL'},
        ],
        'agreeToProvide': true,
      });
      expect(applyRes.displayStatus, DisplayStatus.SUBMITTED);

      // 5. 박지호(4, 공고 101 모집자) 전환
      await api.demoLogin(4);
      final applicants = await api.getApplicants(101);
      expect(applicants.length, 3);

      // 발표 전에는 지원자 연락처가 null (BR-06, BR-09)
      final reviewBefore = await api.getReviewDetail(applyRes.applicationId);
      expect(reviewBefore.contacts, isNull);
      expect(reviewBefore.sharedContactTypes, contains(ContactType.KAKAO_ID));

      // 6. 조기 마감 전 발표 시 409 POSTING_NOT_CLOSED
      await expectLater(
        () => api.announcePosting(101, acceptMessage: '축하합니다!'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.code, 'code', 'POSTING_NOT_CLOSED'),
        ),
      );

      // 7. 조기 마감 후 미정 지원서가 남으면 409 UNDECIDED_APPLICATIONS (BR-07)
      await api.closePosting(101);
      await expectLater(
        () => api.announcePosting(101, acceptMessage: '축하합니다!'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.code, 'code', 'UNDECIDED_APPLICATIONS'),
        ),
      );

      // 8. 3명 모두 결정 후 일괄 발표 (2명 합격, 1명 불합격)
      for (final a in applicants) {
        await api.decideApplication(
          a.applicationId,
          decision: a.applicationId == applyRes.applicationId ||
                  a.name == '이서연'
              ? Decision.ACCEPTED
              : Decision.REJECTED,
        );
      }
      final announceRes = await api.announcePosting(
        101,
        acceptMessage: '합격 축하합니다! 카톡으로 연락드릴게요.',
      );
      expect(announceRes.status, PostingStatus.ANNOUNCED);
      expect(announceRes.accepted, 2);
      expect(announceRes.rejected, 1);
      expect(announceRes.warning, isNull);

      // 9. 김민준(1)으로 전환하여 결과·상호 연락처·활동 이력 확인
      await api.demoLogin(1);
      final appDetail = await api.getMyApplicationDetail(applyRes.applicationId);
      expect(appDetail.displayStatus, DisplayStatus.ACCEPTED);
      expect(appDetail.result?.recruiterContact?.value, 'jiho.park@g.skku.edu');
      expect(
        appDetail.result?.disclosedContacts?.map((e) => e.value),
        contains('minjun_k'),
      );
      final profile = await api.getMyProfile();
      expect(
        profile.activityHistory.any((h) => h.postingId == 101),
        isTrue,
      );
    });
  });

  group('SKKU Crew UI 위젯 테스트', () {
    testWidgets('홈 -> 탐색 -> 공고 상세 -> 지원서 작성 화면 전환 테스트', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = AppController(
        apiClient: SkkuApiClient(forceFallbackOnly: true),
      );
      await controller.init(initialMemberId: 1);

      await tester.pumpWidget(SkkuCrewApp(controller: controller));
      await tester.pumpAndSettle();

      // SCR-04 홈 화면 확인
      expect(find.text('김민준님 맞춤 공고'), findsOneWidget);
      expect(find.text('마감 임박'), findsOneWidget);

      // SCR-05 탐색 이동
      controller.go('/explore');
      await tester.pumpAndSettle();
      expect(find.textContaining('검색 결과'), findsOneWidget);

      // SCR-06 공고 101 상세 이동
      controller.push('/postings/101');
      await tester.pumpAndSettle();
      expect(find.text('지원하기'), findsOneWidget);

      // SCR-07 지원서 작성 이동
      await tester.tap(find.text('지원하기'));
      await tester.pumpAndSettle();
      expect(find.text('항상 공유되는 정보'), findsOneWidget);
      expect(find.text('다음 (추가 질문)'), findsOneWidget);
    });

    testWidgets('모집자 지원자 관리 미정 가드 및 결과 발표 기본 불합격 메시지 확인', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = AppController(
        apiClient: SkkuApiClient(forceFallbackOnly: true),
      );
      await controller.init(initialMemberId: 4);

      await tester.pumpWidget(SkkuCrewApp(controller: controller));
      await tester.pumpAndSettle();

      // SCR-12 공고 101 지원자 관리 화면 이동 (박지호 4번 회원 소유 공고)
      controller.push('/postings/101/applicants');
      await tester.pumpAndSettle();
      expect(find.text('지원 접수만 마감'), findsOneWidget);
      final announceBtnFinder = find.ancestor(
        of: find.textContaining('결과 발표하기 (미정'),
        matching: find.bySubtype<FilledButton>(),
      );
      expect(announceBtnFinder, findsOneWidget);
      final btn = tester.widget<FilledButton>(announceBtnFinder);
      expect(btn.onPressed, isNull);

      // SCR-14 결과 발표 화면에서 기본 불합격 안내 문구가 미리 채워져 있는지 확인
      controller.push('/postings/101/announce');
      await tester.pumpAndSettle();
      expect(find.text('불합격자 안내 메시지 (선택)'), findsOneWidget);
      expect(
        find.text('지원해 주셔서 감사합니다. 아쉽게도 이번 모집에서는 함께하지 못하게 되었습니다.'),
        findsOneWidget,
      );
    });
  });
}
