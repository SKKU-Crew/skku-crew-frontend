import '../constants/codes.dart';

/// 날짜·시간(KST, SRS 6.3절) 및 입력 검증 규칙(표 4-7, 표 4-15, 표 4-26) 유틸리티.
class AppFormatters {
  const AppFormatters._();

  static const List<String> _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  /// KST 기준 "2026.11.08 (일) 23:59" 형식 반환
  static String formatKstDateTime(DateTime? dt) {
    if (dt == null) return '-';
    final kst = dt.toUtc().add(const Duration(hours: 9));
    final y = kst.year.toString().padLeft(4, '0');
    final m = kst.month.toString().padLeft(2, '0');
    final d = kst.day.toString().padLeft(2, '0');
    final wd = _weekdays[kst.weekday - 1];
    final hh = kst.hour.toString().padLeft(2, '0');
    final mm = kst.minute.toString().padLeft(2, '0');
    return '$y.$m.$d ($wd) $hh:$mm';
  }

  static String formatDateOnly(DateTime? dt) {
    if (dt == null) return '-';
    final kst = dt.toUtc().add(const Duration(hours: 9));
    final y = kst.year.toString().padLeft(4, '0');
    final m = kst.month.toString().padLeft(2, '0');
    final d = kst.day.toString().padLeft(2, '0');
    return '$y.$m.$d';
  }

  static String formatMonthDayTime(DateTime? dt) {
    if (dt == null) return '-';
    final kst = dt.toUtc().add(const Duration(hours: 9));
    final m = kst.month.toString().padLeft(2, '0');
    final d = kst.day.toString().padLeft(2, '0');
    final hh = kst.hour.toString().padLeft(2, '0');
    final mm = kst.minute.toString().padLeft(2, '0');
    return '$m.$d $hh:$mm';
  }

  static String formatRelativeTime(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return '방금';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays == 1) return '어제';
    return formatDateOnly(dt);
  }

  static String formatDDay(int? dDay, {PostingStatus? status}) {
    if (status == PostingStatus.CLOSED || status == PostingStatus.ANNOUNCED) {
      return '마감';
    }
    if (dDay == null) return '상시';
    if (dDay <= 0) return 'D-Day';
    return 'D-$dDay';
  }

  static String toIsoKst(DateTime dt) {
    final kst = dt.toUtc().add(const Duration(hours: 9));
    final y = kst.year.toString().padLeft(4, '0');
    final m = kst.month.toString().padLeft(2, '0');
    final d = kst.day.toString().padLeft(2, '0');
    final hh = kst.hour.toString().padLeft(2, '0');
    final mm = kst.minute.toString().padLeft(2, '0');
    final ss = kst.second.toString().padLeft(2, '0');
    return '$y-$m-${d}T$hh:$mm:$ss+09:00';
  }
}

class AppValidators {
  const AppValidators._();

  static final RegExp _phoneRegex = RegExp(r'^010-\d{4}-\d{4}$');
  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _urlRegex = RegExp(r'^https?://[^\s]+$');
  static final RegExp _orgIdRegex = RegExp(r'^[a-z0-9_]{4,20}$');
  static final RegExp _passwordRegex =
      RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[^A-Za-z\d]).{8,20}$');

  static String? validateName(String? value) {
    final v = value?.trim() ?? '';
    if (v.length < 2 || v.length > 20) {
      return '이름은 2~20자로 입력해 주세요.';
    }
    return null;
  }

  static String? validatePhone(String? value, {bool required = false}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) {
      return required ? '전화번호를 입력해 주세요.' : null;
    }
    if (!_phoneRegex.hasMatch(v)) {
      return '010-0000-0000 형식으로 입력해 주세요.';
    }
    return null;
  }

  static String? validateKakaoId(String? value, {bool required = false}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) {
      return required ? '카카오톡 ID를 입력해 주세요.' : null;
    }
    if (v.length < 4 || v.length > 20) {
      return '카카오톡 ID는 4~20자로 입력해 주세요.';
    }
    return null;
  }

  static String? validateEmail(String? value, {bool required = false}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) {
      return required ? '이메일을 입력해 주세요.' : null;
    }
    if (!_emailRegex.hasMatch(v)) {
      return '올바른 이메일 형식이 아닙니다.';
    }
    return null;
  }

  static String? validateUrl(String? value, {bool required = false}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) {
      return required ? 'URL을 입력해 주세요.' : null;
    }
    if (!_urlRegex.hasMatch(v)) {
      return 'URL 형식이 올바르지 않습니다. https://로 시작하는 주소를 입력해 주세요.';
    }
    return null;
  }

  static String? validateOrgLoginId(String? value) {
    final v = value?.trim() ?? '';
    if (!_orgIdRegex.hasMatch(v)) {
      return '영문 소문자·숫자·밑줄 4~20자로 입력해 주세요.';
    }
    return null;
  }

  static String? validateOrgPassword(String? value) {
    final v = value ?? '';
    if (!_passwordRegex.hasMatch(v)) {
      return '영문·숫자·특수문자를 각 1자 이상 포함한 8~20자여야 합니다.';
    }
    return null;
  }

  static String? validateContact(ContactType type, String? value,
      {bool required = false}) {
    switch (type) {
      case ContactType.PHONE:
        return validatePhone(value, required: required);
      case ContactType.KAKAO_ID:
        return validateKakaoId(value, required: required);
      case ContactType.PERSONAL_EMAIL:
      case ContactType.SCHOOL_EMAIL:
        return validateEmail(value, required: required);
    }
  }
}
