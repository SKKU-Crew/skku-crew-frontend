import 'dart:convert';

import '../../core/constants/codes.dart';
import '../../domain/models/api_models.dart';
import 'http_bridge.dart';
import 'local_seed_engine.dart';

/// skku-crew-backend의 32개 REST API 클라이언트.
/// 설정된 baseUrl(기본 http://localhost:8080)에 요청하고, 서버 미실행/네트워크 단절 시
/// LocalSeedEngine으로 자동 폴백하여 시연 및 오프라인 테스트를 보장합니다.
class SkkuApiClient {
  SkkuApiClient({
    String baseUrl = 'http://localhost:8080',
    this.forceFallbackOnly = false,
    LocalSeedEngine? fallbackEngine,
  })  : _baseUrl = _normalizeBaseUrl(baseUrl),
        _fallback = fallbackEngine ?? LocalSeedEngine();

  final LocalSeedEngine _fallback;
  final bool forceFallbackOnly;

  String _baseUrl;
  String? _accessToken;
  bool _isLiveBackend = false;
  int _idempotencySeq = 0;

  String get baseUrl => _baseUrl;
  String? get accessToken => _accessToken;
  bool get isLiveBackend => _isLiveBackend;
  LocalSeedEngine get fallbackEngine => _fallback;

  set baseUrl(String url) {
    _baseUrl = _normalizeBaseUrl(url);
  }

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  static String _normalizeBaseUrl(String raw) {
    var trimmed = raw.trim();
    while (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed.isEmpty ? 'http://localhost:8080' : trimmed;
  }

  String _nextIdempotencyKey() {
    _idempotencySeq++;
    return 'skku-${DateTime.now().microsecondsSinceEpoch}-$_idempotencySeq';
  }

  Future<bool> checkLiveConnection() async {
    if (forceFallbackOnly) {
      _isLiveBackend = false;
      return false;
    }
    try {
      final res = await sendHttpRequest(
        method: 'GET',
        url: '$_baseUrl/api/auth/demo-accounts',
        headers: _headers(),
      );
      _isLiveBackend = res.statusCode >= 200 && res.statusCode < 300;
      return _isLiveBackend;
    } catch (_) {
      _isLiveBackend = false;
      return false;
    }
  }

  Map<String, String> _headers({String? idempotencyKey}) {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
      headers['Idempotency-Key'] = idempotencyKey;
    }
    return headers;
  }

