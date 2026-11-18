import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/codes.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/adaptive_shell.dart';
import '../../core/widgets/common_widgets.dart';
import '../../data/state/app_controller.dart';
import '../../domain/models/api_models.dart';

/// SCR-18 알림 센터 화면 (GET /api/notifications, 읽음 처리, 푸시 설정).
class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  NotificationList? _list;
  bool _loading = true;
  int _lastVersion = -1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _lastVersion = widget.controller.dataVersion;
    if (!widget.controller.isLoggedIn) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final list = await widget.controller.api.getNotifications();
      await widget.controller.refreshUnreadCount();
      if (mounted) {
        setState(() {
          _list = list;
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

  Future<void> _markAllRead() async {
    await widget.controller.api.markAllNotificationsRead();
    await _load();
    if (mounted) AppToast.show(context, '모든 알림을 읽음 처리했습니다.');
  }

  Future<void> _openSettings() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('알림 설정'),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final type in NotificationType.values)
                  SwitchListTile(
                    value: widget.controller.pushSettings[type] ?? true,
                    onChanged: (v) {
                      setLocal(() => widget.controller.pushSettings[type] = v);
                    },
                    activeThumbColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    title: Text(type.label, style: const TextStyle(fontSize: 14)),
                    subtitle: const Text('웹 푸시 알림 받기',
                        style: TextStyle(fontSize: 11)),
                  ),
              ],
            ),
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(NotificationType t) {
    switch (t) {
      case NotificationType.NEW_APPLICATION:
        return Icons.assignment_ind_outlined;
      case NotificationType.POSTING_CLOSED:
        return Icons.event_busy_outlined;
      case NotificationType.RESULT_ANNOUNCED:
        return Icons.campaign_outlined;
      case NotificationType.BOOKMARK_CLOSING_SOON:
        return Icons.schedule;
      case NotificationType.FOLLOWED_ORG_NEW_POSTING:
        return Icons.favorite_border;
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
          title: '알림',
          leadingBack: true,
          showBottomNav: false,
          actions: [
            IconButton(
              tooltip: '알림 설정',
              icon: const Icon(Icons.tune, color: AppColors.textPrimary),
              onPressed: _openSettings,
            ),
          ],
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      children: [
                        Container(
                          color: AppColors.surface,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              Text(
                                '읽지 않은 알림 ${_list?.unreadCount ?? 0}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: (_list?.unreadCount ?? 0) > 0
                                    ? _markAllRead
                                    : null,
                                child: const Text('모두 읽음'),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: (_list?.items.isEmpty ?? true)
                              ? const EmptyStateView(
                                  icon: Icons.notifications_none,
                                  title: '도착한 알림이 없습니다',
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.all(12),
                                  itemCount: _list!.items.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (context, idx) {
                                    final n = _list!.items[idx];
                                    return SectionCard(
                                      backgroundColor: n.read
                                          ? AppColors.surface
                                          : AppColors.primaryTint
                                              .withValues(alpha: 0.55),
                                      borderColor: n.read
                                          ? AppColors.border
                                          : AppColors.primaryBorder,
                                      onTap: () async {
                                        if (!n.read) {
                                          await widget.controller.api
                                              .markNotificationRead(n.id);
                                          await widget.controller
                                              .refreshUnreadCount();
                                        }
                                        widget.controller
                                            .navigateFromNotification(n);
                                      },
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundColor: n.read
                                                ? AppColors.surfaceMuted
                                                : AppColors.primaryTint,
                                            child: Icon(
                                              _iconFor(n.type),
                                              size: 18,
                                              color: n.read
                                                  ? AppColors.textMuted
                                                  : AppColors.primary,
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
                                                      n.title,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Text(
                                                      AppFormatters
                                                          .formatRelativeTime(
                                                              n.createdAt),
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        color:
                                                            AppColors.textMuted,
                                                      ),
                                                    ),
                                                    if (!n.read) ...[
                                                      const SizedBox(width: 6),
                                                      Container(
                                                        width: 7,
                                                        height: 7,
                                                        decoration:
                                                            const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: AppColors
                                                              .accentOrange,
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  n.body,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color:
                                                        AppColors.textSecondary,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}

/// SCR-19 관리자 콘솔 화면 (5대 메뉴: 단체 인증 심사, 신고 처리, 회원 관리, 외부 정보원, 운영 현황).
class AdminConsoleScreen extends StatefulWidget {
  const AdminConsoleScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<AdminConsoleScreen> createState() => _AdminConsoleScreenState();
}

class _AdminConsoleScreenState extends State<AdminConsoleScreen> {
  int _menuIndex = 0;
  int _selectedIdx = 0;
  final _rejectReasonCtrl = TextEditingController();
  final Map<String, bool> _externalSources = {
    '성균관대학교 전체 공지사항': true,
    '소프트웨어융합대학 공지사항': true,
    '공공기관 채용·인턴 정보': true,
    'K-Startup 창업·공모전 공고': true,
    '온통청년 대외활동·청년정책': true,
  };
  final Set<int> _suspendedMemberIds = {};

  @override
  void dispose() {
    _rejectReasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menus = [
      (Icons.verified_user_outlined, '단체 인증 심사'),
      (Icons.flag_outlined, '신고 처리'),
      (Icons.manage_accounts_outlined, '회원 관리'),
      (Icons.rss_feed, '외부 정보원'),
      (Icons.analytics_outlined, '운영 현황'),
    ];
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 900 && !widget.controller.mobileFrameMode;

    return AdaptiveShell(
      controller: widget.controller,
      title: '관리자 콘솔',
      body: isWide
          ? Row(
              children: [
                Container(
                  width: 220,
                  color: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          '관리자 콘솔',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      for (var i = 0; i < menus.length; i++)
                        ListTile(
                          leading: Icon(menus[i].$1,
                              color: Colors.white, size: 20),
                          title: Text(
                            menus[i].$2,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: i == _menuIndex
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                          selected: i == _menuIndex,
                          selectedTileColor: Colors.white12,
                          onTap: () => setState(() {
                            _menuIndex = i;
                            _selectedIdx = 0;
                          }),
                        ),
                    ],
                  ),
                ),
                Expanded(child: _buildAdminContent()),
              ],
            )
          : Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      for (var i = 0; i < menus.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(menus[i].$2),
                            selected: _menuIndex == i,
                            onSelected: (_) => setState(() {
                              _menuIndex = i;
                              _selectedIdx = 0;
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(child: _buildAdminContent()),
              ],
            ),
    );
  }

  Widget _buildAdminContent() {
    switch (_menuIndex) {
      case 0:
        return _buildVerifications();
      case 1:
        return _buildReports();
      case 2:
        return _buildMemberManagement();
      case 3:
        return _buildExternalSources();
      default:
        return _buildStats();
    }
  }

  Widget _buildVerifications() {
    final list = widget.controller.adminVerifications;
    if (list.isEmpty) {
      return const EmptyStateView(
        icon: Icons.check_circle_outline,
        title: '심사 대기 중인 단체가 없습니다',
      );
    }
    final sel = list[_selectedIdx.clamp(0, list.length - 1)];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('단체 인증 신청 내역',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        for (var i = 0; i < list.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SectionCard(
              borderColor:
                  i == _selectedIdx ? AppColors.primary : AppColors.border,
              onTap: () => setState(() => _selectedIdx = i),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(list[i].orgName,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        Text('${list[i].orgType} · ${list[i].loginId}',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  StatusBadge(
                    label: list[i].status,
                    backgroundColor: list[i].status == '승인됨'
                        ? AppColors.primaryTint
                        : list[i].status == '반려됨'
                            ? AppColors.dangerBg
                            : AppColors.warningBg,
                    textColor: list[i].status == '승인됨'
                        ? AppColors.primary
                        : list[i].status == '반려됨'
                            ? AppColors.danger
                            : AppColors.warning,
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('심사 대상: ${sel.orgName}',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('아이디: ${sel.loginId} · 이메일: ${sel.contactEmail}'),
              const SizedBox(height: 6),
              for (final u in sel.urls)
                Text('인증 URL: $u',
                    style: const TextStyle(color: AppColors.primary)),
              const SizedBox(height: 10),
              TextField(
                controller: _rejectReasonCtrl,
                decoration: const InputDecoration(
                  labelText: '반려 사유',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.dangerBorder),
                      ),
                      onPressed: () {
                        if (_rejectReasonCtrl.text.trim().isEmpty) {
                          AppToast.show(context, '반려 사유를 입력해 주세요.',
                              isError: true);
                          return;
                        }
                        setState(() {
                          sel.status = '반려됨';
                          sel.rejectReason = _rejectReasonCtrl.text.trim();
                          widget.controller.adminAuditLogs.insert(
                            0,
                            '[반려] ${sel.orgName} (${sel.rejectReason})',
                          );
                          _rejectReasonCtrl.clear();
                        });
                        AppToast.show(context, '반려 처리되었습니다.');
                      },
                      child: const Text('반려'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary),
                      onPressed: () {
                        setState(() {
                          sel.status = '승인됨';
                          widget.controller.adminAuditLogs.insert(
                            0,
                            '[승인] ${sel.orgName} 단체 인증 완료',
                          );
                        });
                        AppToast.show(context, '${sel.orgName} 인증을 승인했습니다.');
                      },
                      child: const Text('승인'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReports() {
    final sorted = List<AdminReportItem>.from(widget.controller.adminReports)
      ..sort((a, b) => b.reportCount.compareTo(a.reportCount));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('신고 접수 내역',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        for (final r in sorted)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (r.reportCount >= 3)
                        const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: StatusBadge(
                            label: '집중 검토',
                            backgroundColor: AppColors.dangerBg,
                            textColor: AppColors.danger,
                          ),
                        ),
                      StatusBadge(
                        label: '${r.reason} · ${r.reportCount}건',
                        backgroundColor: AppColors.warningBg,
                        textColor: AppColors.warning,
                      ),
                      const Spacer(),
                      if (r.hidden)
                        const TagChip(label: '숨김 처리됨')
                      else if (r.resolved)
                        const TagChip(label: '문제 없음 종결'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(r.postingTitle,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(r.detail,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            r.resolved = true;
                            r.hidden = false;
                            widget.controller.adminAuditLogs
                                .insert(0, '[신고 종결] ${r.postingTitle}');
                          });
                        },
                        child: const Text('문제 없음'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: r.hidden
                              ? AppColors.primary
                              : AppColors.danger,
                        ),
                        onPressed: () {
                          setState(() {
                            r.hidden = !r.hidden;
                            widget.controller.adminAuditLogs.insert(
                              0,
                              '[${r.hidden ? "공고 숨김" : "숨김 해제"}] ${r.postingTitle}',
                            );
                          });
                        },
                        child: Text(r.hidden ? '숨김 해제' : '공고 숨김'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMemberManagement() {
    final accounts = widget.controller.demoAccounts.take(11).toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('전체 회원 관리',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        for (final m in accounts)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SectionCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${m.name} · ${m.memberType.label}',
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        Text(m.description ?? '',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        if (_suspendedMemberIds.contains(m.memberId)) {
                          _suspendedMemberIds.remove(m.memberId);
                        } else {
                          _suspendedMemberIds.add(m.memberId);
                        }
                      });
                    },
                    child: Text(_suspendedMemberIds.contains(m.memberId)
                        ? '정지 해제'
                        : '계정 정지'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildExternalSources() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('외부 공고 연동 관리',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        SectionCard(
          child: Column(
            children: [
              for (final key in _externalSources.keys)
                SwitchListTile(
                  value: _externalSources[key]!,
                  onChanged: (v) =>
                      setState(() => _externalSources[key] = v),
                  activeThumbColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  title: Text(key, style: const TextStyle(fontSize: 14)),
                  subtitle: const Text('정상 연동 중',
                      style: TextStyle(fontSize: 12, color: AppColors.primary)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('서비스 운영 현황',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('주요 활동 지표'),
              const SizedBox(height: 8),
              Text('• 등록 회원: ${widget.controller.demoAccounts.length}명'),
              const Text('• 게시 공고: 21건 · 제출 지원서: 32건'),
              const SizedBox(height: 14),
              const Text('최근 감사 로그',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              for (final log in widget.controller.adminAuditLogs)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('• $log', style: const TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// SCR-20 AI 연결 관리 & 설정 화면.
class AiConnectionScreen extends StatefulWidget {
  const AiConnectionScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<AiConnectionScreen> createState() => _AiConnectionScreenState();
}

class _AiConnectionScreenState extends State<AiConnectionScreen> {
  static const String _mcpUrl = 'https://skkucrew.example/mcp';

  Future<void> _disconnect() async {
    final ok = await showConfirmDialog(
      context,
      title: 'AI 연결 해제',
      message: 'ChatGPT와의 연결을 해제하시겠습니까? 발급된 액세스 토큰이 즉시 무효화됩니다.',
      confirmLabel: '연결 해제',
      isDanger: true,
    );
    if (!ok) return;
    setState(() => widget.controller.mcpConnected = false);
    if (mounted) AppToast.show(context, 'AI 서비스 연결이 해제되었습니다.');
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return AdaptiveShell(
      controller: c,
      title: 'AI 연결 · 설정',
      leadingBack: true,
      showBottomNav: false,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI 어시스턴트 연동',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'ChatGPT 등 내 AI 어시스턴트에 SKKU Crew를 연결하면 대화로 공고를 찾고, 지원 현황을 확인하며, 추가 질문 답변 초안을 저장할 수 있어요.',
                      style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.45),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              _mcpUrl,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 13,
                              ),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(
                                  const ClipboardData(text: _mcpUrl));
                              AppToast.show(context, 'MCP 서버 주소를 복사했습니다.');
                            },
                            icon: const Icon(Icons.copy, size: 15),
                            label: const Text('복사'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('연결 방법',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    const Text(
                      '1. ChatGPT 연동 메뉴에 위 연결 주소 등록\n'
                      '2. SKKU Crew 계정 로그인 및 권한 허용\n'
                      '3. 대화에서 "SKKU Crew로 데이터 분야 공고 찾아줘" 요청',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => c.push('/oauth/authorize'),
                      icon: const Icon(Icons.verified_user_outlined, size: 17),
                      label: const Text('연결 권한 설정'),
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
                      '연결된 AI 서비스',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    if (!c.mcpConnected)
                      const Text('연결된 AI 서비스가 없습니다.',
                          style: TextStyle(color: AppColors.textMuted))
                    else ...[
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: AppColors.textPrimary,
                            child: Text('AI',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('ChatGPT',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700)),
                                Text(
                                  '연결 ${AppFormatters.formatDateOnly(c.mcpConnectedAt)} · 마지막 사용 ${AppFormatters.formatRelativeTime(c.mcpLastUsedAt)}',
                                  style: const TextStyle(
                                      fontSize: 12, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          const TagChip(label: '공고 조회', highlight: true),
                          const TagChip(label: '내 프로필 조회', highlight: true),
                          const TagChip(label: '지원 현황 조회', highlight: true),
                          if (c.mcpAllowBookmark)
                            const TagChip(label: '관심 저장'),
                          if (c.mcpAllowDraft)
                            const TagChip(label: '답변 초안 저장'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.danger,
                            side:
                                const BorderSide(color: AppColors.dangerBorder),
                          ),
                          onPressed: _disconnect,
                          child: const Text('연결 해제'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    const Text(
                      '※ 최종 지원서 제출과 결과 발표는 SKKU Crew에서만 진행됩니다.',
                      style:
                          TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SectionCard(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.help_outline),
                      title: const Text('도움말 / FAQ'),
                      onTap: () => showNoticeDialog(
                        context,
                        title: 'SKKU Crew 도움말',
                        message:
                            '• 개인회원은 성균관대 Google 계정(@g.skku.edu·@skku.edu)으로 로그인합니다.\n'
                            '• 지원 시 선택한 프로필 항목만 전달되며, 연락처는 합격 발표 시에만 공개됩니다.\n'
                            '• 고객센터: support@skkucrew.kr',
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: const Text('이용약관 / 개인정보 처리방침'),
                      onTap: () => showNoticeDialog(
                        context,
                        title: '개인정보 처리방침',
                        message:
                            '• 제출된 지원서 및 연락처 공개 기록은 결과 발표 후 1년간 보관 뒤 파기합니다.\n'
                            '• 취소된 지원서 내용은 취소 즉시 파기합니다.\n'
                            '• 안전한 서비스 제공을 위해 클라우드 인프라 및 푸시 알림 시스템을 운영합니다.',
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.logout, color: AppColors.danger),
                      title: const Text('로그아웃',
                          style: TextStyle(color: AppColors.danger)),
                      onTap: () async {
                        final ok = await showConfirmDialog(
                          context,
                          title: '로그아웃',
                          message: '로그아웃하고 로그인 화면으로 이동하시겠습니까?',
                          confirmLabel: '로그아웃',
                          isDanger: true,
                        );
                        if (ok) c.logout();
                      },
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

/// SCR-21 AI 연결 권한 동의 화면.
class AiConsentScreen extends StatefulWidget {
  const AiConsentScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<AiConsentScreen> createState() => _AiConsentScreenState();
}

class _AiConsentScreenState extends State<AiConsentScreen> {
  late bool _allowBookmark;
  late bool _allowDraft;

  @override
  void initState() {
    super.initState();
    _allowBookmark = widget.controller.mcpAllowBookmark;
    _allowDraft = widget.controller.mcpAllowDraft;
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.controller.currentUser;
    return AdaptiveShell(
      controller: widget.controller,
      title: 'AI 연결 권한 동의',
      leadingBack: true,
      showBottomNav: false,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.textPrimary,
                              child: Text('AI',
                                  style: TextStyle(color: Colors.white)),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.swap_horiz, color: AppColors.textMuted),
                            SizedBox(width: 10),
                            CircleAvatar(
                              backgroundColor: AppColors.primary,
                              child: Icon(Icons.groups, color: Colors.white),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          'ChatGPT가 SKKU Crew 계정에 접근하려고 합니다',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      '${user?.schoolEmail ?? user?.name ?? ""} 로 로그인됨',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('기본 제공 권한',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  const ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.lock_outline, size: 18),
                    title: Text('공고·외부 활동 조회'),
                    subtitle: Text('모집중 공고와 외부 활동 검색'),
                  ),
                  const ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.lock_outline, size: 18),
                    title: Text('내 정보 조회'),
                    subtitle: Text('내 프로필과 지원 현황·결과'),
                  ),
                  const Divider(height: 20),
                  const Text('추가 허용 권한',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  SwitchListTile(
                    value: _allowBookmark,
                    onChanged: (v) => setState(() => _allowBookmark = v),
                    activeThumbColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('관심 저장'),
                    subtitle: const Text('공고를 관심 목록에 저장·해제'),
                  ),
                  SwitchListTile(
                    value: _allowDraft,
                    onChanged: (v) => setState(() => _allowDraft = v),
                    activeThumbColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('답변 초안 저장'),
                    subtitle: const Text('작성한 답변을 임시 초안으로 저장'),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '연동 시 선택한 권한 범위 내에서만 정보가 활용되며, 최종 지원서 제출은 SKKU Crew에서 직접 진행할 수 있습니다.',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            AppToast.show(context, '연결 요청을 거부했습니다.');
                            widget.controller.pop();
                          },
                          child: const Text('거부'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary),
                          onPressed: () {
                            widget.controller.mcpConnected = true;
                            widget.controller.mcpAllowBookmark = _allowBookmark;
                            widget.controller.mcpAllowDraft = _allowDraft;
                            widget.controller.mcpConnectedAt = DateTime.now();
                            AppToast.show(context, 'ChatGPT 연결이 허용되었습니다.');
                            widget.controller.pop();
                          },
                          child: const Text('허용'),
                        ),
                      ),
                    ],
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
