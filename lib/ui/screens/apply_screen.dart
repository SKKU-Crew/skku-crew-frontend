import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/codes.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/adaptive_shell.dart';
import '../../core/widgets/common_widgets.dart';
import '../../data/state/app_controller.dart';
import '../../domain/models/api_models.dart';

/// SCR-07 지원서 작성 화면 (3단계: ① 공유 항목 -> ② 추가 질문 -> ③ 확인·제출).
class ApplyScreen extends StatefulWidget {
  const ApplyScreen({
    super.key,
    required this.controller,
    required this.postingId,
  });

  final AppController controller;
  final int postingId;

  @override
  State<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends State<ApplyScreen> {
  ApplicationForm? _form;
  ProfileResponse? _myProfile;
  bool _loading = true;
  String? _blockError;
  int _step = 0; // 0: 공유 항목, 1: 추가 질문, 2: 확인·제출
  bool _submitting = false;

  // 1단계 공유 상태
  bool _shareProfileImage = false;
  bool _shareBio = true;
  bool _shareMajorsSecondary = true;
  bool _shareSkills = true;
  final Set<int> _selectedExpIds = {};
  final Set<int> _selectedLinkIds = {};
  final Set<int> _selectedFileIds = {};

  // 연락처 공유 및 인라인 입력 (FR-APPL-15~18)
  final Map<ContactType, bool> _contactConsent = {};
  final Map<ContactType, TextEditingController> _contactInputCtrls = {};
  final Map<ContactType, bool> _contactSaveToProfile = {};

  // 2단계 질문 답변
  final Map<int, TextEditingController> _textAnswerCtrls = {};
  final Map<int, String?> _singleChoiceAnswers = {};
  final Map<int, Set<String>> _multiChoiceAnswers = {};
  bool _draftLoadedBanner = false;

  // 3단계 동의
  bool _agreeToProvide = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in _contactInputCtrls.values) {
      c.dispose();
    }
    for (final c in _textAnswerCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _blockError = null;
    });
    try {
      final form =
          await widget.controller.api.getApplicationForm(widget.postingId);
      final profile = await widget.controller.api.getMyProfile();

      _shareProfileImage = form.profileImage.defaultShare;
      _shareBio = form.bio.defaultShare;
      _shareMajorsSecondary = form.majorsSecondary.defaultShare;
      _shareSkills = form.skills.defaultShare;
      _selectedExpIds
        ..clear()
        ..addAll(form.experiences.where((e) => e.defaultShare).map((e) => e.id));
      _selectedLinkIds
        ..clear()
        ..addAll(
            form.portfolioLinks.where((e) => e.defaultShare).map((e) => e.id));
      _selectedFileIds
        ..clear()
        ..addAll(
            form.portfolioFiles.where((e) => e.defaultShare).map((e) => e.id));

      for (final c in form.contacts) {
        _contactConsent[c.type] = c.requested;
        _contactInputCtrls.putIfAbsent(c.type, TextEditingController.new);
        _contactSaveToProfile[c.type] = true;
      }

      for (final q in form.questions) {
        if (q.type == QuestionType.SHORT_TEXT ||
            q.type == QuestionType.LONG_TEXT) {
          _textAnswerCtrls.putIfAbsent(q.id, TextEditingController.new);
        } else if (q.type == QuestionType.SINGLE_CHOICE) {
          _singleChoiceAnswers.putIfAbsent(q.id, () => null);
        } else {
          _multiChoiceAnswers.putIfAbsent(q.id, () => <String>{});
        }
      }

      if (mounted) {
        setState(() {
          _form = form;
          _myProfile = profile;
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _blockError = e.message;
          _loading = false;
        });
      }
    }
  }

  void _applyDraft() {
    final draft = _form?.draft;
    if (draft == null || !draft.exists) return;
    setState(() {
      for (final ans in draft.answers) {
        if (_textAnswerCtrls.containsKey(ans.questionId)) {
          _textAnswerCtrls[ans.questionId]!.text =
              ans.value?.toString() ?? '';
        } else if (_singleChoiceAnswers.containsKey(ans.questionId)) {
          _singleChoiceAnswers[ans.questionId] = ans.value?.toString();
        } else if (_multiChoiceAnswers.containsKey(ans.questionId)) {
          final list = (ans.value is List)
              ? (ans.value as List<dynamic>).map((e) => e.toString()).toSet()
              : <String>{};
          _multiChoiceAnswers[ans.questionId] = list;
        }
      }
      _draftLoadedBanner = true;
    });
    AppToast.show(context, '저장된 답변 초안을 불러왔습니다.');
  }

  List<Map<String, dynamic>> _collectAnswersPayload() {
    final form = _form;
    if (form == null) return const [];
    final list = <Map<String, dynamic>>[];
    for (final q in form.questions) {
      dynamic value;
      if (q.type == QuestionType.SHORT_TEXT ||
          q.type == QuestionType.LONG_TEXT) {
        value = _textAnswerCtrls[q.id]?.text ?? '';
      } else if (q.type == QuestionType.SINGLE_CHOICE) {
        value = _singleChoiceAnswers[q.id];
      } else {
        value = (_multiChoiceAnswers[q.id] ?? <String>{}).toList();
      }
      list.add({'questionId': q.id, 'value': value});
    }
    return list;
  }

  Future<void> _saveDraft() async {
    try {
      final res = await widget.controller.api.saveDraft(
        widget.postingId,
        _collectAnswersPayload(),
        source: DraftSource.WEB,
      );
      if (mounted) {
        setState(() {
          _form = ApplicationForm(
            postingId: _form!.postingId,
            postingTitle: _form!.postingTitle,
            fixedItems: _form!.fixedItems,
            profileImage: _form!.profileImage,
            bio: _form!.bio,
            majorsSecondary: _form!.majorsSecondary,
            skills: _form!.skills,
            experiences: _form!.experiences,
            portfolioLinks: _form!.portfolioLinks,
            portfolioFiles: _form!.portfolioFiles,
            contacts: _form!.contacts,
            questions: _form!.questions,
            draft: res,
          );
        });
        AppToast.show(context, '작성 중인 답변을 임시저장했어요.');
      }
    } on ApiException catch (e) {
      if (mounted) AppToast.show(context, e.message, isError: true);
    }
  }

  bool _validateStep1() {
    final form = _form;
    if (form == null) return false;
    for (final c in form.contacts) {
      final consented = _contactConsent[c.type] == true;
      if (c.requested && !consented) {
        showNoticeDialog(
          context,
          title: '필수 연락처 동의 필요',
          message: '${c.type.label}은(는) 모집자가 요청한 필수 항목이므로 제공에 동의해야 지원할 수 있습니다.',
        );
        return false;
      }
      if (consented && !c.hasValue) {
        final inputVal = _contactInputCtrls[c.type]?.text ?? '';
        final err = AppValidators.validateContact(c.type, inputVal, required: true);
        if (err != null) {
          AppToast.show(context, '${c.type.label}: $err', isError: true);
          return false;
        }
      }
    }
    return true;
  }

  bool _validateStep2() {
    final form = _form;
    if (form == null) return false;
    for (final q in form.questions) {
      if (q.type == QuestionType.SHORT_TEXT ||
          q.type == QuestionType.LONG_TEXT) {
        final text = _textAnswerCtrls[q.id]?.text.trim() ?? '';
        if (q.required && text.isEmpty) {
          AppToast.show(context, '필수 질문에 답변해 주세요: ${q.content}', isError: true);
          return false;
        }
        final limit = q.maxLength ?? (q.type == QuestionType.SHORT_TEXT ? 100 : 1000);
        if (text.length > limit) {
          AppToast.show(context, '${q.content} ($limit자 이하)', isError: true);
          return false;
        }
      } else if (q.type == QuestionType.SINGLE_CHOICE) {
        if (q.required && (_singleChoiceAnswers[q.id] == null)) {
          AppToast.show(context, '필수 질문을 선택해 주세요: ${q.content}', isError: true);
          return false;
        }
      } else {
        if (q.required && (_multiChoiceAnswers[q.id]?.isEmpty ?? true)) {
          AppToast.show(context, '필수 질문을 1개 이상 선택해 주세요: ${q.content}', isError: true);
          return false;
        }
      }
    }
    return true;
  }

  Future<void> _submit() async {
    if (!_agreeToProvide) {
      AppToast.show(context, '정보 제공에 동의해야 제출할 수 있습니다.', isError: true);
      return;
    }
    setState(() => _submitting = true);

    final contactsPayload = <Map<String, dynamic>>[];
    for (final c in _form!.contacts) {
      if (_contactConsent[c.type] == true) {
        contactsPayload.add({
          'type': c.type.name,
          'consent': true,
          if (!c.hasValue) 'value': _contactInputCtrls[c.type]!.text.trim(),
          if (!c.hasValue)
            'saveToProfile': _contactSaveToProfile[c.type] ?? true,
        });
      }
    }

    final payload = {
      'share': {
        'profileImage': _shareProfileImage,
        'bio': _shareBio,
        'majorsSecondary': _shareMajorsSecondary,
        'skills': _shareSkills,
        'experienceIds': _selectedExpIds.toList(),
        'portfolioLinkIds': _selectedLinkIds.toList(),
        'portfolioFileIds': _selectedFileIds.toList(),
      },
      'contacts': contactsPayload,
      'answers': _collectAnswersPayload(),
      'agreeToProvide': _agreeToProvide,
    };

    try {
      await widget.controller.api.submitApplication(widget.postingId, payload);
      widget.controller.bumpDataVersion();
      if (!mounted) return;
      await showNoticeDialog(
        context,
        title: '지원서가 제출되었습니다',
        message: '지원서가 정상적으로 접수되었습니다. 내 활동에서 진행 상태를 확인할 수 있어요.',
      );
      if (mounted) {
        widget.controller.initialMyActivitiesTab = 0;
        widget.controller.go('/me/applications');
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        showNoticeDialog(context, title: '제출 불가', message: e.message);
      }
    }
  }

  void _showRecruiterPreviewModal() {
    final form = _form;
    final profile = _myProfile;
    if (form == null || profile == null) return;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          '내 지원서 미리보기',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${profile.name} · ${profile.majorPrimary ?? ""} · ${profile.academicStatus?.shortLabel ?? ""}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final f in profile.fields)
                      TagChip(label: f.label, highlight: true),
                  ],
                ),
                if (_shareBio && (profile.bio?.isNotEmpty ?? false)) ...[
                  const SizedBox(height: 10),
                  Text(profile.bio!, style: const TextStyle(fontSize: 13)),
                ],
                if (_shareSkills && profile.skills.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text('기술 스택',
                      style:
                          TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final s in profile.skills)
                        TagChip(label: '${s.name} ${s.level.label}'),
                    ],
                  ),
                ],
                if (_selectedExpIds.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text('선택한 경험',
                      style:
                          TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  for (final e in profile.experiences
                      .where((x) => _selectedExpIds.contains(x.id)))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        (e.role ?? '').isNotEmpty
                            ? '• ${e.title} · ${e.role}'
                            : '• ${e.title}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                ],
                if (_selectedLinkIds.isNotEmpty || _selectedFileIds.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text('선택한 포트폴리오',
                      style:
                          TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  for (final l in profile.portfolioLinks
                      .where((x) => _selectedLinkIds.contains(x.id)))
                    Text('• 링크: ${l.title}',
                        style: const TextStyle(fontSize: 13)),
                  for (final f in profile.portfolioFiles
                      .where((x) => _selectedFileIds.contains(x.id)))
                    Text('• 파일: ${f.fileName}',
                        style: const TextStyle(fontSize: 13)),
                ],
                const Divider(height: 20),
                const Text(
                  '※ 연락처는 결과 발표 후 합격한 경우에만 모집자에게 공개됩니다.',
                  style: TextStyle(fontSize: 12, color: AppColors.accentOrange),
                ),
              ],
            ),
          ),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveShell(
      controller: widget.controller,
      title: '지원서 작성',
      leadingBack: true,
      showBottomNav: false,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _blockError != null
              ? EmptyStateView(
                  icon: Icons.warning_amber_rounded,
                  title: _blockError!,
                  actionLabel: _blockError!.contains('프로필')
                      ? '프로필 편집으로 이동'
                      : '뒤로가기',
                  onAction: () {
                    if (_blockError!.contains('프로필')) {
                      widget.controller.go('/me/profile/edit');
                    } else {
                      widget.controller.pop();
                    }
                  },
                )
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      children: [
                        _StepHeader(
                          step: _step,
                          postingTitle: _form!.postingTitle,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: _step == 0
                                ? _buildStep1()
                                : _step == 1
                                    ? _buildStep2()
                                    : _buildStep3(),
                          ),
                        ),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStep1() {
    final f = _form!;
    final fixedFields = (f.fixedItems['fields'] as List<dynamic>? ?? const [])
        .map((e) => Field.fromApi(e.toString()).label)
        .join(' · ');
    final acad = f.fixedItems['academicStatus'] != null
        ? AcademicStatus.fromApi(f.fixedItems['academicStatus'].toString())
            .shortLabel
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '항상 공유되는 정보',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        SectionCard(
          backgroundColor: AppColors.surfaceMuted,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.lock_outline,
                      size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 8),
                  const Text('이름·주전공·학년',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text(
                    '${f.fixedItems['name']} · ${f.fixedItems['majorPrimary']} · $acad',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const Divider(height: 16),
              Row(
                children: [
                  const Icon(Icons.lock_outline,
                      size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 8),
                  const Text('관심 분야',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text(
                    fixedFields,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          '이번 지원에 공유할 항목 선택',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        SectionCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            children: [
              if (f.bio.available)
                CheckboxListTile(
                  value: _shareBio,
                  onChanged: (v) => setState(() => _shareBio = v ?? false),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('한 줄 소개', style: TextStyle(fontSize: 14)),
                ),
              if (f.majorsSecondary.available)
                CheckboxListTile(
                  value: _shareMajorsSecondary,
                  onChanged: (v) =>
                      setState(() => _shareMajorsSecondary = v ?? false),
                  contentPadding: EdgeInsets.zero,
                  title:
                      const Text('복수·부전공', style: TextStyle(fontSize: 14)),
                ),
              if (f.skills.available)
                CheckboxListTile(
                  value: _shareSkills,
                  onChanged: (v) => setState(() => _shareSkills = v ?? false),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('기술 스택', style: TextStyle(fontSize: 14)),
                ),
              if (f.experiences.isNotEmpty) ...[
                const Divider(),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '경험 및 활동 내역',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted),
                    ),
                  ),
                ),
                for (final exp in f.experiences)
                  CheckboxListTile(
                    value: _selectedExpIds.contains(exp.id),
                    onChanged: (v) => setState(() => v == true
                        ? _selectedExpIds.add(exp.id)
                        : _selectedExpIds.remove(exp.id)),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title:
                        Text(exp.title, style: const TextStyle(fontSize: 13)),
                  ),
              ],
              if (f.portfolioLinks.isNotEmpty || f.portfolioFiles.isNotEmpty) ...[
                const Divider(),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '포트폴리오',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted),
                    ),
                  ),
                ),
                for (final l in f.portfolioLinks)
                  CheckboxListTile(
                    value: _selectedLinkIds.contains(l.id),
                    onChanged: (v) => setState(() => v == true
                        ? _selectedLinkIds.add(l.id)
                        : _selectedLinkIds.remove(l.id)),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.title, style: const TextStyle(fontSize: 13)),
                  ),
                for (final pf in f.portfolioFiles)
                  CheckboxListTile(
                    value: _selectedFileIds.contains(pf.id),
                    onChanged: (v) => setState(() => v == true
                        ? _selectedFileIds.add(pf.id)
                        : _selectedFileIds.remove(pf.id)),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title:
                        Text(pf.title, style: const TextStyle(fontSize: 13)),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          '연락처 전달 동의',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        SectionCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              for (final c in f.contacts) ...[
                CheckboxListTile(
                  value: _contactConsent[c.type] ?? false,
                  onChanged: c.requested
                      ? null
                      : (v) => setState(
                          () => _contactConsent[c.type] = v ?? false),
                  contentPadding: EdgeInsets.zero,
                  title: Row(
                    children: [
                      Text(c.type.label, style: const TextStyle(fontSize: 14)),
                      if (c.requested) ...[
                        const SizedBox(width: 6),
                        const StatusBadge(
                          label: '필수 요청',
                          backgroundColor: AppColors.accentOrangeBg,
                          textColor: AppColors.accentOrange,
                        ),
                      ],
                      const Spacer(),
                      Text(
                        c.hasValue ? (c.maskedValue ?? '') : '미등록',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  subtitle: const Text(
                    '합격 시 공개',
                    style:
                        TextStyle(fontSize: 11, color: AppColors.accentOrange),
                  ),
                ),
                if ((_contactConsent[c.type] == true) && !c.hasValue)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, left: 12),
                    child: Column(
                      children: [
                        TextField(
                          controller: _contactInputCtrls[c.type],
                          decoration: InputDecoration(
                            labelText: '${c.type.label} 입력 *',
                            hintText: c.type == ContactType.PHONE
                                ? '010-0000-0000'
                                : '연락처를 입력해 주세요',
                            isDense: true,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        CheckboxListTile(
                          value: _contactSaveToProfile[c.type] ?? true,
                          onChanged: (v) => setState(
                              () => _contactSaveToProfile[c.type] = v ?? true),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            '내 프로필에도 이 연락처 저장하기',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showRecruiterPreviewModal,
            icon: const Icon(Icons.visibility_outlined, size: 18),
            label: const Text('모집자에게 보이는 화면'),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    final questions = _form!.questions;
    final draft = _form!.draft;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (draft != null && draft.exists)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${draft.source?.label ?? "저장된"} 답변 초안이 있습니다',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        draft.notice ?? '불러온 뒤 내용을 수정해 제출하세요.',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: _applyDraft,
                  child: Text(_draftLoadedBanner ? '다시 불러오기' : '초안 불러오기'),
                ),
              ],
            ),
          ),
        if (questions.isEmpty)
          const SectionCard(
            child: Text(
              '이 공고는 추가 질문이 없습니다. 다음 단계로 진행해 주세요.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          )
        else
          for (var i = 0; i < questions.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _buildQuestionField(i + 1, questions[i]),
            ),
      ],
    );
  }

  Widget _buildQuestionField(int index, PostingQuestion q) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Q$index. ${q.content}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (q.required)
                const Text(' *',
                    style: TextStyle(
                        color: AppColors.danger, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          if (q.type == QuestionType.SHORT_TEXT ||
              q.type == QuestionType.LONG_TEXT)
            TextField(
              controller: _textAnswerCtrls[q.id],
              maxLines: q.type == QuestionType.LONG_TEXT ? 4 : 1,
              maxLength:
                  q.maxLength ?? (q.type == QuestionType.SHORT_TEXT ? 100 : 500),
              decoration: const InputDecoration(
                hintText: '답변을 입력해 주세요.',
                border: OutlineInputBorder(),
              ),
            )
          else if (q.type == QuestionType.SINGLE_CHOICE)
            RadioGroup<String>(
              groupValue: _singleChoiceAnswers[q.id],
              onChanged: (v) => setState(() => _singleChoiceAnswers[q.id] = v),
              child: Column(
                children: [
                  for (final opt in (q.options ?? const <String>[]))
                    RadioListTile<String>(
                      value: opt,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(opt, style: const TextStyle(fontSize: 13)),
                    ),
                ],
              ),
            )
          else
            Column(
              children: [
                for (final opt in (q.options ?? const <String>[]))
                  CheckboxListTile(
                    value: _multiChoiceAnswers[q.id]?.contains(opt) ?? false,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(opt, style: const TextStyle(fontSize: 13)),
                    onChanged: (v) {
                      setState(() {
                        final set = _multiChoiceAnswers[q.id]!;
                        v == true ? set.add(opt) : set.remove(opt);
                      });
                    },
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    final consentedContacts = _form!.contacts
        .where((c) => _contactConsent[c.type] == true)
        .map((c) => c.type.label)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '제출 내용 확인',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              const Text('• 필수 공유 항목: 이름, 주전공, 학년, 관심 분야'),
              Text('• 선택 공유: '
                  '${[
                if (_shareBio) '한 줄 소개',
                if (_shareSkills) '기술 스택',
                if (_selectedExpIds.isNotEmpty)
                  '경험 ${_selectedExpIds.length}건',
                if (_selectedLinkIds.isNotEmpty || _selectedFileIds.isNotEmpty)
                  '포트폴리오 ${_selectedLinkIds.length + _selectedFileIds.length}건',
              ].join(', ')}'),
              Text(
                '• 합격 시 공개할 연락처: ${consentedContacts.isEmpty ? "없음" : consentedContacts.join(", ")}',
              ),
              const Divider(height: 22),
              const Text(
                '추가 질문 답변',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              for (final q in _form!.questions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(q.content,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textMuted)),
                      const SizedBox(height: 2),
                      Text(
                        _formatAnswerPreview(q),
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SectionCard(
          backgroundColor: AppColors.primaryTint,
          borderColor: AppColors.primaryBorder,
          child: CheckboxListTile(
            value: _agreeToProvide,
            onChanged: (v) => setState(() => _agreeToProvide = v ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text(
              '[필수] 선택한 프로필 정보와 답변을 모집자에게 제공하며, 연락처는 최종 합격 시에만 공개됨에 동의합니다.',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  String _formatAnswerPreview(PostingQuestion q) {
    if (q.type == QuestionType.SHORT_TEXT || q.type == QuestionType.LONG_TEXT) {
      final t = _textAnswerCtrls[q.id]?.text.trim() ?? '';
      return t.isEmpty ? '(미입력)' : t;
    }
    if (q.type == QuestionType.SINGLE_CHOICE) {
      return _singleChoiceAnswers[q.id] ?? '(미선택)';
    }
    final list = _multiChoiceAnswers[q.id] ?? const <String>{};
    return list.isEmpty ? '(미선택)' : list.join(', ');
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (_step > 0) ...[
            OutlinedButton(
              onPressed: () => setState(() => _step--),
              child: const Text('이전'),
            ),
            const SizedBox(width: 8),
          ],
          if (_step == 1) ...[
            OutlinedButton(
              onPressed: _saveDraft,
              child: const Text('임시저장'),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _submitting
                  ? null
                  : () {
                      if (_step == 0) {
                        if (!_validateStep1()) return;
                        setState(() => _step = 1);
                      } else if (_step == 1) {
                        if (!_validateStep2()) return;
                        setState(() => _step = 2);
                      } else {
                        _submit();
                      }
                    },
              child: Text(
                _step < 2
                    ? '다음'
                    : (_submitting ? '제출 중...' : '지원서 제출하기'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.step, required this.postingTitle});

  final int step;
  final String postingTitle;

  @override
  Widget build(BuildContext context) {
    final labels = ['1. 프로필 선택', '2. 질문 답변', '3. 최종 확인'];
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < labels.length; i++)
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              i == step ? FontWeight.w700 : FontWeight.w500,
                          color: i <= step
                              ? AppColors.primary
                              : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 3,
                        color: i <= step
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            postingTitle,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
