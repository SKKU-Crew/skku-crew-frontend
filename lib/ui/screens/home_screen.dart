import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/codes.dart';
import '../../core/widgets/adaptive_shell.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/posting_card_widget.dart';
import '../../data/state/app_controller.dart';
import '../../domain/models/api_models.dart';

/// SCR-04 홈 화면 (GET /api/me, GET /api/postings/home 연동).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeResponse? _home;
  MeResponse? _me;
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
      final home = await widget.controller.api.getHome();
      MeResponse? me;
      if (widget.controller.isLoggedIn) {
        me = await widget.controller.api.getMe();
      }
      if (mounted) {
        setState(() {
          _home = home;
          _me = me ?? widget.controller.currentUser;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleBookmark(PostingCard card) async {
    if (!widget.controller.isLoggedIn) {
      widget.controller.go('/login');
      return;
    }
    try {
      if (card.bookmarked) {
        await widget.controller.api
            .removeBookmark(BookmarkTarget.POSTING, card.postingId);
      } else {
        await widget.controller.api
            .addBookmark(BookmarkTarget.POSTING, card.postingId);
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
        final userName = _me?.name ?? widget.controller.currentUser?.name ?? '게스트';
        final completeness = _me?.profileCompleteness ??
            widget.controller.currentUser?.profileCompleteness ??
            0;

        return AdaptiveShell(
          controller: widget.controller,
          title: 'SKKU Crew',
          body: RefreshIndicator(
            onRefresh: _load,
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1080),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SearchTriggerBar(
                                onTap: () => widget.controller.go('/explore'),
                              ),
                              const SizedBox(height: 14),
                              if (widget.controller.isLoggedIn &&
                                  completeness < 100)
                                _ProfileBanner(
                                  completeness: completeness,
                                  onTap: () =>
                                      widget.controller.push('/me/profile/edit'),
                                ),
                              const SizedBox(height: 18),
                              _CategoryShortcuts(
                                onSelect: (cat) {
                                  widget.controller.pendingExploreCategories = [
                                    cat
                                  ];
                                  widget.controller.go('/explore');
                                },
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Text(
                                    '$userName님 맞춤 공고',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () =>
                                        widget.controller.go('/explore'),
                                    child: const Text('더보기'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 174,
                                child: (_home?.recommended.isEmpty ?? true)
                                    ? const EmptyStateView(
                                        icon: Icons.explore_outlined,
                                        title: '맞춤 공고가 없습니다',
                                      )
                                    : ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: _home!.recommended.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(width: 12),
                                        itemBuilder: (context, idx) {
                                          final card = _home!.recommended[idx];
                                          return SizedBox(
                                            width: 280,
                                            child: PostingCardWidget(
                                              card: card,
                                              compact: true,
                                              onTap: () => widget.controller.push(
                                                '/postings/${card.postingId}',
                                              ),
                                              onToggleBookmark: () =>
                                                  _toggleBookmark(card),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                              const SizedBox(height: 24),
                              const Row(
                                children: [
                                  Text(
                                    '마감 임박',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    '3일 이내',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              if (_home?.closingSoon.isEmpty ?? true)
                                const SectionCard(
                                  child: Text(
                                    '3일 이내 마감 예정인 공고가 없습니다.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                )
                              else
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final cols = constraints.maxWidth >= 760
                                        ? 2
                                        : 1;
                                    if (cols == 1) {
                                      return Column(
                                        children: [
                                          for (final c in _home!.closingSoon)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10),
                                              child: PostingCardWidget(
                                                card: c,
                                                onTap: () =>
                                                    widget.controller.push(
                                                  '/postings/${c.postingId}',
                                                ),
                                                onToggleBookmark: () =>
                                                    _toggleBookmark(c),
                                              ),
                                            ),
                                        ],
                                      );
                                    }
                                    return Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children: [
                                        for (final c in _home!.closingSoon)
                                          SizedBox(
                                            width:
                                                (constraints.maxWidth - 12) / 2,
                                            child: PostingCardWidget(
                                              card: c,
                                              onTap: () =>
                                                  widget.controller.push(
                                                '/postings/${c.postingId}',
                                              ),
                                              onToggleBookmark: () =>
                                                  _toggleBookmark(c),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              const SizedBox(height: 24),
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

class _SearchTriggerBar extends StatelessWidget {
  const _SearchTriggerBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: AppColors.textMuted, size: 20),
            SizedBox(width: 10),
            Text(
              '관심 있는 활동을 검색해 보세요',
              style: TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileBanner extends StatelessWidget {
  const _ProfileBanner({required this.completeness, required this.onTap});

  final int completeness;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Expanded(
                  child: Text(
                    '프로필을 완성하고 한 번에 지원하세요',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (completeness / 100).clamp(0.0, 1.0),
                      minHeight: 7,
                      backgroundColor: Colors.white24,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$completeness%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryShortcuts extends StatelessWidget {
  const _CategoryShortcuts({required this.onSelect});

  final void Function(Category category) onSelect;

  static const Map<Category, IconData> _icons = {
    Category.PROJECT: Icons.code,
    Category.RESEARCH: Icons.science_outlined,
    Category.CONTEST: Icons.emoji_events_outlined,
    Category.STUDY: Icons.menu_book_outlined,
    Category.CLUB: Icons.groups_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final cat in Category.values)
          Expanded(
            child: InkWell(
              onTap: () => onSelect(cat),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Icon(
                        _icons[cat],
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cat.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
