// ignore_for_file: constant_identifier_names

/// 백엔드 Codes.java와 1:1로 대응하는 열거형 및 FRONTEND.md 기준 화면 표기 매핑.
library;

enum MemberType {
  PERSONAL('개인회원'),
  ORGANIZATION('단체회원'),
  ADMIN('관리자');

  const MemberType(this.label);
  final String label;

  static MemberType fromApi(String? value) => MemberType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => MemberType.PERSONAL,
      );
}

enum Category {
  PROJECT('프로젝트'),
  RESEARCH('연구'),
  CONTEST('공모전'),
  STUDY('스터디'),
  CLUB('동아리·학회');

  const Category(this.label);
  final String label;

  static Category fromApi(String? value) => Category.values.firstWhere(
        (e) => e.name == value,
        orElse: () => Category.PROJECT,
      );

  /// BR-01: 개인회원이 게시 가능한 카테고리
  static const List<Category> personalAllowed = [PROJECT, CONTEST, STUDY];
}

enum Field {
  DEV('개발'),
  AI('AI'),
  DATA('데이터'),
  FINANCE('금융'),
  DESIGN('디자인'),
  PLANNING_MARKETING('기획·마케팅'),
  ETC('기타');

  const Field(this.label);
  final String label;

  static Field fromApi(String? value) => Field.values.firstWhere(
        (e) => e.name == value,
        orElse: () => Field.ETC,
      );
}

enum ActivityMode {
  ONLINE('온라인'),
  OFFLINE('오프라인'),
  HYBRID('온·오프라인 병행');

  const ActivityMode(this.label);
  final String label;

  static ActivityMode fromApi(String? value) => ActivityMode.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ActivityMode.ONLINE,
      );
}

enum AcademicStatus {
  GRADE_1('학부 1학년'),
  GRADE_2('학부 2학년'),
  GRADE_3('학부 3학년'),
  GRADE_4('학부 4학년'),
  GRADE_5_PLUS('5학년 이상'),
  LEAVE('휴학'),
  DEFERRED('졸업유예'),
  MASTER('대학원 석사'),
  PHD('대학원 박사'),
  OTHER('기타(교직원·연구원)');

  const AcademicStatus(this.label);
  final String label;

  String get shortLabel {
    switch (this) {
      case AcademicStatus.GRADE_1:
        return '1학년';
      case AcademicStatus.GRADE_2:
        return '2학년';
      case AcademicStatus.GRADE_3:
        return '3학년';
      case AcademicStatus.GRADE_4:
        return '4학년';
      case AcademicStatus.GRADE_5_PLUS:
        return '5학년 이상';
      case AcademicStatus.LEAVE:
        return '휴학';
      case AcademicStatus.DEFERRED:
        return '졸업유예';
      case AcademicStatus.MASTER:
        return '석사';
      case AcademicStatus.PHD:
        return '박사';
      case AcademicStatus.OTHER:
        return '기타';
    }
  }

  static AcademicStatus fromApi(String? value) => AcademicStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => AcademicStatus.GRADE_1,
      );
}

enum SkillLevel {
  HIGH('상'),
  MID('중'),
  LOW('하');

  const SkillLevel(this.label);
  final String label;

  static SkillLevel fromApi(String? value) => SkillLevel.values.firstWhere(
        (e) => e.name == value,
        orElse: () => SkillLevel.MID,
      );
}

enum ExperienceType {
  PROJECT('프로젝트'),
  EXTRACURRICULAR('대외활동'),
  AWARD('수상'),
  CAREER('경력'),
  ETC('기타');

  const ExperienceType(this.label);
  final String label;

  static ExperienceType fromApi(String? value) => ExperienceType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ExperienceType.PROJECT,
      );
}

enum ContactType {
  SCHOOL_EMAIL('학교 이메일'),
  PHONE('전화번호'),
  KAKAO_ID('카카오톡 ID'),
  PERSONAL_EMAIL('개인 이메일');

  const ContactType(this.label);
  final String label;

  static ContactType fromApi(String? value) => ContactType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ContactType.SCHOOL_EMAIL,
      );
}

enum PostingStatus {
  DRAFT('임시저장'),
  OPEN('모집중'),
  CLOSED('마감'),
  ANNOUNCED('발표 완료'),
  HIDDEN('숨김');

