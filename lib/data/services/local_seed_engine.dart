import 'dart:convert';

import '../../core/constants/codes.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models/api_models.dart';
import 'seed_json_data.dart';

/// skku-crew-backend의 DataStore + Service 로직을 그대로 구현한 로컬 시드 폴백 엔진.
/// 백엔드 서버가 꺼져 있을 때도 모든 32개 API와 동일한 시연 시나리오가 동작하도록 합니다.
class LocalSeedEngine {
  LocalSeedEngine() {
    reset();
  }

  final Map<int, _MemberRecord> _members = {};
  final Map<int, _ProfileRecord> _profiles = {};
  final Map<int, _PostingRecord> _postings = {};
  final Map<int, _ApplicationRecord> _applications = {};
  final List<_ExternalActivityRecord> _externalActivities = [];
  final Map<String, _BookmarkRecord> _bookmarks = {};
  final Map<int, _NotificationRecord> _notifications = {};
  final Map<String, _DraftRecord> _drafts = {};
  final Set<String> _follows = {};
  final Set<String> _closingSoonNotified = {};
  final Map<String, int> _idempotencyKeys = {};

  int _postingSeq = 1000;
  int _questionSeq = 10000;
  int _applicationSeq = 5000;
  int _itemSeq = 100000;
  int _notificationSeq = 20000;

  static const String _defaultRejectMessage =
      '지원해 주셔서 감사합니다. 아쉽게도 이번 모집에서는 함께하지 못하게 되었습니다.';

  static const List<String> _baseSkills = [
    'Java',
    'Kotlin',
    'Python',
    'C',
    'C++',
    'C#',
    'JavaScript',
    'TypeScript',
    'Go',
    'Rust',
    'Swift',
    'Dart',
    'Spring Boot',
    'Django',
    'FastAPI',
    'Flask',
    'Node.js',
    'Express',
    'NestJS',
    'React',
    'Vue.js',
    'Next.js',
    'Flutter',
    'React Native',
    'Android',
    'iOS',
    'MySQL',
    'PostgreSQL',
    'MongoDB',
    'Redis',
    'SQL',
    'AWS',
    'Docker',
    'Kubernetes',
    'Git',
    'Linux',
    'Pandas',
    'NumPy',
    'scikit-learn',
    'PyTorch',
    'TensorFlow',
    'OpenCV',
    'R',
    'Tableau',
    'Power BI',
    'Excel',
    'Figma',
    'Photoshop',
    'Illustrator',
    'Premiere Pro',
    'Notion',
    'Canva',
    'ROS',
    'Unity',
    'Streamlit',
  ];

  void reset() {
    _members.clear();
    _profiles.clear();
    _postings.clear();
    _applications.clear();
    _externalActivities.clear();
    _bookmarks.clear();
    _notifications.clear();
    _drafts.clear();
    _follows.clear();
    _closingSoonNotified.clear();
    _idempotencyKeys.clear();

    final now = DateTime.now();

    final membersList =
        jsonDecode(SeedJsonData.membersJson) as List<dynamic>;
    for (final raw in membersList) {
      final m = _MemberRecord.fromJson(raw as Map<String, dynamic>);
      _members[m.id] = m;
    }

    final profilesList =
        jsonDecode(SeedJsonData.profilesJson) as List<dynamic>;
    for (final raw in profilesList) {
      final p = _ProfileRecord.fromJson(raw as Map<String, dynamic>);
      _profiles[p.memberId] = p;
    }

    final postingsList =
        jsonDecode(SeedJsonData.postingsJson) as List<dynamic>;
    for (final raw in postingsList) {
      final p = _PostingRecord.fromJson(raw as Map<String, dynamic>, now);
      _postings[p.id] = p;
    }

    final appsList =
        jsonDecode(SeedJsonData.applicationsJson) as List<dynamic>;
    for (final raw in appsList) {
      final a = _ApplicationRecord.fromJson(
        raw as Map<String, dynamic>,
        now,
        _postings,
      );
      _applications[a.id] = a;
    }

    for (final pr in _profiles.values) {
      for (final h in pr.activityHistory) {
        final p = _postings[h.postingId];
        if (h.announcedAt == null && p != null) {
          h.announcedAt = p.announcedAt;
        }
      }
    }

    final extList =
        jsonDecode(SeedJsonData.externalActivitiesJson) as List<dynamic>;
    for (final raw in extList) {
      _externalActivities.add(
        _ExternalActivityRecord.fromJson(raw as Map<String, dynamic>, now),
      );
    }

    final bmList = jsonDecode(SeedJsonData.bookmarksJson) as List<dynamic>;
    for (final raw in bmList) {
      final b = _BookmarkRecord.fromJson(raw as Map<String, dynamic>, now);
      _bookmarks[b.key] = b;
    }

    final notiList =
        jsonDecode(SeedJsonData.notificationsJson) as List<dynamic>;
    for (final raw in notiList) {
      final n =
          _NotificationRecord.fromJson(raw as Map<String, dynamic>, now);
      _notifications[n.id] = n;
      if (n.type == NotificationType.BOOKMARK_CLOSING_SOON &&
          n.postingId != null) {
        _closingSoonNotified.add('${n.memberId}:${n.postingId}');
      }
    }

    final followList = jsonDecode(SeedJsonData.followsJson) as List<dynamic>;
    for (final raw in followList) {
      final map = raw as Map<String, dynamic>;
      _follows.add('${map['memberId']}:${map['orgId']}');
    }

    final draftList = jsonDecode(SeedJsonData.draftsJson) as List<dynamic>;
    for (final raw in draftList) {
      final d = _DraftRecord.fromJson(raw as Map<String, dynamic>, now);
      _drafts[d.key] = d;
    }

    _postingSeq = _postings.keys.fold(1000, (a, b) => a > b ? a : b);
    _applicationSeq =
        _applications.keys.fold(5000, (a, b) => a > b ? a : b);
    var maxQ = 10000;
    for (final p in _postings.values) {
      for (final q in p.questions) {
        if (q.id > maxQ) maxQ = q.id;
      }
    }
    _questionSeq = maxQ;
    _notificationSeq =
        _notifications.keys.fold(20000, (a, b) => a > b ? a : b);
  }

  // ---------------- 인증 ----------------

  List<DemoAccount> demoAccounts() {
    final list = _members.values.toList()..sort((a, b) => a.id.compareTo(b.id));
    return list
        .map(
          (m) => DemoAccount(
            memberId: m.id,
            name: m.name,
            memberType: m.type,
            description: m.demoDescription,
          ),
        )
        .toList();
  }

  LoginResponse demoLogin(int memberId) {
    final m = _members[memberId];
    if (m == null) {
      throw const ApiException(
        statusCode: 404,
        code: 'NOT_FOUND',
        message: '회원을 찾을 수 없습니다.',
      );
    }
    return LoginResponse(
      accessToken: 'demo-${m.id}',
      member: _toMe(m),
    );
  }

  MeResponse me(String? token) {
    final m = _requireMember(token);
    return _toMe(m);
  }

  MeResponse _toMe(_MemberRecord m) {
    final p = _profiles[m.id];
    return MeResponse(
      memberId: m.id,
      name: m.name,
      memberType: m.type,
      schoolEmail: m.schoolEmail,
      profileCompleted: p?.isRequiredFilled,
      profileCompleteness: p?.completeness,
    );
  }

  // ---------------- 프로필 ----------------

  ProfileResponse getMyProfile(String? token) {
    final m = _requirePersonal(token);
    final p = _profileOf(m.id);
    return _toProfileResponse(m, p);
  }

  ProfileResponse updateMyProfile(String? token, ProfileUpdateRequest req) {
    final m = _requirePersonal(token);
    final errors = <FieldErrorItem>[];
    if (req.name.length < 2 || req.name.length > 20) {
      errors.add(const FieldErrorItem(
          field: 'name', message: '이름은 2~20자입니다.'));
    }
    if (req.fields.length > 5) {
      errors.add(const FieldErrorItem(
          field: 'fields', message: '관심 분야는 최대 5개입니다.'));
    }
    if (req.bio != null && req.bio!.length > 50) {
      errors.add(const FieldErrorItem(
          field: 'bio', message: '한 줄 소개는 50자 이하입니다.'));
    }
    final phoneErr = AppValidators.validatePhone(req.contacts.phone);
    if (phoneErr != null) {
      errors.add(FieldErrorItem(field: 'contacts.phone', message: phoneErr));
    }
    final kakaoErr = AppValidators.validateKakaoId(req.contacts.kakaoId);
    if (kakaoErr != null) {
      errors
          .add(FieldErrorItem(field: 'contacts.kakaoId', message: kakaoErr));
    }
    final emailErr = AppValidators.validateEmail(req.contacts.personalEmail);
    if (emailErr != null) {
      errors.add(
          FieldErrorItem(field: 'contacts.personalEmail', message: emailErr));
    }
    if (errors.isNotEmpty) {
      throw ApiException(
        statusCode: 400,
        code: 'VALIDATION_FAILED',
        message: '입력값을 확인해 주세요.',
        fieldErrors: errors,
      );
    }

    final p = _profileOf(m.id);
    m.name = req.name;
    p.profileImageUrl = req.profileImageUrl;
    p.majorPrimary = req.majorPrimary;
    p.majorsSecondary = List<String>.from(req.majorsSecondary);
    p.academicStatus = req.academicStatus;
    p.bio = req.bio;
    p.fields = List<Field>.from(req.fields);
    p.skills = req.skills
        .map((s) => _SkillRecord(
              id: s.id ?? ++_itemSeq,
              name: s.name,
              level: s.level,
            ))
        .toList();
    p.experiences = req.experiences
        .map((e) => _ExperienceRecord(
              id: e.id ?? ++_itemSeq,
              type: e.type,
              title: e.title,
              role: e.role,
              startDate: e.startDate,
              endDate: e.endDate,
              description: e.description,
            ))
        .toList();
    p.portfolioLinks = req.portfolioLinks
        .map((l) => _PortfolioLinkRecord(
              id: l.id ?? ++_itemSeq,
              title: l.title,
              url: l.url,
            ))
        .toList();
    p.portfolioFiles = req.portfolioFiles
        .map((f) => _PortfolioFileRecord(
              id: f.id ?? ++_itemSeq,
              fileName: f.fileName,
              url: f.url,
            ))
        .toList();
    p.contacts = _ContactsRecord(
      phone: req.contacts.phone,
      kakaoId: req.contacts.kakaoId,
      personalEmail: req.contacts.personalEmail,
    );
    p.defaultShare = Map<String, bool>.from(req.defaultShare);
    return _toProfileResponse(m, p);
  }

  ProfileResponse setHistoryVisible(
    String? token,
    int applicationId,
    bool visible,
  ) {
    final m = _requirePersonal(token);
    final p = _profileOf(m.id);
    final idx = p.activityHistory
        .indexWhere((element) => element.applicationId == applicationId);
    if (idx < 0) {
      throw const ApiException(
        statusCode: 404,
        code: 'NOT_FOUND',
        message: '활동 이력을 찾을 수 없습니다.',
      );
    }
    p.activityHistory[idx].visible = visible;
    return _toProfileResponse(m, p);
  }

