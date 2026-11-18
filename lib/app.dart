import 'package:flutter/material.dart';

import 'core/constants/app_colors.dart';
import 'data/state/app_controller.dart';
import 'ui/screens/apply_screen.dart';
import 'ui/screens/auth_screens.dart';
import 'ui/screens/explore_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/my_activities_screen.dart';
import 'ui/screens/noti_admin_mcp_screens.dart';
import 'ui/screens/org_external_screens.dart';
import 'ui/screens/posting_detail_screen.dart';
import 'ui/screens/posting_manage_screens.dart';
import 'ui/screens/profile_screens.dart';

class SkkuCrewApp extends StatelessWidget {
  const SkkuCrewApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SKKU Crew',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
        scaffoldBackgroundColor: AppColors.background,
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
      home: _RootViewport(controller: controller),
    );
  }
}

class _RootViewport extends StatelessWidget {
  const _RootViewport({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final screen = !controller.initialized
            ? const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              )
            : _resolveScreen(controller.currentPath);

        if (!controller.mobileFrameMode) {
          return screen;
        }

        return Scaffold(
          backgroundColor: const Color(0xFFE5E7EB),
          body: SafeArea(
            bottom: false,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 14),
                width: 412,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: const Color(0xFF111827),
                    width: 8,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 24,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    size: const Size(
                      396,
                      820,
                    ),
                  ),
                  child: screen,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _resolveScreen(String rawPath) {
    final uri = Uri.tryParse(rawPath) ?? Uri(path: '/');
    final path = uri.path;
    final seg = uri.pathSegments;

    if (path == '/login') {
      return LoginScreen(controller: controller);
    }
    if (path == '/signup') {
      return SignupIndividualScreen(controller: controller);
    }
    if (path == '/org/signup') {
      return SignupOrgScreen(controller: controller);
    }
    if (path == '/explore') {
      return ExploreScreen(controller: controller);
    }
    if (path == '/external') {
      return ExternalActivitiesScreen(controller: controller);
    }
    if (path == '/me/applications') {
      return MyActivitiesScreen(controller: controller);
    }
    if (path == '/me/profile') {
      return ProfileScreen(controller: controller);
    }
    if (path == '/me/profile/edit') {
      return ProfileEditScreen(controller: controller);
    }
    if (path == '/postings/new') {
      return PostingFormScreen(controller: controller);
    }
    if (path == '/org/dashboard') {
      return OrgDashboardScreen(controller: controller);
    }
    if (path == '/notifications') {
      return NotificationCenterScreen(controller: controller);
    }
    if (path.startsWith('/admin')) {
      return AdminConsoleScreen(controller: controller);
    }
    if (path == '/settings/ai') {
      return AiConnectionScreen(controller: controller);
    }
    if (path == '/oauth/authorize') {
      return AiConsentScreen(controller: controller);
    }

    // 동적 경로 매칭 (/postings/{id}, /postings/{id}/apply, /postings/{id}/applicants, /postings/{id}/announce)
    if (seg.length >= 2 && seg[0] == 'postings') {
      final postingId = int.tryParse(seg[1]);
      if (postingId != null) {
        if (seg.length == 2) {
          return PostingDetailScreen(
            controller: controller,
            postingId: postingId,
          );
        }
        if (seg.length == 3 && seg[2] == 'apply') {
          return ApplyScreen(
            controller: controller,
            postingId: postingId,
          );
        }
        if (seg.length == 3 && seg[2] == 'applicants') {
          return ApplicantListScreen(
            controller: controller,
            postingId: postingId,
          );
        }
        if (seg.length == 3 && seg[2] == 'announce') {
          return AnnounceResultScreen(
            controller: controller,
            postingId: postingId,
          );
        }
      }
    }

    // /applications/{id} (지원서 검토 SCR-13)
    if (seg.length == 2 && seg[0] == 'applications') {
      final appId = int.tryParse(seg[1]);
      if (appId != null) {
        return ApplicationReviewScreen(
          controller: controller,
          applicationId: appId,
        );
      }
    }

    // /orgs/{orgId} (조직 페이지 SCR-16)
    if (seg.length == 2 && seg[0] == 'orgs') {
      final orgId = int.tryParse(seg[1]);
      if (orgId != null) {
        return OrgPageScreen(
          controller: controller,
          orgId: orgId,
        );
      }
    }

    return HomeScreen(controller: controller);
  }
}
