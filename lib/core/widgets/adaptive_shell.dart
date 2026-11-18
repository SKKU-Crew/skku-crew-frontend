import 'package:flutter/material.dart';

import '../../data/state/app_controller.dart';
import '../constants/app_colors.dart';
import '../constants/codes.dart';
import 'common_widgets.dart';

/// SRS 3.1.1(1)~(2) 반응형 내비게이션 쉘.
/// - 모바일(360~767px) · 태블릿(768~1023px): 상단 앱바 + 하단 탭 바
/// - 데스크톱(1024px+): 상단 내비게이션 바 + 검색 + 로그인 상태 표시
class AdaptiveShell extends StatelessWidget {
  const AdaptiveShell({
    super.key,
    required this.controller,
    required this.title,
    required this.body,
    this.showBottomNav = true,
    this.floatingActionButton,
    this.leadingBack = false,
    this.actions = const [],
  });

  final AppController controller;
  final String title;
  final Widget body;
  final bool showBottomNav;
  final Widget? floatingActionButton;
  final bool leadingBack;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1024 && !controller.mobileFrameMode;
    final user = controller.currentUser;
    final isOrg = user?.memberType == MemberType.ORGANIZATION;
    final isAdmin = user?.memberType == MemberType.ADMIN;

    final navItems = _navItems(isOrg: isOrg, isAdmin: isAdmin, userId: user?.memberId);
    final selectedIndex = _selectedIndex(controller.currentPath, navItems);

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.background,
        floatingActionButton: floatingActionButton,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(62),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                if (leadingBack) ...[
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: controller.pop,
                  ),
                  const SizedBox(width: 4),
                ],
                InkWell(
                  onTap: () => controller.go(controller.defaultHomePath),
                  child: const Text(
                    'SKKU Crew',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                for (var i = 0; i < navItems.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: TextButton.icon(
                      onPressed: () => controller.go(navItems[i].path),
                      icon: Icon(
                        navItems[i].icon,
                        size: 18,
                        color: i == selectedIndex
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                      label: Text(
                        navItems[i].label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: i == selectedIndex
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: i == selectedIndex
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: i == selectedIndex
                            ? AppColors.primaryTint
                            : Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                const Spacer(),
                SizedBox(
                  width: 196,
                  height: 36,
                  child: TextField(
                    textInputAction: TextInputAction.search,
                    onSubmitted: (v) {
                      final trimmed = v.trim();
                      if (trimmed.isNotEmpty && trimmed.length < 2) {
                        AppToast.show(
                          context,
                          '검색어는 2자 이상 입력해 주세요.',
                          isError: true,
                        );
                        return;
                      }
                      controller.openExploreWithKeyword(v);
                    },
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: '공고·태그 검색',
                      hintStyle: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textMuted,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 34,
                        minHeight: 34,
                      ),
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.surfaceMuted,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ...actions,
                _NotificationBellButton(controller: controller),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'AI 연결',
                  icon: const Icon(Icons.settings_outlined,
                      color: AppColors.textSecondary),
                  onPressed: () => controller.push('/settings/ai'),
                ),
                const SizedBox(width: 8),
                if (user != null)
                  InkWell(
                    onTap: () => controller.push('/login'),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              user.name.isEmpty ? 'U' : user.name[0],
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.swap_horiz,
                              size: 16, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  )
                else
                  FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary),
                    onPressed: () => controller.go('/login'),
                    child: const Text('로그인'),
                  ),
              ],
            ),
          ),
        ),
        body: body,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: floatingActionButton,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: AppColors.border)),
        leading: leadingBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: controller.pop,
              )
            : null,
        automaticallyImplyLeading: false,
        title: Text(
          title,
          style: TextStyle(
            fontSize: title == 'SKKU Crew' ? 19 : 17,
            fontWeight: title == 'SKKU Crew' ? FontWeight.w800 : FontWeight.w700,
            color: title == 'SKKU Crew'
                ? AppColors.primary
                : AppColors.textPrimary,
          ),
        ),
        actions: [
          ...actions,
          if (user != null) ...[
            _NotificationBellButton(controller: controller),
            IconButton(
              tooltip: 'AI 연결',
              icon: const Icon(
                Icons.settings_outlined,
                color: AppColors.textSecondary,
                size: 21,
              ),
              onPressed: () => controller.push('/settings/ai'),
            ),
          ] else
            TextButton(
              onPressed: () => controller.go('/login'),
              child: const Text('로그인'),
            ),
        ],
      ),
      body: body,
      bottomNavigationBar: showBottomNav && user != null
          ? NavigationBar(
              selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
              onDestinationSelected: (idx) => controller.go(navItems[idx].path),
              backgroundColor: AppColors.surface,
              indicatorColor: AppColors.primaryTint,
              height: 64,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
                for (final item in navItems)
                  NavigationDestination(
                    icon: Icon(item.icon, size: 22),
                    selectedIcon:
                        Icon(item.icon, size: 22, color: AppColors.primary),
                    label: item.label,
                  ),
              ],
            )
          : null,
    );
  }

  List<_NavItem> _navItems({
    required bool isOrg,
    required bool isAdmin,
    required int? userId,
  }) {
    if (isAdmin) {
      return const [
        _NavItem('관리자 콘솔', Icons.admin_panel_settings_outlined, '/admin/verifications'),
        _NavItem('탐색', Icons.search, '/explore'),
        _NavItem('외부활동', Icons.public, '/external'),
      ];
    }
    if (isOrg) {
      return [
        const _NavItem('대시보드', Icons.dashboard_outlined, '/org/dashboard'),
        const _NavItem('공고 관리', Icons.assignment_outlined, '/me/applications'),
        const _NavItem('탐색', Icons.search, '/explore'),
        const _NavItem('외부활동', Icons.public, '/external'),
        _NavItem('조직 페이지', Icons.apartment_outlined, '/orgs/${userId ?? 6}'),
      ];
    }
    return const [
      _NavItem('홈', Icons.home_outlined, '/'),
      _NavItem('탐색', Icons.search, '/explore'),
      _NavItem('외부활동', Icons.public, '/external'),
      _NavItem('내 활동', Icons.assignment_outlined, '/me/applications'),
      _NavItem('프로필', Icons.person_outline, '/me/profile'),
    ];
  }

  int _selectedIndex(String path, List<_NavItem> items) {
    for (var i = 0; i < items.length; i++) {
      final p = items[i].path;
      if (path == p) return i;
      if (p != '/' && path.startsWith(p)) return i;
    }
    return 0;
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon, this.path);
  final String label;
  final IconData icon;
  final String path;
}

class _NotificationBellButton extends StatelessWidget {
  const _NotificationBellButton({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final count = controller.unreadCount;
        return IconButton(
          tooltip: '알림 센터',
          onPressed: () => controller.push('/notifications'),
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_none,
                color: AppColors.textPrimary,
                size: 24,
              ),
              if (count > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
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
