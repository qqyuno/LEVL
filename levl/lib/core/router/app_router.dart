import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/dashboard/presentation/screens/dashboard_page.dart';

part 'app_router.g.dart';

abstract class AppRoutes {
  static const splash      = '/';
  static const onboarding  = '/onboarding';
  static const dashboard   = '/dashboard';
  static const character   = '/character';
  static const aiMentor    = '/mentor';
}

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  // Auth guard will be wired in Phase 2
  return GoRouter(
    initialLocation: AppRoutes.dashboard, // show dashboard mock for now
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const _SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Онбординг — Фаза 3')),
        ),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.character,
        name: 'character',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Character Sheet — Фаза 6')),
        ),
      ),
      GoRoute(
        path: AppRoutes.aiMentor,
        name: 'aiMentor',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('AI Ментор — Фаза 7')),
        ),
      ),
    ],
  );
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('LEVL'),
      ),
    );
  }
}
