import 'package:flutter/material.dart';

import '../../domain/models/api_models.dart';
import '../constants/app_colors.dart';
import 'common_widgets.dart';

/// 공고 카드 공통 위젯 (SCR-04 홈, SCR-05 탐색, SCR-08 관심, SCR-16 조직 페이지 공용).
class PostingCardWidget extends StatelessWidget {
  const PostingCardWidget({
    super.key,
    required this.card,
    required this.onTap,
    this.onToggleBookmark,
    this.compact = false,
    this.selected = false,
  });

  final PostingCard card;
  final VoidCallback onTap;
  final VoidCallback? onToggleBookmark;
  final bool compact;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      onTap: onTap,
      padding: EdgeInsets.all(compact ? 14 : 16),
      borderColor: selected ? AppColors.primary : AppColors.border,
      backgroundColor: selected ? AppColors.primaryTint.withValues(alpha: 0.35) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusBadge.category(card.category),
              if (card.requestsContact) ...[
                const SizedBox(width: 6),
                const StatusBadge(
                  label: '연락처 요청',
                  backgroundColor: AppColors.accentOrangeBg,
                  textColor: AppColors.accentOrange,
                ),
              ],
              const Spacer(),
              if (onToggleBookmark != null)
                InkWell(
                  onTap: onToggleBookmark,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      card.bookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      size: 20,
                      color: card.bookmarked
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            card.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compact ? 14 : 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final f in card.fields) TagChip(label: f.label, highlight: true),
              for (final s in card.skills.take(compact ? 2 : 3))
                TagChip(label: s),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        card.recruiter.displayTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    if (card.recruiter.verified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${card.capacity}명',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              DDayText(dDay: card.dDay, status: card.status),
            ],
          ),
        ],
      ),
    );
  }
}