  Future<T> _request<T>({
    required String method,
    required String path,
    Map<String, dynamic>? queryMulti,
    Object? body,
    String? idempotencyKey,
    required T Function(dynamic decoded) parseLive,
    required T Function() onFallback,
  }) async {
    if (forceFallbackOnly) {
      _isLiveBackend = false;
      return onFallback();
    }

    final url = _buildUrl(path, queryMulti);
    try {
      final res = await sendHttpRequest(
        method: method,
        url: url,
        headers: _headers(idempotencyKey: idempotencyKey),
        body: body == null ? null : jsonEncode(body),
      );
      _isLiveBackend = true;
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded =
            res.body.trim().isEmpty ? null : jsonDecode(res.body);
        return parseLive(decoded);
      }
      final errMap = res.body.trim().isNotEmpty
          ? (jsonDecode(res.body) as Map<String, dynamic>)
          : <String, dynamic>{};
      throw ApiException.fromResponse(res.statusCode, errMap);
    } on ApiException {
      rethrow;
    } catch (_) {
      _isLiveBackend = false;
      return onFallback();
    }
  }

  String _buildUrl(String path, Map<String, dynamic>? queryMulti) {
    if (queryMulti == null || queryMulti.isEmpty) {
      return '$_baseUrl$path';
    }
    final parts = <String>[];
    queryMulti.forEach((key, value) {
      if (value == null) return;
      if (value is Iterable) {
        for (final item in value) {
          if (item != null) {
            parts.add(
                '${Uri.encodeQueryComponent(key)}=${Uri.encodeQueryComponent(item.toString())}');
          }
        }
      } else {
        final s = value.toString();
        if (s.isNotEmpty) {
          parts.add(
              '${Uri.encodeQueryComponent(key)}=${Uri.encodeQueryComponent(s)}');
        }
      }
    });
    if (parts.isEmpty) return '$_baseUrl$path';
    return '$_baseUrl$path?${parts.join('&')}';
  }

  // ---------------- 1. 인증 ----------------

  Future<List<DemoAccount>> getDemoAccounts() {
    return _request(
      method: 'GET',
      path: '/api/auth/demo-accounts',
      parseLive: (d) => (d as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(DemoAccount.fromJson)
          .toList(),
      onFallback: _fallback.demoAccounts,
    );
  }

  Future<LoginResponse> demoLogin(int memberId) async {
    final res = await _request(
      method: 'POST',
      path: '/api/auth/demo-login',
      body: {'memberId': memberId},
      parseLive: (d) => LoginResponse.fromJson(d as Map<String, dynamic>),
      onFallback: () => _fallback.demoLogin(memberId),
    );
    _accessToken = res.accessToken;
    return res;
  }

  Future<MeResponse> getMe() {
    return _request(
      method: 'GET',
      path: '/api/me',
      parseLive: (d) => MeResponse.fromJson(d as Map<String, dynamic>),
      onFallback: () => _fallback.me(_accessToken),
    );
  }

  // ---------------- 2. 프로필 ----------------

  Future<ProfileResponse> getMyProfile() {
    return _request(
      method: 'GET',
      path: '/api/profiles/me',
      parseLive: (d) => ProfileResponse.fromJson(d as Map<String, dynamic>),
      onFallback: () => _fallback.getMyProfile(_accessToken),
    );
  }

  Future<ProfileResponse> updateMyProfile(ProfileUpdateRequest req) {
    return _request(
      method: 'PUT',
      path: '/api/profiles/me',
      body: req.toJson(),
      parseLive: (d) => ProfileResponse.fromJson(d as Map<String, dynamic>),
      onFallback: () => _fallback.updateMyProfile(_accessToken, req),
    );
  }

  Future<ProfileResponse> setActivityHistoryVisible(
    int applicationId,
    bool visible,
  ) {
    return _request(
      method: 'PATCH',
      path: '/api/profiles/me/activity-history/$applicationId',
      body: {'visible': visible},
      parseLive: (d) => ProfileResponse.fromJson(d as Map<String, dynamic>),
      onFallback: () =>
          _fallback.setHistoryVisible(_accessToken, applicationId, visible),
    );
  }

  Future<List<String>> suggestSkills(String keyword, {int limit = 10}) {
    return _request(
      method: 'GET',
      path: '/api/skills',
      queryMulti: {'keyword': keyword, 'limit': limit},
      parseLive: (d) => (d as List<dynamic>).map((e) => e.toString()).toList(),
      onFallback: () => _fallback.skillSuggestions(keyword, limit: limit),
    );
  }

  // ---------------- 3. 공고 ----------------

  Future<PageResponse<PostingCard>> searchPostings({
    String? keyword,
    List<Category>? categories,
    List<Field>? fields,
    List<ActivityMode>? modes,
    MemberType? recruiterType,
    bool includeClosed = false,
    SortType sort = SortType.LATEST,
    int page = 0,
    int size = 20,
  }) {
    return _request(
      method: 'GET',
      path: '/api/postings',
      queryMulti: {
        'keyword': keyword,
        'category': categories?.map((e) => e.name).toList(),
        'field': fields?.map((e) => e.name).toList(),
        'mode': modes?.map((e) => e.name).toList(),
        'recruiterType': recruiterType?.name,
        'includeClosed': includeClosed,
        'sort': sort.name,
        'page': page,
        'size': size,
      },
      parseLive: (d) => PageResponse.fromJson(
        d as Map<String, dynamic>,
        PostingCard.fromJson,
      ),
      onFallback: () => _fallback.searchPostings(
        token: _accessToken,
        keyword: keyword,
        categories: categories,
        fields: fields,
        modes: modes,
        recruiterType: recruiterType,
        includeClosed: includeClosed,
        sort: sort,
        page: page,
        size: size,
      ),
    );
  }

  Future<HomeResponse> getHome() {
    return _request(
      method: 'GET',
      path: '/api/postings/home',
      parseLive: (d) => HomeResponse.fromJson(d as Map<String, dynamic>),
      onFallback: () => _fallback.home(_accessToken),
    );
  }

  Future<List<MyPostingItem>> getMyPostings({PostingStatus? status}) {
    return _request(
      method: 'GET',
      path: '/api/postings/mine',
      queryMulti: {'status': status?.name},
      parseLive: (d) => (d as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(MyPostingItem.fromJson)
          .toList(),
      onFallback: () => _fallback.myPostings(_accessToken, status: status),
    );
  }

  Future<PostingDetail> getPostingDetail(int postingId) {
    return _request(
      method: 'GET',
      path: '/api/postings/$postingId',
      parseLive: (d) => PostingDetail.fromJson(d as Map<String, dynamic>),
      onFallback: () => _fallback.postingDetail(_accessToken, postingId),
    );
  }

  Future<PostingDetail> createPosting(PostingCreateRequest req) {
    return _request(
      method: 'POST',
      path: '/api/postings',
      body: req.toJson(),
      parseLive: (d) => PostingDetail.fromJson(d as Map<String, dynamic>),
      onFallback: () => _fallback.createPosting(_accessToken, req),
    );
  }

  Future<PostingStatus> closePosting(int postingId) {
    return _request(
      method: 'POST',
      path: '/api/postings/$postingId/close',
      parseLive: (d) => PostingStatus.fromApi(
          (d as Map<String, dynamic>)['status']?.toString()),
      onFallback: () => _fallback.closePosting(_accessToken, postingId),
    );
  }

  // ---------------- 4. 지원 및 초안 ----------------

  Future<ApplicationForm> getApplicationForm(int postingId) {
    return _request(
      method: 'GET',
      path: '/api/postings/$postingId/application-form',
      parseLive: (d) => ApplicationForm.fromJson(d as Map<String, dynamic>),
      onFallback: () => _fallback.applicationForm(_accessToken, postingId),
    );
  }

  Future<ApplyResponse> submitApplication(
    int postingId,
    Map<String, dynamic> payload,
  ) {
    final idem = _nextIdempotencyKey();
    return _request(
      method: 'POST',
      path: '/api/postings/$postingId/applications',
      idempotencyKey: idem,
      body: payload,
      parseLive: (d) => ApplyResponse.fromJson(d as Map<String, dynamic>),
      onFallback: () => _fallback.apply(
        _accessToken,
        postingId,
        payload,
        idempotencyKey: idem,
      ),
    );
  }

  Future<List<MyApplicationItem>> getMyApplications() {
    return _request(
      method: 'GET',
      path: '/api/applications/me',
      parseLive: (d) => (d as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(MyApplicationItem.fromJson)
          .toList(),
      onFallback: () => _fallback.myApplications(_accessToken),
    );
  }

  Future<ApplicationDetail> getMyApplicationDetail(int applicationId) {
    return _request(
      method: 'GET',
      path: '/api/applications/$applicationId',
      parseLive: (d) =>
          ApplicationDetail.fromJson(d as Map<String, dynamic>),
      onFallback: () =>
          _fallback.myApplicationDetail(_accessToken, applicationId),
    );
  }

  Future<DisplayStatus> withdrawApplication(int applicationId) {
    return _request(
      method: 'POST',
      path: '/api/applications/$applicationId/withdraw',
      parseLive: (d) => DisplayStatus.fromApi(
          (d as Map<String, dynamic>)['displayStatus']?.toString()),
      onFallback: () =>
          _fallback.withdrawApplication(_accessToken, applicationId),
    );
  }

  Future<DraftResponse> getDraft(int postingId) {
    return _request(
      method: 'GET',
      path: '/api/postings/$postingId/application-draft',
      parseLive: (d) => DraftResponse.fromJson(d as Map<String, dynamic>),
      onFallback: () => _fallback.getDraft(_accessToken, postingId),
    );
  }

  Future<DraftResponse> saveDraft(
    int postingId,
    List<Map<String, dynamic>> answers, {
    DraftSource source = DraftSource.WEB,
  }) {
    return _request(
      method: 'PUT',
      path: '/api/postings/$postingId/application-draft',
      body: {'answers': answers, 'source': source.name},
      parseLive: (d) => DraftResponse.fromJson(d as Map<String, dynamic>),
      onFallback: () =>
          _fallback.saveDraft(_accessToken, postingId, answers, source: source),
    );
  }

  Future<DraftResponse> deleteDraft(int postingId) {
    return _request(
      method: 'DELETE',
      path: '/api/postings/$postingId/application-draft',
      parseLive: (d) => DraftResponse.fromJson(d as Map<String, dynamic>),
      onFallback: () => _fallback.deleteDraft(_accessToken, postingId),
    );
  }

  // ---------------- 5. 검토·선발 ----------------

  Future<List<ApplicantItem>> getApplicants(
    int postingId, {
    Decision? decision,
    ApplicantSort sort = ApplicantSort.SUBMITTED,
    String? keyword,
  }) {
    return _request(
      method: 'GET',
      path: '/api/postings/$postingId/applications',
      queryMulti: {
        'decision': decision?.name,
        'sort': sort.name,
        'keyword': keyword,
      },
      parseLive: (d) => (d as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(ApplicantItem.fromJson)
          .toList(),
      onFallback: () => _fallback.applicants(
        _accessToken,
        postingId,
        decision: decision,
        sort: sort,
        keyword: keyword,
      ),
    );
  }

  Future<ReviewDetail> getReviewDetail(int applicationId) {
    return _request(
      method: 'GET',
      path: '/api/applications/$applicationId/review',
      parseLive: (d) => ReviewDetail.fromJson(d as Map<String, dynamic>),
      onFallback: () =>
          _fallback.reviewApplication(_accessToken, applicationId),
    );
  }

  Future<DecisionResponse> decideApplication(
    int applicationId, {
    required Decision decision,
    String? memo,
  }) {
    return _request(
      method: 'PATCH',
      path: '/api/applications/$applicationId/decision',
      body: {'decision': decision.name, 'memo': memo},
      parseLive: (d) {
        final m = d as Map<String, dynamic>;
        return DecisionResponse(
          applicationId: (m['applicationId'] as num).toInt(),
          decision: Decision.fromApi(m['decision']?.toString()),
          memo: m['memo']?.toString(),
        );
      },
      onFallback: () => _fallback.decideApplication(
        _accessToken,
        applicationId,
        decision: decision,
        memo: memo,
      ),
    );
  }

  Future<AnnounceResponse> announcePosting(
    int postingId, {
    required String acceptMessage,
    String? rejectMessage,
  }) {
    return _request(
      method: 'POST',
      path: '/api/postings/$postingId/announce',
      body: {
        'acceptMessage': acceptMessage,
        'rejectMessage': rejectMessage,
      },
      parseLive: (d) => AnnounceResponse.fromJson(d as Map<String, dynamic>),
      onFallback: () => _fallback.announcePosting(
        _accessToken,
        postingId,
        acceptMessage: acceptMessage,
        rejectMessage: rejectMessage,
      ),
    );
  }

  Future<List<AcceptedContact>> getAcceptedContacts(int postingId) {
    return _request(
      method: 'GET',
      path: '/api/postings/$postingId/accepted-contacts',
      parseLive: (d) => (d as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(AcceptedContact.fromJson)
          .toList(),
      onFallback: () => _fallback.acceptedContacts(_accessToken, postingId),
    );
  }

  // ---------------- 6. 외부 활동 / 관심 / 조직 / 알림 / 초기화 ----------------

  Future<PageResponse<ExternalActivityItem>> searchExternalActivities({
    String? keyword,
    ExternalType? type,
    List<Field>? fields,
    String? source,
    SortType sort = SortType.DEADLINE,
    int page = 0,
    int size = 20,
  }) {
    return _request(
      method: 'GET',
      path: '/api/external-activities',
      queryMulti: {
        'keyword': keyword,
        'type': type?.name,
        'field': fields?.map((e) => e.name).toList(),
        'source': source,
        'sort': sort.name,
        'page': page,
        'size': size,
      },
      parseLive: (d) => PageResponse.fromJson(
        d as Map<String, dynamic>,
        ExternalActivityItem.fromJson,
      ),
      onFallback: () => _fallback.searchExternalActivities(
        token: _accessToken,
        keyword: keyword,
        type: type,
        fields: fields,
        source: source,
        sort: sort,
        page: page,
        size: size,
      ),
    );
  }

  Future<BookmarkList> getBookmarks() {
    return _request(
      method: 'GET',
      path: '/api/bookmarks',
      parseLive: (d) => BookmarkList.fromJson(d as Map<String, dynamic>),
      onFallback: () => _fallback.listBookmarks(_accessToken),
    );
  }

  Future<bool> addBookmark(BookmarkTarget targetType, int targetId) {
    return _request(
      method: 'POST',
      path: '/api/bookmarks',
      body: {'targetType': targetType.name, 'targetId': targetId},
      parseLive: (d) => (d as Map<String, dynamic>)['bookmarked'] == true,
      onFallback: () =>
          _fallback.addBookmark(_accessToken, targetType, targetId),
    );
  }

  Future<bool> removeBookmark(BookmarkTarget targetType, int targetId) {
    return _request(
      method: 'DELETE',
      path: '/api/bookmarks/${targetType.name}/$targetId',
      parseLive: (d) => (d as Map<String, dynamic>)['bookmarked'] == true,
      onFallback: () =>
          _fallback.removeBookmark(_accessToken, targetType, targetId),
    );
  }

  Future<OrgPage> getOrgPage(int orgId) {
    return _request(
      method: 'GET',
      path: '/api/organizations/$orgId',
      parseLive: (d) => OrgPage.fromJson(d as Map<String, dynamic>),
      onFallback: () => _fallback.orgPage(_accessToken, orgId),
    );
  }

  Future<FollowResponse> followOrg(int orgId) {
    return _request(
      method: 'POST',
      path: '/api/organizations/$orgId/follow',
      parseLive: (d) {
        final m = d as Map<String, dynamic>;
        return FollowResponse(
          orgId: (m['orgId'] as num).toInt(),
          followed: m['followed'] == true,
          followerCount: (m['followerCount'] as num?)?.toInt() ?? 0,
        );
      },
      onFallback: () => _fallback.followOrg(_accessToken, orgId),
    );
  }

  Future<FollowResponse> unfollowOrg(int orgId) {
    return _request(
      method: 'DELETE',
      path: '/api/organizations/$orgId/follow',
      parseLive: (d) {
        final m = d as Map<String, dynamic>;
        return FollowResponse(
          orgId: (m['orgId'] as num).toInt(),
          followed: m['followed'] == true,
          followerCount: (m['followerCount'] as num?)?.toInt() ?? 0,
        );
      },
      onFallback: () => _fallback.unfollowOrg(_accessToken, orgId),
    );
  }

  Future<NotificationList> getNotifications({bool unreadOnly = false}) {
    return _request(
      method: 'GET',
      path: '/api/notifications',
      queryMulti: {'unreadOnly': unreadOnly},
      parseLive: (d) => NotificationList.fromJson(d as Map<String, dynamic>),
      onFallback: () =>
          _fallback.listNotifications(_accessToken, unreadOnly: unreadOnly),
    );
  }

  Future<int> getUnreadCount() {
    return _request(
      method: 'GET',
      path: '/api/notifications/unread-count',
      parseLive: (d) =>
          ((d as Map<String, dynamic>)['unreadCount'] as num?)?.toInt() ?? 0,
      onFallback: () => _fallback.unreadCount(_accessToken),
    );
  }

  Future<NotificationItem> markNotificationRead(int notificationId) {
    return _request(
      method: 'POST',
      path: '/api/notifications/$notificationId/read',
      parseLive: (d) => NotificationItem.fromJson(d as Map<String, dynamic>),
      onFallback: () =>
          _fallback.markNotificationRead(_accessToken, notificationId),
    );
  }

  Future<int> markAllNotificationsRead() {
    return _request(
      method: 'POST',
      path: '/api/notifications/read-all',
      parseLive: (d) =>
          ((d as Map<String, dynamic>)['unreadCount'] as num?)?.toInt() ?? 0,
      onFallback: () => _fallback.markAllNotificationsRead(_accessToken),
    );
  }

  Future<void> resetDevData() {
    return _request<void>(
      method: 'POST',
      path: '/api/dev/reset',
      parseLive: (_) {},
      onFallback: _fallback.reset,
    );
  }
}
