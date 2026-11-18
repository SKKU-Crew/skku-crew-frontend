import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/codes.dart';
import 'common_widgets.dart';

/// 제출된 지원서의 프로필 스냅샷을 읽기 전용으로 렌더링하는 공용 위젯 (SCR-08, SCR-13 공용).
class SnapshotViewWidget extends StatelessWidget {
  const SnapshotViewWidget({super.key, required this.snapshot});

  final Map<String, dynamic> snapshot;

  @override
  Widget build(BuildContext context) {
    final name = snapshot['name']?.toString() ?? '-';
    final majorPrimary = snapshot['majorPrimary']?.toString() ?? '';
    final academicStatus = snapshot['academicStatus'] != null
        ? AcademicStatus.fromApi(snapshot['academicStatus'].toString())
            .shortLabel
        : '';
    final majorsSecondary =
        (snapshot['majorsSecondary'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList();
    final bio = snapshot['bio']?.toString();
    final fields = (snapshot['fields'] as List<dynamic>? ?? const [])
        .map((e) => Field.fromApi(e.toString()))
        .toList();
    final skills = (snapshot['skills'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final experiences = (snapshot['experiences'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final links = (snapshot['portfolioLinks'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final files = (snapshot['portfolioFiles'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primaryTint,
              child: Text(
                name.isEmpty ? '?' : name[0],
                style: const TextStyle(
                  fontSize: 16,
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
                  Text(
                    name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (majorPrimary.isNotEmpty) majorPrimary,
                      if (majorsSecondary.isNotEmpty)
                        '복수: ${majorsSecondary.join(", ")}',
                      if (academicStatus.isNotEmpty) academicStatus,
                    ].join(' · '),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (bio != null && bio.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            bio,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          ),
        ],
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final f in fields) TagChip(label: f.label, highlight: true),
            for (final s in skills)
              TagChip(
                label:
                    '${s['name']} ${SkillLevel.fromApi(s['level']?.toString()).label}',
              ),
          ],
        ),
        if (experiences.isNotEmpty) ...[
          const SizedBox(height: 14),
          const Text(
            '경험',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 6),
          for (final e in experiences)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (e['role']?.toString() ?? '').isNotEmpty
                          ? '${e['title'] ?? ''} · ${e['role']}'
                          : (e['title']?.toString() ?? ''),
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    if ((e['description']?.toString() ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        e['description'].toString(),
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
        if (links.isNotEmpty || files.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final l in links)
                Chip(
                  avatar: const Icon(Icons.link, size: 15),
                  label: Text(l['title']?.toString() ?? '링크',
                      style: const TextStyle(fontSize: 12)),
                ),
              for (final f in files)
                Chip(
                  avatar: const Icon(Icons.picture_as_pdf_outlined, size: 15),
                  label: Text(f['fileName']?.toString() ?? 'PDF',
                      style: const TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
