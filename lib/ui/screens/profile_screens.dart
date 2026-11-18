import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/codes.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/adaptive_shell.dart';
import '../../core/widgets/common_widgets.dart';
import '../../data/state/app_controller.dart';
import '../../domain/models/api_models.dart';

/// SCR-09 내 프로필 화면 (GET /api/profiles/me, 활동 이력 공개 토글).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileResponse? _profile;
  bool _loading = true;
  String? _error;
  int _lastVersion = -1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _lastVersion = widget.controller.dataVersion;
    if (!widget.controller.isLoggedIn ||
        widget.controller.currentUser?.memberType != MemberType.PERSONAL) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = '개인회원 로그인 후 이용할 수 있습니다.';
        });
      }
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final p = await widget.controller.api.getMyProfile();
      if (mounted) {
        setState(() {
          _profile = p;
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _loading = false;
        });
      }
    }
  }

  Future<void> _toggleHistory(ActivityHistoryItem item, bool visible) async {
    try {
      final updated = await widget.controller.api
          .setActivityHistoryVisible(item.applicationId, visible);
      if (mounted) {
        setState(() => _profile = updated);
        AppToast.show(context, visible ? '활동 이력을 공개로 설정했습니다.' : '활동 이력을 숨겼습니다.');
      }
    } on ApiException catch (e) {
      if (mounted) AppToast.show(context, e.message, isError: true);
    }
  }

  void _showPreviewModal() {
    final p = _profile;
    if (p == null) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('모집자에게 보이는 화면'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${p.name} · ${p.majorPrimary ?? "전공 미입력"} · ${p.academicStatus?.shortLabel ?? ""}',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final f in p.fields)
                      TagChip(label: f.label, highlight: true),
                  ],
                ),
                if (p.defaultShare['bio'] == true &&
                    (p.bio?.isNotEmpty ?? false)) ...[
                  const SizedBox(height: 10),
                  Text(p.bio!, style: const TextStyle(fontSize: 13)),
                ],
                if (p.defaultShare['skills'] == true && p.skills.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final s in p.skills)
                        TagChip(label: '${s.name} ${s.level.label}'),
                    ],
                  ),
                ],
                if (p.defaultShare['experiences'] == true &&
                    p.experiences.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text('경험',
                      style:
                          TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  for (final e in p.experiences)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('• ${e.title}',
                          style: const TextStyle(fontSize: 13)),
                    ),
                ],
                const Divider(height: 20),
                const Text(
                  '※ 연락처는 지원 시 동의 후 합격 발표한 경우에만 공개됩니다.',
                  style:
                      TextStyle(fontSize: 12, color: AppColors.accentOrange),
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
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        if (_lastVersion != widget.controller.dataVersion) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _load());
        }

        return AdaptiveShell(
          controller: widget.controller,
          title: '내 프로필',
          actions: [
            if (_profile != null)
              TextButton(
                onPressed: () => widget.controller.push('/me/profile/edit'),
                child: const Text(
                  '편집',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null || _profile == null
                  ? EmptyStateView(
                      icon: Icons.person_outline,
                      title: _error ?? '프로필을 불러올 수 없습니다.',
                    )
                  : _buildContent(_profile!),
        );
      },
    );
  }

  Widget _buildContent(ProfileResponse p) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: AppColors.primaryTint,
                              child: Text(
                                p.name.isEmpty ? '?' : p.name[0],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    [
                                      p.majorPrimary ?? '전공 미입력',
                                      if (p.majorsSecondary.isNotEmpty)
                                        '복수: ${p.majorsSecondary.join(", ")}',
                                      if (p.academicStatus != null)
                                        p.academicStatus!.shortLabel,
                                    ].join(' · '),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  if (p.bio != null && p.bio!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      p.bio!,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Text(
                              '프로필 완성도',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.textMuted),
                            ),
                            const Spacer(),
                            Text(
                              '${p.completeness}%',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: (p.completeness / 100).clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor: AppColors.surfaceMuted,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '관심 분야 · 기술',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final f in p.fields)
                              TagChip(label: f.label, highlight: true),
                          ],
                        ),
                        if (p.skills.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final s in p.skills)
                                TagChip(label: '${s.name} ${s.level.label}'),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              '경험',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                            const Spacer(),
                            Text(
                              '${p.experiences.length}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (p.experiences.isEmpty)
                          const Text('등록된 경험이 없습니다.',
                              style: TextStyle(
                                  fontSize: 13, color: AppColors.textMuted))
                        else
                          for (final e in p.experiences)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      TagChip(label: e.type.label),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          e.title,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${e.role ?? ""} · ${e.startDate ?? ""} ~ ${e.endDate ?? "진행중"}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted),
                                  ),
                                  if ((e.description ?? '').isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      e.description!,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '포트폴리오 · 연락처',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            for (final l in p.portfolioLinks)
                              Chip(
                                avatar: const Icon(Icons.link, size: 15),
                                label: Text(l.title,
                                    style: const TextStyle(fontSize: 12)),
                              ),
                            for (final f in p.portfolioFiles)
                              Chip(
                                avatar: const Icon(
                                    Icons.picture_as_pdf_outlined,
                                    size: 15),
                                label: Text(f.fileName,
                                    style: const TextStyle(fontSize: 12)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '학교 이메일: ${p.schoolEmail ?? "-"} · 카카오톡 ID: ${p.contacts.kakaoId ?? "미등록"} · 전화번호: ${p.contacts.phone ?? "미등록"} · 개인 이메일: ${p.contacts.personalEmail ?? "미등록"}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        const Row(
                          children: [
                            Icon(Icons.lock_outline,
                                size: 14, color: AppColors.textMuted),
                            SizedBox(width: 6),
                            Text(
                              '지원할 때 선택한 항목만 모집자에게 공개돼요.',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SKKU Crew 활동 이력',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        if (p.activityHistory.isEmpty)
                          const Text(
                            '아직 선발 완료된 활동 이력이 없습니다.',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textMuted),
                          )
                        else
                          for (final h in p.activityHistory)
                            SwitchListTile(
                              value: h.visible,
                              onChanged: (v) => _toggleHistory(h, v),
                              contentPadding: EdgeInsets.zero,
                              activeThumbColor: AppColors.primary,
                              title: Text(
                                h.postingTitle,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                '${h.recruiterName} · ${AppFormatters.formatDateOnly(h.announcedAt)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _showPreviewModal,
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('모집자에게 보이는 화면'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// SCR-10 프로필 편집 화면 (PUT /api/profiles/me, GET /api/skills 자동완성).
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _skillSearchCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _kakaoCtrl = TextEditingController();
  final _personalEmailCtrl = TextEditingController();

  String _majorPrimary = DomainConstants.skkuDepartments.first;
  final List<String> _majorsSecondary = [];
  AcademicStatus _academicStatus = AcademicStatus.GRADE_3;
  final List<Field> _fields = [];
  final List<SkillItem> _skills = [];
  SkillLevel _newSkillLevel = SkillLevel.MID;
  List<String> _skillSuggestions = const [];
  final List<ExperienceItem> _experiences = [];
  final List<PortfolioLinkItem> _links = [];
  final List<PortfolioFileItem> _files = [];
  Map<String, bool> _defaultShare = {};

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _skillSearchCtrl.dispose();
    _phoneCtrl.dispose();
    _kakaoCtrl.dispose();
    _personalEmailCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final p = await widget.controller.api.getMyProfile();
      _nameCtrl.text = p.name;
      _bioCtrl.text = p.bio ?? '';
      _majorPrimary = p.majorPrimary != null &&
              DomainConstants.skkuDepartments.contains(p.majorPrimary)
          ? p.majorPrimary!
          : DomainConstants.skkuDepartments.first;
      _majorsSecondary
        ..clear()
        ..addAll(p.majorsSecondary);
      _academicStatus = p.academicStatus ?? AcademicStatus.GRADE_3;
      _fields
        ..clear()
        ..addAll(p.fields);
      _skills
        ..clear()
        ..addAll(p.skills);
      _experiences
        ..clear()
        ..addAll(p.experiences);
      _links
        ..clear()
        ..addAll(p.portfolioLinks);
      _files
        ..clear()
        ..addAll(p.portfolioFiles);
      _phoneCtrl.text = p.contacts.phone ?? '';
      _kakaoCtrl.text = p.contacts.kakaoId ?? '';
      _personalEmailCtrl.text = p.contacts.personalEmail ?? '';
      _defaultShare = Map<String, bool>.from(p.defaultShare);
      if (mounted) setState(() => _loading = false);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        AppToast.show(context, e.message, isError: true);
      }
    }
  }

  Future<void> _updateSkillSuggestions(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _skillSuggestions = const []);
      return;
    }
    final list = await widget.controller.api.suggestSkills(query.trim());
    if (mounted) setState(() => _skillSuggestions = list);
  }

  void _addSkill(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    if (_skills.length >= 20) {
      AppToast.show(context, '기술 스택은 최대 20개까지 등록할 수 있습니다.', isError: true);
      return;
    }
    if (_skills.any((s) => s.name.toLowerCase() == trimmed.toLowerCase())) {
      return;
    }
    setState(() {
      _skills.add(SkillItem(name: trimmed, level: _newSkillLevel));
      _skillSearchCtrl.clear();
      _skillSuggestions = const [];
    });
  }

  Future<void> _addExperienceDialog({
    ExperienceItem? initial,
    int? editIndex,
  }) async {
    final titleCtrl = TextEditingController(text: initial?.title ?? '');
    final roleCtrl = TextEditingController(text: initial?.role ?? '');
    final descCtrl = TextEditingController(text: initial?.description ?? '');
    var type = initial?.type ?? ExperienceType.PROJECT;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(initial == null ? '경험 추가' : '경험 수정'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<ExperienceType>(
                  initialValue: type,
                  decoration: const InputDecoration(
                      labelText: '유형', border: OutlineInputBorder()),
                  items: [
                    for (final t in ExperienceType.values)
                      DropdownMenuItem(value: t, child: Text(t.label)),
                  ],
                  onChanged: (v) => setLocal(() => type = v ?? type),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                      labelText: '제목 *', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: roleCtrl,
                  decoration: const InputDecoration(
                      labelText: '역할', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  maxLength: 500,
                  decoration: const InputDecoration(
                      labelText: '설명', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(initial == null ? '추가' : '저장'),
            ),
          ],
        ),
      ),
    );
    if (ok == true && titleCtrl.text.trim().isNotEmpty) {
      final item = ExperienceItem(
        id: initial?.id,
        type: type,
        title: titleCtrl.text.trim(),
        role: roleCtrl.text.trim(),
        startDate: initial?.startDate ?? '2026-09-01',
        endDate: initial?.endDate,
        description: descCtrl.text.trim(),
      );
      setState(() {
        if (editIndex != null &&
            editIndex >= 0 &&
            editIndex < _experiences.length) {
          _experiences[editIndex] = item;
        } else {
          _experiences.add(item);
        }
      });
    }
    titleCtrl.dispose();
    roleCtrl.dispose();
    descCtrl.dispose();
  }

  Future<void> _addFileDialog() async {
    final nameCtrl = TextEditingController();
    final urlCtrl = TextEditingController(
      text: 'https://files.skkucrew.example/portfolio_${_files.length + 1}.pdf',
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('포트폴리오 PDF 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'PDF 파일명 *',
                hintText: '예: 김성균_포트폴리오.pdf',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: urlCtrl,
              decoration: const InputDecoration(
                labelText: '파일 URL 또는 경로 *',
                hintText: 'https://...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('추가'),
          ),
        ],
      ),
    );
    if (ok == true) {
      var name = nameCtrl.text.trim();
      final url = urlCtrl.text.trim();
      if (name.isEmpty) {
        if (mounted) AppToast.show(context, '파일명을 입력해 주세요.', isError: true);
      } else {
        if (!name.toLowerCase().endsWith('.pdf')) {
          name = '$name.pdf';
        }
        final urlErr = AppValidators.validateUrl(url, required: true);
        if (urlErr != null) {
          if (mounted) AppToast.show(context, urlErr, isError: true);
        } else {
          setState(() {
            _files.add(PortfolioFileItem(fileName: name, url: url));
          });
        }
      }
    }
    nameCtrl.dispose();
    urlCtrl.dispose();
  }

  Future<void> _addLinkDialog() async {
    final titleCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('포트폴리오 링크 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              maxLength: 30,
              decoration: const InputDecoration(
                  labelText: '링크 이름',
                  hintText: '예: GitHub, 포트폴리오',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: urlCtrl,
              decoration: const InputDecoration(
                  labelText: '링크 주소',
                  hintText: 'https://...',
                  border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('취소')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('추가')),
        ],
      ),
    );
    if (ok == true) {
      final err = AppValidators.validateUrl(urlCtrl.text, required: true);
      if (err != null) {
        if (mounted) AppToast.show(context, err, isError: true);
      } else {
        setState(() {
          _links.add(PortfolioLinkItem(
            title: titleCtrl.text.trim().isEmpty
                ? '링크'
                : titleCtrl.text.trim(),
            url: urlCtrl.text.trim(),
          ));
        });
      }
    }
    titleCtrl.dispose();
    urlCtrl.dispose();
  }

  Future<void> _save() async {
    if (_fields.isEmpty) {
      AppToast.show(context, '관심 분야를 1~5개 선택해 주세요.', isError: true);
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.controller.api.updateMyProfile(
        ProfileUpdateRequest(
          name: _nameCtrl.text.trim(),
          majorPrimary: _majorPrimary,
          majorsSecondary: _majorsSecondary,
          academicStatus: _academicStatus,
          bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
          fields: _fields,
          skills: _skills,
          experiences: _experiences,
          portfolioLinks: _links,
          portfolioFiles: _files,
          contacts: ContactsData(
            phone: _phoneCtrl.text.trim().isEmpty
                ? null
                : _phoneCtrl.text.trim(),
            kakaoId: _kakaoCtrl.text.trim().isEmpty
                ? null
                : _kakaoCtrl.text.trim(),
            personalEmail: _personalEmailCtrl.text.trim().isEmpty
                ? null
                : _personalEmailCtrl.text.trim(),
          ),
          defaultShare: _defaultShare,
        ),
      );
      await widget.controller.refreshMe();
      widget.controller.bumpDataVersion();
      if (mounted) {
        AppToast.show(context, '프로필이 저장되었습니다.');
        widget.controller.pop();
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        AppToast.show(context, e.message, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveShell(
      controller: widget.controller,
      title: '프로필 편집',
      leadingBack: true,
      showBottomNav: false,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('기본 정보',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _nameCtrl,
                                    maxLength: 20,
                                    decoration: const InputDecoration(
                                      labelText: '이름 *',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: _bioCtrl,
                                    maxLength: 50,
                                    decoration: const InputDecoration(
                                      labelText: '한 줄 소개',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  DropdownButtonFormField<String>(
                                    initialValue: _majorPrimary,
                                    decoration: const InputDecoration(
                                      labelText: '주전공 *',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: [
                                      for (final d
                                          in DomainConstants.skkuDepartments)
                                        DropdownMenuItem(
                                            value: d, child: Text(d)),
                                    ],
                                    onChanged: (v) {
                                      if (v != null) {
                                        setState(() => _majorPrimary = v);
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '복수·부전공 (선택, ${_majorsSecondary.length}/2)',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      if (_majorsSecondary.isNotEmpty) ...[
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: [
                                            for (final m in _majorsSecondary)
                                              InputChip(
                                                label: Text(m,
                                                    style: const TextStyle(
                                                        fontSize: 12)),
                                                onDeleted: () => setState(() =>
                                                    _majorsSecondary.remove(m)),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                      if (_majorsSecondary.length < 2)
                                        DropdownButtonFormField<String>(
                                          key: ValueKey(
                                              'sec_${_majorPrimary}_${_majorsSecondary.join(",")}'),
                                          decoration: const InputDecoration(
                                            labelText: '복수·부전공 추가',
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                          items: [
                                            for (final d in DomainConstants
                                                .skkuDepartments)
                                              if (d != _majorPrimary &&
                                                  !_majorsSecondary.contains(d))
                                                DropdownMenuItem(
                                                    value: d, child: Text(d)),
                                          ],
                                          onChanged: (v) {
                                            if (v != null &&
                                                _majorsSecondary.length < 2 &&
                                                !_majorsSecondary.contains(v)) {
                                              setState(
                                                  () => _majorsSecondary.add(v));
                                            }
                                          },
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  DropdownButtonFormField<AcademicStatus>(
                                    initialValue: _academicStatus,
                                    decoration: const InputDecoration(
                                      labelText: '학년 · 학적 상태 *',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: [
                                      for (final a in AcademicStatus.values)
                                        DropdownMenuItem(
                                            value: a, child: Text(a.label)),
                                    ],
                                    onChanged: (v) {
                                      if (v != null) {
                                        setState(() => _academicStatus = v);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            SectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '관심 분야',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: [
                                      for (final f in Field.values)
                                        FilterChip(
                                          label: Text(f.label),
                                          selected: _fields.contains(f),
                                          onSelected: (v) {
                                            setState(() {
                                              if (v) {
                                                if (_fields.length < 5) {
                                                  _fields.add(f);
                                                }
                                              } else {
                                                _fields.remove(f);
                                              }
                                            });
                                          },
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            SectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '보유 기술 스택',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _skillSearchCtrl,
                                          onChanged: _updateSkillSuggestions,
                                          onSubmitted: _addSkill,
                                          decoration: const InputDecoration(
                                            hintText: '기술 스택 검색 (예: Python, Flutter)',
                                            isDense: true,
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      DropdownButton<SkillLevel>(
                                        value: _newSkillLevel,
                                        items: [
                                          for (final l in SkillLevel.values)
                                            DropdownMenuItem(
                                              value: l,
                                              child: Text('숙련도 ${l.label}'),
                                            ),
                                        ],
                                        onChanged: (v) => setState(() =>
                                            _newSkillLevel =
                                                v ?? SkillLevel.MID),
                                      ),
                                      const SizedBox(width: 6),
                                      FilledButton(
                                        style: FilledButton.styleFrom(
                                            backgroundColor: AppColors.primary),
                                        onPressed: () =>
                                            _addSkill(_skillSearchCtrl.text),
                                        child: const Text('추가'),
                                      ),
                                    ],
                                  ),
                                  if (_skillSuggestions.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: [
                                        for (final s in _skillSuggestions)
                                          ActionChip(
                                            label: Text('+ $s',
                                                style: const TextStyle(
                                                    fontSize: 12)),
                                            onPressed: () => _addSkill(s),
                                          ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      for (var i = 0; i < _skills.length; i++)
                                        InputChip(
                                          label: Text(
                                            '${_skills[i].name} ${_skills[i].level.label}',
                                          ),
                                          onDeleted: () => setState(
                                              () => _skills.removeAt(i)),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            SectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        '경험 및 활동 내역',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      const Spacer(),
                                      TextButton.icon(
                                        onPressed: _experiences.length < 20
                                            ? _addExperienceDialog
                                            : null,
                                        icon: const Icon(Icons.add, size: 18),
                                        label: const Text('경험 추가'),
                                      ),
                                    ],
                                  ),
                                  for (var i = 0; i < _experiences.length; i++)
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                      title: Text(_experiences[i].title),
                                      subtitle: Text(
                                          '${_experiences[i].type.label} · ${_experiences[i].role ?? ""}'),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                                Icons.edit_outlined,
                                                size: 18),
                                            onPressed: () =>
                                                _addExperienceDialog(
                                              initial: _experiences[i],
                                              editIndex: i,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.delete_outline,
                                                size: 18),
                                            onPressed: () => setState(
                                                () => _experiences.removeAt(i)),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            SectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        '포트폴리오 · 연락처',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      const Spacer(),
                                      TextButton.icon(
                                        onPressed: _links.length < 5
                                            ? _addLinkDialog
                                            : null,
                                        icon: const Icon(Icons.add_link,
                                            size: 18),
                                        label: const Text('링크 추가'),
                                      ),
                                    ],
                                  ),
                                  for (var i = 0; i < _links.length; i++)
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                      leading: const Icon(Icons.link, size: 18),
                                      title: Text(_links[i].title),
                                      subtitle: Text(_links[i].url),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            size: 18),
                                        onPressed: () =>
                                            setState(() => _links.removeAt(i)),
                                      ),
                                    ),
                                  const Divider(height: 16),
                                  Row(
                                    children: [
                                      Text(
                                        '포트폴리오 PDF (${_files.length}/3, 각 10MB 이하)',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const Spacer(),
                                      TextButton.icon(
                                        onPressed: _files.length < 3
                                            ? _addFileDialog
                                            : null,
                                        icon: const Icon(
                                            Icons.upload_file_outlined,
                                            size: 18),
                                        label: const Text('PDF 추가'),
                                      ),
                                    ],
                                  ),
                                  for (var i = 0; i < _files.length; i++)
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                      leading: const Icon(
                                          Icons.picture_as_pdf_outlined,
                                          size: 18,
                                          color: AppColors.danger),
                                      title: Text(_files[i].fileName),
                                      subtitle: Text(_files[i].url),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            size: 18),
                                        onPressed: () =>
                                            setState(() => _files.removeAt(i)),
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _kakaoCtrl,
                                    decoration: const InputDecoration(
                                      labelText: '카카오톡 ID',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: _phoneCtrl,
                                    decoration: const InputDecoration(
                                      labelText: '전화번호',
                                      hintText: '010-0000-0000',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: _personalEmailCtrl,
                                    decoration: const InputDecoration(
                                      labelText: '개인 이메일',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            SectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '지원 시 기본 공개 항목',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  for (final entry in const [
                                    ('bio', '한 줄 소개'),
                                    ('skills', '기술 스택'),
                                    ('experiences', '경험'),
                                    ('portfolioLinks', '포트폴리오 링크'),
                                    ('portfolioFiles', '포트폴리오 PDF'),
                                  ])
                                    SwitchListTile(
                                      value: _defaultShare[entry.$1] ?? false,
                                      onChanged: (v) => setState(
                                          () => _defaultShare[entry.$1] = v),
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      activeThumbColor: AppColors.primary,
                                      title: Text(entry.$2,
                                          style: const TextStyle(fontSize: 13)),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _saving ? null : _save,
                          child: Text(
                            _saving ? '저장 중...' : '저장',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
