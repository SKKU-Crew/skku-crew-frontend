import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/codes.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/adaptive_shell.dart';
import '../../core/widgets/common_widgets.dart';
import '../../data/state/app_controller.dart';
import '../../domain/models/api_models.dart';

/// SCR-01 로그인 (데모 계정 원클릭 로그인 + 개인 Google / 단체 아이디·비번 탭).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _tabIndex = 0; // 0: 개인회원, 1: 단체회원
  final _orgIdCtrl = TextEditingController();
  final _orgPwCtrl = TextEditingController();
  bool _staySignedIn = true;
  int _orgFailCount = 0;
  DateTime? _lockUntil;
  String? _orgError;
  List<DemoAccount> _accounts = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  @override
  void dispose() {
    _orgIdCtrl.dispose();
    _orgPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    setState(() => _loading = true);
    try {
      final list = await widget.controller.api.getDemoAccounts();
      if (mounted) {
        setState(() {
          _accounts = list;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _handleGoogleSimulation() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '성균관대학교 Google 계정 선택',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                '학교 이메일(@g.skku.edu · @skku.edu) 계정으로 로그인해 주세요.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryTint,
                  child: Text('김', style: TextStyle(color: AppColors.primary)),
                ),
                title: const Text('김민준'),
                subtitle: const Text('minjun.kim@g.skku.edu'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await widget.controller.loginAs(1);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryTint,
                  child: Text('박', style: TextStyle(color: AppColors.primary)),
                ),
                title: const Text('박지호'),
                subtitle: const Text('jiho.park@g.skku.edu'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await widget.controller.loginAs(4);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.infoBg,
                  child: Icon(Icons.person_add, color: AppColors.info, size: 18),
                ),
                title: const Text('신규 학우 계정으로 가입하기'),
                subtitle: const Text('new.student@g.skku.edu'),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.controller.push('/signup');
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.dangerBg,
                  child: Icon(Icons.block, color: AppColors.danger, size: 18),
                ),
                title: const Text('학교 외 일반 Google 계정'),
                subtitle: const Text('external.user@gmail.com'),
                onTap: () {
                  Navigator.pop(ctx);
                  showNoticeDialog(
                    context,
                    title: '가입할 수 없는 계정',
                    message:
                        '성균관대학교 Google 계정(@g.skku.edu·@skku.edu)으로만 가입할 수 있습니다.',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleOrgLogin() async {
    if (_lockUntil != null && DateTime.now().isBefore(_lockUntil!)) {
      final mins = _lockUntil!.difference(DateTime.now()).inMinutes + 1;
      setState(() {
        _orgError = '로그인 5회 연속 실패로 10분간 제한되었습니다. 약 $mins분 후 다시 시도해 주세요.';
      });
      return;
    }
    final id = _orgIdCtrl.text.trim();
    final pw = _orgPwCtrl.text;
    if (id == 'dlab_skku' && pw.isNotEmpty) {
      _orgFailCount = 0;
      await widget.controller.loginAs(6);
      return;
    }
    if (id == 'rbot_skku' && pw.isNotEmpty) {
      _orgFailCount = 0;
      await widget.controller.loginAs(7);
      return;
    }
    _orgFailCount++;
    if (_orgFailCount >= 5) {
      _lockUntil = DateTime.now().add(const Duration(minutes: 10));
      setState(() {
        _orgError = '5회 연속 실패로 10분간 로그인이 제한됩니다.';
      });
    } else {
      setState(() {
        _orgError = '아이디 또는 비밀번호를 다시 확인해 주세요.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyAccounts = _accounts
        .where((a) => [1, 4, 2, 3, 5, 6, 7, 8].contains(a.memberId))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.groups, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 12),
                const Text(
                  'SKKU Crew',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '흩어진 교내·외 커리어 활동을 프로필 하나로',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
                const SizedBox(height: 24),
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SegmentedButton<int>(
                        segments: const [
                          ButtonSegment(value: 0, label: Text('개인회원')),
                          ButtonSegment(value: 1, label: Text('단체회원')),
                        ],
                        selected: {_tabIndex},
                        onSelectionChanged: (s) =>
                            setState(() => _tabIndex = s.first),
                      ),
                      const SizedBox(height: 16),
                      if (_tabIndex == 0) ...[
                        OutlinedButton.icon(
                          onPressed: _handleGoogleSimulation,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: AppColors.border),
                          ),
                          icon: const Icon(Icons.g_mobiledata,
                              size: 26, color: AppColors.textPrimary),
                          label: const Text(
                            'Google 계정으로 계속하기',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryTint,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '성균관대학교 Google 계정(@g.skku.edu·@skku.edu)만 사용할 수 있어요. 처음 로그인하면 바로 가입이 진행됩니다.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ] else ...[
                        TextField(
                          controller: _orgIdCtrl,
                          decoration: const InputDecoration(
                            labelText: '단체 아이디',
                            hintText: '예: dlab_skku',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _orgPwCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: '비밀번호',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        if (_orgError != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _orgError!,
                            style: const TextStyle(
                              color: AppColors.danger,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _handleOrgLogin,
                          child: const Text('단체회원 로그인'),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () =>
                                  widget.controller.push('/org/signup'),
                              child: const Text('단체회원 가입 · 인증 신청'),
                            ),
                            const Text('·',
                                style: TextStyle(color: AppColors.textLight)),
                            TextButton(
                              onPressed: () => _showPasswordResetDialog(context),
                              child: const Text('비밀번호 재설정'),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        value: _staySignedIn,
                        onChanged: (v) =>
                            setState(() => _staySignedIn = v ?? true),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text(
                          '로그인 상태 유지',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.bolt, size: 18, color: AppColors.primary),
                          SizedBox(width: 6),
                          Text(
                            '체험 계정으로 둘러보기',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '원하는 계정을 선택하면 바로 해당 화면으로 시작할 수 있어요.',
                        style:
                            TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 12),
                      if (_loading)
                        const Center(child: CircularProgressIndicator())
                      else
                        for (final acc in keyAccounts)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    acc.memberType == MemberType.ORGANIZATION
                                        ? AppColors.primary
                                        : acc.memberType == MemberType.ADMIN
                                            ? AppColors.textPrimary
                                            : AppColors.primaryTint,
                                child: Text(
                                  acc.name.isEmpty ? '?' : acc.name[0],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: acc.memberType == MemberType.PERSONAL
                                        ? AppColors.primary
                                        : Colors.white,
                                  ),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    acc.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  TagChip(label: acc.memberType.label),
                                ],
                              ),
                              subtitle: Text(
                                acc.description ?? '',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: const Icon(Icons.chevron_right, size: 18),
                              onTap: () =>
                                  widget.controller.loginAs(acc.memberId),
                            ),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showPasswordResetDialog(BuildContext context) async {
    final emailCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    var codeSent = false;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('비밀번호 재설정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: '대표 연락 이메일',
                  border: OutlineInputBorder(),
                ),
              ),
              if (codeSent) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(
                    labelText: '인증 코드 6자리',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () {
                if (!codeSent) {
                  setLocal(() => codeSent = true);
                } else {
                  Navigator.pop(ctx);
                  AppToast.show(context, '새 비밀번호 설정이 완료되었습니다.');
                }
              },
              child: Text(codeSent ? '확인' : '인증 코드 발송'),
            ),
          ],
        ),
      ),
    );
    emailCtrl.dispose();
    codeCtrl.dispose();
  }
}

/// SCR-02 개인회원 가입 화면.
class SignupIndividualScreen extends StatefulWidget {
  const SignupIndividualScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<SignupIndividualScreen> createState() => _SignupIndividualScreenState();
}

class _SignupIndividualScreenState extends State<SignupIndividualScreen> {
  final _nameCtrl = TextEditingController(text: '김성균');
  bool _agreeTerms = false;
  bool _agreePrivacy = false;
  bool _agreeContactOptional = false;
  bool _completed = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveShell(
      controller: widget.controller,
      title: '개인회원 가입',
      leadingBack: true,
      showBottomNav: false,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SectionCard(
              child: _completed
                  ? Column(
                      children: [
                        const Icon(Icons.celebration,
                            size: 48, color: AppColors.primary),
                        const SizedBox(height: 12),
                        const Text(
                          '가입이 완료되었어요!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '프로필을 한 번 등록하면 모든 지원에 재사용하고, 지원할 때마다 공개할 항목만 선택할 수 있어요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    widget.controller.loginAs(1),
                                child: const Text('나중에 하기'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primary),
                                onPressed: () async {
                                  await widget.controller.loginAs(1,
                                      navigateToDefault: false);
                                  widget.controller.go('/me/profile/edit');
                                },
                                child: const Text('프로필 작성하기'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.primaryTint,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primary,
                                child: Text('김',
                                    style: TextStyle(color: Colors.white)),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'new.student@g.skku.edu',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      '성균관대학교 계정으로 확인되었습니다 ✓',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _nameCtrl,
                          decoration: InputDecoration(
                            labelText: '이름 *',
                            helperText: '실명 또는 활동명을 입력해 주세요.',
                            errorText: AppValidators.validateName(_nameCtrl.text),
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 16),
                        CheckboxListTile(
                          value: _agreeTerms && _agreePrivacy,
                          onChanged: (v) => setState(() {
                            _agreeTerms = v ?? false;
                            _agreePrivacy = v ?? false;
                          }),
                          title: const Text(
                            '필수 약관 전체 동의',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        const Divider(),
                        CheckboxListTile(
                          value: _agreeTerms,
                          onChanged: (v) =>
                              setState(() => _agreeTerms = v ?? false),
                          title: const Text('[필수] 서비스 이용약관',
                              style: TextStyle(fontSize: 13)),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        CheckboxListTile(
                          value: _agreePrivacy,
                          onChanged: (v) =>
                              setState(() => _agreePrivacy = v ?? false),
                          title: const Text('[필수] 개인정보 수집·이용 동의',
                              style: TextStyle(fontSize: 13)),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        CheckboxListTile(
                          value: _agreeContactOptional,
                          onChanged: (v) =>
                              setState(() => _agreeContactOptional = v ?? false),
                          title: const Text(
                            '[선택] 연락처 등 추가 프로필 정보 수집·이용 동의',
                            style: TextStyle(fontSize: 13),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: (_agreeTerms &&
                                  _agreePrivacy &&
                                  AppValidators.validateName(_nameCtrl.text) ==
                                      null)
                              ? () => setState(() => _completed = true)
                              : null,
                          child: const Text('가입하기'),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// SCR-03 단체회원 가입 · 인증 신청 화면.
class SignupOrgScreen extends StatefulWidget {
  const SignupOrgScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<SignupOrgScreen> createState() => _SignupOrgScreenState();
}

class _SignupOrgScreenState extends State<SignupOrgScreen> {
  final _idCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _orgNameCtrl = TextEditingController();
  final _repNameCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  String _orgType = '학회';
  bool _agreeRequired = false;
  bool _submitted = false;

  @override
  void dispose() {
    _idCtrl.dispose();
    _pwCtrl.dispose();
    _emailCtrl.dispose();
    _orgNameCtrl.dispose();
    _repNameCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final errors = [
      AppValidators.validateOrgLoginId(_idCtrl.text),
      AppValidators.validateOrgPassword(_pwCtrl.text),
      AppValidators.validateEmail(_emailCtrl.text, required: true),
      AppValidators.validateUrl(_urlCtrl.text, required: true),
    ].whereType<String>().toList();

    if (_orgNameCtrl.text.trim().length < 2 ||
        _repNameCtrl.text.trim().length < 2 ||
        !_agreeRequired) {
      AppToast.show(context, '필수 항목과 약관 동의를 확인해 주세요.', isError: true);
      return;
    }
    if (errors.isNotEmpty) {
      AppToast.show(context, errors.first, isError: true);
      return;
    }

    widget.controller.adminVerifications.insert(
      0,
      AdminVerificationItem(
        id: DateTime.now().millisecondsSinceEpoch,
        orgName: _orgNameCtrl.text.trim(),
        orgType: _orgType,
        loginId: _idCtrl.text.trim(),
        contactEmail: _emailCtrl.text.trim(),
        submittedAt: DateTime.now(),
        status: '인증 대기',
        urls: [_urlCtrl.text.trim()],
        isNameChange: false,
      ),
    );
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveShell(
      controller: widget.controller,
      title: '단체회원 가입 · 인증 신청',
      leadingBack: true,
      showBottomNav: false,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SectionCard(
              child: _submitted
                  ? Column(
                      children: [
                        const Icon(Icons.verified_user_outlined,
                            size: 48, color: AppColors.primary),
                        const SizedBox(height: 12),
                        const Text(
                          '인증 신청이 접수되었습니다',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '관리자가 공식 SNS·웹 페이지 URL을 확인한 뒤 승인하면 공고를 게시하고 조직 페이지를 공개할 수 있습니다. 심사 결과는 대표 연락 이메일과 알림으로 안내합니다.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary),
                          onPressed: () => widget.controller.go('/login'),
                          child: const Text('로그인 화면으로'),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.warningBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '관리자가 인증 자료를 확인한 후 승인합니다. 승인 전에는 공고를 게시할 수 없어요.',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.warning),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _idCtrl,
                          decoration: const InputDecoration(
                            labelText: '아이디 *',
                            helperText: '영문 소문자, 숫자 4~20자',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _pwCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: '비밀번호 *',
                            helperText: '영문, 숫자, 특수문자 조합 8~20자',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _emailCtrl,
                          decoration: const InputDecoration(
                            labelText: '대표 연락 이메일 *',
                            hintText: 'dlab.skku@gmail.com',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _orgNameCtrl,
                                decoration: const InputDecoration(
                                  labelText: '단체명 *',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _repNameCtrl,
                                decoration: const InputDecoration(
                                  labelText: '대표자 이름 *',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '단체 유형 *',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            for (final t in DomainConstants.orgTypes)
                              ChoiceChip(
                                label: Text(t),
                                selected: _orgType == t,
                                onSelected: (_) =>
                                    setState(() => _orgType = t),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _urlCtrl,
                          decoration: const InputDecoration(
                            labelText: '공식 SNS 또는 웹사이트 주소 *',
                            hintText: 'https://instagram.com/dlab_skku',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        CheckboxListTile(
                          value: _agreeRequired,
                          onChanged: (v) =>
                              setState(() => _agreeRequired = v ?? false),
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: const Text(
                            '[필수] 이용약관 및 개인정보 수집·이용 동의',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _submit,
                          child: const Text('가입 및 인증 신청'),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
