import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/codes.dart';
import '../utils/formatters.dart';

/// SRS 3.1.1 (3) 메시지 표시 표준: 처리 결과/시스템 오류 상단 토스트, 확인 대화상자, 업무 규칙 위반 대화상자.
class AppToast {
  const AppToast._();

  static OverlayEntry? _activeEntry;
  static Timer? _activeTimer;

  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    _activeTimer?.cancel();
    _activeTimer = null;
    try {
      _activeEntry?.remove();
    } catch (_) {}
    _activeEntry = null;

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: isError ? AppColors.danger : AppColors.primary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(milliseconds: 1800),
        ),
      );
      return;
    }

    final topOffset = MediaQuery.paddingOf(context).top + 16;
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        top: topOffset,
        left: 16,
        right: 16,
        child: IgnorePointer(
          ignoring: true,
          child: Align(
            alignment: Alignment.topCenter,
            child: Material(
              color: Colors.transparent,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isError ? AppColors.danger : AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x26000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isError
                            ? Icons.error_outline
                            : Icons.check_circle_outline,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    _activeEntry = entry;
    overlay.insert(entry);
    _activeTimer = Timer(const Duration(milliseconds: 1800), () {
      if (_activeEntry == entry) {
        try {
          entry.remove();
        } catch (_) {}
        _activeEntry = null;
      }
      _activeTimer = null;
    });
  }
}

/// NFR-SAFE-01: 되돌리기 어려운 작업 실행 전 확인 대화상자.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = '확인',
  bool isDanger = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
      content: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('취소', style: TextStyle(color: AppColors.textMuted)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: isDanger ? AppColors.danger : AppColors.primary,
          ),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result == true;
}

/// 표 3-3 업무 규칙 위반 / 안내 대화상자.
Future<void> showNoticeDialog(
  BuildContext context, {
  required String title,
  required String message,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
      content: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
      actions: [
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('확인'),
        ),
      ],
    ),
  );
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    this.icon,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final IconData? icon;

  factory StatusBadge.category(Category category) {
    return StatusBadge(
      label: category.label,
      backgroundColor: AppColors.primaryTint,
      textColor: AppColors.primary,
      borderColor: AppColors.primaryBorder,
    );
  }

  factory StatusBadge.postingStatus(PostingStatus status) {
    switch (status) {
      case PostingStatus.OPEN:
        return const StatusBadge(
          label: '모집중',
          backgroundColor: AppColors.primaryTint,
          textColor: AppColors.primary,
        );
      case PostingStatus.CLOSED:
        return const StatusBadge(
          label: '마감',
          backgroundColor: AppColors.surfaceMuted,
          textColor: AppColors.textSecondary,
        );
      case PostingStatus.ANNOUNCED:
        return const StatusBadge(
          label: '발표 완료',
          backgroundColor: AppColors.infoBg,
          textColor: AppColors.info,
        );
      case PostingStatus.DRAFT:
        return const StatusBadge(
          label: '임시저장',
          backgroundColor: AppColors.warningBg,
          textColor: AppColors.warning,
        );
      case PostingStatus.HIDDEN:
        return const StatusBadge(
          label: '숨김',
          backgroundColor: AppColors.dangerBg,
          textColor: AppColors.danger,
        );
    }
  }

  factory StatusBadge.displayStatus(DisplayStatus status) {
    switch (status) {
      case DisplayStatus.SUBMITTED:
        return const StatusBadge(
          label: '제출 완료',
          backgroundColor: AppColors.primaryTint,
          textColor: AppColors.primary,
        );
      case DisplayStatus.UNDER_REVIEW:
        return const StatusBadge(
          label: '심사 중',
          backgroundColor: AppColors.warningBg,
          textColor: AppColors.warning,
        );
      case DisplayStatus.ACCEPTED:
        return const StatusBadge(
          label: '합격',
          backgroundColor: AppColors.primary,
          textColor: Colors.white,
        );
      case DisplayStatus.REJECTED:
        return const StatusBadge(
          label: '불합격',
          backgroundColor: AppColors.surfaceMuted,
          textColor: AppColors.textMuted,
        );
      case DisplayStatus.WITHDRAWN:
        return const StatusBadge(
          label: '지원 취소',
          backgroundColor: AppColors.surfaceMuted,
          textColor: AppColors.textLight,
        );
    }
  }

  factory StatusBadge.decision(Decision decision) {
    switch (decision) {
      case Decision.PENDING:
        return const StatusBadge(
          label: '미정',
          backgroundColor: AppColors.warningBg,
          textColor: AppColors.warning,
        );
      case Decision.ACCEPTED:
        return const StatusBadge(
          label: '합격',
          backgroundColor: AppColors.primaryTint,
          textColor: AppColors.primary,
        );
      case Decision.REJECTED:
        return const StatusBadge(
          label: '불합격',
          backgroundColor: AppColors.dangerBg,
          textColor: AppColors.danger,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.label, this.highlight = false});

  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: highlight ? AppColors.primaryTint : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: highlight ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class DDayText extends StatelessWidget {
  const DDayText({super.key, this.dDay, this.status});

  final int? dDay;
  final PostingStatus? status;

  @override
  Widget build(BuildContext context) {
    final text = AppFormatters.formatDDay(dDay, status: status);
    final isUrgent =
        (status == null || status == PostingStatus.OPEN) &&
            dDay != null &&
            dDay! <= 5;
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: isUrgent ? AppColors.accentOrange : AppColors.textMuted,
      ),
    );
  }
}

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: AppColors.textLight),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.borderColor,
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor ?? AppColors.border),
      ),
      child: child,
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: content,
      ),
    );
  }
}
