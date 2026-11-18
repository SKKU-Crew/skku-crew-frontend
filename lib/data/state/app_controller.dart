import 'package:flutter/foundation.dart' hide Category;

import '../../core/constants/codes.dart';
import '../../domain/models/api_models.dart';
import '../services/skku_api_client.dart';

/// 앱 전역 상태(인증 세션, 라우팅, 알림 배지, 시연 모드, 정적 보조 기능 상태)를 관리합니다.
class AppController extends ChangeNotifier {
  AppController({SkkuApiClient? apiClient})
      : api = apiClient ?? SkkuApiClient();

  final SkkuApiClient api;

  bool _initialized = false;
  bool get initialized => _initialized;

  MeResponse? _currentUser;
  MeResponse? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  List<DemoAccount> _demoAccounts = const [];
  List<DemoAccount> get demoAccounts => _demoAccounts;

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  bool _mobileFrameMode = false;
  bool get mobileFrameMode => _mobileFrameMode;

  bool _showDemoBar = true;
  bool get showDemoBar => _showDemoBar;

  int _dataVersion = 0;
  int get dataVersion => _dataVersion;

  final List<String> _history = ['/'];
  String get currentPath => _history.last;
  bool get canGoBack => _history.length > 1;

  // 화면 간 파라미터 전달용 상태
  List<Category> pendingExploreCategories = const [];
  String? pendingExploreKeyword;
  Decision? pendingApplicantFilter;
  int? highlightApplicationId;
  int initialMyActivitiesTab = 0;
  PostingCreateRequest? duplicatePostingSource;

  // 최근 검색어 (FR-SRCH-09: 최대 10개)
  final List<String> recentSearches = ['데이터', 'Flutter', '공모전'];

  // 백엔드 데모에 없는 정적 UI/보조 기능 상태 (docs/FRONTEND.md 5절 안내 기반)
  final List<QuestionTemplateItem> questionTemplates = [
    const QuestionTemplateItem(
      id: 1,
      name: '동아리/학회 기본 질문 세트',
      questions: [
        QuestionInput(
          type: QuestionType.LONG_TEXT,
          content: '지원 동기를 적어 주세요.',
          required: true,
          maxLength: 500,
        ),
        QuestionInput(
          type: QuestionType.SINGLE_CHOICE,
          content: '주 1회 정기 세션 참석이 가능한가요?',
          required: true,
          options: ['가능', '어려움'],
        ),
      ],
    ),
    const QuestionTemplateItem(
      id: 2,
      name: '프로젝트 팀원 모집 질문 세트',
      questions: [
        QuestionInput(
          type: QuestionType.LONG_TEXT,
          content: '관련 프로젝트 경험이나 맡고 싶은 역할을 적어 주세요.',
          required: true,
          maxLength: 500,
        ),
        QuestionInput(
          type: QuestionType.SHORT_TEXT,
          content: '주간 투입 가능 시간을 적어 주세요.',
          required: false,
          maxLength: 100,
        ),
      ],
    ),
  ];

  // 알림 푸시 설정 (FR-NOTI-04)
  final Map<NotificationType, bool> pushSettings = {
    NotificationType.NEW_APPLICATION: true,
    NotificationType.POSTING_CLOSED: true,
    NotificationType.RESULT_ANNOUNCED: true,
    NotificationType.BOOKMARK_CLOSING_SOON: true,
    NotificationType.FOLLOWED_ORG_NEW_POSTING: false,
  };

  // MCP AI 연결 상태 (SCR-20, SCR-21)
  bool mcpConnected = true;
  bool mcpAllowBookmark = true;
  bool mcpAllowDraft = true;
  DateTime mcpConnectedAt = DateTime.now().subtract(const Duration(days: 15));
  DateTime mcpLastUsedAt = DateTime.now().subtract(const Duration(minutes: 12));

