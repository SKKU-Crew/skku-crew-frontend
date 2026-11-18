import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/codes.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/adaptive_shell.dart';
import '../../core/widgets/common_widgets.dart';
import '../../data/state/app_controller.dart';
import '../../domain/models/api_models.dart';

/// SCR-06 공고 상세 화면.
class PostingDetailScreen extends StatelessWidget {
  const PostingDetailScreen({
    super.key,
    required this.controller,
    required this.postingId,
  });

  final AppController controller;
  final int postingId;

  @override
  Widget build(BuildContext context) {
    return AdaptiveShell(
      controller: controller,
      title: '공고 상세',
      leadingBack: true,
      showBottomNav: false,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: PostingDetailContent(
            controller: controller,
            postingId: postingId,
            embedded: false,
          ),
        ),
      ),
    );
  }
}

/// SCR-06 단독 화면과 SCR-05 태블릿/데스크톱 우측 상세 미리보기에서 공용으로 사용.
class PostingDetailContent extends StatefulWidget {
  const PostingDetailContent({
    super.key,
    required this.controller,
    required this.postingId,
    this.embedded = false,
    this.onChanged,
  });

  final AppController controller;
  final int postingId;
  final bool embedded;
  final VoidCallback? onChanged;

  @override
  State<PostingDetailContent> createState() => _PostingDetailContentState();
}

