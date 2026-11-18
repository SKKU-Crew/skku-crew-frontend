import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/codes.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/adaptive_shell.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/snapshot_view.dart';
import '../../data/state/app_controller.dart';
import '../../domain/models/api_models.dart';

/// SCR-11 공고 작성 화면 (4단계: 기본 정보 -> 상세 내용 -> 추가 질문 · 요청 연락처 -> 미리보기).
class PostingFormScreen extends StatefulWidget {
  const PostingFormScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<PostingFormScreen> createState() => _PostingFormScreenState();
}

class _PostingFormScreenState extends State<PostingFormScreen> {
  int _step = 0;
  final _titleCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController(text: '2');
  final _placeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _skillCtrl = TextEditingController();

  Category _category = Category.PROJECT;
  final List<Field> _fields = [Field.DATA];
  ActivityMode _mode = ActivityMode.HYBRID;
  DateTime _deadline = DateTime.now().add(const Duration(days: 7));
  final List<String> _skills = ['Python'];
  final List<_EditableQuestion> _questions = [];
  final Set<ContactType> _requestedContacts = {};
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final dup = widget.controller.duplicatePostingSource;
    if (dup != null) {
      widget.controller.duplicatePostingSource = null;
      _category = dup.category;
      _titleCtrl.text = dup.title;
      _fields
        ..clear()
        ..addAll(dup.fields);
      _capacityCtrl.text = dup.capacity.toString();
      _mode = dup.activityMode;
      _placeCtrl.text = dup.place ?? '';
      _skills
        ..clear()
        ..addAll(dup.skills);
      _descCtrl.text = dup.description;
      _requestedContacts
        ..clear()
        ..addAll(dup.requestedContacts);
      for (final q in dup.questions) {
        _questions.add(_EditableQuestion(
          type: q.type,
          content: q.content,
          required: q.required,
          maxLength: q.maxLength,
          options: q.options ?? const ['옵션 1', '옵션 2'],
        ));
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _capacityCtrl.dispose();
    _placeCtrl.dispose();
    _descCtrl.dispose();
    _skillCtrl.dispose();
    for (final q in _questions) {
      q.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline.isAfter(now) ? _deadline : now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (date == null || !mounted) return;
    setState(() {
      _deadline = DateTime(date.year, date.month, date.day, 23, 59);
    });
  }

  void _addQuestion() {
    if (_questions.length >= 10) {
      AppToast.show(context, '추가 질문은 최대 10개까지 작성할 수 있습니다.', isError: true);
      return;
    }
    setState(() {
      _questions.add(_EditableQuestion(
        type: QuestionType.LONG_TEXT,
        content: '',
        required: true,
        maxLength: 500,
      ));
    });
  }

  void _loadTemplate(QuestionTemplateItem tpl) {
    setState(() {
      for (final q in _questions) {
        q.dispose();
      }
      _questions.clear();
      for (final q in tpl.questions) {
        _questions.add(_EditableQuestion(
          type: q.type,
          content: q.content,
          required: q.required,
          maxLength: q.maxLength,
          options: q.options ?? const ['옵션 1', '옵션 2'],
        ));
      }
    });
    AppToast.show(context, "'${tpl.name}' 템플릿을 불러왔습니다.");
  }

  Future<void> _submit({required bool publish}) async {
    if (_titleCtrl.text.trim().length < 5) {
      AppToast.show(context, '제목은 5~50자로 입력해 주세요.', isError: true);
      setState(() => _step = 0);
      return;
    }
    if (_fields.isEmpty) {
      AppToast.show(context, '분야를 1~3개 선택해 주세요.', isError: true);
      setState(() => _step = 0);
      return;
    }
    if (_descCtrl.text.trim().length < 10) {
      AppToast.show(context, '상세 설명을 입력해 주세요.', isError: true);
      setState(() => _step = 1);
      return;
    }
    setState(() => _submitting = true);

    final req = PostingCreateRequest(
      publish: publish,
      category: _category,
      title: _titleCtrl.text.trim(),
      fields: _fields,
      capacity: int.tryParse(_capacityCtrl.text.trim()) ?? 1,
      deadline: AppFormatters.toIsoKst(_deadline),
      activityMode: _mode,
      place: _placeCtrl.text.trim().isEmpty ? null : _placeCtrl.text.trim(),
      skills: _skills,
      description: _descCtrl.text.trim(),
      questions: _questions
          .where((q) => q.contentCtrl.text.trim().isNotEmpty)
          .map((q) => QuestionInput(
                type: q.type,
                content: q.contentCtrl.text.trim(),
                required: q.required,
                maxLength: q.type == QuestionType.LONG_TEXT ? 500 : null,
                options: (q.type == QuestionType.SINGLE_CHOICE ||
                        q.type == QuestionType.MULTI_CHOICE)
                    ? q.optionsCtrl.text
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList()
                    : null,
              ))
          .toList(),
      requestedContacts: _requestedContacts.toList(),
    );

    try {
      final created = await widget.controller.api.createPosting(req);
      widget.controller.bumpDataVersion();
      if (mounted) {
        AppToast.show(
          context,
          publish ? '공고가 게시되었습니다.' : '공고가 임시저장되었습니다.',
        );
        widget.controller.go('/postings/${created.postingId}');
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        showNoticeDialog(context, title: '작성 오류', message: e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPersonal =
        widget.controller.currentUser?.memberType == MemberType.PERSONAL;
    final stepTitles = ['기본 정보', '상세 내용', '추가 질문', '미리보기'];

    return AdaptiveShell(
      controller: widget.controller,
      title: '공고 작성',
      leadingBack: true,
      showBottomNav: false,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 740),
          child: Column(
            children: [
              Container(
                color: AppColors.surface,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    for (var i = 0; i < stepTitles.length; i++)
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _step = i),
                          child: Column(
                            children: [
                              Text(
                                stepTitles[i],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: i == _step
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: i <= _step
                                      ? AppColors.primary
                                      : AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 3,
                                color: i <= _step
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _step == 0
                      ? _buildStep0(isPersonal)
                      : _step == 1
                          ? _buildStep1()
                          : _step == 2
                              ? _buildStep2()
                              : _buildStep3(),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    OutlinedButton(
                      onPressed:
                          _submitting ? null : () => _submit(publish: false),
                      child: const Text('임시저장'),
                    ),
                    const SizedBox(width: 8),
                    if (_step > 0) ...[
                      OutlinedButton(
                        onPressed: () => setState(() => _step--),
                        child: const Text('이전'),
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
                                if (_step < 3) {
                                  setState(() => _step++);
                                } else {
                                  _submit(publish: true);
                                }
                              },
                        child: Text(
                          _step < 3
                              ? '다음'
                              : (_submitting ? '게시 중...' : '공고 게시하기'),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep0(bool isPersonal) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleCtrl,
            maxLength: 50,
            decoration: const InputDecoration(
              labelText: '공고 제목 *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          const Text('카테고리 *', style: TextStyle(fontWeight: FontWeight.w600)),
          if (isPersonal)
            const Padding(
              padding: EdgeInsets.only(top: 2, bottom: 6),
              child: Text(
                '동아리·학회 및 연구 모집은 단체 계정에서 등록할 수 있어요.',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final c in Category.values)
                ChoiceChip(
                  label: Text(c.label),
                  selected: _category == c,
                  onSelected: (isPersonal && !Category.personalAllowed.contains(c))
                      ? null
                      : (_) => setState(() => _category = c),
                ),
            ],
          ),
          const SizedBox(height: 14),
          const Text('모집 분야 *',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
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
                        if (_fields.length < 3) _fields.add(f);
                      } else {
                        _fields.remove(f);
                      }
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _capacityCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '모집 인원 *',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: _pickDeadline,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: '마감 일시 *',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today, size: 18),
                    ),
                    child: Text(
                      AppFormatters.formatKstDateTime(_deadline),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('활동 방식 *', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              for (final m in ActivityMode.values)
                ChoiceChip(
                  label: Text(m.label),
                  selected: _mode == m,
                  onSelected: (_) => setState(() => _mode = m),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _placeCtrl,
            maxLength: 50,
            decoration: const InputDecoration(
              labelText: '활동 장소',
              hintText: '예: 자연과학캠퍼스 디지털도서관',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _skillCtrl,
                  decoration: const InputDecoration(
                    labelText: '우대 기술 스택',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  final v = _skillCtrl.text.trim();
                  if (v.isNotEmpty && _skills.length < 10) {
                    setState(() {
                      _skills.add(v);
                      _skillCtrl.clear();
                    });
                  }
                },
                child: const Text('추가'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: [
              for (var i = 0; i < _skills.length; i++)
                InputChip(
                  label: Text(_skills[i]),
                  onDeleted: () => setState(() => _skills.removeAt(i)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descCtrl,
            maxLines: 6,
            maxLength: 3000,
            decoration: const InputDecoration(
              labelText: '상세 내용 *',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '지원자 추가 질문',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            PopupMenuButton<QuestionTemplateItem>(
              onSelected: _loadTemplate,
              itemBuilder: (ctx) => [
                for (final tpl in widget.controller.questionTemplates)
                  PopupMenuItem(value: tpl, child: Text(tpl.name)),
              ],
              child: const Chip(
                avatar: Icon(Icons.library_books_outlined, size: 16),
                label: Text('템플릿 불러오기', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < _questions.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('질문 ${i + 1}',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      const Spacer(),
                      DropdownButton<QuestionType>(
                        value: _questions[i].type,
                        isDense: true,
                        items: [
                          for (final t in QuestionType.values)
                            DropdownMenuItem(value: t, child: Text(t.label)),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => _questions[i].type = v);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: () =>
                            setState(() => _questions.removeAt(i).dispose()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _questions[i].contentCtrl,
                    decoration: const InputDecoration(
                      labelText: '질문 내용',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (_questions[i].type == QuestionType.SINGLE_CHOICE ||
                      _questions[i].type == QuestionType.MULTI_CHOICE) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: _questions[i].optionsCtrl,
                      decoration: const InputDecoration(
                        labelText: '선택 항목',
                        hintText: '가능, 어려움',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                  SwitchListTile(
                    value: _questions[i].required,
                    onChanged: (v) =>
                        setState(() => _questions[i].required = v),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('필수 답변', style: TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _addQuestion,
            icon: const Icon(Icons.add),
            label: const Text('질문 추가'),
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '합격자 연락 수단',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(
                '최종 합격 발표가 완료된 뒤 합격자의 연락처만 공개됩니다.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  for (final ct in ContactType.values)
                    FilterChip(
                      label: Text(ct.label),
                      selected: _requestedContacts.contains(ct),
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            if (_requestedContacts.length < 2) {
                              _requestedContacts.add(ct);
                            } else {
                              AppToast.show(context, '요청 연락처는 최대 2개입니다.',
                                  isError: true);
                            }
                          } else {
                            _requestedContacts.remove(ct);
                          }
                        });
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusBadge.category(_category),
              const SizedBox(width: 8),
              Text(
                '마감 ${AppFormatters.formatKstDateTime(_deadline)}',
                style:
                    const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _titleCtrl.text.trim().isEmpty
                ? '(제목 미입력)'
                : _titleCtrl.text.trim(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: [
              for (final f in _fields) TagChip(label: f.label, highlight: true),
              for (final s in _skills) TagChip(label: s),
            ],
          ),
          const Divider(height: 22),
          Text('모집 인원: ${_capacityCtrl.text}명 · 활동 방식: ${_mode.label}'),
          if (_requestedContacts.isNotEmpty)
            Text(
              '요청 연락처: ${_requestedContacts.map((e) => e.label).join(", ")}',
              style: const TextStyle(color: AppColors.accentOrange),
            ),
          const SizedBox(height: 12),
          Text(
            _descCtrl.text.trim().isEmpty
                ? '(상세 설명 미입력)'
                : _descCtrl.text.trim(),
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _EditableQuestion {
  _EditableQuestion({
    required this.type,
    required String content,
    required this.required,
    this.maxLength,
    List<String> options = const ['가능', '어려움'],
  })  : contentCtrl = TextEditingController(text: content),
        optionsCtrl = TextEditingController(text: options.join(', '));

  QuestionType type;
  bool required;
  int? maxLength;
  final TextEditingController contentCtrl;
  final TextEditingController optionsCtrl;

  void dispose() {
    contentCtrl.dispose();
    optionsCtrl.dispose();
  }
}

/// SCR-12 지원자 관리 화면.
class ApplicantListScreen extends StatefulWidget {
  const ApplicantListScreen({
    super.key,
    required this.controller,
    required this.postingId,
  });

  final AppController controller;
  final int postingId;

  @override
  State<ApplicantListScreen> createState() => _ApplicantListScreenState();
}

class _ApplicantListScreenState extends State<ApplicantListScreen> {
  PostingDetail? _posting;
  List<ApplicantItem> _allApplicants = const [];
  List<ApplicantItem> _filtered = const [];
  Decision? _decisionFilter;
  ApplicantSort _sort = ApplicantSort.SUBMITTED;
  final _searchCtrl = TextEditingController();
  bool _loading = true;
  int _lastVersion = -1;

  @override
  void initState() {
    super.initState();
    if (widget.controller.pendingApplicantFilter != null) {
      _decisionFilter = widget.controller.pendingApplicantFilter;
      widget.controller.pendingApplicantFilter = null;
    }
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    _lastVersion = widget.controller.dataVersion;
    if (mounted) setState(() => _loading = true);
    try {
      final detail =
          await widget.controller.api.getPostingDetail(widget.postingId);
      final all = await widget.controller.api.getApplicants(widget.postingId);
      final filtered = await widget.controller.api.getApplicants(
        widget.postingId,
        decision: _decisionFilter,
        sort: _sort,
        keyword: _searchCtrl.text.trim().isEmpty
            ? null
            : _searchCtrl.text.trim(),
      );
      if (mounted) {
        setState(() {
          _posting = detail;
          _allApplicants = all;
          _filtered = filtered;
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        AppToast.show(context, e.message, isError: true);
      }
    }
  }

  Future<void> _closeEarly() async {
    final ok = await showConfirmDialog(
      context,
      title: '조기 마감',
      message: '공고를 지금 마감하고 결과 발표 단계로 이동하시겠습니까?',
      confirmLabel: '조기 마감',
      isDanger: true,
    );
    if (!ok) return;
    try {
      await widget.controller.api.closePosting(widget.postingId);
      widget.controller.bumpDataVersion();
      if (mounted) AppToast.show(context, '공고가 마감되었습니다.');
      await _load();
    } on ApiException catch (e) {
      if (mounted) AppToast.show(context, e.message, isError: true);
    }
  }

  Future<void> _showAcceptedContactsModal() async {
    try {
      final list =
          await widget.controller.api.getAcceptedContacts(widget.postingId);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('합격자 연락처'),
          content: SizedBox(
            width: 440,
            child: list.isEmpty
                ? const Text('합격자 연락처 내역이 없습니다.')
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final item in list)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(item.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            subtitle: Text(
                              item.contacts.isEmpty
                                  ? '공개에 동의한 연락처 없음'
                                  : item.contacts
                                      .map((c) => '${c.type.label}: ${c.value}')
                                      .join('\n'),
                            ),
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
    } on ApiException catch (e) {
      if (mounted) AppToast.show(context, e.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        if (_lastVersion != widget.controller.dataVersion) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _load());
        }

        final valid = _allApplicants.where((a) => !a.withdrawn).toList();
        final pendingCount =
            valid.where((a) => a.decision == Decision.PENDING).length;
        final acceptedCount =
            valid.where((a) => a.decision == Decision.ACCEPTED).length;
        final rejectedCount =
            valid.where((a) => a.decision == Decision.REJECTED).length;

        return AdaptiveShell(
          controller: widget.controller,
          title: '지원자 관리',
          leadingBack: true,
          showBottomNav: false,
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: Column(
                      children: [
                        Container(
                          color: AppColors.surface,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (_posting != null)
                                    StatusBadge.postingStatus(_posting!.status),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _posting?.title ?? '',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _StatTile('전체', valid.length),
                                  _StatTile('미정', pendingCount,
                                      color: AppColors.warning),
                                  _StatTile('합격', acceptedCount,
                                      color: AppColors.primary),
                                  _StatTile('불합격', rejectedCount,
                                      color: AppColors.textMuted),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _searchCtrl,
                                      onSubmitted: (_) => _load(),
                                      decoration: const InputDecoration(
                                        hintText: '이름 또는 기술 검색',
                                        prefixIcon: Icon(Icons.search, size: 18),
                                        isDense: true,
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  DropdownButton<ApplicantSort>(
                                    value: _sort,
                                    items: [
                                      for (final s in ApplicantSort.values)
                                        DropdownMenuItem(
                                            value: s, child: Text(s.label)),
                                    ],
                                    onChanged: (v) {
                                      if (v != null) {
                                        setState(() => _sort = v);
                                        _load();
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                children: [
                                  ChoiceChip(
                                    label: const Text('전체'),
                                    selected: _decisionFilter == null,
                                    onSelected: (_) {
                                      setState(() => _decisionFilter = null);
                                      _load();
                                    },
                                  ),
                                  for (final d in Decision.values)
                                    ChoiceChip(
                                      label: Text(d.label),
                                      selected: _decisionFilter == d,
                                      onSelected: (_) {
                                        setState(() => _decisionFilter = d);
                                        _load();
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: _filtered.isEmpty
                              ? const EmptyStateView(
                                  icon: Icons.people_outline,
                                  title: '조건에 맞는 지원자가 없습니다',
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _filtered.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (context, idx) {
                                    final a = _filtered[idx];
                                    return SectionCard(
                                      onTap: a.withdrawn
                                          ? null
                                          : () => widget.controller.push(
                                                '/applications/${a.applicationId}',
                                              ),
                                      backgroundColor: a.withdrawn
                                          ? AppColors.surfaceMuted
                                          : null,
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: a.withdrawn
                                                ? AppColors.border
                                                : AppColors.primaryTint,
                                            child: Text(
                                              a.name.isEmpty ? '?' : a.name[0],
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: a.withdrawn
                                                    ? AppColors.textMuted
                                                    : AppColors.primary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      a.name,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    if (a.hasMemo) ...[
                                                      const SizedBox(width: 6),
                                                      const Icon(
                                                          Icons.sticky_note_2_outlined,
                                                          size: 14,
                                                          color: AppColors
                                                              .textMuted),
                                                    ],
                                                  ],
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  a.withdrawn
                                                      ? '지원자가 지원을 취소했습니다.'
                                                      : '${a.department ?? ""} · ${a.academicStatus?.shortLabel ?? ""} · ${AppFormatters.formatMonthDayTime(a.submittedAt)}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.textMuted,
                                                  ),
                                                ),
                                                if (!a.withdrawn &&
                                                    a.topSkills.isNotEmpty) ...[
                                                  const SizedBox(height: 6),
                                                  Wrap(
                                                    spacing: 4,
                                                    children: [
                                                      for (final s in a.topSkills)
                                                        TagChip(label: s),
                                                    ],
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (a.withdrawn)
                                            const StatusBadge(
                                              label: '취소됨',
                                              backgroundColor:
                                                  AppColors.surfaceMuted,
                                              textColor: AppColors.textLight,
                                            )
                                          else if (a.decision != null)
                                            StatusBadge.decision(a.decision!),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                        _buildBottomBar(pendingCount),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildBottomBar(int pendingCount) {
    final status = _posting?.status;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == PostingStatus.OPEN)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.dangerBorder),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _closeEarly,
                    child: const Text('조기 마감 후 발표 진행'),
                  ),
                ),
              ],
            )
          else if (status == PostingStatus.CLOSED) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: pendingCount > 0
                    ? null
                    : () => widget.controller
                        .push('/postings/${widget.postingId}/announce'),
                child: const Text('결과 발표'),
              ),
            ),
            if (pendingCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '아직 심사하지 않은 지원자가 $pendingCount명 있습니다. 모두 결정한 뒤 발표할 수 있어요.',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.accentOrange),
                ),
              ),
          ] else if (status == PostingStatus.ANNOUNCED)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _showAcceptedContactsModal,
                icon: const Icon(Icons.contact_phone_outlined, size: 18),
                label: const Text('합격자 연락처 보기'),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile(this.label, this.count, {this.color = AppColors.textPrimary});

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w800, color: color),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// SCR-13 지원서 검토 화면.
class ApplicationReviewScreen extends StatefulWidget {
  const ApplicationReviewScreen({
    super.key,
    required this.controller,
    required this.applicationId,
  });

  final AppController controller;
  final int applicationId;

  @override
  State<ApplicationReviewScreen> createState() =>
      _ApplicationReviewScreenState();
}

class _ApplicationReviewScreenState extends State<ApplicationReviewScreen> {
  late int _currentAppId;
  ReviewDetail? _detail;
  List<ApplicantItem> _siblings = const [];
  final _memoCtrl = TextEditingController();
  Decision _decision = Decision.PENDING;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _currentAppId = widget.applicationId;
    _load();
  }

  @override
  void dispose() {
    _memoCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final d = await widget.controller.api.getReviewDetail(_currentAppId);
      final list =
          await widget.controller.api.getApplicants(d.posting.postingId);
      final validList = list.where((e) => !e.withdrawn).toList();
      if (mounted) {
        setState(() {
          _detail = d;
          _siblings = validList;
          _decision = d.decision ?? Decision.PENDING;
          _memoCtrl.text = d.memo ?? '';
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        AppToast.show(context, e.message, isError: true);
      }
    }
  }

  Future<void> _saveDecision(Decision decision) async {
    setState(() {
      _decision = decision;
      _saving = true;
    });
    try {
      await widget.controller.api.decideApplication(
        _currentAppId,
        decision: decision,
        memo: _memoCtrl.text.trim(),
      );
      widget.controller.bumpDataVersion();
      if (mounted) {
        setState(() => _saving = false);
        AppToast.show(context, '${decision.label} 상태로 저장되었습니다.');
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
    final idx =
        _siblings.indexWhere((element) => element.applicationId == _currentAppId);
    final total = _siblings.length;

    return AdaptiveShell(
      controller: widget.controller,
      title: '지원서 검토',
      leadingBack: true,
      showBottomNav: false,
      body: _loading || _detail == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SnapshotViewWidget(
                                      snapshot: _detail!.snapshot),
                                  const Divider(height: 22),
                                  if (_detail!.contacts != null &&
                                      _detail!.contacts!.isNotEmpty)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '합격자 공개 연락처',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        for (final c in _detail!.contacts!)
                                          Text('${c.type.label}: ${c.value}'),
                                      ],
                                    )
                                  else
                                    const Row(
                                      children: [
                                        Icon(Icons.lock_outline,
                                            size: 16,
                                            color: AppColors.accentOrange),
                                        SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            '연락처는 최종 합격 발표 후 공개됩니다.',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.accentOrange,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            for (var i = 0; i < _detail!.answers.length; i++)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: SectionCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Q${i + 1}. ${_detail!.answers[i].content}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _detail!.answers[i].value is List
                                            ? (_detail!.answers[i].value
                                                    as List)
                                                .join(', ')
                                            : (_detail!.answers[i].value
                                                    ?.toString() ??
                                                '(미입력)'),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            SectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.lock_outline,
                                          size: 15, color: AppColors.textMuted),
                                      SizedBox(width: 6),
                                      Text(
                                        '심사 메모',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _memoCtrl,
                                    maxLines: 2,
                                    maxLength: 500,
                                    decoration: const InputDecoration(
                                      hintText: '모집자만 볼 수 있는 메모를 남겨보세요.',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    '선발 여부',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      for (final d in [
                                        Decision.ACCEPTED,
                                        Decision.REJECTED,
                                        Decision.PENDING,
                                      ])
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 3),
                                            child: _decision == d
                                                ? FilledButton(
                                                    style: FilledButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          d == Decision.ACCEPTED
                                                              ? AppColors
                                                                  .primary
                                                              : d ==
                                                                      Decision
                                                                          .REJECTED
                                                                  ? AppColors
                                                                      .danger
                                                                  : AppColors
                                                                      .warning,
                                                    ),
                                                    onPressed: _saving
                                                        ? null
                                                        : () =>
                                                            _saveDecision(d),
                                                    child: Text(d.label),
                                                  )
                                                : OutlinedButton(
                                                    onPressed: _saving
                                                        ? null
                                                        : () =>
                                                            _saveDecision(d),
                                                    child: Text(d.label),
                                                  ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        border: Border(top: BorderSide(color: AppColors.border)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: idx > 0
                                  ? () {
                                      setState(() {
                                        _currentAppId =
                                            _siblings[idx - 1].applicationId;
                                      });
                                      _load();
                                    }
                                  : null,
                              child: const Text('< 이전'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: idx >= 0 && idx < total - 1
                                  ? () {
                                      setState(() {
                                        _currentAppId =
                                            _siblings[idx + 1].applicationId;
                                      });
                                      _load();
                                    }
                                  : null,
                              child: const Text('다음 >'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

/// SCR-14 결과 발표 화면.
class AnnounceResultScreen extends StatefulWidget {
  const AnnounceResultScreen({
    super.key,
    required this.controller,
    required this.postingId,
  });

  final AppController controller;
  final int postingId;

  @override
  State<AnnounceResultScreen> createState() => _AnnounceResultScreenState();
}

class _AnnounceResultScreenState extends State<AnnounceResultScreen> {
  PostingDetail? _posting;
  int _accepted = 0;
  int _rejected = 0;
  int _pending = 0;
  bool _loading = true;
  bool _submitting = false;

  final _acceptMsgCtrl = TextEditingController(
    text: '합격을 축하합니다! 오리엔테이션 및 향후 일정은 공개된 연락처로 안내드리겠습니다.',
  );
  final _rejectMsgCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _acceptMsgCtrl.dispose();
    _rejectMsgCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final p = await widget.controller.api.getPostingDetail(widget.postingId);
      final apps = await widget.controller.api.getApplicants(widget.postingId);
      final valid = apps.where((a) => !a.withdrawn).toList();
      if (mounted) {
        setState(() {
          _posting = p;
          _accepted =
              valid.where((a) => a.decision == Decision.ACCEPTED).length;
          _rejected =
              valid.where((a) => a.decision == Decision.REJECTED).length;
          _pending =
              valid.where((a) => a.decision == Decision.PENDING).length;
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        AppToast.show(context, e.message, isError: true);
      }
    }
  }

  Future<void> _announce() async {
    if (_acceptMsgCtrl.text.trim().isEmpty) {
      AppToast.show(context, '합격자 안내 메시지를 입력해 주세요.', isError: true);
      return;
    }
    final ok = await showConfirmDialog(
      context,
      title: '결과 발표 확인',
      message: '결과를 발표하면 모든 지원자에게 동시에 공개되며 이후 결과를 수정할 수 없습니다. 발표할까요?',
      confirmLabel: '발표하기',
    );
    if (!ok) return;

    setState(() => _submitting = true);
    try {
      final res = await widget.controller.api.announcePosting(
        widget.postingId,
        acceptMessage: _acceptMsgCtrl.text.trim(),
        rejectMessage: _rejectMsgCtrl.text.trim().isEmpty
            ? null
            : _rejectMsgCtrl.text.trim(),
      );
      widget.controller.bumpDataVersion();
      if (!mounted) return;
      await showNoticeDialog(
        context,
        title: '결과 발표가 완료되었습니다',
        message:
            '합격 ${res.accepted}명, 불합격 ${res.rejected}명에게 결과가 공개되고 알림이 발송되었습니다.${res.warning != null ? "\n\n${res.warning}" : ""}',
      );
      if (mounted) widget.controller.pop();
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        showNoticeDialog(context, title: '발표 불가', message: e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final capacity = _posting?.capacity ?? 0;
    final overCapacity = _accepted > capacity;

    return AdaptiveShell(
      controller: widget.controller,
      title: '결과 발표',
      leadingBack: true,
      showBottomNav: false,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _posting?.title ?? '',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                _StatTile('합격', _accepted,
                                    color: AppColors.primary),
                                _StatTile('불합격', _rejected,
                                    color: AppColors.textMuted),
                                _StatTile('모집 인원', capacity),
                              ],
                            ),
                            if (_pending > 0) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.dangerBg,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '결정하지 않은 지원서가 $_pending건 있습니다. 모든 지원자 결정 후 발표할 수 있습니다.',
                                  style: const TextStyle(
                                      color: AppColors.danger, fontSize: 13),
                                ),
                              ),
                            ],
                            if (overCapacity) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.warningBg,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: AppColors.warningBorder),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded,
                                        color: AppColors.warning, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '합격 인원($_accepted명)이 모집 인원($capacity명)을 넘습니다.',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.warning,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            SectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    controller: _acceptMsgCtrl,
                                    maxLines: 4,
                                    maxLength: 500,
                                    decoration: const InputDecoration(
                                      labelText: '합격자 안내 메시지 *',
                                      hintText: '오리엔테이션 일정, 단체 대화방 링크 등',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _rejectMsgCtrl,
                                    maxLines: 3,
                                    maxLength: 500,
                                    decoration: const InputDecoration(
                                      labelText: '불합격자 안내 메시지',
                                      hintText: '비워두면 기본 안내 문구가 전달됩니다.',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.info_outline,
                                      size: 17, color: AppColors.textMuted),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '발표 후 합격자가 제공에 동의한 연락처와 모집자의 연락처가 서로 공개됩니다. 발표 후에는 결과를 수정할 수 없습니다.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        height: 1.45,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        border: Border(top: BorderSide(color: AppColors.border)),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          onPressed: _submitting ? null : _announce,
                          icon: const Icon(Icons.campaign_outlined),
                          label: Text(
                            _submitting ? '발표 중...' : '발표하기',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