  // 관리자 콘솔 정적 시뮬레이션 데이터 (SCR-19)
  final List<AdminVerificationItem> adminVerifications = [
    AdminVerificationItem(
      id: 1,
      orgName: '창업 동아리 런치패드',
      orgType: '동아리',
      loginId: 'launchpad_skku',
      contactEmail: 'launchpad@example.com',
      submittedAt: DateTime.now().subtract(const Duration(hours: 6)),
      status: '재신청',
      urls: ['https://instagram.com/launchpad_skku'],
      isNameChange: false,
    ),
    AdminVerificationItem(
      id: 2,
      orgName: '지능형 시스템 연구실',
      orgType: '연구실',
      loginId: 'isys_lab',
      contactEmail: 'isys@skku.edu',
      submittedAt: DateTime.now().subtract(const Duration(days: 1)),
      status: '인증 대기',
      urls: ['https://cs.skku.edu/isyslab'],
      isNameChange: false,
    ),
    AdminVerificationItem(
      id: 3,
      orgName: '성균 밴드 동아리 소리샘',
      orgType: '동아리',
      loginId: 'sorisem_band',
      contactEmail: 'sorisem@example.com',
      submittedAt: DateTime.now().subtract(const Duration(days: 2)),
      status: '인증 대기',
      urls: ['https://instagram.com/skku_sorisem'],
      isNameChange: false,
    ),
  ];

  final List<AdminReportItem> adminReports = [
    AdminReportItem(
      id: 1,
      postingId: 121,
      postingTitle: '교내 데이터 분석 경진대회 함께 나갈 팀원',
      recruiterName: '윤서아',
      reportCount: 3,
      reason: '부적절한 내용',
      detail: '외부 상업 링크가 포함되어 있다는 신고가 3건 누적되었습니다.',
      hidden: false,
    ),
    AdminReportItem(
      id: 2,
      postingId: 116,
      postingTitle: '교내 동아리 홍보 영상 제작 팀',
      recruiterName: '윤서아',
      reportCount: 1,
      reason: '광고·스팸',
      detail: '보상 기준이 모호하다는 문의가 접수되었습니다.',
      hidden: false,
    ),
  ];

  final List<String> adminAuditLogs = [
    '[승인] 데이터 분석 학회 D:LAB 단체 인증 승인 (운영자)',
    '[승인] 로봇 학회 R:BOT 단체 인증 승인 (운영자)',
  ];

  Future<void> init({int initialMemberId = 1}) async {
    await api.checkLiveConnection();
    _demoAccounts = await api.getDemoAccounts();
    await loginAs(initialMemberId, navigateToDefault: false);
    _initialized = true;
    notifyListeners();
  }

  Future<void> loginAs(
    int memberId, {
    bool navigateToDefault = true,
  }) async {
    final res = await api.demoLogin(memberId);
    _currentUser = res.member;
    await refreshUnreadCount();
    _dataVersion++;
    if (navigateToDefault) {
      if (_currentUser?.memberType == MemberType.ORGANIZATION) {
        go('/org/dashboard');
      } else if (_currentUser?.memberType == MemberType.ADMIN) {
        go('/admin/verifications');
      } else {
        go('/');
      }
    } else {
      notifyListeners();
    }
  }

  void logout() {
    api.setAccessToken(null);
    _currentUser = null;
    _unreadCount = 0;
    _dataVersion++;
    go('/login');
  }

  Future<void> refreshMe() async {
    if (!isLoggedIn) return;
    _currentUser = await api.getMe();
    await refreshUnreadCount();
    notifyListeners();
  }