class _PostingDetailContentState extends State<PostingDetailContent> {
  PostingDetail? _detail;
  bool _loading = true;
  String? _error;
  int _lastVersion = -1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant PostingDetailContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.postingId != widget.postingId) {
      _load();
    }
  }

  Future<void> _load() async {
    _lastVersion = widget.controller.dataVersion;
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final d = await widget.controller.api.getPostingDetail(widget.postingId);
      if (mounted) {
        setState(() {
          _detail = d;
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

  Future<void> _toggleBookmark() async {
    final d = _detail;
    if (d == null) return;
    if (!widget.controller.isLoggedIn) {
      widget.controller.go('/login');
      return;
    }
    try {
      final next = d.bookmarked
          ? await widget.controller.api
              .removeBookmark(BookmarkTarget.POSTING, d.postingId)
          : await widget.controller.api
              .addBookmark(BookmarkTarget.POSTING, d.postingId);
      if (mounted) {
        setState(() => _detail = d.copyWith(bookmarked: next));
      }
      widget.onChanged?.call();
    } on ApiException catch (e) {
      if (mounted) AppToast.show(context, e.message, isError: true);
    }
  }

  Future<void> _showReportDialog() async {
    String selectedReason = '허위·사기 의심';
    final detailCtrl = TextEditingController();
    final submitted = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('공고 신고하기'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '신고 사유를 선택해 주세요.',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 8),
              RadioGroup<String>(
                groupValue: selectedReason,
                onChanged: (v) =>
                    setLocal(() => selectedReason = v ?? selectedReason),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final r in ['허위·사기 의심', '부적절한 내용', '광고·스팸', '기타'])
                      RadioListTile<String>(
                        value: r,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(r, style: const TextStyle(fontSize: 13)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: detailCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: '상세 내용',
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
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('신고 제출'),
            ),
          ],
        ),
      ),
    );
    detailCtrl.dispose();
    if (submitted == true && mounted) {
      AppToast.show(context, '신고가 접수되었습니다. 관리자가 검토합니다.');
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
        if (_loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_error != null || _detail == null) {
          return EmptyStateView(
            icon: Icons.error_outline,
            title: _error ?? '존재하지 않거나 비공개된 공고입니다.',
            actionLabel: '목록으로',
            onAction: () => widget.controller.go('/explore'),
          );
        }

        final d = _detail!;
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        StatusBadge.category(d.category),
                        const SizedBox(width: 6),
                        StatusBadge.postingStatus(d.status),
                        const SizedBox(width: 8),
                        DDayText(dDay: d.dDay, status: d.status),
                        const Spacer(),
                        IconButton(
                          tooltip: '관심 저장',
                          onPressed: _toggleBookmark,
                          icon: Icon(
                            d.bookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: d.bookmarked
                                ? AppColors.primary
                                : AppColors.textMuted,
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'report') _showReportDialog();
                            if (v == 'manage') {
                              widget.controller
                                  .push('/postings/${d.postingId}/applicants');
                            }
                          },
                          itemBuilder: (ctx) => [
                            if (d.viewerAction == ViewerAction.OWNER)
                              const PopupMenuItem(
                                value: 'manage',
                                child: Text('내 공고 관리'),
                              )
                            else
                              const PopupMenuItem(
                                value: 'report',
                                child: Text('공고 신고'),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      d.title,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SectionCard(
                      padding: const EdgeInsets.all(14),
                      onTap: d.recruiter.type == MemberType.ORGANIZATION
                          ? () => widget.controller
                              .push('/orgs/${d.recruiter.memberId}')
                          : null,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primaryTint,
                            child: Text(
                              d.recruiter.name.isEmpty
                                  ? '?'
                                  : d.recruiter.name[0],
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      d.recruiter.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (d.recruiter.verified) ...[
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.verified,
                                        size: 15,
                                        color: AppColors.primary,
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  d.recruiter.type == MemberType.ORGANIZATION
                                      ? '${d.recruiter.orgType ?? "단체"} · 조직 페이지 보기'
                                      : '${d.recruiter.department ?? "소속 미기재"} · 개인 모집자',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (d.recruiter.type == MemberType.ORGANIZATION)
                            const Icon(Icons.chevron_right,
                                color: AppColors.textMuted),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SectionCard(
                      child: Column(
                        children: [
                          _InfoRow('모집 인원', '${d.capacity}명'),
                          _InfoRow(
                            '마감 일시',
                            AppFormatters.formatKstDateTime(d.deadline),
                          ),
                          if (d.activityStart != null || d.activityEnd != null)
                            _InfoRow(
                              '활동 기간',
                              '${d.activityStart ?? ""} ~ ${d.activityEnd ?? ""}',
                            ),
                          _InfoRow(
                            '활동 방식',
                            d.place != null && d.place!.isNotEmpty
                                ? '${d.activityMode.label} (${d.place})'
                                : d.activityMode.label,
                          ),
                          const Divider(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 84,
                                child: Text(
                                  '분야',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    for (final f in d.fields)
                                      TagChip(label: f.label, highlight: true),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (d.skills.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: 84,
                                  child: Text(
                                    '우대 기술',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      for (final s in d.skills) TagChip(label: s),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '상세 설명',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            d.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SectionCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.quiz_outlined,
                                  size: 18, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                '추가 질문 ${d.questions.length}개',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              const Spacer(),
                              const Text(
                                '지원 시 작성',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          if (d.requestedContacts.isNotEmpty) ...[
                            const Divider(height: 18),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.contact_phone_outlined,
                                    size: 18, color: AppColors.accentOrange),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${d.requestedContacts.map((e) => e.label).join(", ")} 제공 필요 (합격 시 공개)',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.accentOrange,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 16, color: AppColors.textMuted),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '부적절한 공고이거나 과도한 개인정보를 요구하나요? 우측 상단 메뉴에서 신고할 수 있습니다.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: _buildBottomAction(d),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomAction(PostingDetail d) {
    switch (d.viewerAction) {
      case ViewerAction.APPLY:
        return SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () =>
                widget.controller.push('/postings/${d.postingId}/apply'),
            child: const Text(
              '지원하기',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        );
      case ViewerAction.APPLIED:
        return Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('지원 완료'),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              ),
              onPressed: () {
                widget.controller.initialMyActivitiesTab = 0;
                widget.controller.go('/me/applications');
              },
              child: const Text('지원 현황 보기'),
            ),
          ],
        );
      case ViewerAction.CLOSED:
        return SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: null,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('모집 마감'),
          ),
        );
      case ViewerAction.OWNER:
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => widget.controller
                .push('/postings/${d.postingId}/applicants'),
            icon: const Icon(Icons.people_outline, size: 18),
            label: Text('내 공고 관리 · 지원자 ${d.applicantCount ?? 0}명'),
          ),
        );
      case ViewerAction.NOT_ALLOWED:
        return SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: null,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: const Text('개인회원만 지원할 수 있습니다'),
          ),
        );
      case ViewerAction.LOGIN_REQUIRED:
        return SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            onPressed: () => widget.controller.go('/login'),
            child: const Text('로그인 후 지원하기'),
          ),
        );
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
