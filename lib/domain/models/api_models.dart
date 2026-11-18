import '../../core/constants/codes.dart';

/// SRS 표 3-29 오류 응답 및 FieldError 모델.
class FieldErrorItem {
  const FieldErrorItem({required this.field, required this.message});

  final String field;
  final String message;

  factory FieldErrorItem.fromJson(Map<String, dynamic> json) => FieldErrorItem(
        field: json['field']?.toString() ?? '',
        message: json['message']?.toString() ?? '',
      );
}

class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
    this.fieldErrors = const [],
  });

  final int statusCode;
  final String code;
  final String message;
  final List<FieldErrorItem> fieldErrors;

  factory ApiException.fromResponse(int statusCode, Map<String, dynamic> json) {
    final rawErrors = json['fieldErrors'] as List<dynamic>? ?? const [];
    return ApiException(
      statusCode: statusCode,
      code: json['code']?.toString() ?? 'ERROR',
      message: json['message']?.toString() ?? '요청 처리 중 오류가 발생했습니다.',
      fieldErrors: rawErrors
          .whereType<Map<String, dynamic>>()
          .map(FieldErrorItem.fromJson)
          .toList(),
    );
  }

  @override
  String toString() => 'ApiException($statusCode, $code): $message';
}

class PageResponse<T> {
  const PageResponse({
    required this.items,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.hasNext,
  });

  final List<T> items;
  final int page;
  final int size;
  final int totalElements;
  final bool hasNext;

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    return PageResponse<T>(
      items: rawItems.whereType<Map<String, dynamic>>().map(fromItem).toList(),
      page: (json['page'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? 20,
      totalElements: (json['totalElements'] as num?)?.toInt() ?? 0,
      hasNext: json['hasNext'] as bool? ?? false,
    );
  }
}

// ---------------- 인증 ----------------

class DemoAccount {
  const DemoAccount({
    required this.memberId,
    required this.name,
    required this.memberType,
    this.description,
  });

  final int memberId;
  final String name;
  final MemberType memberType;
  final String? description;

  factory DemoAccount.fromJson(Map<String, dynamic> json) => DemoAccount(
        memberId: (json['memberId'] as num).toInt(),
        name: json['name']?.toString() ?? '',
        memberType: MemberType.fromApi(json['memberType']?.toString()),
        description: json['description']?.toString(),
      );
}

class MeResponse {
  const MeResponse({
    required this.memberId,
    required this.name,
    required this.memberType,
    this.schoolEmail,
    this.profileCompleted,
    this.profileCompleteness,
  });

  final int memberId;
  final String name;
  final MemberType memberType;
  final String? schoolEmail;
  final bool? profileCompleted;
  final int? profileCompleteness;

  factory MeResponse.fromJson(Map<String, dynamic> json) => MeResponse(
        memberId: (json['memberId'] as num).toInt(),
        name: json['name']?.toString() ?? '',
        memberType: MemberType.fromApi(json['memberType']?.toString()),
        schoolEmail: json['schoolEmail']?.toString(),
        profileCompleted: json['profileCompleted'] as bool?,
        profileCompleteness: (json['profileCompleteness'] as num?)?.toInt(),
      );
}

class LoginResponse {
  const LoginResponse({required this.accessToken, required this.member});

  final String accessToken;
  final MeResponse member;

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        accessToken: json['accessToken']?.toString() ?? '',
        member: MeResponse.fromJson(
          (json['member'] as Map<String, dynamic>?) ?? const {},
        ),
      );
}

// ---------------- 프로필 ----------------

class SkillItem {
  const SkillItem({this.id, required this.name, required this.level});

  final int? id;
  final String name;
  final SkillLevel level;

  factory SkillItem.fromJson(Map<String, dynamic> json) => SkillItem(
        id: (json['id'] as num?)?.toInt(),
        name: json['name']?.toString() ?? '',
        level: SkillLevel.fromApi(json['level']?.toString()),
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        'level': level.name,
      };
}

class ExperienceItem {
  const ExperienceItem({
    this.id,
    required this.type,
    required this.title,
    this.role,
    this.startDate,
    this.endDate,
    this.description,
  });

  final int? id;
  final ExperienceType type;
  final String title;
  final String? role;
  final String? startDate;
  final String? endDate;
  final String? description;

  factory ExperienceItem.fromJson(Map<String, dynamic> json) => ExperienceItem(
        id: (json['id'] as num?)?.toInt(),
        type: ExperienceType.fromApi(json['type']?.toString()),
        title: json['title']?.toString() ?? '',
        role: json['role']?.toString(),
        startDate: json['startDate']?.toString(),
        endDate: json['endDate']?.toString(),
        description: json['description']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'type': type.name,
        'title': title,
        'role': role,
        'startDate': startDate,
        'endDate': endDate,
        'description': description,
      };
}

class PortfolioLinkItem {
  const PortfolioLinkItem({this.id, required this.title, required this.url});

  final int? id;
  final String title;
  final String url;

  factory PortfolioLinkItem.fromJson(Map<String, dynamic> json) =>
      PortfolioLinkItem(
        id: (json['id'] as num?)?.toInt(),
        title: json['title']?.toString() ?? '',
        url: json['url']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'title': title,
        'url': url,
      };
}

class PortfolioFileItem {
  const PortfolioFileItem({this.id, required this.fileName, required this.url});

  final int? id;
  final String fileName;
  final String url;