  Future<void> refreshUnreadCount() async {
    if (!isLoggedIn) {
      _unreadCount = 0;
      notifyListeners();
      return;
    }
    try {
      _unreadCount = await api.getUnreadCount();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> resetDemoData() async {
    final currentId = _currentUser?.memberId ?? 1;
    await api.resetDevData();
    await loginAs(currentId, navigateToDefault: false);
    _dataVersion++;
    notifyListeners();
  }

  Future<bool> updateBaseUrl(String newUrl) async {
    api.baseUrl = newUrl;
    final ok = await api.checkLiveConnection();
    if (ok && _currentUser != null) {
      try {
        _demoAccounts = await api.getDemoAccounts();
        await loginAs(_currentUser!.memberId, navigateToDefault: false);
      } catch (_) {}
    }
    _dataVersion++;
    notifyListeners();
    return ok;
  }

  void bumpDataVersion() {
    _dataVersion++;
    notifyListeners();
  }

  void toggleMobileFrameMode() {
    _mobileFrameMode = !_mobileFrameMode;
    notifyListeners();
  }

  void toggleDemoBar() {
    _showDemoBar = !_showDemoBar;
    notifyListeners();
  }

  void addRecentSearch(String keyword) {
    final k = keyword.trim();
    if (k.length < 2) return;
    recentSearches.remove(k);
    recentSearches.insert(0, k);
    if (recentSearches.length > 10) {
      recentSearches.removeRange(10, recentSearches.length);
    }
    notifyListeners();
  }

  void removeRecentSearch(String keyword) {
    recentSearches.remove(keyword);
    notifyListeners();
  }

  void clearRecentSearches() {
    recentSearches.clear();
    notifyListeners();
  }

  // ---------------- 선언형 URL 라우팅 ----------------

  void openExploreWithKeyword(String keyword) {
    final trimmed = keyword.trim();
    if (trimmed.isNotEmpty && trimmed.length < 2) {
      return;
    }
    pendingExploreKeyword = trimmed;
    _dataVersion++;
    go('/explore');
  }

  void go(String path) {
    _history
      ..clear()
      ..add(path);
    notifyListeners();
  }

  void push(String path) {
    if (_history.last == path) return;
    _history.add(path);
    notifyListeners();
  }

  void pop() {
    if (_history.length > 1) {
      _history.removeLast();
      notifyListeners();
    } else {
      go(defaultHomePath);
    }
  }

  String get defaultHomePath {
    if (_currentUser?.memberType == MemberType.ORGANIZATION) {
      return '/org/dashboard';
    }
    if (_currentUser?.memberType == MemberType.ADMIN) {
      return '/admin/verifications';
    }
    return '/';
  }

  void navigateFromNotification(NotificationItem item) {
    final screen = item.targetScreen;
    if (screen == 'SCR-12' && item.postingId != null) {
      push('/postings/${item.postingId}/applicants');
    } else if (screen == 'SCR-08') {
      initialMyActivitiesTab = 0;
      highlightApplicationId = item.applicationId;
      go('/me/applications');
    } else if (screen == 'SCR-06' && item.postingId != null) {
      push('/postings/${item.postingId}');
    } else if (screen == 'SCR-15') {
      go('/org/dashboard');
    } else {
      go(defaultHomePath);
    }
  }
}

class QuestionTemplateItem {
  const QuestionTemplateItem({
    required this.id,
    required this.name,
    required this.questions,
  });

  final int id;
  final String name;
  final List<QuestionInput> questions;
}

class AdminVerificationItem {
  AdminVerificationItem({
    required this.id,
    required this.orgName,
    required this.orgType,
    required this.loginId,
    required this.contactEmail,
    required this.submittedAt,
    required this.status,
    required this.urls,
    required this.isNameChange,
    this.rejectReason,
  });

  final int id;
  final String orgName;
  final String orgType;
  final String loginId;
  final String contactEmail;
  final DateTime submittedAt;
  String status;
  final List<String> urls;
  final bool isNameChange;
  String? rejectReason;
}

class AdminReportItem {
  AdminReportItem({
    required this.id,
    required this.postingId,
    required this.postingTitle,
    required this.recruiterName,
    required this.reportCount,
    required this.reason,
    required this.detail,
    required this.hidden,
  });

  final int id;
  final int postingId;
  final String postingTitle;
  final String recruiterName;
  final int reportCount;
  final String reason;
  final String detail;
  bool hidden;
  bool resolved = false;
}
