import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/codes.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/adaptive_shell.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/posting_card_widget.dart';
import '../../core/widgets/snapshot_view.dart';
import '../../data/state/app_controller.dart';
import '../../domain/models/api_models.dart';

/// SCR-08 내 활동 화면 (지원 현황 / 내 공고 / 관심 탭).
class MyActivitiesScreen extends StatefulWidget {
  const MyActivitiesScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<MyActivitiesScreen> createState() => _MyActivitiesScreenState();
}

class _MyActivitiesScreenState extends State<MyActivitiesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<MyApplicationItem> _applications = const [];
  List<MyPostingItem> _myPostings = const [];
  BookmarkList? _bookmarks;
  PostingStatus? _myPostingStatusFilter;
  bool _loading = true;
  int _lastVersion = -1;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.controller.initialMyActivitiesTab.clamp(0, 2),
    );
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    _lastVersion = widget.controller.dataVersion;
    if (!widget.controller.isLoggedIn) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    if (mounted) setState(() => _loading = true);
    try {
      final isPersonal =
          widget.controller.currentUser?.memberType == MemberType.PERSONAL;
      final apps = isPersonal
          ? await widget.controller.api.getMyApplications()
          : const <MyApplicationItem>[];
      final myPosts = await widget.controller.api
          .getMyPostings(status: _myPostingStatusFilter);
      final bm = isPersonal
          ? await widget.controller.api.getBookmarks()
          : const BookmarkList(postings: [], externalActivities: []);
      if (mounted) {
        setState(() {
          _applications = apps;
          _myPostings = myPosts;
          _bookmarks = bm;
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

  Future<void> _withdraw(MyApplicationItem item) async {
    final ok = await showConfirmDialog(
      context,
      title: '지원 취소',
      message:
          "'${item.posting.title}' 지원을 취소하시겠습니까? 취소된 지원서의 내용은 즉시 파기되며 마감 전까지 재지원할 수 있습니다.",
      confirmLabel: '지원 취소',
      isDanger: true,
    );
    if (!ok) return;
    try {
      await widget.controller.api.withdrawApplication(item.applicationId);
      widget.controller.bumpDataVersion();
      if (mounted) AppToast.show(context, '지원이 취소되었습니다.');
      await _load();
    } on ApiException catch (e) {
      if (mounted) showNoticeDialog(context, title: '취소 불가', message: e.message);
    }
  }

  Future<void> _openApplicationDetail(int applicationId, {bool focusResult = false}) async {
    try {
      final detail =
          await widget.controller.api.getMyApplicationDetail(applicationId);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            detail.posting.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusBadge.displayStatus(detail.displayStatus),
                      const SizedBox(width: 8),
                      Text(
                        '제출: ${AppFormatters.formatKstDateTime(detail.submittedAt)}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  if (detail.result != null) ...[
                    const SizedBox(height: 14),
                    SectionCard(
                      backgroundColor: detail.result!.result ==
                              DisplayStatus.ACCEPTED
                          ? AppColors.primaryTint
                          : AppColors.surfaceMuted,
                      borderColor: detail.result!.result ==
                              DisplayStatus.ACCEPTED
                          ? AppColors.primaryBorder
                          : AppColors.border,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detail.result!.result == DisplayStatus.ACCEPTED
                                ? '🎉 합격을 축하합니다!'
                                : '선발 결과 안내',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            detail.result!.message,
                            style: const TextStyle(fontSize: 13, height: 1.5),
                          ),
                          if (detail.result!.recruiterContact != null) ...[
                            const Divider(height: 18),
                            Text(
                              '모집자 연락처 · ${detail.result!.recruiterContact!.type.label}: ${detail.result!.recruiterContact!.value}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                          if (detail.result!.disclosedContacts != null &&
                              detail.result!.disclosedContacts!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            for (final dc in detail.result!.disclosedContacts!)
                              Text(
                                '전달된 내 연락처 · ${dc.type.label}: ${dc.value}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  if (!focusResult && detail.snapshot.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      '제출한 프로필 정보',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 8),
                    SectionCard(
                      child: SnapshotViewWidget(snapshot: detail.snapshot),
                    ),
                  ],
                  if (detail.answers.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Text(
                      '추가 질문 답변',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 6),
                    for (final ans in detail.answers)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SectionCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ans.content,
                                  style: const TextStyle(
                                      fontSize: 12, color: AppColors.textMuted)),
                              const SizedBox(height: 4),
                              Text(
                                ans.value is List
                                    ? (ans.value as List).join(', ')
                                    : (ans.value?.toString() ?? '-'),
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                widget.controller.push('/postings/${detail.posting.postingId}');
              },
              child: const Text('공고 보기'),
            ),
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

        return AdaptiveShell(
          controller: widget.controller,
          title: '내 활동',
          body: !widget.controller.isLoggedIn
              ? EmptyStateView(
                  icon: Icons.lock_outline,
                  title: '로그인이 필요합니다',
                  actionLabel: '로그인하기',
                  onAction: () => widget.controller.go('/login'),
                )
              : Column(
                  children: [
                    Container(
                      color: AppColors.surface,
                      child: TabBar(
                        controller: _tabCtrl,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textMuted,
                        indicatorColor: AppColors.primary,
                        tabs: const [
                          Tab(text: '지원 현황'),
                          Tab(text: '내 공고'),
                          Tab(text: '관심'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _loading
                          ? const Center(child: CircularProgressIndicator())
                          : TabBarView(
                              controller: _tabCtrl,
                              children: [
                                _buildApplicationsTab(),
                                _buildMyPostingsTab(),
                                _buildBookmarksTab(),
                              ],
                            ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildApplicationsTab() {
    if (_applications.isEmpty) {
      return EmptyStateView(
        icon: Icons.assignment_outlined,
        title: '아직 지원한 공고가 없습니다',
        subtitle: '관심 있는 활동을 탐색하고 프로필로 간편하게 지원해 보세요.',
        actionLabel: '활동 탐색하기',
        onAction: () => widget.controller.go('/explore'),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _applications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, idx) {
          final item = _applications[idx];
          final isHighlighted =
              widget.controller.highlightApplicationId == item.applicationId;
          final isResultReady = item.displayStatus == DisplayStatus.ACCEPTED ||
              item.displayStatus == DisplayStatus.REJECTED;
          final canWithdraw =
              item.displayStatus == DisplayStatus.SUBMITTED &&
                  item.posting.status == PostingStatus.OPEN;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 780),
              child: SectionCard(
                borderColor:
                    isHighlighted ? AppColors.primary : AppColors.border,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        StatusBadge.category(item.posting.category),
                        const Spacer(),
                        StatusBadge.displayStatus(item.displayStatus),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.posting.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.posting.recruiterName} · 제출 ${AppFormatters.formatDateOnly(item.submittedAt)}'
                      '${item.announcedAt != null ? " · 결과 발표 ${AppFormatters.formatDateOnly(item.announcedAt)}" : ""}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (isResultReady)
                          Expanded(
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary),
                              onPressed: () => _openApplicationDetail(
                                  item.applicationId,
                                  focusResult: true),
                              child: const Text('결과 보기'),
                            ),
                          )
                        else if (item.displayStatus != DisplayStatus.WITHDRAWN)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  _openApplicationDetail(item.applicationId),
                              child: const Text('제출 내용'),
                            ),
                          ),
                        if (canWithdraw) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.danger,
                                side: const BorderSide(
                                    color: AppColors.dangerBorder),
                              ),
                              onPressed: () => _withdraw(item),
                              child: const Text('지원 취소'),
                            ),
                          ),
                        ],
                        if (item.displayStatus == DisplayStatus.WITHDRAWN)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => widget.controller
                                  .push('/postings/${item.posting.postingId}'),
                              child: const Text('공고 다시 보기'),
                            ),
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
    );
  }

  Widget _buildMyPostingsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('전체'),
                  selected: _myPostingStatusFilter == null,
                  onSelected: (_) {
                    setState(() => _myPostingStatusFilter = null);
                    _load();
                  },
                ),
                const SizedBox(width: 6),
                for (final st in [
                  PostingStatus.OPEN,
                  PostingStatus.CLOSED,
                  PostingStatus.ANNOUNCED,
                  PostingStatus.DRAFT,
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(st.label),
                      selected: _myPostingStatusFilter == st,
                      onSelected: (_) {
                        setState(() => _myPostingStatusFilter = st);
                        _load();
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _myPostings.isEmpty
              ? EmptyStateView(
                  icon: Icons.post_add,
                  title: '작성한 공고가 없습니다',
                  actionLabel: '새 공고 작성하기',
                  onAction: () => widget.controller.push('/postings/new'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _myPostings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, idx) {
                    final p = _myPostings[idx];
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 780),
                        child: SectionCard(
                          onTap: () => widget.controller
                              .push('/postings/${p.postingId}/applicants'),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  StatusBadge.postingStatus(p.status),
                                  const SizedBox(width: 6),
                                  StatusBadge.category(p.category),
                                  const Spacer(),
                                  Text(
                                    '마감 ${AppFormatters.formatDateOnly(p.deadline)}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                p.title,
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                children: [
                                  TagChip(
                                      label: '지원자 ${p.counts.total}명',
                                      highlight: true),
                                  TagChip(label: '미정 ${p.counts.pending}명'),
                                  TagChip(label: '합격 ${p.counts.accepted}명'),
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
    );
  }

  Widget _buildBookmarksTab() {
    final bm = _bookmarks;
    if (bm == null ||
        (bm.postings.isEmpty && bm.externalActivities.isEmpty)) {
      return EmptyStateView(
        icon: Icons.bookmark_border,
        title: '저장한 관심 공고·외부 활동이 없습니다',
        actionLabel: '활동 탐색하기',
        onAction: () => widget.controller.go('/explore'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '관심 모집 공고',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                for (final c in bm.postings)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: PostingCardWidget(
                      card: c,
                      onTap: () =>
                          widget.controller.push('/postings/${c.postingId}'),
                      onToggleBookmark: () async {
                        await widget.controller.api.removeBookmark(
                            BookmarkTarget.POSTING, c.postingId);
                        _load();
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                const Text(
                  '관심 대외활동',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                for (final e in bm.externalActivities)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SectionCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.type.label,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  e.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${e.organizer} · ${DomainConstants.externalSourceLabel(e.source)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await widget.controller.api.removeBookmark(
                                  BookmarkTarget.EXTERNAL_ACTIVITY, e.id);
                              _load();
                            },
                            icon: const Icon(Icons.bookmark,
                                color: AppColors.primary),
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
    );
  }
}
