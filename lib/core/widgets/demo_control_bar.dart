import 'package:flutter/material.dart';

import '../../data/state/app_controller.dart';
import '../constants/app_colors.dart';
import 'common_widgets.dart';

/// 발표 시연 및 백엔드 연동을 제어하는 상단 컨트롤 바.
class DemoControlBar extends StatelessWidget {
  const DemoControlBar({super.key, required this.controller});

  final AppController controller;

  static const List<({int id, String label})> quickPersonas = [
    (id: 1, label: '김민준'),
    (id: 4, label: '박지호'),
    (id: 2, label: '이서연'),
    (id: 6, label: 'D:LAB'),
    (id: 7, label: 'R:BOT'),
    (id: 8, label: '관리자'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final live = controller.api.isLiveBackend;
        final currentId = controller.currentUser?.memberId;

        if (!controller.showDemoBar) {
          return Container(
            color: const Color(0xFF1F2937),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Icon(
                  live ? Icons.cloud_done : Icons.storage,
                  size: 14,
                  color: live ? const Color(0xFF4ADE80) : const Color(0xFFFBBF24),
                ),
                const SizedBox(width: 6),
                Text(
                  '시연 바 · ${controller.currentUser?.name ?? "비회원"}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                const Spacer(),
                TextButton(
                  onPressed: controller.toggleDemoBar,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 24),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text(
                    '시연 컨트롤 펼치기',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          color: const Color(0xFF1F2937),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                InkWell(
                  onTap: () => _showBackendConfigDialog(context),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: live
                          ? const Color(0xFF065F46)
                          : const Color(0xFF374151),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: live
                                ? const Color(0xFF4ADE80)
                                : const Color(0xFFFBBF24),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          live ? '서버 연결됨' : '로컬 모드',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  '계정 전환:',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
                const SizedBox(width: 6),
                for (final p in quickPersonas)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: ChoiceChip(
                      label: Text(
                        p.label,
                        style: TextStyle(
                          fontSize: 11,
                          color: currentId == p.id
                              ? Colors.white
                              : Colors.white70,
                        ),
                      ),
                      selected: currentId == p.id,
                      onSelected: (_) async {
                        await controller.loginAs(p.id);
                        if (context.mounted) {
                          AppToast.show(context, '${p.label} 계정으로 전환했습니다.');
                        }
                      },
                      selectedColor: AppColors.primaryLight,
                      backgroundColor: const Color(0xFF374151),
                      side: BorderSide.none,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                  ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: controller.toggleMobileFrameMode,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white30),
                    minimumSize: const Size(0, 30),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  icon: Icon(
                    controller.mobileFrameMode
                        ? Icons.desktop_windows
                        : Icons.smartphone,
                    size: 14,
                  ),
                  label: Text(
                    controller.mobileFrameMode ? '반응형 뷰' : '모바일 프레임',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                const SizedBox(width: 6),
                OutlinedButton.icon(
                  onPressed: () async {
                    await controller.resetDemoData();
                    if (context.mounted) {
                      AppToast.show(context, '시연 데이터가 초기 상태로 재설정되었습니다.');
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFCA5A5),
                    side: const BorderSide(color: Color(0xFF7F1D1D)),
                    minimumSize: const Size(0, 30),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  icon: const Icon(Icons.refresh, size: 14),
                  label: const Text('초기화', style: TextStyle(fontSize: 11)),
                ),
                const SizedBox(width: 6),
                IconButton(
                  tooltip: '시연 바 접기',
                  onPressed: controller.toggleDemoBar,
                  icon: const Icon(
                    Icons.keyboard_arrow_up,
                    color: Colors.white70,
                    size: 18,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showBackendConfigDialog(BuildContext context) async {
    final textCtrl = TextEditingController(text: controller.api.baseUrl);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Spring Boot 백엔드 서버 연결 설정',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'skku-crew-backend 주소(예: http://localhost:8080 또는 ngrok https 주소)를 입력하면 실시간 API로 연동됩니다. 서버가 꺼져 있으면 내장 시드 엔진이 자동 동작합니다.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textCtrl,
              decoration: const InputDecoration(
                labelText: 'Base URL',
                hintText: 'http://localhost:8080',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('닫기'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              final ok = await controller.updateBaseUrl(textCtrl.text);
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (context.mounted) {
                AppToast.show(
                  context,
                  ok
                      ? '백엔드(${controller.api.baseUrl})와 연결되었습니다!'
                      : '백엔드에 연결할 수 없어 내장 시드 모드로 동작합니다.',
                  isError: !ok,
                );
              }
            },
            child: const Text('연결 확인'),
          ),
        ],
      ),
    );
    textCtrl.dispose();
  }
}
