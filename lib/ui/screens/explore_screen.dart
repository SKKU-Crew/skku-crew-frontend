import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/codes.dart';
import '../../core/widgets/adaptive_shell.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/posting_card_widget.dart';
import '../../data/state/app_controller.dart';
import '../../domain/models/api_models.dart';
import 'posting_detail_screen.dart';

/// SCR-05 활동 탐색 화면 (GET /api/postings 연동, 태블릿/데스크톱 2열 지원).
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchCtrl = TextEditingController();
  final Set<Category> _categories = {};
  final Set<Field> _fields = {};
  final Set<ActivityMode> _modes = {};
  MemberType? _recruiterType;
  bool _includeClosed = false;
  SortType _sort = SortType.LATEST;

  List<PostingCard> _items = const [];
  int _totalElements = 0;
  bool _hasNext = false;
  int _page = 0;
  bool _loading = true;
  int? _selectedPostingId;
  int _lastVersion = -1;

  @override
  void initState() {
    super.initState();
    if (widget.controller.pendingExploreCategories.isNotEmpty) {
      _categories.addAll(widget.controller.pendingExploreCategories);
      widget.controller.pendingExploreCategories = const [];
    }
    if (widget.controller.pendingExploreKeyword != null) {
      _searchCtrl.text = widget.controller.pendingExploreKeyword!;
      widget.controller.pendingExploreKeyword = null;
    }
    _search(resetPage: true);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _search({bool resetPage = true}) async {
    _lastVersion = widget.controller.dataVersion;
    final kw = _searchCtrl.text.trim();
    if (kw.isNotEmpty && kw.length < 2) {
      AppToast.show(context, '검색어는 2자 이상 입력해 주세요.', isError: true);
      return;
    }
    if (kw.length >= 2) {
      widget.controller.addRecentSearch(kw);
    }
    if (resetPage) _page = 0;
    if (mounted) setState(() => _loading = true);

    try {
      final res = await widget.controller.api.searchPostings(
        keyword: kw.isEmpty ? null : kw,
        categories: _categories.toList(),
        fields: _fields.toList(),
        modes: _modes.toList(),
        recruiterType: _recruiterType,
        includeClosed: _includeClosed,
        sort: _sort,
        page: _page,
        size: 20,
      );
      if (!mounted) return;
      setState(() {
        if (resetPage) {
          _items = res.items;
        } else {
          _items = [..._items, ...res.items];
        }
        _totalElements = res.totalElements;
        _hasNext = res.hasNext;
        _loading = false;
        if (_items.isNotEmpty &&
            (_selectedPostingId == null ||
                !_items.any((e) => e.postingId == _selectedPostingId))) {
          _selectedPostingId = _items.first.postingId;
        }
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        AppToast.show(context, e.message, isError: true);
      }
    }
  }

  void _resetFilters() {
    setState(() {
      _searchCtrl.clear();
      _categories.clear();
      _fields.clear();
      _modes.clear();
      _recruiterType = null;
      _includeClosed = false;
      _sort = SortType.LATEST;
    });
    _search(resetPage: true);
  }

  int get _activeFilterCount =>
      _categories.length +
      _fields.length +
      _modes.length +
      (_recruiterType != null ? 1 : 0) +
      (_includeClosed ? 1 : 0);

  Future<void> _toggleBookmark(PostingCard card) async {
    if (!widget.controller.isLoggedIn) {
      widget.controller.go('/login');
      return;
    }
    try {
      final next = card.bookmarked
          ? await widget.controller.api
              .removeBookmark(BookmarkTarget.POSTING, card.postingId)
          : await widget.controller.api
              .addBookmark(BookmarkTarget.POSTING, card.postingId);
      setState(() {
        _items = _items
            .map((e) =>
                e.postingId == card.postingId ? e.copyWith(bookmarked: next) : e)
            .toList();
      });
    } on ApiException catch (e) {
      if (mounted) AppToast.show(context, e.message, isError: true);
    }
  }

  Future<void> _openFilterDialog() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '상세 필터',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setLocal(() {
                            _categories.clear();
                            _fields.clear();
                            _modes.clear();
                            _recruiterType = null;
                            _includeClosed = false;
                          });
                        },
                        child: const Text('초기화'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('카테고리',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      for (final c in Category.values)
                        FilterChip(
                          label: Text(c.label),
                          selected: _categories.contains(c),
                          onSelected: (v) => setLocal(() =>
                              v ? _categories.add(c) : _categories.remove(c)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('분야',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      for (final f in Field.values)
                        FilterChip(
                          label: Text(f.label),
                          selected: _fields.contains(f),
                          onSelected: (v) => setLocal(
                              () => v ? _fields.add(f) : _fields.remove(f)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('활동 방식',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      for (final m in ActivityMode.values)
                        FilterChip(
                          label: Text(m.label),
                          selected: _modes.contains(m),
                          onSelected: (v) => setLocal(
                              () => v ? _modes.add(m) : _modes.remove(m)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('모집자 유형',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('전체'),
                        selected: _recruiterType == null,
                        onSelected: (_) =>
                            setLocal(() => _recruiterType = null),
                      ),
                      ChoiceChip(
                        label: const Text('개인 모집자'),
                        selected: _recruiterType == MemberType.PERSONAL,
                        onSelected: (_) =>
                            setLocal(() => _recruiterType = MemberType.PERSONAL),
                      ),
                      ChoiceChip(
                        label: const Text('단체회원'),
                        selected: _recruiterType == MemberType.ORGANIZATION,
                        onSelected: (_) => setLocal(
                            () => _recruiterType = MemberType.ORGANIZATION),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    value: _includeClosed,
                    onChanged: (v) => setLocal(() => _includeClosed = v),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('마감 포함',
                        style: TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _search(resetPage: true);
                      },
                      child: const Text('적용하기'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.controller.currentUser;
    final canPost = user != null && user.memberType != MemberType.ADMIN;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        if (widget.controller.pendingExploreKeyword != null) {
          final kw = widget.controller.pendingExploreKeyword!;
          widget.controller.pendingExploreKeyword = null;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _searchCtrl.text = kw;
            _search(resetPage: true);
          });
        } else if (_lastVersion != widget.controller.dataVersion) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _search(resetPage: true));
        }

        final width = MediaQuery.sizeOf(context).width;
        final isTwoColumn = width >= 768 && !widget.controller.mobileFrameMode;

        return AdaptiveShell(
          controller: widget.controller,
          title: '탐색',
          floatingActionButton: canPost
              ? FloatingActionButton.extended(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  onPressed: () => widget.controller.push('/postings/new'),
                  icon: const Icon(Icons.add),
                  label: const Text('모집하기'),
                )
              : null,
          body: Column(
            children: [
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            onSubmitted: (_) => _search(resetPage: true),
                            decoration: InputDecoration(
                              hintText: '관심 있는 활동, 기술 스택, 학회 검색',
                              prefixIcon: const Icon(Icons.search, size: 20),
                              suffixIcon: _searchCtrl.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        _search(resetPage: true);
                                      },
                                    )
                                  : null,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                          ),
                          onPressed: () => _search(resetPage: true),
                          child: const Text('검색'),
                        ),
                      ],
                    ),
                    if (widget.controller.recentSearches.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 28,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            const Center(
                              child: Text(
                                '최근:',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            for (final kw in widget.controller.recentSearches)
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: InputChip(
                                  label: Text(kw,
                                      style: const TextStyle(fontSize: 11)),
                                  onPressed: () {
                                    _searchCtrl.text = kw;
                                    _search(resetPage: true);
                                  },
                                  onDeleted: () =>
                                      widget.controller.removeRecentSearch(kw),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ActionChip(
                            avatar: const Icon(Icons.tune, size: 16),
                            label: Text(
                              _activeFilterCount > 0
                                  ? '필터 $_activeFilterCount'
                                  : '필터',
                            ),
                            backgroundColor: _activeFilterCount > 0
                                ? AppColors.primaryTint
                                : null,
                            onPressed: _openFilterDialog,
                          ),
                          const SizedBox(width: 6),
                          for (final c in Category.values)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: FilterChip(
                                label: Text(c.label,
                                    style: const TextStyle(fontSize: 12)),
                                selected: _categories.contains(c),
                                onSelected: (v) {
                                  setState(() => v
                                      ? _categories.add(c)
                                      : _categories.remove(c));
                                  _search(resetPage: true);
                                },
                              ),
                            ),
                          for (final f in Field.values)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: FilterChip(
                                label: Text(f.label,
                                    style: const TextStyle(fontSize: 12)),
                                selected: _fields.contains(f),
                                onSelected: (v) {
                                  setState(() =>
                                      v ? _fields.add(f) : _fields.remove(f));
                                  _search(resetPage: true);
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '검색 결과 $_totalElements건',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        DropdownButton<SortType>(
                          value: _sort,
                          isDense: true,
                          underline: const SizedBox.shrink(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          items: [
                            for (final s in SortType.values)
                              DropdownMenuItem(value: s, child: Text(s.label)),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _sort = v);
                            _search(resetPage: true);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _loading && _items.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _items.isEmpty
                        ? EmptyStateView(
                            icon: Icons.search_off,
                            title: '조건에 맞는 공고가 없어요',
                            subtitle: '검색어나 필터 조건을 변경해 보세요.',
                            actionLabel: '필터 초기화',
                            onAction: _resetFilters,
                          )
                        : isTwoColumn
                            ? Row(
                                children: [
                                  SizedBox(
                                    width: width >= 1100 ? 440 : 360,
                                    child: _buildListView(isTwoColumn: true),
                                  ),
                                  const VerticalDivider(width: 1),
                                  Expanded(
                                    child: _selectedPostingId == null
                                        ? const EmptyStateView(
                                            icon: Icons.article_outlined,
                                            title: '왼쪽 목록에서 공고를 선택해 주세요',
                                          )
                                        : Container(
                                            color: AppColors.background,
                                            child: PostingDetailContent(
                                              controller: widget.controller,
                                              postingId: _selectedPostingId!,
                                              embedded: true,
                                              onChanged: () =>
                                                  _search(resetPage: true),
                                            ),
                                          ),
                                  ),
                                ],
                              )
                            : _buildListView(isTwoColumn: false),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListView({required bool isTwoColumn}) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 84),
      itemCount: _items.length + (_hasNext ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return Center(
            child: OutlinedButton(
              onPressed: () {
                _page++;
                _search(resetPage: false);
              },
              child: const Text('더 불러오기'),
            ),
          );
        }
        final card = _items[index];
        return PostingCardWidget(
          card: card,
          selected: isTwoColumn && _selectedPostingId == card.postingId,
          onTap: () {
            if (isTwoColumn) {
              setState(() => _selectedPostingId = card.postingId);
            } else {
              widget.controller.push('/postings/${card.postingId}');
            }
          },
          onToggleBookmark: () => _toggleBookmark(card),
        );
      },
    );
  }
}
