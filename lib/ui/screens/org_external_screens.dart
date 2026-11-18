import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/codes.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/adaptive_shell.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/posting_card_widget.dart';
import '../../data/state/app_controller.dart';
import '../../domain/models/api_models.dart';

/// SCR-15 단체 대시보드 화면.
class OrgDashboardScreen extends StatefulWidget {
  const OrgDashboardScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<OrgDashboardScreen> createState() => _OrgDashboardScreenState();
}

class _OrgDashboardScreenState extends State<OrgDashboardScreen> {
  OrgPage? _org;
  List<MyPostingItem> _myPostings = const [];
  bool _loading = true;
  int _lastVersion = -1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _lastVersion = widget.controller.dataVersion;
    final orgId = widget.controller.currentUser?.memberId ?? 6;
    if (mounted) setState(() => _loading = true);
    try {
      final org = await widget.controller.api.getOrgPage(orgId);
      final mine = await widget.controller.api.getMyPostings();
      if (mounted) {
        setState(() {
          _org = org;
          _myPostings = mine;
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

  Future<void> _duplicateLastPosting() async {
    if (_myPostings.isEmpty) {
      AppToast.show(context, '복제할 이전 공고가 없습니다.', isError: true);
      return;
    }
    final detail =
        await widget.controller.api.getPostingDetail(_myPostings.first.postingId);
    widget.controller.duplicatePostingSource = PostingCreateRequest(
      publish: false,
      category: detail.category,
      title: detail.title,
      fields: detail.fields,
      capacity: detail.capacity,
      deadline: AppFormatters.toIsoKst(DateTime.now().add(const Duration(days: 7))),
      activityMode: detail.activityMode,
      place: detail.place,
      skills: detail.skills,
      description: detail.description,
      requestedContacts: detail.requestedContacts,
      questions: detail.questions
          .map((q) => QuestionInput(
                type: q.type,
                content: q.content,
                required: q.required,
                maxLength: q.maxLength,
                options: q.options,
              ))
          .toList(),
    );
    if (mounted) widget.controller.push('/postings/new');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        if (_lastVersion != widget.controller.dataVersion) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _load());
        }

        final openCount =
            _myPostings.where((p) => p.status == PostingStatus.OPEN).length;
        final totalApplicants =
            _myPostings.fold<int>(0, (sum, p) => sum + p.counts.total);
        final totalPending =
            _myPostings.fold<int>(0, (sum, p) => sum + p.counts.pending);

        return AdaptiveShell(
          controller: widget.controller,
          title: '단체 대시보드',
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 820),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_org != null)
                                SectionCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 22,
                                            backgroundColor: AppColors.primary,
                                            child: Text(
                                              _org!.name.isEmpty
                                                  ? 'O'
                                                  : _org!.name[0],
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w800),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _org!.name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                                Text(
                                                  _org!.orgType,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.textMuted,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          StatusBadge(
                                            label: _org!.verified
                                                ? '인증 완료'
                                                : '인증 대기',
                                            icon: _org!.verified
                                                ? Icons.verified
                                                : Icons.hourglass_top,
                                            backgroundColor: _org!.verified
                                                ? AppColors.primaryTint
                                                : AppColors.warningBg,
                                            textColor: _org!.verified
                                                ? AppColors.primary
                                                : AppColors.warning,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          _MetricTile('모집중 공고', openCount),
                                          _MetricTile('전체 지원자', totalApplicants),
                                          _MetricTile('미결정', totalPending,
                                              color: AppColors.warning),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: FilledButton.icon(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                      ),
                                      onPressed: () =>
                                          widget.controller.push('/postings/new'),
                                      icon: const Icon(Icons.add),
                                      label: const Text('새 공고'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                      ),
                                      onPressed: _duplicateLastPosting,
                                      icon: const Icon(Icons.copy_outlined,
                                          size: 18),
                                      label: const Text('이전 공고 복제'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                '공고별 모집 현황',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 10),
                              for (final p in _myPostings)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: SectionCard(
                                    onTap: () => widget.controller.push(
                                      '/postings/${p.postingId}/applicants',
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              StatusBadge.postingStatus(
                                                  p.status),
                                              const SizedBox(height: 6),
                                              Text(
                                                p.title,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '마감 ${AppFormatters.formatDateOnly(p.deadline)}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textMuted,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${p.counts.total}명',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                widget.controller
                                                        .pendingApplicantFilter =
                                                    Decision.PENDING;
                                                widget.controller.push(
                                                  '/postings/${p.postingId}/applicants',
                                                );
                                              },
                                              child: Text(
                                                '미정 ${p.counts.pending}건',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: p.counts.pending > 0
                                                      ? AppColors.accentOrange
                                                      : AppColors.textMuted,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile(this.label, this.value,
      {this.color = AppColors.textPrimary});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

/// SCR-16 조직 페이지 화면.
class OrgPageScreen extends StatefulWidget {
  const OrgPageScreen({
    super.key,
    required this.controller,
    required this.orgId,
  });

  final AppController controller;
  final int orgId;

  @override
  State<OrgPageScreen> createState() => _OrgPageScreenState();
}

class _OrgPageScreenState extends State<OrgPageScreen> {
  OrgPage? _org;
  bool _loading = true;
  int _lastVersion = -1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _lastVersion = widget.controller.dataVersion;
    if (mounted) setState(() => _loading = true);
    try {
      final page = await widget.controller.api.getOrgPage(widget.orgId);
      if (mounted) {
        setState(() {
          _org = page;
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

  Future<void> _toggleFollow() async {
    final org = _org;
    if (org == null) return;
    if (!widget.controller.isLoggedIn) {
      widget.controller.go('/login');
      return;
    }
    try {
      final res = org.followed
          ? await widget.controller.api.unfollowOrg(org.orgId)
          : await widget.controller.api.followOrg(org.orgId);
      if (mounted) {
        AppToast.show(
          context,
          res.followed
              ? '관심 조직으로 등록했습니다. 새 공고가 올라오면 알려드릴게요.'
              : '관심 조직 등록을 해제했습니다.',
        );
      }
      await _load();
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
        final isPersonal =
            widget.controller.currentUser?.memberType == MemberType.PERSONAL;

        return AdaptiveShell(
          controller: widget.controller,
          title: '조직 페이지',
          leadingBack: widget.controller.canGoBack,
          body: _loading || _org == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 780),
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
                                        radius: 28,
                                        backgroundColor: AppColors.primary,
                                        child: Text(
                                          _org!.name.isEmpty
                                              ? 'O'
                                              : _org!.name[0],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    _org!.name,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                ),
                                                if (_org!.verified) ...[
                                                  const SizedBox(width: 6),
                                                  const Icon(Icons.verified,
                                                      size: 18,
                                                      color: AppColors.primary),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${_org!.orgType} · ${_org!.verified ? "인증된 조직" : "미인증"} · 관심 ${_org!.followerCount}명',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if ((_org!.intro ?? '').isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      _org!.intro!,
                                      style: const TextStyle(
                                          fontSize: 14, height: 1.5),
                                    ),
                                  ],
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      for (final f in _org!.fields)
                                        TagChip(
                                            label: f.label, highlight: true),
                                      for (final l in _org!.links)
                                        Chip(
                                          avatar: const Icon(Icons.link,
                                              size: 14),
                                          label: Text(l.title,
                                              style: const TextStyle(
                                                  fontSize: 12)),
                                        ),
                                    ],
                                  ),
                                  if (isPersonal) ...[
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: _org!.followed
                                          ? FilledButton.icon(
                                              style: FilledButton.styleFrom(
                                                  backgroundColor:
                                                      AppColors.primary),
                                              onPressed: _toggleFollow,
                                              icon: const Icon(Icons.favorite),
                                              label: const Text('관심 조직 등록됨'),
                                            )
                                          : OutlinedButton.icon(
                                              onPressed: _toggleFollow,
                                              icon: const Icon(
                                                  Icons.favorite_border),
                                              label: const Text('관심 조직 등록'),
                                            ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              '진행 중인 모집 공고',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 10),
                            if (_org!.openPostings.isEmpty)
                              const Text('현재 모집중인 공고가 없습니다.',
                                  style: TextStyle(color: AppColors.textMuted))
                            else
                              for (final c in _org!.openPostings)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: PostingCardWidget(
                                    card: c,
                                    onTap: () => widget.controller
                                        .push('/postings/${c.postingId}'),
                                  ),
                                ),
                            const SizedBox(height: 18),
                            const Text(
                              '마감된 공고',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 10),
                            for (final c in _org!.pastPostings)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: SectionCard(
                                  onTap: () => widget.controller
                                      .push('/postings/${c.postingId}'),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          c.title,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      StatusBadge.postingStatus(c.status),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

/// SCR-17 외부 활동 화면 (GET /api/external-activities 연동).
class ExternalActivitiesScreen extends StatefulWidget {
  const ExternalActivitiesScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<ExternalActivitiesScreen> createState() =>
      _ExternalActivitiesScreenState();
}

class _ExternalActivitiesScreenState extends State<ExternalActivitiesScreen> {
  final _searchCtrl = TextEditingController();
  ExternalType? _type;
  final Set<Field> _fields = {};
  String? _source; // null: 전체, SKKU_NOTICE, PUBLIC_API
  final SortType _sort = SortType.DEADLINE;

  List<ExternalActivityItem> _items = const [];
  bool _loading = true;
  int _lastVersion = -1;

  @override
  void initState() {
    super.initState();
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
      final res = await widget.controller.api.searchExternalActivities(
        keyword: _searchCtrl.text.trim().isEmpty
            ? null
            : _searchCtrl.text.trim(),
        type: _type,
        fields: _fields.toList(),
        source: _source,
        sort: _sort,
      );
      if (mounted) {
        setState(() {
          _items = res.items;
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

  Future<void> _toggleBookmark(ExternalActivityItem item) async {
    if (!widget.controller.isLoggedIn) {
      widget.controller.go('/login');
      return;
    }
    try {
      final next = item.bookmarked
          ? await widget.controller.api
              .removeBookmark(BookmarkTarget.EXTERNAL_ACTIVITY, item.id)
          : await widget.controller.api
              .addBookmark(BookmarkTarget.EXTERNAL_ACTIVITY, item.id);
      setState(() {
        _items = _items
            .map((e) => e.id == item.id ? e.copyWith(bookmarked: next) : e)
            .toList();
      });
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

        return AdaptiveShell(
          controller: widget.controller,
          title: '외부 활동',
          body: Column(
            children: [
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('전체'),
                            selected: _type == null,
                            onSelected: (_) {
                              setState(() => _type = null);
                              _load();
                            },
                          ),
                          const SizedBox(width: 6),
                          for (final t in ExternalType.values)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text(t.label),
                                selected: _type == t,
                                onSelected: (_) {
                                  setState(() => _type = t);
                                  _load();
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            onSubmitted: (_) => _load(),
                            decoration: const InputDecoration(
                              hintText: '외부 활동 검색',
                              prefixIcon: Icon(Icons.search, size: 18),
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<String?>(
                          value: _source,
                          items: const [
                            DropdownMenuItem(value: null, child: Text('전체 출처')),
                            DropdownMenuItem(
                                value: 'SKKU_NOTICE', child: Text('성균관대 공지')),
                            DropdownMenuItem(
                                value: 'PUBLIC_API', child: Text('대외·공공기관')),
                          ],
                          onChanged: (v) {
                            setState(() => _source = v);
                            _load();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final f in Field.values)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: FilterChip(
                                label: Text(f.label,
                                    style: const TextStyle(fontSize: 12)),
                                selected: _fields.contains(f),
                                onSelected: (v) {
                                  setState(() => v
                                      ? _fields.add(f)
                                      : _fields.remove(f));
                                  _load();
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _items.isEmpty
                        ? EmptyStateView(
                            icon: Icons.public_off,
                            title: '조건에 맞는 외부 활동이 없습니다',
                            actionLabel: '필터 초기화',
                            onAction: () {
                              setState(() {
                                _searchCtrl.clear();
                                _type = null;
                                _fields.clear();
                                _source = null;
                              });
                              _load();
                            },
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, idx) {
                              final item = _items[idx];
                              return Center(
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 820),
                                  child: SectionCard(
                                    onTap: () => showNoticeDialog(
                                      context,
                                      title: '공식 안내 페이지',
                                      message:
                                          '${item.title}\n주관: ${item.organizer}\n원문 URL: ${item.url}\n\n외부 활동은 서비스 안에서 지원하지 않고 원문 공지로 연결합니다.',
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            StatusBadge(
                                              label: item.type.label,
                                              backgroundColor:
                                                  AppColors.primaryTint,
                                              textColor: AppColors.primary,
                                            ),
                                            const SizedBox(width: 6),
                                            TagChip(
                                              label: DomainConstants
                                                  .externalSourceLabel(
                                                      item.source),
                                            ),
                                            const Spacer(),
                                            if (widget.controller.currentUser
                                                    ?.memberType ==
                                                MemberType.PERSONAL)
                                              IconButton(
                                                visualDensity:
                                                    VisualDensity.compact,
                                                onPressed: () =>
                                                    _toggleBookmark(item),
                                                icon: Icon(
                                                  item.bookmarked
                                                      ? Icons.bookmark
                                                      : Icons.bookmark_border,
                                                  color: item.bookmarked
                                                      ? AppColors.primary
                                                      : AppColors.textMuted,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          item.title,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${item.organizer} · 게시 ${AppFormatters.formatDateOnly(item.postedAt)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Wrap(
                                              spacing: 6,
                                              children: [
                                                for (final f in item.fields)
                                                  TagChip(
                                                    label: f.label,
                                                    highlight: true,
                                                  ),
                                              ],
                                            ),
                                            const Spacer(),
                                            DDayText(dDay: item.dDay),
                                            const SizedBox(width: 8),
                                            const Row(
                                              children: [
                                                Text(
                                                  '원문 보기',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                                SizedBox(width: 2),
                                                Icon(Icons.open_in_new,
                                                    size: 14,
                                                    color: AppColors.primary),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}