  List<String> skillSuggestions(String? keyword, {int limit = 10}) {
    final all = <String>{..._baseSkills};
    for (final p in _postings.values) {
      all.addAll(p.skills);
    }
    for (final pr in _profiles.values) {
      for (final s in pr.skills) {
        all.add(s.name);
      }
    }
    final kw = (keyword ?? '').trim().toLowerCase();
    final filtered = all.where((s) {
      if (kw.isEmpty) return true;
      return s.toLowerCase().contains(kw);
    }).toList();
    filtered.sort((a, b) {
      final pa = a.toLowerCase().startsWith(kw);
      final pb = b.toLowerCase().startsWith(kw);
      if (pa != pb) return pa ? -1 : 1;
      return a.toLowerCase().compareTo(b.toLowerCase());
    });
    return filtered.take(limit.clamp(1, 50)).toList();
  }

  // ---------------- 공고 ----------------

  PageResponse<PostingCard> searchPostings({
    String? token,
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
    _closeExpiredPostings();
    final viewer = _optionalMember(token);
    var kw = keyword?.trim().toLowerCase();
    if (kw != null && kw.length < 2) kw = null;

    final list = _postings.values.where((p) {
      final statusOk = p.status == PostingStatus.OPEN ||
          (includeClosed &&
              (p.status == PostingStatus.CLOSED ||
                  p.status == PostingStatus.ANNOUNCED));
      if (!statusOk) return false;
      if (categories != null &&
          categories.isNotEmpty &&
          !categories.contains(p.category)) {
        return false;
      }
      if (fields != null &&
          fields.isNotEmpty &&
          !p.fields.any(fields.contains)) {
        return false;
      }
      if (modes != null &&
          modes.isNotEmpty &&
          !modes.contains(p.activityMode)) {
        return false;
      }
      final rec = _members[p.recruiterId]!;
      if (recruiterType != null && rec.type != recruiterType) return false;
      if (kw != null && !_matchesPosting(p, rec, kw)) return false;
      return true;
    }).toList();

    list.sort((a, b) {
      if (sort == SortType.DEADLINE) {
        return a.deadline.compareTo(b.deadline);
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    final cards = list.map((p) => _toPostingCard(p, viewer)).toList();
    return _paginate(cards, page, size);
  }

  HomeResponse home(String? token) {
    _closeExpiredPostings();
    final viewer = _optionalMember(token);
    final open = _postings.values
        .where((p) => p.status == PostingStatus.OPEN)
        .toList();
    final profile = viewer == null ? null : _profiles[viewer.id];

    List<_PostingRecord> recommended;
    if (profile == null || profile.fields.isEmpty) {
      recommended = List<_PostingRecord>.from(open)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      final mySkills =
          profile.skills.map((s) => s.name.toLowerCase()).toSet();
      recommended = open.where((p) => p.recruiterId != viewer!.id).toList()
        ..sort((a, b) {
          final sa = _matchScore(a, profile, mySkills);
          final sb = _matchScore(b, profile, mySkills);
          if (sa != sb) return sb.compareTo(sa);
          return b.createdAt.compareTo(a.createdAt);
        });
    }

    final limit = DateTime.now().add(const Duration(days: 3));
    final closingSoon = open
        .where((p) => p.deadline.isBefore(limit))
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));

    return HomeResponse(
      recommended:
          recommended.take(10).map((p) => _toPostingCard(p, viewer)).toList(),
      closingSoon:
          closingSoon.take(10).map((p) => _toPostingCard(p, viewer)).toList(),
    );
  }

  List<MyPostingItem> myPostings(String? token, {PostingStatus? status}) {
    _closeExpiredPostings();
    final recruiter = _requireMember(token);
    final list = _postings.values
        .where((p) => p.recruiterId == recruiter.id)
        .where((p) => status == null || p.status == status)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return list
        .map(
          (p) => MyPostingItem(
            postingId: p.id,
            title: p.title,
            category: p.category,
            status: p.status,
            deadline: p.deadline,
            counts: _counts(p.id),
          ),
        )
        .toList();
  }

  PostingDetail postingDetail(String? token, int postingId) {
    _closeExpiredPostings();
    final viewer = _optionalMember(token);
    final p = _getPosting(postingId);
    final owner = viewer != null && p.recruiterId == viewer.id;
    if (p.status == PostingStatus.DRAFT && !owner) {
      throw const ApiException(
        statusCode: 404,
        code: 'NOT_FOUND',
        message: '공고를 찾을 수 없습니다.',
      );
    }
    return _toPostingDetail(p, viewer);
  }

  PostingDetail createPosting(String? token, PostingCreateRequest req) {
    final recruiter = _requireMember(token);
    if (recruiter.type == MemberType.ADMIN) {
      throw const ApiException(
        statusCode: 403,
        code: 'FORBIDDEN',
        message: '관리자는 공고를 작성할 수 없습니다.',
      );
    }
    final errors = <FieldErrorItem>[];
    if (req.title.trim().isEmpty) {
      errors.add(const FieldErrorItem(field: 'title', message: '제목을 입력해 주세요.'));
    }
    if (recruiter.type == MemberType.PERSONAL &&
        !Category.personalAllowed.contains(req.category)) {
      errors.add(const FieldErrorItem(
        field: 'category',
        message: '개인회원은 프로젝트·공모전·스터디 공고만 올릴 수 있습니다.',
      ));
    }
    if (req.fields.isEmpty) {
      errors.add(
          const FieldErrorItem(field: 'fields', message: '분야를 1개 이상 선택해 주세요.'));
    }
    final deadline = DateTime.tryParse(req.deadline);
    if (deadline == null || !deadline.isAfter(DateTime.now())) {
      errors.add(const FieldErrorItem(
        field: 'deadline',
        message: '마감 일시는 현재 이후여야 합니다.',
      ));
    }
    if (req.requestedContacts.length > 2) {
      errors.add(const FieldErrorItem(
        field: 'requestedContacts',
        message: '요청 연락처는 최대 2개입니다.',
      ));
    }
    if (req.questions.length > 10) {
      errors.add(const FieldErrorItem(
        field: 'questions',
        message: '추가 질문은 최대 10개입니다.',
      ));
    }
    if (errors.isNotEmpty) {
      throw ApiException(
        statusCode: 400,
        code: 'VALIDATION_FAILED',
        message: '입력값을 확인해 주세요.',
        fieldErrors: errors,
      );
    }

    final id = ++_postingSeq;
    var order = 1;
    final qs = req.questions
        .map(
          (qi) => PostingQuestion(
            id: ++_questionSeq,
            order: order++,
            type: qi.type,
            content: qi.content,
            required: qi.required,
            maxLength: qi.maxLength,
            options: qi.options,
          ),
        )
        .toList();

    final p = _PostingRecord(
      id: id,
      recruiterId: recruiter.id,
      category: req.category,
      title: req.title.trim(),
      fields: List<Field>.from(req.fields),
      capacity: req.capacity,
      deadline: deadline!,
      activityStart: req.activityStart,
      activityEnd: req.activityEnd,
      activityMode: req.activityMode,
      place: req.place,
      skills: List<String>.from(req.skills),
      description: req.description,
      imageUrl: req.imageUrl,
      questions: qs,
      requestedContacts: List<ContactType>.from(req.requestedContacts),
      status: req.publish ? PostingStatus.OPEN : PostingStatus.DRAFT,
      createdAt: DateTime.now(),
    );
    _postings[p.id] = p;

    if (p.status == PostingStatus.OPEN &&
        recruiter.type == MemberType.ORGANIZATION) {
      for (final followerId in _followersOf(recruiter.id)) {
        _notify(
          followerId,
          NotificationType.FOLLOWED_ORG_NEW_POSTING,
          '관심 조직 새 공고',
          "${recruiter.name}이(가) '${p.title}'을(를) 게시했습니다.",
          'SCR-06',
          postingId: p.id,
        );
      }
    }
    return _toPostingDetail(p, recruiter);
  }

  PostingStatus closePosting(String? token, int postingId) {
    final recruiter = _requireMember(token);
    final p = _getOwnedPosting(recruiter, postingId);
    if (p.status != PostingStatus.OPEN) {
      throw const ApiException(
        statusCode: 409,
        code: 'INVALID_STATUS',
        message: '모집중인 공고만 마감할 수 있습니다.',
      );
    }
    p.status = PostingStatus.CLOSED;
    _onPostingClosed(p);
    return p.status;
  }

  // ---------------- 지원 ----------------

  ApplicationForm applicationForm(String? token, int postingId) {
    _closeExpiredPostings();
    final applicant = _requireMember(token);
    final p = _getPosting(postingId);
    _checkCanApply(applicant, p);
    final pr = _profileOf(applicant.id);

    final fixed = <String, dynamic>{
      'name': applicant.name,
      'majorPrimary': pr.majorPrimary,
      'academicStatus': pr.academicStatus?.name,
      'fields': pr.fields.map((e) => e.name).toList(),
    };

    final selectable = <String, dynamic>{
      'profileImage': {
        'available': pr.profileImageUrl != null && pr.profileImageUrl!.isNotEmpty,
        'defaultShare': (pr.profileImageUrl != null &&
                pr.profileImageUrl!.isNotEmpty) &&
            (pr.defaultShare['profileImage'] == true),
      },
      'bio': {
        'available': pr.bio != null && pr.bio!.trim().isNotEmpty,
        'defaultShare': (pr.bio != null && pr.bio!.trim().isNotEmpty) &&
            (pr.defaultShare['bio'] == true),
      },
      'majorsSecondary': {
        'available': pr.majorsSecondary.isNotEmpty,
        'defaultShare': pr.majorsSecondary.isNotEmpty &&
            (pr.defaultShare['majorsSecondary'] == true),
      },
      'skills': {
        'available': pr.skills.isNotEmpty,
        'defaultShare':
            pr.skills.isNotEmpty && (pr.defaultShare['skills'] == true),
      },
      'experiences': pr.experiences
          .map((e) => {
                'id': e.id,
                'title': e.title,
                'defaultShare': pr.defaultShare['experiences'] == true,
              })
          .toList(),
      'portfolioLinks': pr.portfolioLinks
          .map((l) => {
                'id': l.id,
                'title': l.title,
                'defaultShare': pr.defaultShare['portfolioLinks'] == true,
              })
          .toList(),
      'portfolioFiles': pr.portfolioFiles
          .map((f) => {
                'id': f.id,
                'title': f.fileName,
                'defaultShare': pr.defaultShare['portfolioFiles'] == true,
              })
          .toList(),
    };

    final contacts = ContactType.values.map((t) {
      final val = _contactValue(applicant, pr, t);
      return ContactOption(
        type: t,
        requested: p.requestedContacts.contains(t),
        hasValue: val != null && val.trim().isNotEmpty,
        maskedValue: _maskContact(t, val),
      );
    }).toList();

    return ApplicationForm(
      postingId: p.id,
      postingTitle: p.title,
      fixedItems: fixed,
      profileImage: SelectableBoolOption.fromJson(
          selectable['profileImage'] as Map<String, dynamic>),
      bio: SelectableBoolOption.fromJson(
          selectable['bio'] as Map<String, dynamic>),
      majorsSecondary: SelectableBoolOption.fromJson(
          selectable['majorsSecondary'] as Map<String, dynamic>),
      skills: SelectableBoolOption.fromJson(
          selectable['skills'] as Map<String, dynamic>),
      experiences: (selectable['experiences'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(SelectableEntityOption.fromJson)
          .toList(),
      portfolioLinks: (selectable['portfolioLinks'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(SelectableEntityOption.fromJson)
          .toList(),
      portfolioFiles: (selectable['portfolioFiles'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(SelectableEntityOption.fromJson)
          .toList(),
      contacts: contacts,
      questions: p.questions,
      draft: _draftView(applicant.id, p),
    );
  }

  ApplyResponse apply(
    String? token,
    int postingId,
    Map<String, dynamic> reqBody, {
    String? idempotencyKey,
  }) {
    _closeExpiredPostings();
    if (idempotencyKey != null && _idempotencyKeys.containsKey(idempotencyKey)) {
      final existing = _applications[_idempotencyKeys[idempotencyKey]!];
      if (existing != null) {
        final ep = _getPosting(existing.postingId);
        return ApplyResponse(
          applicationId: existing.id,
          postingId: existing.postingId,
          displayStatus: _displayStatus(existing, ep),
          submittedAt: existing.submittedAt,
        );
      }
    }

    final applicant = _requireMember(token);
    final p = _getPosting(postingId);
    _checkCanApply(applicant, p);
    final pr = _profileOf(applicant.id);

    if (reqBody['agreeToProvide'] != true) {
      throw const ApiException(
        statusCode: 400,
        code: 'VALIDATION_FAILED',
        message: '정보 제공에 동의해야 제출할 수 있습니다.',
        fieldErrors: [
          FieldErrorItem(field: 'agreeToProvide', message: '동의가 필요합니다.'),
        ],
      );
    }

    final answerMap = <int, dynamic>{};
    for (final raw in (reqBody['answers'] as List<dynamic>? ?? const [])) {
      if (raw is Map<String, dynamic> && raw['questionId'] != null) {
        answerMap[(raw['questionId'] as num).toInt()] = raw['value'];
      }
    }

    final errors = <FieldErrorItem>[];
    for (final q in p.questions) {
      if (q.required && _isEmptyAnswer(answerMap[q.id])) {
        errors.add(FieldErrorItem(
          field: 'answers[${q.id}]',
          message: '필수 질문입니다: ${q.content}',
        ));
      }
    }

    final contactInputs = <ContactType, Map<String, dynamic>>{};
    for (final raw in (reqBody['contacts'] as List<dynamic>? ?? const [])) {
      if (raw is Map<String, dynamic> && raw['type'] != null) {
        contactInputs[ContactType.fromApi(raw['type'].toString())] = raw;
      }
    }

    final sharedContacts = <_SharedContactRecord>[];
    for (final t in ContactType.values) {
      final ci = contactInputs[t];
      final requested = p.requestedContacts.contains(t);
      if (ci == null || ci['consent'] != true) {
        if (requested) {
          errors.add(FieldErrorItem(
            field: 'contacts.${t.name}',
            message: '요청 연락처는 제공에 동의해야 지원할 수 있습니다.',
          ));
        }
        continue;
      }
      final rawVal = ci['value']?.toString().trim();
      final val = (rawVal != null && rawVal.isNotEmpty)
          ? rawVal
          : _contactValue(applicant, pr, t);
      if (val == null || val.trim().isEmpty) {
        errors.add(FieldErrorItem(
          field: 'contacts.${t.name}',
          message: '연락처 값을 입력해 주세요.',
        ));
        continue;
      }
      sharedContacts.add(_SharedContactRecord(
        type: t,
        value: val.trim(),
        consent: true,
      ));
      if (rawVal != null &&
          rawVal.isNotEmpty &&
          ci['saveToProfile'] == true) {
        _saveContactToProfile(pr, t, rawVal);
      }
    }

    if (errors.isNotEmpty) {
      final contactProblem =
          errors.any((e) => e.field.startsWith('contacts.'));
      throw ApiException(
        statusCode: contactProblem ? 409 : 400,
        code: contactProblem ? 'REQUESTED_CONTACT_MISSING' : 'VALIDATION_FAILED',
        message: contactProblem
            ? '요청 연락처를 입력하고 제공에 동의해 주세요.'
            : '필수 질문에 답해 주세요.',
        fieldErrors: errors,
      );
    }

    final share = (reqBody['share'] as Map<String, dynamic>?) ?? const {};
    final sharedItems = <String>[];
    final snapshot = _buildSnapshot(applicant, pr, share, sharedItems);
    for (final c in sharedContacts) {
      sharedItems.add('contact:${c.type.name}');
    }

    final answers = answerMap.entries
        .map((e) => _AnswerRecord(questionId: e.key, value: e.value))
        .toList();

    final app = _ApplicationRecord(
      id: ++_applicationSeq,
      postingId: p.id,
      applicantId: applicant.id,
      snapshot: snapshot,
      sharedItems: sharedItems,
      contacts: sharedContacts,
      answers: answers,
      submittedAt: DateTime.now(),
    );
    _applications[app.id] = app;
    if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
      _idempotencyKeys[idempotencyKey] = app.id;
    }
    _drafts.remove('${applicant.id}:${p.id}');

    _notify(
      p.recruiterId,
      NotificationType.NEW_APPLICATION,
      '새 지원서가 도착했어요',
      "'${p.title}'에 ${applicant.name}님이 지원했어요.",
      'SCR-12',
      postingId: p.id,
      applicationId: app.id,
    );

    return ApplyResponse(
      applicationId: app.id,
      postingId: p.id,
      displayStatus: _displayStatus(app, p),
      submittedAt: app.submittedAt,
    );
  }

  List<MyApplicationItem> myApplications(String? token) {
    _closeExpiredPostings();
    final applicant = _requireMember(token);
    final list = _applications.values
        .where((a) => a.applicantId == applicant.id)
        .toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

    return list.map((a) {
      final p = _getPosting(a.postingId);
      return MyApplicationItem(
        applicationId: a.id,
        posting: _toPostingRef(p),
        displayStatus: _displayStatus(a, p),
        submittedAt: a.submittedAt,
        announcedAt:
            p.status == PostingStatus.ANNOUNCED ? p.announcedAt : null,
      );
    }).toList();
  }

  ApplicationDetail myApplicationDetail(String? token, int applicationId) {
    _closeExpiredPostings();
    final applicant = _requireMember(token);
    final a = _getApplication(applicationId);
    if (a.applicantId != applicant.id) {
      throw const ApiException(
        statusCode: 403,
        code: 'FORBIDDEN',
        message: '본인 지원서만 볼 수 있습니다.',
      );
    }
    final p = _getPosting(a.postingId);
    final status = _displayStatus(a, p);
    if (a.withdrawn) {
      return ApplicationDetail(
        applicationId: a.id,
        posting: _toPostingRef(p),
        displayStatus: status,
        submittedAt: a.submittedAt,
        snapshot: const {},
        sharedItems: const [],
        answers: const [],
        result: null,
      );
    }
    ResultView? result;
    if (status == DisplayStatus.ACCEPTED) {
      final recruiter = _members[p.recruiterId]!;
      final recruiterContact = recruiter.type == MemberType.ORGANIZATION
          ? ContactValue(
              type: ContactType.PERSONAL_EMAIL,
              value: recruiter.contactEmail ?? '',
            )
          : ContactValue(
              type: ContactType.SCHOOL_EMAIL,
              value: recruiter.schoolEmail ?? '',
            );
      result = ResultView(
        result: status,
        message: p.acceptMessage ?? '',
        recruiterContact: recruiterContact,
        disclosedContacts: a.contacts
            .map((c) => DisclosedContact(
                  type: c.type,
                  value: c.value,
                  disclosedAt: a.disclosedAt,
                ))
            .toList(),
      );
    } else if (status == DisplayStatus.REJECTED) {
      final msg = (p.rejectMessage != null && p.rejectMessage!.trim().isNotEmpty)
          ? p.rejectMessage!
          : _defaultRejectMessage;
      result = ResultView(result: status, message: msg);
    }

    return ApplicationDetail(
      applicationId: a.id,
      posting: _toPostingRef(p),
      displayStatus: status,
      submittedAt: a.submittedAt,
      snapshot: a.snapshot,
      sharedItems: a.sharedItems,
      answers: _answerViews(a.answers, p),
      result: result,
    );
  }

  DisplayStatus withdrawApplication(String? token, int applicationId) {
    _closeExpiredPostings();
    final applicant = _requireMember(token);
    final a = _getApplication(applicationId);
    if (a.applicantId != applicant.id) {
      throw const ApiException(
        statusCode: 403,
        code: 'FORBIDDEN',
        message: '본인 지원서만 취소할 수 있습니다.',
      );
    }
    final p = _getPosting(a.postingId);
    if (p.status != PostingStatus.OPEN) {
      throw const ApiException(
        statusCode: 409,
        code: 'WITHDRAW_NOT_ALLOWED',
        message: '마감 이후에는 지원을 취소할 수 없습니다.',
      );
    }
    a.withdrawn = true;
    return DisplayStatus.WITHDRAWN;
  }

  // ---------------- 초안 ----------------

  DraftResponse getDraft(String? token, int postingId) {
    _closeExpiredPostings();
    final applicant = _requirePersonal(token);
    final p = _getPosting(postingId);
    return _draftView(applicant.id, p);
  }

  DraftResponse saveDraft(
    String? token,
    int postingId,
    List<Map<String, dynamic>> answerInputs, {
    DraftSource source = DraftSource.WEB,
  }) {
    _closeExpiredPostings();
    final applicant = _requirePersonal(token);
    final p = _getPosting(postingId);
    _checkCanApply(applicant, p);

    final qMap = {for (final q in p.questions) q.id: q};
    final errors = <FieldErrorItem>[];
    final savedAnswers = <_AnswerRecord>[];

    for (final ai in answerInputs) {
      final qId = (ai['questionId'] as num?)?.toInt();
      final q = qId == null ? null : qMap[qId];
      if (q == null) {
        errors.add(FieldErrorItem(
          field: 'answers[$qId]',
          message: '이 공고에 없는 질문입니다.',
        ));
        continue;
      }
      final val = ai['value'];
      if (val is String && q.maxLength != null && val.length > q.maxLength!) {
        errors.add(FieldErrorItem(
          field: 'answers[${q.id}]',
          message: '${q.maxLength}자 이하로 입력해 주세요.',
        ));
        continue;
      }
      savedAnswers.add(_AnswerRecord(questionId: q.id, value: val));
    }

    if (errors.isNotEmpty) {
      throw ApiException(
        statusCode: 400,
        code: 'VALIDATION_FAILED',
        message: '초안 내용을 확인해 주세요.',
        fieldErrors: errors,
      );
    }

    final d = _DraftRecord(
      memberId: applicant.id,
      postingId: p.id,
      answers: savedAnswers,
      source: source,
      updatedAt: DateTime.now(),
    );
    _drafts[d.key] = d;
    return _draftView(applicant.id, p);
  }

  DraftResponse deleteDraft(String? token, int postingId) {
    final applicant = _requirePersonal(token);
    final p = _getPosting(postingId);
    _drafts.remove('${applicant.id}:${p.id}');
    return _draftView(applicant.id, p);
  }

  // ---------------- 검토·선발 ----------------

  List<ApplicantItem> applicants(
    String? token,
    int postingId, {
    Decision? decision,
    ApplicantSort sort = ApplicantSort.SUBMITTED,
    String? keyword,
  }) {
    final recruiter = _requireMember(token);
    _getOwnedPosting(recruiter, postingId);
    final kw =
        keyword == null || keyword.trim().isEmpty ? null : keyword.trim().toLowerCase();

    final apps = _applications.values
        .where((a) => a.postingId == postingId)
        .where((a) => decision == null || (!a.withdrawn && a.decision == decision))
        .where((a) => kw == null || _matchesApplicant(a, kw))
        .toList();

    final items = apps.map((a) {
      final m = _members[a.applicantId];
      final pr = _profiles[a.applicantId];
      final name = m?.name ?? '(알 수 없음)';
      if (a.withdrawn) {
        return ApplicantItem(
          applicationId: a.id,
          name: name,
          submittedAt: a.submittedAt,
          hasMemo: false,
          withdrawn: true,
        );
      }
      final topSkills =
          pr == null ? <String>[] : pr.skills.take(3).map((s) => s.name).toList();
      return ApplicantItem(
        applicationId: a.id,
        name: name,
        department: pr?.majorPrimary,
        academicStatus: pr?.academicStatus,
        topSkills: topSkills,
        submittedAt: a.submittedAt,
        decision: a.decision,
        hasMemo: a.memo != null && a.memo!.trim().isNotEmpty,
        withdrawn: false,
      );
    }).toList();

    items.sort((a, b) {
      if (sort == ApplicantSort.NAME) {
        return a.name.compareTo(b.name);
      }
      return (a.submittedAt ?? DateTime(0))
          .compareTo(b.submittedAt ?? DateTime(0));
    });
    return items;
  }

  ReviewDetail reviewApplication(String? token, int applicationId) {
    final recruiter = _requireMember(token);
    final a = _getApplication(applicationId);
    final p = _getOwnedPosting(recruiter, a.postingId);
    if (a.withdrawn) {
      return ReviewDetail(
        applicationId: a.id,
        posting: _toPostingRef(p),
        snapshot: const {},
        answers: const [],
        sharedContactTypes: const [],
        submittedAt: a.submittedAt,
        withdrawn: true,
      );
    }
    List<ContactValue>? contacts;
    if (p.status == PostingStatus.ANNOUNCED && a.decision == Decision.ACCEPTED) {
      contacts = a.contacts
          .map((c) => ContactValue(type: c.type, value: c.value))
          .toList();
    }
    return ReviewDetail(
      applicationId: a.id,
      posting: _toPostingRef(p),
      snapshot: a.snapshot,
      answers: _answerViews(a.answers, p),
      sharedContactTypes: a.contacts.map((c) => c.type).toList(),
      contacts: contacts,
      decision: a.decision,
      memo: a.memo,
      submittedAt: a.submittedAt,
      withdrawn: false,
    );
  }

  DecisionResponse decideApplication(
    String? token,
    int applicationId, {
    Decision? decision,
    String? memo,
  }) {
    final recruiter = _requireMember(token);
    final a = _getApplication(applicationId);
    final p = _getOwnedPosting(recruiter, a.postingId);
    if (p.status == PostingStatus.ANNOUNCED) {
      throw const ApiException(
        statusCode: 409,
        code: 'ALREADY_ANNOUNCED',
        message: '결과 발표 후에는 결정을 바꿀 수 없습니다.',
      );
    }
    if (a.withdrawn) {
      throw const ApiException(
        statusCode: 409,
        code: 'WITHDRAWN',
        message: '취소된 지원서입니다.',
      );
    }
    if (decision != null) a.decision = decision;
    if (memo != null) a.memo = memo;
    return DecisionResponse(
      applicationId: a.id,
      decision: a.decision,
      memo: a.memo,
    );
  }

  AnnounceResponse announcePosting(
    String? token,
    int postingId, {
    required String acceptMessage,
    String? rejectMessage,
  }) {
    _closeExpiredPostings();
    final recruiter = _requireMember(token);
    final p = _getOwnedPosting(recruiter, postingId);
    if (p.status == PostingStatus.ANNOUNCED) {
      throw const ApiException(
        statusCode: 409,
        code: 'ALREADY_ANNOUNCED',
        message: '이미 결과를 발표했습니다.',
      );
    }
    if (p.status != PostingStatus.CLOSED) {
      throw const ApiException(
        statusCode: 409,
        code: 'POSTING_NOT_CLOSED',
        message: '마감된 공고만 결과를 발표할 수 있습니다.',
      );
    }
    final valid = _applications.values
        .where((a) => a.postingId == postingId && !a.withdrawn)
        .toList();
    final pending = valid.where((a) => a.decision == Decision.PENDING).length;
    if (pending > 0) {
      throw ApiException(
        statusCode: 409,
        code: 'UNDECIDED_APPLICATIONS',
        message: '결정하지 않은 지원서가 $pending건 있습니다.',
      );
    }
    if (acceptMessage.trim().isEmpty) {
      throw const ApiException(
        statusCode: 400,
        code: 'VALIDATION_FAILED',
        message: '합격자 안내 메시지를 입력해 주세요.',
        fieldErrors: [
          FieldErrorItem(field: 'acceptMessage', message: '필수 항목입니다.'),
        ],
      );
    }

    final now = DateTime.now();
    p.acceptMessage = acceptMessage.trim();
    p.rejectMessage =
        (rejectMessage != null && rejectMessage.trim().isNotEmpty)
            ? rejectMessage.trim()
            : null;
    p.status = PostingStatus.ANNOUNCED;
    p.announcedAt = now;

    final recruiterMember = _members[p.recruiterId]!;
    var accepted = 0;
    for (final a in valid) {
      if (a.decision == Decision.ACCEPTED) {
        accepted++;
        a.disclosedAt = now;
        final pr = _profiles[a.applicantId];
        pr?.activityHistory.add(
          _ActivityHistoryRecord(
            applicationId: a.id,
            postingId: p.id,
            postingTitle: p.title,
            recruiterName: recruiterMember.name,
            announcedAt: now,
            visible: true,
          ),
        );
      }
      _notify(
        a.applicantId,
        NotificationType.RESULT_ANNOUNCED,
        '선발 결과가 발표되었어요',
        "'${p.title}' 지원 결과를 확인해 보세요.",
        'SCR-08',
        postingId: p.id,
        applicationId: a.id,
      );
    }

    final rejected = valid.length - accepted;
    final warning = accepted > p.capacity
        ? '합격 인원($accepted명)이 모집 인원(${p.capacity}명)을 넘었습니다.'
        : null;

    return AnnounceResponse(
      postingId: p.id,
      status: p.status,
      accepted: accepted,
      rejected: rejected,
      announcedAt: now,
      warning: warning,
    );
  }

  List<AcceptedContact> acceptedContacts(String? token, int postingId) {
    final recruiter = _requireMember(token);
    final p = _getOwnedPosting(recruiter, postingId);
    if (p.status != PostingStatus.ANNOUNCED) {
      throw const ApiException(
        statusCode: 409,
        code: 'NOT_ANNOUNCED',
        message: '결과 발표 후에 확인할 수 있습니다.',
      );
    }
    return _applications.values
        .where((a) =>
            a.postingId == postingId &&
            !a.withdrawn &&
            a.decision == Decision.ACCEPTED)
        .map((a) => AcceptedContact(
              applicationId: a.id,
              name: _members[a.applicantId]?.name ?? '(알 수 없음)',
              contacts: a.contacts
                  .map((c) => ContactValue(type: c.type, value: c.value))
                  .toList(),
              disclosedAt: a.disclosedAt,
            ))
        .toList();
  }

  // ---------------- 외부 활동 / 관심 / 조직 / 알림 ----------------

  PageResponse<ExternalActivityItem> searchExternalActivities({
    String? token,
    String? keyword,
    ExternalType? type,
    List<Field>? fields,
    String? source,
    SortType sort = SortType.DEADLINE,
    int page = 0,
    int size = 20,
  }) {
    final viewer = _optionalMember(token);
    final kw =
        keyword == null || keyword.trim().isEmpty ? null : keyword.trim().toLowerCase();
    final nowDate = DateTime.now();
    final today = DateTime(nowDate.year, nowDate.month, nowDate.day);

    final filtered = _externalActivities.where((e) {
      if (e.deadline != null && e.deadline!.isBefore(today)) return false;
      if (type != null && e.type != type) return false;
      if (source != null &&
          source.isNotEmpty &&
          source.toUpperCase() != e.source.toUpperCase()) {
        return false;
      }
      if (fields != null &&
          fields.isNotEmpty &&
          !e.fields.any(fields.contains)) {
        return false;
      }
      if (kw != null) {
        final match = e.title.toLowerCase().contains(kw) ||
            e.organizer.toLowerCase().contains(kw);
        if (!match) return false;
      }
      return true;
    }).toList();

    filtered.sort((a, b) {
      if (sort == SortType.LATEST) {
        return b.postedAt.compareTo(a.postedAt);
      }
      if (a.deadline == null && b.deadline == null) return 0;
      if (a.deadline == null) return 1;
      if (b.deadline == null) return -1;
      return a.deadline!.compareTo(b.deadline!);
    });

    final items = filtered.map((e) => _toExternalItem(e, viewer)).toList();
    return _paginate(items, page, size);
  }

  BookmarkList listBookmarks(String? token) {
    final member = _requirePersonal(token);
    final list = _bookmarks.values
        .where((b) => b.memberId == member.id)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final postings = <PostingCard>[];
    final externals = <ExternalActivityItem>[];
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    for (final b in list) {
      if (b.targetType == BookmarkTarget.POSTING) {
        final p = _postings[b.targetId];
        if (p != null &&
            p.status != PostingStatus.DRAFT &&
            p.status != PostingStatus.HIDDEN) {
          postings.add(_toPostingCard(p, member));
        }
      } else {
        final idx =
            _externalActivities.indexWhere((element) => element.id == b.targetId);
        if (idx >= 0) {
          final e = _externalActivities[idx];
          if (e.deadline == null || !e.deadline!.isBefore(todayDate)) {
            externals.add(_toExternalItem(e, member));
          }
        }
      }
    }
    return BookmarkList(postings: postings, externalActivities: externals);
  }

  bool addBookmark(String? token, BookmarkTarget targetType, int targetId) {
    final member = _requirePersonal(token);
    final b = _BookmarkRecord(
      memberId: member.id,
      targetType: targetType,
      targetId: targetId,
      createdAt: DateTime.now(),
    );
    _bookmarks.putIfAbsent(b.key, () => b);
    return true;
  }

  bool removeBookmark(String? token, BookmarkTarget targetType, int targetId) {
    final member = _requirePersonal(token);
    _bookmarks.remove('${member.id}:${targetType.name}:$targetId');
    return false;
  }

  OrgPage orgPage(String? token, int orgId) {
    _closeExpiredPostings();
    final viewer = _optionalMember(token);
    final org = _members[orgId];
    if (org == null || org.type != MemberType.ORGANIZATION) {
      throw const ApiException(
        statusCode: 404,
        code: 'NOT_FOUND',
        message: '조직을 찾을 수 없습니다.',
      );
    }
    final mine = _postings.values
        .where((p) => p.recruiterId == orgId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final open = mine
        .where((p) => p.status == PostingStatus.OPEN)
        .map((p) => _toPostingCard(p, viewer))
        .toList();
    final past = mine
        .where((p) =>
            p.status == PostingStatus.CLOSED ||
            p.status == PostingStatus.ANNOUNCED)
        .map((p) => _toPostingCard(p, viewer))
        .toList();

    return OrgPage(
      orgId: org.id,
      name: org.name,
      orgType: org.orgType ?? '단체',
      verified: org.verified,
      logoUrl: org.logoUrl,
      intro: org.orgIntro,
      fields: org.orgFields,
      links: org.orgLinks,
      followed:
          viewer != null && _follows.contains('${viewer.id}:$orgId'),
      followerCount: _followersOf(orgId).length,
      openPostings: open,
      pastPostings: past,
    );
  }

  FollowResponse followOrg(String? token, int orgId) {
    final member = _requirePersonal(token);
    _follows.add('${member.id}:$orgId');
    return FollowResponse(
      orgId: orgId,
      followed: true,
      followerCount: _followersOf(orgId).length,
    );
  }

  FollowResponse unfollowOrg(String? token, int orgId) {
    final member = _requirePersonal(token);
    _follows.remove('${member.id}:$orgId');
    return FollowResponse(
      orgId: orgId,
      followed: false,
      followerCount: _followersOf(orgId).length,
    );
  }

  NotificationList listNotifications(String? token, {bool unreadOnly = false}) {
    final member = _requireMember(token);
    _generateClosingSoonNotifications();
    final all = _notifications.values
        .where((n) => n.memberId == member.id)
        .toList()
      ..sort((a, b) {
        final cmp = b.createdAt.compareTo(a.createdAt);
        return cmp != 0 ? cmp : b.id.compareTo(a.id);
      });
    final unread = all.where((n) => !n.read).length;
    final items = all
        .where((n) => !unreadOnly || !n.read)
        .map((n) => n.toDto())
        .toList();
    return NotificationList(unreadCount: unread, items: items);
  }

  int unreadCount(String? token) {
    final member = _requireMember(token);
    _generateClosingSoonNotifications();
    return _notifications.values
        .where((n) => n.memberId == member.id && !n.read)
        .length;
  }

  NotificationItem markNotificationRead(String? token, int notificationId) {
    final member = _requireMember(token);
    final n = _notifications[notificationId];
    if (n == null) {
      throw const ApiException(
        statusCode: 404,
        code: 'NOT_FOUND',
        message: '알림을 찾을 수 없습니다.',
      );
    }
    if (n.memberId != member.id) {
      throw const ApiException(
        statusCode: 403,
        code: 'FORBIDDEN',
        message: '본인 알림만 읽음 처리할 수 있습니다.',
      );
    }
    n.read = true;
    return n.toDto();
  }

  int markAllNotificationsRead(String? token) {
    final member = _requireMember(token);
    for (final n in _notifications.values) {
      if (n.memberId == member.id) n.read = true;
    }
    return 0;
  }

  // ---------------- 내부 헬퍼 ----------------

  _MemberRecord? _optionalMember(String? auth) {
    if (auth == null || auth.trim().isEmpty) return null;
    var token = auth.trim();
    if (token.toLowerCase().startsWith('bearer ')) {
      token = token.substring(7).trim();
    }
    if (!token.startsWith('demo-')) return null;
    final id = int.tryParse(token.substring(5));
    return id == null ? null : _members[id];
  }

  _MemberRecord _requireMember(String? auth) {
    final m = _optionalMember(auth);
    if (m == null) {
      throw const ApiException(
        statusCode: 401,
        code: 'UNAUTHORIZED',
        message: '로그인이 필요합니다.',
      );
    }
    return m;
  }

  _MemberRecord _requirePersonal(String? auth) {
    final m = _requireMember(auth);
    if (m.type != MemberType.PERSONAL) {
      throw const ApiException(
        statusCode: 403,
        code: 'FORBIDDEN',
        message: '개인회원만 사용할 수 있는 기능입니다.',
      );
    }
    return m;
  }

  _ProfileRecord _profileOf(int memberId) {
    return _profiles.putIfAbsent(
      memberId,
      () => _ProfileRecord(memberId: memberId),
    );
  }

  _PostingRecord _getPosting(int id) {
    final p = _postings[id];
    if (p == null) {
      throw const ApiException(
        statusCode: 404,
        code: 'NOT_FOUND',
        message: '공고를 찾을 수 없습니다.',
      );
    }
    return p;
  }

  _PostingRecord _getOwnedPosting(_MemberRecord recruiter, int postingId) {
    final p = _getPosting(postingId);
    if (p.recruiterId != recruiter.id) {
      throw const ApiException(
        statusCode: 403,
        code: 'FORBIDDEN',
        message: '본인 공고만 관리할 수 있습니다.',
      );
    }
    return p;
  }

  _ApplicationRecord _getApplication(int id) {
    final a = _applications[id];
    if (a == null) {
      throw const ApiException(
        statusCode: 404,
        code: 'NOT_FOUND',
        message: '지원서를 찾을 수 없습니다.',
      );
    }
    return a;
  }

  void _closeExpiredPostings() {
    final now = DateTime.now();
    for (final p in _postings.values) {
      if (p.status == PostingStatus.OPEN && !p.deadline.isAfter(now)) {
        p.status = PostingStatus.CLOSED;
        _onPostingClosed(p);
      }
    }
  }

  void _onPostingClosed(_PostingRecord p) {
    final count = _applications.values
        .where((a) => a.postingId == p.id && !a.withdrawn)
        .length;
    _notify(
      p.recruiterId,
      NotificationType.POSTING_CLOSED,
      '모집이 마감되었어요',
      "'${p.title}' 지원서 $count건을 검토하고 결과를 발표해 주세요.",
      'SCR-12',
      postingId: p.id,
    );
    _drafts.removeWhere((_, d) => d.postingId == p.id);
  }

  void _generateClosingSoonNotifications() {
    _closeExpiredPostings();
    final limit = DateTime.now().add(const Duration(hours: 24));
    for (final b in _bookmarks.values) {
      if (b.targetType != BookmarkTarget.POSTING) continue;
      final p = _postings[b.targetId];
      if (p == null ||
          p.status != PostingStatus.OPEN ||
          p.deadline.isAfter(limit)) {
        continue;
      }
      final key = '${b.memberId}:${p.id}';
      if (_closingSoonNotified.contains(key)) continue;
      final applied = _applications.values.any((a) =>
          a.postingId == p.id && a.applicantId == b.memberId && !a.withdrawn);
      if (applied) continue;
      _closingSoonNotified.add(key);
      _notify(
        b.memberId,
        NotificationType.BOOKMARK_CLOSING_SOON,
        '관심 공고 마감 임박',
        "'${p.title}' 모집이 24시간 안에 마감됩니다. 아직 지원하지 않았어요.",
        'SCR-06',
        postingId: p.id,
      );
    }
  }

  void _notify(
    int memberId,
    NotificationType type,
    String title,
    String body,
    String targetScreen, {
    int? postingId,
    int? applicationId,
  }) {
    final id = ++_notificationSeq;
    _notifications[id] = _NotificationRecord(
      id: id,
      memberId: memberId,
      type: type,
      title: title,
      body: body,
      targetScreen: targetScreen,
      postingId: postingId,
      applicationId: applicationId,
      read: false,
      createdAt: DateTime.now(),
    );
  }

  void _checkCanApply(_MemberRecord applicant, _PostingRecord p) {
    if (applicant.type != MemberType.PERSONAL) {
      throw const ApiException(
        statusCode: 403,
        code: 'FORBIDDEN',
        message: '개인회원만 지원할 수 있습니다.',
      );
    }
    if (p.recruiterId == applicant.id) {
      throw const ApiException(
        statusCode: 409,
        code: 'OWN_POSTING',
        message: '본인 공고에는 지원할 수 없습니다.',
      );
    }
    if (p.status != PostingStatus.OPEN || !p.deadline.isAfter(DateTime.now())) {
      throw const ApiException(
        statusCode: 409,
        code: 'APPLICATION_CLOSED',
        message: '모집이 마감되어 지원할 수 없습니다.',
      );
    }
    final already = _applications.values.any((a) =>
        a.postingId == p.id &&
        a.applicantId == applicant.id &&
        !a.withdrawn);
    if (already) {
      throw const ApiException(
        statusCode: 409,
        code: 'ALREADY_APPLIED',
        message: '이미 지원한 공고입니다.',
      );
    }
    final pr = _profiles[applicant.id];
    if (pr == null || !pr.isRequiredFilled) {
      throw const ApiException(
        statusCode: 409,
        code: 'PROFILE_INCOMPLETE',
        message: '프로필 필수 항목(주전공, 학년, 관심 분야)을 먼저 입력해 주세요.',
      );
    }
  }

  ProfileResponse _toProfileResponse(_MemberRecord m, _ProfileRecord p) {
    return ProfileResponse(
      name: m.name,
      schoolEmail: m.schoolEmail,
      profileImageUrl: p.profileImageUrl,
      majorPrimary: p.majorPrimary,
      majorsSecondary: p.majorsSecondary,
      academicStatus: p.academicStatus,
      bio: p.bio,
      fields: p.fields,
      skills: p.skills
          .map((s) => SkillItem(id: s.id, name: s.name, level: s.level))
          .toList(),
      experiences: p.experiences
          .map((e) => ExperienceItem(
                id: e.id,
                type: e.type,
                title: e.title,
                role: e.role,
                startDate: e.startDate,
                endDate: e.endDate,
                description: e.description,
              ))
          .toList(),
      portfolioLinks: p.portfolioLinks
          .map((l) => PortfolioLinkItem(id: l.id, title: l.title, url: l.url))
          .toList(),
      portfolioFiles: p.portfolioFiles
          .map((f) =>
              PortfolioFileItem(id: f.id, fileName: f.fileName, url: f.url))
          .toList(),
      contacts: ContactsData(
        phone: p.contacts.phone,
        kakaoId: p.contacts.kakaoId,
        personalEmail: p.contacts.personalEmail,
      ),
      defaultShare: Map<String, bool>.from(p.defaultShare),
      activityHistory: p.activityHistory
          .map((h) => ActivityHistoryItem(
                applicationId: h.applicationId,
                postingId: h.postingId,
                postingTitle: h.postingTitle,
                recruiterName: h.recruiterName,
                announcedAt: h.announcedAt,
                visible: h.visible,
              ))
          .toList(),
      completeness: p.completeness,
    );
  }

  PostingCard _toPostingCard(_PostingRecord p, _MemberRecord? viewer) {
    return PostingCard(
      postingId: p.id,
      category: p.category,
      title: p.title,
      recruiter: _recruiterView(p),
      fields: p.fields,
      skills: p.skills,
      capacity: p.capacity,
      deadline: p.deadline,
      dDay: _dDay(p.deadline),
      status: p.status,
      requestsContact: p.requestedContacts.isNotEmpty,
      bookmarked: viewer != null &&
          _bookmarks.containsKey(
              '${viewer.id}:${BookmarkTarget.POSTING.name}:${p.id}'),
    );
  }

  PostingDetail _toPostingDetail(_PostingRecord p, _MemberRecord? viewer) {
    final owner = viewer != null && p.recruiterId == viewer.id;
    final applicantCount = owner
        ? _applications.values
            .where((a) => a.postingId == p.id && !a.withdrawn)
            .length
        : null;
    return PostingDetail(
      postingId: p.id,
      category: p.category,
      title: p.title,
      recruiter: _recruiterView(p),
      fields: p.fields,
      capacity: p.capacity,
      deadline: p.deadline,
      dDay: _dDay(p.deadline),
      activityStart: p.activityStart,
      activityEnd: p.activityEnd,
      activityMode: p.activityMode,
      place: p.place,
      skills: p.skills,
      description: p.description,
      imageUrl: p.imageUrl,
      questions: p.questions,
      requestedContacts: p.requestedContacts,
      status: p.status,
      applicantCount: applicantCount,
      viewerAction: _viewerAction(p, viewer),
      bookmarked: viewer != null &&
          _bookmarks.containsKey(
              '${viewer.id}:${BookmarkTarget.POSTING.name}:${p.id}'),
      createdAt: p.createdAt,
    );
  }

  PostingRef _toPostingRef(_PostingRecord p) {
    final rec = _members[p.recruiterId]!;
    return PostingRef(
      postingId: p.id,
      title: p.title,
      category: p.category,
      deadline: p.deadline,
      status: p.status,
      recruiterName: rec.name,
    );
  }

  RecruiterView _recruiterView(_PostingRecord p) {
    final m = _members[p.recruiterId]!;
    final dept = m.type == MemberType.PERSONAL
        ? _profiles[m.id]?.majorPrimary
        : null;
    return RecruiterView(
      type: m.type,
      memberId: m.id,
      name: m.name,
      department: dept,
      orgType: m.orgType,
      verified: m.verified,
    );
  }

  ViewerAction _viewerAction(_PostingRecord p, _MemberRecord? viewer) {
    if (viewer == null) return ViewerAction.LOGIN_REQUIRED;
    if (p.recruiterId == viewer.id) return ViewerAction.OWNER;
    if (p.status != PostingStatus.OPEN) return ViewerAction.CLOSED;
    if (viewer.type != MemberType.PERSONAL) return ViewerAction.NOT_ALLOWED;
    final applied = _applications.values.any((a) =>
        a.postingId == p.id && a.applicantId == viewer.id && !a.withdrawn);
    return applied ? ViewerAction.APPLIED : ViewerAction.APPLY;
  }

  ApplicantCounts _counts(int postingId) {
    final apps =
        _applications.values.where((a) => a.postingId == postingId).toList();
    final withdrawn = apps.where((a) => a.withdrawn).length;
    final pending = apps
        .where((a) => !a.withdrawn && a.decision == Decision.PENDING)
        .length;
    final accepted = apps
        .where((a) => !a.withdrawn && a.decision == Decision.ACCEPTED)
        .length;
    final rejected = apps
        .where((a) => !a.withdrawn && a.decision == Decision.REJECTED)
        .length;
    return ApplicantCounts(
      total: apps.length - withdrawn,
      pending: pending,
      accepted: accepted,
      rejected: rejected,
      withdrawn: withdrawn,
    );
  }

  DraftResponse _draftView(int memberId, _PostingRecord p) {
    if (p.status != PostingStatus.OPEN) {
      _drafts.remove('$memberId:${p.id}');
    }
    final d = _drafts['$memberId:${p.id}'];
    if (d == null) {
      return DraftResponse(
        postingId: p.id,
        postingTitle: p.title,
        exists: false,
      );
    }
    return DraftResponse(
      postingId: p.id,
      postingTitle: p.title,
      exists: true,
      answers: _answerViews(d.answers, p),
      source: d.source,
      updatedAt: d.updatedAt,
      notice:
          '초안만 저장되었습니다. 아직 지원이 제출되지 않았으니 SKKU Crew에서 확인 후 제출하세요.',
    );
  }

  List<AnswerView> _answerViews(
      List<_AnswerRecord> answers, _PostingRecord p) {
    final byId = {for (final a in answers) a.questionId: a.value};
    final qs = List<PostingQuestion>.from(p.questions)
      ..sort((a, b) => a.order.compareTo(b.order));
    return qs
        .map((q) => AnswerView(
              questionId: q.id,
              content: q.content,
              value: byId[q.id],
            ))
        .toList();
  }

  DisplayStatus _displayStatus(_ApplicationRecord a, _PostingRecord p) {
    if (a.withdrawn) return DisplayStatus.WITHDRAWN;
    if (p.status == PostingStatus.ANNOUNCED) {
      return a.decision == Decision.ACCEPTED
          ? DisplayStatus.ACCEPTED
          : DisplayStatus.REJECTED;
    }
    if (p.status == PostingStatus.OPEN) return DisplayStatus.SUBMITTED;
    return DisplayStatus.UNDER_REVIEW;
  }

  ExternalActivityItem _toExternalItem(
      _ExternalActivityRecord e, _MemberRecord? viewer) {
    int? dDay;
    if (e.deadline != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final target = DateTime(e.deadline!.year, e.deadline!.month, e.deadline!.day);
      final diff = target.difference(today).inDays;
      dDay = diff < 0 ? 0 : diff;
    }
    return ExternalActivityItem(
      id: e.id,
      type: e.type,
      title: e.title,
      organizer: e.organizer,
      fields: e.fields,
      source: e.source,
      postedAt: e.postedAt,
      deadline: e.deadline,
      dDay: dDay,
      url: e.url,
      bookmarked: viewer != null &&
          _bookmarks.containsKey(
              '${viewer.id}:${BookmarkTarget.EXTERNAL_ACTIVITY.name}:${e.id}'),
    );
  }

  List<int> _followersOf(int orgId) {
    final suffix = ':$orgId';
    return _follows
        .where((k) => k.endsWith(suffix))
        .map((k) => int.parse(k.split(':').first))
        .toList();
  }

  int _dDay(DateTime deadline) {
    final nowKst = DateTime.now().toUtc().add(const Duration(hours: 9));
    final dlKst = deadline.toUtc().add(const Duration(hours: 9));
    final today = DateTime(nowKst.year, nowKst.month, nowKst.day);
    final target = DateTime(dlKst.year, dlKst.month, dlKst.day);
    final diff = target.difference(today).inDays;
    return diff < 0 ? 0 : diff;
  }

  bool _matchesPosting(_PostingRecord p, _MemberRecord rec, String kw) {
    if (p.title.toLowerCase().contains(kw) ||
        p.description.toLowerCase().contains(kw)) {
      return true;
    }
    if (p.skills.any((s) => s.toLowerCase().contains(kw))) return true;
    return rec.name.toLowerCase().contains(kw);
  }

  int _matchScore(
      _PostingRecord p, _ProfileRecord pr, Set<String> mySkills) {
    final fieldHits = p.fields.where((f) => pr.fields.contains(f)).length;
    final skillHits = p.skills
        .where((s) => mySkills.contains(s.toLowerCase()))
        .length;
    return fieldHits + skillHits;
  }

  bool _matchesApplicant(_ApplicationRecord a, String kw) {
    final name = _members[a.applicantId]?.name ?? '';
    if (name.toLowerCase().contains(kw)) return true;
    if (a.withdrawn) return false;
    final skills = a.snapshot['skills'];
    if (skills is List<dynamic>) {
      for (final o in skills) {
        if (o is Map<String, dynamic> &&
            o['name'] != null &&
            o['name'].toString().toLowerCase().contains(kw)) {
          return true;
        }
      }
    }
    return false;
  }

  String? _contactValue(_MemberRecord m, _ProfileRecord pr, ContactType t) {
    switch (t) {
      case ContactType.SCHOOL_EMAIL:
        return m.schoolEmail;
      case ContactType.PHONE:
        return pr.contacts.phone;
      case ContactType.KAKAO_ID:
        return pr.contacts.kakaoId;
      case ContactType.PERSONAL_EMAIL:
        return pr.contacts.personalEmail;
    }
  }

  void _saveContactToProfile(
      _ProfileRecord pr, ContactType t, String value) {
    switch (t) {
      case ContactType.PHONE:
        pr.contacts.phone = value;
        break;
      case ContactType.KAKAO_ID:
        pr.contacts.kakaoId = value;
        break;
      case ContactType.PERSONAL_EMAIL:
        pr.contacts.personalEmail = value;
        break;
      case ContactType.SCHOOL_EMAIL:
        break;
    }
  }

  String? _maskContact(ContactType t, String? v) {
    if (v == null || v.trim().isEmpty) return null;
    if (t == ContactType.PHONE && v.length >= 13) {
      return '${v.substring(0, 4)}****${v.substring(8)}';
    }
    final at = v.indexOf('@');
    if (at > 0) {
      final local = v.substring(0, at);
      final shown = local.length <= 3 ? local[0] : local.substring(0, 3);
      return '$shown***${v.substring(at)}';
    }
    return v.length <= 3 ? '${v[0]}**' : '${v.substring(0, 3)}***';
  }

  bool _isEmptyAnswer(dynamic v) {
    if (v == null) return true;
    if (v is String) return v.trim().isEmpty;
    if (v is List<dynamic>) return v.isEmpty;
    return false;
  }

  Map<String, dynamic> _buildSnapshot(
    _MemberRecord m,
    _ProfileRecord pr,
    Map<String, dynamic> share,
    List<String> sharedItems,
  ) {
    final snap = <String, dynamic>{
      'name': m.name,
      'majorPrimary': pr.majorPrimary,
      'academicStatus': pr.academicStatus?.name,
      'fields': pr.fields.map((e) => e.name).toList(),
    };
    if (share['profileImage'] == true &&
        pr.profileImageUrl != null &&
        pr.profileImageUrl!.isNotEmpty) {
      snap['profileImageUrl'] = pr.profileImageUrl;
      sharedItems.add('profileImage');
    }
    if (share['bio'] == true && pr.bio != null && pr.bio!.isNotEmpty) {
      snap['bio'] = pr.bio;
      sharedItems.add('bio');
    }
    if (share['majorsSecondary'] == true && pr.majorsSecondary.isNotEmpty) {
      snap['majorsSecondary'] = List<String>.from(pr.majorsSecondary);
      sharedItems.add('majorsSecondary');
    }
    if (share['skills'] == true && pr.skills.isNotEmpty) {
      snap['skills'] = pr.skills
          .map((s) => {'name': s.name, 'level': s.level.name})
          .toList();
      sharedItems.add('skills');
    }
    final expIds = (share['experienceIds'] as List<dynamic>? ?? const [])
        .map((e) => (e as num).toInt())
        .toSet();
    if (expIds.isNotEmpty) {
      final exps = pr.experiences.where((e) => expIds.contains(e.id)).toList();
      if (exps.isNotEmpty) {
        snap['experiences'] = exps
            .map((e) => {
                  'type': e.type.name,
                  'title': e.title,
                  'role': e.role,
                  'startDate': e.startDate,
                  'endDate': e.endDate,
                  'description': e.description,
                })
            .toList();
        for (final e in exps) {
          sharedItems.add('experience:${e.id}');
        }
      }
    }
    final linkIds = (share['portfolioLinkIds'] as List<dynamic>? ?? const [])
        .map((e) => (e as num).toInt())
        .toSet();
    if (linkIds.isNotEmpty) {
      final links =
          pr.portfolioLinks.where((l) => linkIds.contains(l.id)).toList();
      if (links.isNotEmpty) {
        snap['portfolioLinks'] =
            links.map((l) => {'title': l.title, 'url': l.url}).toList();
        for (final l in links) {
          sharedItems.add('portfolioLink:${l.id}');
        }
      }
    }
    final fileIds = (share['portfolioFileIds'] as List<dynamic>? ?? const [])
        .map((e) => (e as num).toInt())
        .toSet();
    if (fileIds.isNotEmpty) {
      final files =
          pr.portfolioFiles.where((f) => fileIds.contains(f.id)).toList();
      if (files.isNotEmpty) {
        snap['portfolioFiles'] =
            files.map((f) => {'fileName': f.fileName, 'url': f.url}).toList();
        for (final f in files) {
          sharedItems.add('portfolioFile:${f.id}');
        }
      }
    }
    return snap;
  }

  PageResponse<T> _paginate<T>(List<T> all, int page, int size) {
    final safeSize = size <= 0 ? 20 : size.clamp(1, 100);
    final safePage = page < 0 ? 0 : page;
    final from = (safePage * safeSize).clamp(0, all.length);
    final to = (from + safeSize).clamp(0, all.length);
    return PageResponse<T>(
      items: all.sublist(from, to),
      page: safePage,
      size: safeSize,
      totalElements: all.length,
      hasNext: to < all.length,
    );
  }
}

// ---------------- 내부 엔터티 레코드 ----------------

DateTime _plusDays(DateTime base, double days) {
  return base.add(Duration(minutes: (days * 24 * 60).round()));
}

class _MemberRecord {
  _MemberRecord({
    required this.id,
    required this.type,
    required this.name,
    this.schoolEmail,
    this.contactEmail,
    this.orgIntro,
    this.demoDescription,
    this.orgType,
    this.verified = false,
    this.logoUrl,
    this.orgFields = const [],
    this.orgLinks = const [],
  });

  final int id;
  final MemberType type;
  String name;
  final String? schoolEmail;
  final String? contactEmail;
  final String? orgIntro;
  final String? demoDescription;
  final String? orgType;
  final bool verified;
  final String? logoUrl;
  final List<Field> orgFields;
  final List<OrgLink> orgLinks;

  factory _MemberRecord.fromJson(Map<String, dynamic> j) => _MemberRecord(
        id: (j['id'] as num).toInt(),
        type: MemberType.fromApi(j['type']?.toString()),
        name: j['name']?.toString() ?? '',
        schoolEmail: j['schoolEmail']?.toString(),
        contactEmail: j['contactEmail']?.toString(),
        orgIntro: j['orgIntro']?.toString(),
        demoDescription: j['demoDescription']?.toString(),
        orgType: j['orgType']?.toString(),
        verified: j['verified'] as bool? ?? false,
        logoUrl: j['logoUrl']?.toString(),
        orgFields: (j['orgFields'] as List<dynamic>? ?? const [])
            .map((e) => Field.fromApi(e.toString()))
            .toList(),
        orgLinks: (j['orgLinks'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(OrgLink.fromJson)
            .toList(),
      );
}

class _SkillRecord {
  _SkillRecord({required this.id, required this.name, required this.level});
  final int id;
  final String name;
  final SkillLevel level;

  factory _SkillRecord.fromJson(Map<String, dynamic> j) => _SkillRecord(
        id: (j['id'] as num?)?.toInt() ?? 0,
        name: j['name']?.toString() ?? '',
        level: SkillLevel.fromApi(j['level']?.toString()),
      );
}

class _ExperienceRecord {
  _ExperienceRecord({
    required this.id,
    required this.type,
    required this.title,
    this.role,
    this.startDate,
    this.endDate,
    this.description,
  });

  final int id;
  final ExperienceType type;
  final String title;
  final String? role;
  final String? startDate;
  final String? endDate;
  final String? description;

  factory _ExperienceRecord.fromJson(Map<String, dynamic> j) =>
      _ExperienceRecord(
        id: (j['id'] as num?)?.toInt() ?? 0,
        type: ExperienceType.fromApi(j['type']?.toString()),
        title: j['title']?.toString() ?? '',
        role: j['role']?.toString(),
        startDate: j['startDate']?.toString(),
        endDate: j['endDate']?.toString(),
        description: j['description']?.toString(),
      );
}

class _PortfolioLinkRecord {
  _PortfolioLinkRecord(
      {required this.id, required this.title, required this.url});
  final int id;
  final String title;
  final String url;

  factory _PortfolioLinkRecord.fromJson(Map<String, dynamic> j) =>
      _PortfolioLinkRecord(
        id: (j['id'] as num?)?.toInt() ?? 0,
        title: j['title']?.toString() ?? '',
        url: j['url']?.toString() ?? '',
      );
}

class _PortfolioFileRecord {
  _PortfolioFileRecord(
      {required this.id, required this.fileName, required this.url});
  final int id;
  final String fileName;
  final String url;

  factory _PortfolioFileRecord.fromJson(Map<String, dynamic> j) =>
      _PortfolioFileRecord(
        id: (j['id'] as num?)?.toInt() ?? 0,
        fileName: j['fileName']?.toString() ?? '',
        url: j['url']?.toString() ?? '',
      );
}

class _ContactsRecord {
  _ContactsRecord({this.phone, this.kakaoId, this.personalEmail});
  String? phone;
  String? kakaoId;
  String? personalEmail;

  factory _ContactsRecord.fromJson(Map<String, dynamic>? j) => _ContactsRecord(
        phone: j?['phone']?.toString(),
        kakaoId: j?['kakaoId']?.toString(),
        personalEmail: j?['personalEmail']?.toString(),
      );
}

class _ActivityHistoryRecord {
  _ActivityHistoryRecord({
    required this.applicationId,
    required this.postingId,
    required this.postingTitle,
    required this.recruiterName,
    this.announcedAt,
    required this.visible,
  });

  final int applicationId;
  final int postingId;
  final String postingTitle;
  final String recruiterName;
  DateTime? announcedAt;
  bool visible;

  factory _ActivityHistoryRecord.fromJson(Map<String, dynamic> j) =>
      _ActivityHistoryRecord(
        applicationId: (j['applicationId'] as num?)?.toInt() ?? 0,
        postingId: (j['postingId'] as num?)?.toInt() ?? 0,
        postingTitle: j['postingTitle']?.toString() ?? '',
        recruiterName: j['recruiterName']?.toString() ?? '',
        announcedAt: j['announcedAt'] != null
            ? DateTime.tryParse(j['announcedAt'].toString())
            : null,
        visible: j['visible'] as bool? ?? true,
      );
}

class _ProfileRecord {
  _ProfileRecord({
    required this.memberId,
    this.profileImageUrl,
    this.majorPrimary,
    List<String>? majorsSecondary,
    this.academicStatus,
    this.bio,
    List<Field>? fields,
    List<_SkillRecord>? skills,
    List<_ExperienceRecord>? experiences,
    List<_PortfolioLinkRecord>? portfolioLinks,
    List<_PortfolioFileRecord>? portfolioFiles,
    _ContactsRecord? contacts,
    Map<String, bool>? defaultShare,
    List<_ActivityHistoryRecord>? activityHistory,
  })  : majorsSecondary = majorsSecondary ?? [],
        fields = fields ?? [],
        skills = skills ?? [],
        experiences = experiences ?? [],
        portfolioLinks = portfolioLinks ?? [],
        portfolioFiles = portfolioFiles ?? [],
        contacts = contacts ?? _ContactsRecord(),
        defaultShare = defaultShare ?? {},
        activityHistory = activityHistory ?? [];

  final int memberId;
  String? profileImageUrl;
  String? majorPrimary;
  List<String> majorsSecondary;
  AcademicStatus? academicStatus;
  String? bio;
  List<Field> fields;
  List<_SkillRecord> skills;
  List<_ExperienceRecord> experiences;
  List<_PortfolioLinkRecord> portfolioLinks;
  List<_PortfolioFileRecord> portfolioFiles;
  _ContactsRecord contacts;
  Map<String, bool> defaultShare;
  List<_ActivityHistoryRecord> activityHistory;

  bool get isRequiredFilled =>
      majorPrimary != null &&
      majorPrimary!.trim().isNotEmpty &&
      academicStatus != null &&
      fields.isNotEmpty;

  int get completeness {
    var score = isRequiredFilled ? 40 : 0;
    if (profileImageUrl != null && profileImageUrl!.trim().isNotEmpty) {
      score += 10;
    }
    if (bio != null && bio!.trim().isNotEmpty) score += 10;
    if (skills.isNotEmpty) score += 10;
    if (experiences.isNotEmpty) score += 10;
    if (portfolioLinks.isNotEmpty || portfolioFiles.isNotEmpty) score += 10;
    final hasContact = (contacts.phone?.trim().isNotEmpty ?? false) ||
        (contacts.kakaoId?.trim().isNotEmpty ?? false) ||
        (contacts.personalEmail?.trim().isNotEmpty ?? false);
    if (hasContact) score += 10;
    return score;
  }

  factory _ProfileRecord.fromJson(Map<String, dynamic> j) => _ProfileRecord(
        memberId: (j['memberId'] as num).toInt(),
        profileImageUrl: j['profileImageUrl']?.toString(),
        majorPrimary: j['majorPrimary']?.toString(),
        majorsSecondary: (j['majorsSecondary'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        academicStatus: j['academicStatus'] != null
            ? AcademicStatus.fromApi(j['academicStatus'].toString())
            : null,
        bio: j['bio']?.toString(),
        fields: (j['fields'] as List<dynamic>? ?? const [])
            .map((e) => Field.fromApi(e.toString()))
            .toList(),
        skills: (j['skills'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(_SkillRecord.fromJson)
            .toList(),
        experiences: (j['experiences'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(_ExperienceRecord.fromJson)
            .toList(),
        portfolioLinks: (j['portfolioLinks'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(_PortfolioLinkRecord.fromJson)
            .toList(),
        portfolioFiles: (j['portfolioFiles'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(_PortfolioFileRecord.fromJson)
            .toList(),
        contacts:
            _ContactsRecord.fromJson(j['contacts'] as Map<String, dynamic>?),
        defaultShare: ((j['defaultShare'] as Map<String, dynamic>?) ?? const {})
            .map((k, v) => MapEntry(k, v == true)),
        activityHistory: (j['activityHistory'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(_ActivityHistoryRecord.fromJson)
            .toList(),
      );
}

class _PostingRecord {
  _PostingRecord({
    required this.id,
    required this.recruiterId,
    required this.category,
    required this.title,
    required this.fields,
    required this.capacity,
    required this.deadline,
    this.activityStart,
    this.activityEnd,
    required this.activityMode,
    this.place,
    required this.skills,
    required this.description,
    this.imageUrl,
    required this.questions,
    required this.requestedContacts,
    required this.status,
    this.acceptMessage,
    this.rejectMessage,
    this.announcedAt,
    required this.createdAt,
  });

  final int id;
  final int recruiterId;
  final Category category;
  final String title;
  final List<Field> fields;
  final int capacity;
  final DateTime deadline;
  final String? activityStart;
  final String? activityEnd;
  final ActivityMode activityMode;
  final String? place;
  final List<String> skills;
  final String description;
  final String? imageUrl;
  final List<PostingQuestion> questions;
  final List<ContactType> requestedContacts;
  PostingStatus status;
  String? acceptMessage;
  String? rejectMessage;
  DateTime? announcedAt;
  final DateTime createdAt;

  factory _PostingRecord.fromJson(Map<String, dynamic> j, DateTime now) {
    final dlDays = (j['deadlineDaysFromNow'] as num?)?.toDouble() ?? 5.0;
    final crDays = (j['createdDaysAgo'] as num?)?.toDouble() ?? 1.0;
    final anDays = (j['announcedDaysAgo'] as num?)?.toDouble();
    return _PostingRecord(
      id: (j['id'] as num).toInt(),
      recruiterId: (j['recruiterId'] as num).toInt(),
      category: Category.fromApi(j['category']?.toString()),
      title: j['title']?.toString() ?? '',
      fields: (j['fields'] as List<dynamic>? ?? const [])
          .map((e) => Field.fromApi(e.toString()))
          .toList(),
      capacity: (j['capacity'] as num?)?.toInt() ?? 1,
      deadline: _plusDays(now, dlDays),
      activityStart: j['activityStart']?.toString(),
      activityEnd: j['activityEnd']?.toString(),
      activityMode: ActivityMode.fromApi(j['activityMode']?.toString()),
      place: j['place']?.toString(),
      skills: (j['skills'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      description: j['description']?.toString() ?? '',
      imageUrl: j['imageUrl']?.toString(),
      questions: (j['questions'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(PostingQuestion.fromJson)
          .toList(),
      requestedContacts:
          (j['requestedContacts'] as List<dynamic>? ?? const [])
              .map((e) => ContactType.fromApi(e.toString()))
              .toList(),
      status: PostingStatus.fromApi(j['status']?.toString()),
      acceptMessage: j['acceptMessage']?.toString(),
      rejectMessage: j['rejectMessage']?.toString(),
      announcedAt: anDays == null ? null : _plusDays(now, -anDays),
      createdAt: _plusDays(now, -crDays),
    );
  }
}

class _SharedContactRecord {
  _SharedContactRecord({
    required this.type,
    required this.value,
    required this.consent,
  });

  final ContactType type;
  final String value;
  final bool consent;

  factory _SharedContactRecord.fromJson(Map<String, dynamic> j) =>
      _SharedContactRecord(
        type: ContactType.fromApi(j['type']?.toString()),
        value: j['value']?.toString() ?? '',
        consent: j['consent'] as bool? ?? true,
      );
}

class _AnswerRecord {
  _AnswerRecord({required this.questionId, this.value});
  final int questionId;
  final dynamic value;

  factory _AnswerRecord.fromJson(Map<String, dynamic> j) => _AnswerRecord(
        questionId: (j['questionId'] as num).toInt(),
        value: j['value'],
      );
}

class _ApplicationRecord {
  _ApplicationRecord({
    required this.id,
    required this.postingId,
    required this.applicantId,
    required this.snapshot,
    required this.sharedItems,
    required this.contacts,
    required this.answers,
    this.withdrawn = false,
    this.decision = Decision.PENDING,
    this.memo,
    required this.submittedAt,
    this.disclosedAt,
  });

  final int id;
  final int postingId;
  final int applicantId;
  final Map<String, dynamic> snapshot;
  final List<String> sharedItems;
  final List<_SharedContactRecord> contacts;
  final List<_AnswerRecord> answers;
  bool withdrawn;
  Decision decision;
  String? memo;
  final DateTime submittedAt;
  DateTime? disclosedAt;

  factory _ApplicationRecord.fromJson(
    Map<String, dynamic> j,
    DateTime now,
    Map<int, _PostingRecord> postings,
  ) {
    final postingId = (j['postingId'] as num).toInt();
    final decision = Decision.fromApi(j['decision']?.toString());
    final subDays = (j['submittedDaysAgo'] as num?)?.toDouble() ?? 1.0;
    final p = postings[postingId];
    DateTime? disclosed;
    if (decision == Decision.ACCEPTED &&
        p != null &&
        p.status == PostingStatus.ANNOUNCED) {
      disclosed = p.announcedAt;
    }
    return _ApplicationRecord(
      id: (j['id'] as num).toInt(),
      postingId: postingId,
      applicantId: (j['applicantId'] as num).toInt(),
      snapshot: (j['snapshot'] as Map<String, dynamic>?) ?? const {},
      sharedItems: (j['sharedItems'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      contacts: (j['contacts'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(_SharedContactRecord.fromJson)
          .toList(),
      answers: (j['answers'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(_AnswerRecord.fromJson)
          .toList(),
      withdrawn: j['withdrawn'] as bool? ?? false,
      decision: decision,
      memo: j['memo']?.toString(),
      submittedAt: _plusDays(now, -subDays),
      disclosedAt: disclosed,
    );
  }
}

class _ExternalActivityRecord {
  _ExternalActivityRecord({
    required this.id,
    required this.type,
    required this.title,
    required this.organizer,
    required this.fields,
    required this.source,
    required this.postedAt,
    this.deadline,
    required this.url,
  });

  final int id;
  final ExternalType type;
  final String title;
  final String organizer;
  final List<Field> fields;
  final String source;
  final DateTime postedAt;
  final DateTime? deadline;
  final String url;

  factory _ExternalActivityRecord.fromJson(
      Map<String, dynamic> j, DateTime now) {
    final postedAgo = (j['postedDaysAgo'] as num?)?.toInt() ?? 1;
    final dlDays = (j['deadlineDaysFromNow'] as num?)?.toInt();
    return _ExternalActivityRecord(
      id: (j['id'] as num).toInt(),
      type: ExternalType.fromApi(j['type']?.toString()),
      title: j['title']?.toString() ?? '',
      organizer: j['organizer']?.toString() ?? '',
      fields: (j['fields'] as List<dynamic>? ?? const [])
          .map((e) => Field.fromApi(e.toString()))
          .toList(),
      source: j['source']?.toString() ?? 'PUBLIC_API',
      postedAt: now.subtract(Duration(days: postedAgo)),
      deadline: dlDays == null ? null : now.add(Duration(days: dlDays)),
      url: j['url']?.toString() ?? '',
    );
  }
}

class _BookmarkRecord {
  _BookmarkRecord({
    required this.memberId,
    required this.targetType,
    required this.targetId,
    required this.createdAt,
  });

  final int memberId;
  final BookmarkTarget targetType;
  final int targetId;
  final DateTime createdAt;

  String get key => '$memberId:${targetType.name}:$targetId';

  factory _BookmarkRecord.fromJson(Map<String, dynamic> j, DateTime now) {
    final days = (j['createdDaysAgo'] as num?)?.toDouble() ?? 1.0;
    return _BookmarkRecord(
      memberId: (j['memberId'] as num).toInt(),
      targetType: BookmarkTarget.fromApi(j['targetType']?.toString()),
      targetId: (j['targetId'] as num).toInt(),
      createdAt: _plusDays(now, -days),
    );
  }
}

class _NotificationRecord {
  _NotificationRecord({
    required this.id,
    required this.memberId,
    required this.type,
    required this.title,
    required this.body,
    required this.targetScreen,
    this.postingId,
    this.applicationId,
    required this.read,
    required this.createdAt,
  });

  final int id;
  final int memberId;
  final NotificationType type;
  final String title;
  final String body;
  final String targetScreen;
  final int? postingId;
  final int? applicationId;
  bool read;
  final DateTime createdAt;

  factory _NotificationRecord.fromJson(Map<String, dynamic> j, DateTime now) {
    final days = (j['createdDaysAgo'] as num?)?.toDouble() ?? 1.0;
    return _NotificationRecord(
      id: (j['id'] as num).toInt(),
      memberId: (j['memberId'] as num).toInt(),
      type: NotificationType.fromApi(j['type']?.toString()),
      title: j['title']?.toString() ?? '',
      body: j['body']?.toString() ?? '',
      targetScreen: j['targetScreen']?.toString() ?? 'SCR-06',
      postingId: (j['postingId'] as num?)?.toInt(),
      applicationId: (j['applicationId'] as num?)?.toInt(),
      read: j['read'] as bool? ?? false,
      createdAt: _plusDays(now, -days),
    );
  }

  NotificationItem toDto() => NotificationItem(
        id: id,
        type: type,
        title: title,
        body: body,
        targetScreen: targetScreen,
        postingId: postingId,
        applicationId: applicationId,
        read: read,
        createdAt: createdAt,
      );
}

class _DraftRecord {
  _DraftRecord({
    required this.memberId,
    required this.postingId,
    required this.answers,
    required this.source,
    required this.updatedAt,
  });

  final int memberId;
  final int postingId;
  final List<_AnswerRecord> answers;
  final DraftSource source;
  final DateTime updatedAt;

  String get key => '$memberId:$postingId';

  factory _DraftRecord.fromJson(Map<String, dynamic> j, DateTime now) {
    final days = (j['updatedDaysAgo'] as num?)?.toDouble() ?? 0.3;
    return _DraftRecord(
      memberId: (j['memberId'] as num).toInt(),
      postingId: (j['postingId'] as num).toInt(),
      answers: (j['answers'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(_AnswerRecord.fromJson)
          .toList(),
      source: DraftSource.fromApiNullable(j['source']?.toString()) ??
          DraftSource.WEB,
      updatedAt: _plusDays(now, -days),
    );
  }
}