  const PostingStatus(this.label);
  final String label;

  static PostingStatus fromApi(String? value) => PostingStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => PostingStatus.OPEN,
      );
}

enum QuestionType {
  SHORT_TEXT('단답형'),
  LONG_TEXT('장문형'),
  SINGLE_CHOICE('단일 선택'),
  MULTI_CHOICE('복수 선택');

  const QuestionType(this.label);
  final String label;

  static QuestionType fromApi(String? value) => QuestionType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => QuestionType.SHORT_TEXT,
      );
}

enum Decision {
  PENDING('미정'),
  ACCEPTED('합격'),
  REJECTED('불합격');

  const Decision(this.label);
  final String label;

  static Decision fromApi(String? value) => Decision.values.firstWhere(
        (e) => e.name == value,
        orElse: () => Decision.PENDING,
      );
}

enum DisplayStatus {
  SUBMITTED('제출 완료'),
  UNDER_REVIEW('심사 중'),
  ACCEPTED('합격'),
  REJECTED('불합격'),
  WITHDRAWN('지원 취소');

  const DisplayStatus(this.label);
  final String label;

  static DisplayStatus fromApi(String? value) => DisplayStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => DisplayStatus.SUBMITTED,
      );
}

enum ViewerAction {
  APPLY,
  APPLIED,
  CLOSED,
  OWNER,
  NOT_ALLOWED,
  LOGIN_REQUIRED;

  static ViewerAction fromApi(String? value) => ViewerAction.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ViewerAction.APPLY,
      );
}

enum ExternalType {
  CONTEST('공모전·대회'),
  INTERN_JOB('인턴·채용'),
  EDUCATION('교육·부트캠프'),
  EXTRACURRICULAR('대외활동'),
  RESEARCH_PROGRAM('연구 프로그램'),
  ETC('기타');

  const ExternalType(this.label);
  final String label;

  static ExternalType fromApi(String? value) => ExternalType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ExternalType.ETC,
      );
}

enum SortType {
  LATEST('최신순'),
  DEADLINE('마감 임박순');

  const SortType(this.label);
  final String label;
}

enum BookmarkTarget {
  POSTING,
  EXTERNAL_ACTIVITY;

  static BookmarkTarget fromApi(String? value) =>
      BookmarkTarget.values.firstWhere(
        (e) => e.name == value,
        orElse: () => BookmarkTarget.POSTING,
      );
}

enum NotificationType {
  NEW_APPLICATION('새 지원서'),
  POSTING_CLOSED('모집 마감'),
  RESULT_ANNOUNCED('결과 발표'),
  BOOKMARK_CLOSING_SOON('마감 임박'),
  FOLLOWED_ORG_NEW_POSTING('관심 조직');

  const NotificationType(this.label);
  final String label;

  static NotificationType fromApi(String? value) =>
      NotificationType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => NotificationType.NEW_APPLICATION,
      );
}

enum ApplicantSort {
  SUBMITTED('제출순'),
  NAME('이름순');

  const ApplicantSort(this.label);
  final String label;
}

enum DraftSource {
  WEB('웹 임시저장'),
  MCP('AI 초안');

  const DraftSource(this.label);
  final String label;

  static DraftSource? fromApiNullable(String? value) {
    if (value == null) return null;
    for (final e in DraftSource.values) {
      if (e.name == value) return e;
    }
    return null;
  }
}

class DomainConstants {
  const DomainConstants._();

  static const List<String> skkuDepartments = [
    '소프트웨어학과',
    '데이터사이언스융합전공',
    '통계학과',
    '경영학과',
    '경제학과',
    '글로벌경제학과',
    '글로벌경영학과',
    '전자전기공학부',
    '컴퓨터교육과',
    '디자인학과',
    '수학과',
    '산업공학과',
    '시스템경영공학과',
    '컬처앤테크놀로지융합전공',
    '인공지능융합전공',
    '미디어커뮤니케이션학과',
    '기타(학과 외 소속)',
  ];

  static const List<String> orgTypes = [
    '동아리',
    '학회',
    '연구실',
    '기타',
  ];

  static String externalSourceLabel(String source) {
    switch (source) {
      case 'SKKU_NOTICE':
        return '성대 공지';
      case 'PUBLIC_API':
        return '공공기관';
      default:
        return source;
    }
  }
}