  factory PortfolioFileItem.fromJson(Map<String, dynamic> json) =>
      PortfolioFileItem(
        id: (json['id'] as num?)?.toInt(),
        fileName: json['fileName']?.toString() ?? '',
        url: json['url']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'fileName': fileName,
        'url': url,
      };
}

class ContactsData {
  const ContactsData({this.phone, this.kakaoId, this.personalEmail});

  final String? phone;
  final String? kakaoId;
  final String? personalEmail;

  factory ContactsData.fromJson(Map<String, dynamic> json) => ContactsData(
        phone: json['phone']?.toString(),
        kakaoId: json['kakaoId']?.toString(),
        personalEmail: json['personalEmail']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'kakaoId': kakaoId,
        'personalEmail': personalEmail,
      };
}

class ActivityHistoryItem {
  const ActivityHistoryItem({
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
  final DateTime? announcedAt;
  final bool visible;

  factory ActivityHistoryItem.fromJson(Map<String, dynamic> json) =>
      ActivityHistoryItem(
        applicationId: (json['applicationId'] as num?)?.toInt() ?? 0,
        postingId: (json['postingId'] as num?)?.toInt() ?? 0,
        postingTitle: json['postingTitle']?.toString() ?? '',
        recruiterName: json['recruiterName']?.toString() ?? '',
        announcedAt: json['announcedAt'] != null
            ? DateTime.tryParse(json['announcedAt'].toString())
            : null,
        visible: json['visible'] as bool? ?? true,
      );
}

class ProfileResponse {
  const ProfileResponse({
    required this.name,
    this.schoolEmail,
    this.profileImageUrl,
    this.majorPrimary,
    this.majorsSecondary = const [],
    this.academicStatus,
    this.bio,
    this.fields = const [],
    this.skills = const [],
    this.experiences = const [],
    this.portfolioLinks = const [],
    this.portfolioFiles = const [],
    required this.contacts,
    this.defaultShare = const {},
    this.activityHistory = const [],
    required this.completeness,
  });

  final String name;
  final String? schoolEmail;
  final String? profileImageUrl;
  final String? majorPrimary;
  final List<String> majorsSecondary;
  final AcademicStatus? academicStatus;
  final String? bio;
  final List<Field> fields;
  final List<SkillItem> skills;
  final List<ExperienceItem> experiences;
  final List<PortfolioLinkItem> portfolioLinks;
  final List<PortfolioFileItem> portfolioFiles;
  final ContactsData contacts;
  final Map<String, bool> defaultShare;
  final List<ActivityHistoryItem> activityHistory;
  final int completeness;

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    final rawShare = json['defaultShare'] as Map<String, dynamic>? ?? const {};
    return ProfileResponse(
      name: json['name']?.toString() ?? '',
      schoolEmail: json['schoolEmail']?.toString(),
      profileImageUrl: json['profileImageUrl']?.toString(),
      majorPrimary: json['majorPrimary']?.toString(),
      majorsSecondary: (json['majorsSecondary'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      academicStatus: json['academicStatus'] != null
          ? AcademicStatus.fromApi(json['academicStatus'].toString())
          : null,
      bio: json['bio']?.toString(),
      fields: (json['fields'] as List<dynamic>? ?? const [])
          .map((e) => Field.fromApi(e.toString()))
          .toList(),
      skills: (json['skills'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SkillItem.fromJson)
          .toList(),
      experiences: (json['experiences'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ExperienceItem.fromJson)
          .toList(),
      portfolioLinks: (json['portfolioLinks'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(PortfolioLinkItem.fromJson)
          .toList(),
      portfolioFiles: (json['portfolioFiles'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(PortfolioFileItem.fromJson)
          .toList(),
      contacts: ContactsData.fromJson(
        (json['contacts'] as Map<String, dynamic>?) ?? const {},
      ),
      defaultShare: rawShare.map((k, v) => MapEntry(k, v == true)),
      activityHistory: (json['activityHistory'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ActivityHistoryItem.fromJson)
          .toList(),
      completeness: (json['completeness'] as num?)?.toInt() ?? 0,
    );
  }

  bool get isRequiredFilled =>
      majorPrimary != null &&
      majorPrimary!.trim().isNotEmpty &&
      academicStatus != null &&
      fields.isNotEmpty;
}

class ProfileUpdateRequest {
  const ProfileUpdateRequest({
    required this.name,
    this.profileImageUrl,
    this.majorPrimary,
    this.majorsSecondary = const [],
    this.academicStatus,
    this.bio,
    this.fields = const [],
    this.skills = const [],
    this.experiences = const [],
    this.portfolioLinks = const [],
    this.portfolioFiles = const [],
    required this.contacts,
    this.defaultShare = const {},
  });

  final String name;
  final String? profileImageUrl;
  final String? majorPrimary;
  final List<String> majorsSecondary;
  final AcademicStatus? academicStatus;
  final String? bio;
  final List<Field> fields;
  final List<SkillItem> skills;
  final List<ExperienceItem> experiences;
  final List<PortfolioLinkItem> portfolioLinks;
  final List<PortfolioFileItem> portfolioFiles;
  final ContactsData contacts;
  final Map<String, bool> defaultShare;

  Map<String, dynamic> toJson() => {
        'name': name,
        'profileImageUrl': profileImageUrl,
        'majorPrimary': majorPrimary,
        'majorsSecondary': majorsSecondary,
        'academicStatus': academicStatus?.name,
        'bio': bio,
        'fields': fields.map((e) => e.name).toList(),
        'skills': skills.map((e) => e.toJson()).toList(),
        'experiences': experiences.map((e) => e.toJson()).toList(),
        'portfolioLinks': portfolioLinks.map((e) => e.toJson()).toList(),
        'portfolioFiles': portfolioFiles.map((e) => e.toJson()).toList(),
        'contacts': contacts.toJson(),
        'defaultShare': defaultShare,
      };
}

// ---------------- 공고 ----------------

class RecruiterView {
  const RecruiterView({
    required this.type,
    required this.memberId,
    required this.name,
    this.department,
    this.orgType,
    required this.verified,
  });

  final MemberType type;
  final int memberId;
  final String name;
  final String? department;
  final String? orgType;
  final bool verified;

  String get displayTitle {
    if (type == MemberType.PERSONAL &&
        department != null &&
        department!.isNotEmpty) {
      return '$name ($department)';
    }
    return name;
  }

  factory RecruiterView.fromJson(Map<String, dynamic> json) => RecruiterView(
        type: MemberType.fromApi(json['type']?.toString()),
        memberId: (json['memberId'] as num?)?.toInt() ?? 0,
        name: json['name']?.toString() ?? '',
        department: json['department']?.toString(),
        orgType: json['orgType']?.toString(),
        verified: json['verified'] as bool? ?? false,
      );
}

class PostingQuestion {
  const PostingQuestion({
    required this.id,
    required this.order,
    required this.type,
    required this.content,
    required this.required,
    this.maxLength,
    this.options,
  });

  final int id;
  final int order;
  final QuestionType type;
  final String content;
  final bool required;
  final int? maxLength;
  final List<String>? options;

  factory PostingQuestion.fromJson(Map<String, dynamic> json) =>
      PostingQuestion(
        id: (json['id'] as num?)?.toInt() ?? 0,
        order: (json['order'] as num?)?.toInt() ?? 0,
        type: QuestionType.fromApi(json['type']?.toString()),
        content: json['content']?.toString() ?? '',
        required: json['required'] as bool? ?? false,
        maxLength: (json['maxLength'] as num?)?.toInt(),
        options: (json['options'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
      );
}

class PostingCard {
  const PostingCard({
    required this.postingId,
    required this.category,
    required this.title,
    required this.recruiter,
    required this.fields,
    required this.skills,
    required this.capacity,
    this.deadline,
    this.dDay,
    required this.status,
    required this.requestsContact,
    required this.bookmarked,
  });

  final int postingId;
  final Category category;
  final String title;
  final RecruiterView recruiter;
  final List<Field> fields;
  final List<String> skills;
  final int capacity;
  final DateTime? deadline;
  final int? dDay;
  final PostingStatus status;
  final bool requestsContact;
  final bool bookmarked;

  PostingCard copyWith({bool? bookmarked}) => PostingCard(
        postingId: postingId,
        category: category,
        title: title,
        recruiter: recruiter,
        fields: fields,
        skills: skills,
        capacity: capacity,
        deadline: deadline,
        dDay: dDay,
        status: status,
        requestsContact: requestsContact,
        bookmarked: bookmarked ?? this.bookmarked,
      );

  factory PostingCard.fromJson(Map<String, dynamic> json) => PostingCard(
        postingId: (json['postingId'] as num).toInt(),
        category: Category.fromApi(json['category']?.toString()),
        title: json['title']?.toString() ?? '',
        recruiter: RecruiterView.fromJson(
          (json['recruiter'] as Map<String, dynamic>?) ?? const {},
        ),
        fields: (json['fields'] as List<dynamic>? ?? const [])
            .map((e) => Field.fromApi(e.toString()))
            .toList(),
        skills: (json['skills'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        capacity: (json['capacity'] as num?)?.toInt() ?? 1,
        deadline: json['deadline'] != null
            ? DateTime.tryParse(json['deadline'].toString())
            : null,
        dDay: (json['dDay'] as num?)?.toInt(),
        status: PostingStatus.fromApi(json['status']?.toString()),
        requestsContact: json['requestsContact'] as bool? ?? false,
        bookmarked: json['bookmarked'] as bool? ?? false,
      );
}

class PostingDetail {
  const PostingDetail({
    required this.postingId,
    required this.category,
    required this.title,
    required this.recruiter,
    required this.fields,
    required this.capacity,
    this.deadline,
    this.dDay,
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
    this.applicantCount,
    required this.viewerAction,
    required this.bookmarked,
    this.createdAt,
  });

  final int postingId;
  final Category category;
  final String title;
  final RecruiterView recruiter;
  final List<Field> fields;
  final int capacity;
  final DateTime? deadline;
  final int? dDay;
  final String? activityStart;
  final String? activityEnd;
  final ActivityMode activityMode;
  final String? place;
  final List<String> skills;
  final String description;
  final String? imageUrl;
  final List<PostingQuestion> questions;
  final List<ContactType> requestedContacts;
  final PostingStatus status;
  final int? applicantCount;
  final ViewerAction viewerAction;
  final bool bookmarked;
  final DateTime? createdAt;

  PostingDetail copyWith({bool? bookmarked}) => PostingDetail(
        postingId: postingId,
        category: category,
        title: title,
        recruiter: recruiter,
        fields: fields,
        capacity: capacity,
        deadline: deadline,
        dDay: dDay,
        activityStart: activityStart,
        activityEnd: activityEnd,
        activityMode: activityMode,
        place: place,
        skills: skills,
        description: description,
        imageUrl: imageUrl,
        questions: questions,
        requestedContacts: requestedContacts,
        status: status,
        applicantCount: applicantCount,
        viewerAction: viewerAction,
        bookmarked: bookmarked ?? this.bookmarked,
        createdAt: createdAt,
      );

  factory PostingDetail.fromJson(Map<String, dynamic> json) => PostingDetail(
        postingId: (json['postingId'] as num).toInt(),
        category: Category.fromApi(json['category']?.toString()),
        title: json['title']?.toString() ?? '',
        recruiter: RecruiterView.fromJson(
          (json['recruiter'] as Map<String, dynamic>?) ?? const {},
        ),
        fields: (json['fields'] as List<dynamic>? ?? const [])
            .map((e) => Field.fromApi(e.toString()))
            .toList(),
        capacity: (json['capacity'] as num?)?.toInt() ?? 1,
        deadline: json['deadline'] != null
            ? DateTime.tryParse(json['deadline'].toString())
            : null,
        dDay: (json['dDay'] as num?)?.toInt(),
        activityStart: json['activityStart']?.toString(),
        activityEnd: json['activityEnd']?.toString(),
        activityMode: ActivityMode.fromApi(json['activityMode']?.toString()),
        place: json['place']?.toString(),
        skills: (json['skills'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        description: json['description']?.toString() ?? '',
        imageUrl: json['imageUrl']?.toString(),
        questions: (json['questions'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(PostingQuestion.fromJson)
            .toList(),
        requestedContacts:
            (json['requestedContacts'] as List<dynamic>? ?? const [])
                .map((e) => ContactType.fromApi(e.toString()))
                .toList(),
        status: PostingStatus.fromApi(json['status']?.toString()),
        applicantCount: (json['applicantCount'] as num?)?.toInt(),
        viewerAction: ViewerAction.fromApi(json['viewerAction']?.toString()),
        bookmarked: json['bookmarked'] as bool? ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString())
            : null,
      );
}

class HomeResponse {
  const HomeResponse({required this.recommended, required this.closingSoon});

  final List<PostingCard> recommended;
  final List<PostingCard> closingSoon;

  factory HomeResponse.fromJson(Map<String, dynamic> json) => HomeResponse(
        recommended: (json['recommended'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(PostingCard.fromJson)
            .toList(),
        closingSoon: (json['closingSoon'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(PostingCard.fromJson)
            .toList(),
      );
}

class QuestionInput {
  const QuestionInput({
    required this.type,
    required this.content,
    required this.required,
    this.maxLength,
    this.options,
  });

  final QuestionType type;
  final String content;
  final bool required;
  final int? maxLength;
  final List<String>? options;

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'content': content,
        'required': required,
        'maxLength': maxLength,
        'options': options,
      };
}

class PostingCreateRequest {
  const PostingCreateRequest({
    required this.publish,
    required this.category,
    required this.title,
    required this.fields,
    required this.capacity,
    required this.deadline,
    this.activityStart,
    this.activityEnd,
    required this.activityMode,
    this.place,
    this.skills = const [],
    required this.description,
    this.imageUrl,
    this.questions = const [],
    this.requestedContacts = const [],
  });

  final bool publish;
  final Category category;
  final String title;
  final List<Field> fields;
  final int capacity;
  final String deadline;
  final String? activityStart;
  final String? activityEnd;
  final ActivityMode activityMode;
  final String? place;
  final List<String> skills;
  final String description;
  final String? imageUrl;
  final List<QuestionInput> questions;
  final List<ContactType> requestedContacts;

  Map<String, dynamic> toJson() => {
        'publish': publish,
        'category': category.name,
        'title': title,
        'fields': fields.map((e) => e.name).toList(),
        'capacity': capacity,
        'deadline': deadline,
        'activityStart': activityStart,
        'activityEnd': activityEnd,
        'activityMode': activityMode.name,
        'place': place,
        'skills': skills,
        'description': description,
        'imageUrl': imageUrl,
        'questions': questions.map((e) => e.toJson()).toList(),
        'requestedContacts': requestedContacts.map((e) => e.name).toList(),
      };
}

class ApplicantCounts {
  const ApplicantCounts({
    required this.total,
    required this.pending,
    required this.accepted,
    required this.rejected,
    required this.withdrawn,
  });

  final int total;
  final int pending;
  final int accepted;
  final int rejected;
  final int withdrawn;

  factory ApplicantCounts.fromJson(Map<String, dynamic> json) =>
      ApplicantCounts(
        total: (json['total'] as num?)?.toInt() ?? 0,
        pending: (json['pending'] as num?)?.toInt() ?? 0,
        accepted: (json['accepted'] as num?)?.toInt() ?? 0,
        rejected: (json['rejected'] as num?)?.toInt() ?? 0,
        withdrawn: (json['withdrawn'] as num?)?.toInt() ?? 0,
      );
}

class MyPostingItem {
  const MyPostingItem({
    required this.postingId,
    required this.title,
    required this.category,
    required this.status,
    this.deadline,
    required this.counts,
  });

  final int postingId;
  final String title;
  final Category category;
  final PostingStatus status;
  final DateTime? deadline;
  final ApplicantCounts counts;

  factory MyPostingItem.fromJson(Map<String, dynamic> json) => MyPostingItem(
        postingId: (json['postingId'] as num).toInt(),
        title: json['title']?.toString() ?? '',
        category: Category.fromApi(json['category']?.toString()),
        status: PostingStatus.fromApi(json['status']?.toString()),
        deadline: json['deadline'] != null
            ? DateTime.tryParse(json['deadline'].toString())
            : null,
        counts: ApplicantCounts.fromJson(
          (json['counts'] as Map<String, dynamic>?) ?? const {},
        ),
      );
}

// ---------------- 지원 및 초안 ----------------

class SelectableBoolOption {
  const SelectableBoolOption({
    required this.available,
    required this.defaultShare,
  });

  final bool available;
  final bool defaultShare;

  factory SelectableBoolOption.fromJson(Map<String, dynamic>? json) =>
      SelectableBoolOption(
        available: json?['available'] as bool? ?? false,
        defaultShare: json?['defaultShare'] as bool? ?? false,
      );
}

class SelectableEntityOption {
  const SelectableEntityOption({
    required this.id,
    required this.title,
    required this.defaultShare,
  });

  final int id;
  final String title;
  final bool defaultShare;

  factory SelectableEntityOption.fromJson(Map<String, dynamic> json) =>
      SelectableEntityOption(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title']?.toString() ?? '',
        defaultShare: json['defaultShare'] as bool? ?? false,
      );
}

class ContactOption {
  const ContactOption({
    required this.type,
    required this.requested,
    required this.hasValue,
    this.maskedValue,
  });

  final ContactType type;
  final bool requested;
  final bool hasValue;
  final String? maskedValue;

  factory ContactOption.fromJson(Map<String, dynamic> json) => ContactOption(
        type: ContactType.fromApi(json['type']?.toString()),
        requested: json['requested'] as bool? ?? false,
        hasValue: json['hasValue'] as bool? ?? false,
        maskedValue: json['maskedValue']?.toString(),
      );
}

class AnswerView {
  const AnswerView({required this.questionId, required this.content, this.value});

  final int questionId;
  final String content;
  final dynamic value;

  factory AnswerView.fromJson(Map<String, dynamic> json) => AnswerView(
        questionId: (json['questionId'] as num?)?.toInt() ?? 0,
        content: json['content']?.toString() ?? '',
        value: json['value'],
      );
}

class DraftResponse {
  const DraftResponse({
    required this.postingId,
    required this.postingTitle,
    required this.exists,
    this.answers = const [],
    this.source,
    this.updatedAt,
    this.notice,
  });

  final int postingId;
  final String postingTitle;
  final bool exists;
  final List<AnswerView> answers;
  final DraftSource? source;
  final DateTime? updatedAt;
  final String? notice;

  factory DraftResponse.fromJson(Map<String, dynamic> json) => DraftResponse(
        postingId: (json['postingId'] as num?)?.toInt() ?? 0,
        postingTitle: json['postingTitle']?.toString() ?? '',
        exists: json['exists'] as bool? ?? false,
        answers: (json['answers'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(AnswerView.fromJson)
            .toList(),
        source: DraftSource.fromApiNullable(json['source']?.toString()),
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'].toString())
            : null,
        notice: json['notice']?.toString(),
      );
}

class ApplicationForm {
  const ApplicationForm({
    required this.postingId,
    required this.postingTitle,
    required this.fixedItems,
    required this.profileImage,
    required this.bio,
    required this.majorsSecondary,
    required this.skills,
    required this.experiences,
    required this.portfolioLinks,
    required this.portfolioFiles,
    required this.contacts,
    required this.questions,
    this.draft,
  });

  final int postingId;
  final String postingTitle;
  final Map<String, dynamic> fixedItems;
  final SelectableBoolOption profileImage;
  final SelectableBoolOption bio;
  final SelectableBoolOption majorsSecondary;
  final SelectableBoolOption skills;
  final List<SelectableEntityOption> experiences;
  final List<SelectableEntityOption> portfolioLinks;
  final List<SelectableEntityOption> portfolioFiles;
  final List<ContactOption> contacts;
  final List<PostingQuestion> questions;
  final DraftResponse? draft;

  factory ApplicationForm.fromJson(Map<String, dynamic> json) {
    final sel = (json['selectableItems'] as Map<String, dynamic>?) ?? const {};
    return ApplicationForm(
      postingId: (json['postingId'] as num?)?.toInt() ?? 0,
      postingTitle: json['postingTitle']?.toString() ?? '',
      fixedItems: (json['fixedItems'] as Map<String, dynamic>?) ?? const {},
      profileImage: SelectableBoolOption.fromJson(
          sel['profileImage'] as Map<String, dynamic>?),
      bio: SelectableBoolOption.fromJson(sel['bio'] as Map<String, dynamic>?),
      majorsSecondary: SelectableBoolOption.fromJson(
          sel['majorsSecondary'] as Map<String, dynamic>?),
      skills:
          SelectableBoolOption.fromJson(sel['skills'] as Map<String, dynamic>?),
      experiences: (sel['experiences'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SelectableEntityOption.fromJson)
          .toList(),
      portfolioLinks: (sel['portfolioLinks'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SelectableEntityOption.fromJson)
          .toList(),
      portfolioFiles: (sel['portfolioFiles'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SelectableEntityOption.fromJson)
          .toList(),
      contacts: (json['contacts'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ContactOption.fromJson)
          .toList(),
      questions: (json['questions'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(PostingQuestion.fromJson)
          .toList(),
      draft: json['draft'] is Map<String, dynamic>
          ? DraftResponse.fromJson(json['draft'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PostingRef {
  const PostingRef({
    required this.postingId,
    required this.title,
    required this.category,
    this.deadline,
    required this.status,
    required this.recruiterName,
  });

  final int postingId;
  final String title;
  final Category category;
  final DateTime? deadline;
  final PostingStatus status;
  final String recruiterName;

  factory PostingRef.fromJson(Map<String, dynamic> json) => PostingRef(
        postingId: (json['postingId'] as num?)?.toInt() ?? 0,
        title: json['title']?.toString() ?? '',
        category: Category.fromApi(json['category']?.toString()),
        deadline: json['deadline'] != null
            ? DateTime.tryParse(json['deadline'].toString())
            : null,
        status: PostingStatus.fromApi(json['status']?.toString()),
        recruiterName: json['recruiterName']?.toString() ?? '',
      );
}

class MyApplicationItem {
  const MyApplicationItem({
    required this.applicationId,
    required this.posting,
    required this.displayStatus,
    this.submittedAt,
    this.announcedAt,
  });

  final int applicationId;
  final PostingRef posting;
  final DisplayStatus displayStatus;
  final DateTime? submittedAt;
  final DateTime? announcedAt;

  factory MyApplicationItem.fromJson(Map<String, dynamic> json) =>
      MyApplicationItem(
        applicationId: (json['applicationId'] as num).toInt(),
        posting: PostingRef.fromJson(
          (json['posting'] as Map<String, dynamic>?) ?? const {},
        ),
        displayStatus: DisplayStatus.fromApi(json['displayStatus']?.toString()),
        submittedAt: json['submittedAt'] != null
            ? DateTime.tryParse(json['submittedAt'].toString())
            : null,
        announcedAt: json['announcedAt'] != null
            ? DateTime.tryParse(json['announcedAt'].toString())
            : null,
      );
}

class ContactValue {
  const ContactValue({required this.type, required this.value});

  final ContactType type;
  final String value;

  factory ContactValue.fromJson(Map<String, dynamic> json) => ContactValue(
        type: ContactType.fromApi(json['type']?.toString()),
        value: json['value']?.toString() ?? '',
      );
}

class DisclosedContact {
  const DisclosedContact({
    required this.type,
    required this.value,
    this.disclosedAt,
  });

  final ContactType type;
  final String value;
  final DateTime? disclosedAt;

  factory DisclosedContact.fromJson(Map<String, dynamic> json) =>
      DisclosedContact(
        type: ContactType.fromApi(json['type']?.toString()),
        value: json['value']?.toString() ?? '',
        disclosedAt: json['disclosedAt'] != null
            ? DateTime.tryParse(json['disclosedAt'].toString())
            : null,
      );
}

class ResultView {
  const ResultView({
    required this.result,
    required this.message,
    this.recruiterContact,
    this.disclosedContacts,
  });

  final DisplayStatus result;
  final String message;
  final ContactValue? recruiterContact;
  final List<DisclosedContact>? disclosedContacts;

  factory ResultView.fromJson(Map<String, dynamic> json) => ResultView(
        result: DisplayStatus.fromApi(json['result']?.toString()),
        message: json['message']?.toString() ?? '',
        recruiterContact: json['recruiterContact'] is Map<String, dynamic>
            ? ContactValue.fromJson(
                json['recruiterContact'] as Map<String, dynamic>)
            : null,
        disclosedContacts: (json['disclosedContacts'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(DisclosedContact.fromJson)
            .toList(),
      );
}

class ApplicationDetail {
  const ApplicationDetail({
    required this.applicationId,
    required this.posting,
    required this.displayStatus,
    this.submittedAt,
    required this.snapshot,
    required this.sharedItems,
    required this.answers,
    this.result,
  });

  final int applicationId;
  final PostingRef posting;
  final DisplayStatus displayStatus;
  final DateTime? submittedAt;
  final Map<String, dynamic> snapshot;
  final List<String> sharedItems;
  final List<AnswerView> answers;
  final ResultView? result;

  factory ApplicationDetail.fromJson(Map<String, dynamic> json) =>
      ApplicationDetail(
        applicationId: (json['applicationId'] as num).toInt(),
        posting: PostingRef.fromJson(
          (json['posting'] as Map<String, dynamic>?) ?? const {},
        ),
        displayStatus: DisplayStatus.fromApi(json['displayStatus']?.toString()),
        submittedAt: json['submittedAt'] != null
            ? DateTime.tryParse(json['submittedAt'].toString())
            : null,
        snapshot: (json['snapshot'] as Map<String, dynamic>?) ?? const {},
        sharedItems: (json['sharedItems'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        answers: (json['answers'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(AnswerView.fromJson)
            .toList(),
        result: json['result'] is Map<String, dynamic>
            ? ResultView.fromJson(json['result'] as Map<String, dynamic>)
            : null,
      );
}

// ---------------- 검토·선발 ----------------

class ApplicantItem {
  const ApplicantItem({
    required this.applicationId,
    required this.name,
    this.department,
    this.academicStatus,
    this.topSkills = const [],
    this.submittedAt,
    this.decision,
    required this.hasMemo,
    required this.withdrawn,
  });

  final int applicationId;
  final String name;
  final String? department;
  final AcademicStatus? academicStatus;
  final List<String> topSkills;
  final DateTime? submittedAt;
  final Decision? decision;
  final bool hasMemo;
  final bool withdrawn;

  factory ApplicantItem.fromJson(Map<String, dynamic> json) => ApplicantItem(
        applicationId: (json['applicationId'] as num).toInt(),
        name: json['name']?.toString() ?? '',
        department: json['department']?.toString(),
        academicStatus: json['academicStatus'] != null
            ? AcademicStatus.fromApi(json['academicStatus'].toString())
            : null,
        topSkills: (json['topSkills'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        submittedAt: json['submittedAt'] != null
            ? DateTime.tryParse(json['submittedAt'].toString())
            : null,
        decision: json['decision'] != null
            ? Decision.fromApi(json['decision'].toString())
            : null,
        hasMemo: json['hasMemo'] as bool? ?? false,
        withdrawn: json['withdrawn'] as bool? ?? false,
      );
}

class ReviewDetail {
  const ReviewDetail({
    required this.applicationId,
    required this.posting,
    required this.snapshot,
    required this.answers,
    required this.sharedContactTypes,
    this.contacts,
    this.decision,
    this.memo,
    this.submittedAt,
    required this.withdrawn,
  });

  final int applicationId;
  final PostingRef posting;
  final Map<String, dynamic> snapshot;
  final List<AnswerView> answers;
  final List<ContactType> sharedContactTypes;
  final List<ContactValue>? contacts;
  final Decision? decision;
  final String? memo;
  final DateTime? submittedAt;
  final bool withdrawn;

  factory ReviewDetail.fromJson(Map<String, dynamic> json) => ReviewDetail(
        applicationId: (json['applicationId'] as num).toInt(),
        posting: PostingRef.fromJson(
          (json['posting'] as Map<String, dynamic>?) ?? const {},
        ),
        snapshot: (json['snapshot'] as Map<String, dynamic>?) ?? const {},
        answers: (json['answers'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(AnswerView.fromJson)
            .toList(),
        sharedContactTypes:
            (json['sharedContactTypes'] as List<dynamic>? ?? const [])
                .map((e) => ContactType.fromApi(e.toString()))
                .toList(),
        contacts: (json['contacts'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(ContactValue.fromJson)
            .toList(),
        decision: json['decision'] != null
            ? Decision.fromApi(json['decision'].toString())
            : null,
        memo: json['memo']?.toString(),
        submittedAt: json['submittedAt'] != null
            ? DateTime.tryParse(json['submittedAt'].toString())
            : null,
        withdrawn: json['withdrawn'] as bool? ?? false,
      );
}

class AnnounceResponse {
  const AnnounceResponse({
    required this.postingId,
    required this.status,
    required this.accepted,
    required this.rejected,
    this.announcedAt,
    this.warning,
  });

  final int postingId;
  final PostingStatus status;
  final int accepted;
  final int rejected;
  final DateTime? announcedAt;
  final String? warning;

  factory AnnounceResponse.fromJson(Map<String, dynamic> json) =>
      AnnounceResponse(
        postingId: (json['postingId'] as num).toInt(),
        status: PostingStatus.fromApi(json['status']?.toString()),
        accepted: (json['accepted'] as num?)?.toInt() ?? 0,
        rejected: (json['rejected'] as num?)?.toInt() ?? 0,
        announcedAt: json['announcedAt'] != null
            ? DateTime.tryParse(json['announcedAt'].toString())
            : null,
        warning: json['warning']?.toString(),
      );
}

class AcceptedContact {
  const AcceptedContact({
    required this.applicationId,
    required this.name,
    required this.contacts,
    this.disclosedAt,
  });

  final int applicationId;
  final String name;
  final List<ContactValue> contacts;
  final DateTime? disclosedAt;

  factory AcceptedContact.fromJson(Map<String, dynamic> json) =>
      AcceptedContact(
        applicationId: (json['applicationId'] as num).toInt(),
        name: json['name']?.toString() ?? '',
        contacts: (json['contacts'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(ContactValue.fromJson)
            .toList(),
        disclosedAt: json['disclosedAt'] != null
            ? DateTime.tryParse(json['disclosedAt'].toString())
            : null,
      );
}

// ---------------- 외부 활동 / 관심 / 알림 / 조직 ----------------

class ExternalActivityItem {
  const ExternalActivityItem({
    required this.id,
    required this.type,
    required this.title,
    required this.organizer,
    required this.fields,
    required this.source,
    this.postedAt,
    this.deadline,
    this.dDay,
    required this.url,
    required this.bookmarked,
  });

  final int id;
  final ExternalType type;
  final String title;
  final String organizer;
  final List<Field> fields;
  final String source;
  final DateTime? postedAt;
  final DateTime? deadline;
  final int? dDay;
  final String url;
  final bool bookmarked;

  ExternalActivityItem copyWith({bool? bookmarked}) => ExternalActivityItem(
        id: id,
        type: type,
        title: title,
        organizer: organizer,
        fields: fields,
        source: source,
        postedAt: postedAt,
        deadline: deadline,
        dDay: dDay,
        url: url,
        bookmarked: bookmarked ?? this.bookmarked,
      );

  factory ExternalActivityItem.fromJson(Map<String, dynamic> json) =>
      ExternalActivityItem(
        id: (json['id'] as num).toInt(),
        type: ExternalType.fromApi(json['type']?.toString()),
        title: json['title']?.toString() ?? '',
        organizer: json['organizer']?.toString() ?? '',
        fields: (json['fields'] as List<dynamic>? ?? const [])
            .map((e) => Field.fromApi(e.toString()))
            .toList(),
        source: json['source']?.toString() ?? 'PUBLIC_API',
        postedAt: json['postedAt'] != null
            ? DateTime.tryParse(json['postedAt'].toString())
            : null,
        deadline: json['deadline'] != null
            ? DateTime.tryParse(json['deadline'].toString())
            : null,
        dDay: (json['dDay'] as num?)?.toInt(),
        url: json['url']?.toString() ?? '',
        bookmarked: json['bookmarked'] as bool? ?? false,
      );
}

class BookmarkList {
  const BookmarkList({
    required this.postings,
    required this.externalActivities,
  });

  final List<PostingCard> postings;
  final List<ExternalActivityItem> externalActivities;

  factory BookmarkList.fromJson(Map<String, dynamic> json) => BookmarkList(
        postings: (json['postings'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(PostingCard.fromJson)
            .toList(),
        externalActivities:
            (json['externalActivities'] as List<dynamic>? ?? const [])
                .whereType<Map<String, dynamic>>()
                .map(ExternalActivityItem.fromJson)
                .toList(),
      );
}

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.targetScreen,
    this.postingId,
    this.applicationId,
    required this.read,
    this.createdAt,
  });

  final int id;
  final NotificationType type;
  final String title;
  final String body;
  final String targetScreen;
  final int? postingId;
  final int? applicationId;
  final bool read;
  final DateTime? createdAt;

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        id: (json['id'] as num).toInt(),
        type: NotificationType.fromApi(json['type']?.toString()),
        title: json['title']?.toString() ?? '',
        body: json['body']?.toString() ?? '',
        targetScreen: json['targetScreen']?.toString() ?? 'SCR-06',
        postingId: (json['postingId'] as num?)?.toInt(),
        applicationId: (json['applicationId'] as num?)?.toInt(),
        read: json['read'] as bool? ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString())
            : null,
      );
}

class NotificationList {
  const NotificationList({required this.unreadCount, required this.items});

  final int unreadCount;
  final List<NotificationItem> items;

  factory NotificationList.fromJson(Map<String, dynamic> json) =>
      NotificationList(
        unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
        items: (json['items'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(NotificationItem.fromJson)
            .toList(),
      );
}

class OrgLink {
  const OrgLink({required this.title, required this.url});

  final String title;
  final String url;

  factory OrgLink.fromJson(Map<String, dynamic> json) => OrgLink(
        title: json['title']?.toString() ?? '',
        url: json['url']?.toString() ?? '',
      );
}

class OrgPage {
  const OrgPage({
    required this.orgId,
    required this.name,
    required this.orgType,
    required this.verified,
    this.logoUrl,
    this.intro,
    required this.fields,
    required this.links,
    required this.followed,
    required this.followerCount,
    required this.openPostings,
    required this.pastPostings,
  });

  final int orgId;
  final String name;
  final String orgType;
  final bool verified;
  final String? logoUrl;
  final String? intro;
  final List<Field> fields;
  final List<OrgLink> links;
  final bool followed;
  final int followerCount;
  final List<PostingCard> openPostings;
  final List<PostingCard> pastPostings;

  factory OrgPage.fromJson(Map<String, dynamic> json) => OrgPage(
        orgId: (json['orgId'] as num).toInt(),
        name: json['name']?.toString() ?? '',
        orgType: json['orgType']?.toString() ?? '단체',
        verified: json['verified'] as bool? ?? false,
        logoUrl: json['logoUrl']?.toString(),
        intro: json['intro']?.toString(),
        fields: (json['fields'] as List<dynamic>? ?? const [])
            .map((e) => Field.fromApi(e.toString()))
            .toList(),
        links: (json['links'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(OrgLink.fromJson)
            .toList(),
        followed: json['followed'] as bool? ?? false,
        followerCount: (json['followerCount'] as num?)?.toInt() ?? 0,
        openPostings: (json['openPostings'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(PostingCard.fromJson)
            .toList(),
        pastPostings: (json['pastPostings'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(PostingCard.fromJson)
            .toList(),
      );
}

class ApplyResponse {
  const ApplyResponse({
    required this.applicationId,
    required this.postingId,
    required this.displayStatus,
    this.submittedAt,
  });

  final int applicationId;
  final int postingId;
  final DisplayStatus displayStatus;
  final DateTime? submittedAt;

  factory ApplyResponse.fromJson(Map<String, dynamic> json) => ApplyResponse(
        applicationId: (json['applicationId'] as num).toInt(),
        postingId: (json['postingId'] as num).toInt(),
        displayStatus: DisplayStatus.fromApi(json['displayStatus']?.toString()),
        submittedAt: json['submittedAt'] != null
            ? DateTime.tryParse(json['submittedAt'].toString())
            : null,
      );
}

class FollowResponse {
  const FollowResponse({
    required this.orgId,
    required this.followed,
    required this.followerCount,
  });

  final int orgId;
  final bool followed;
  final int followerCount;
}

class DecisionResponse {
  const DecisionResponse({
    required this.applicationId,
    required this.decision,
    this.memo,
  });

  final int applicationId;
  final Decision decision;
  final String? memo;
}
