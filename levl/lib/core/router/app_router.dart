import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/welcome_page.dart';
import '../../features/dashboard/presentation/screens/dashboard_page.dart';
import '../../features/onboarding/presentation/screens/onboarding_page.dart';
import '../../features/onboarding/presentation/providers/onboarding_provider.dart';

part 'app_router.g.dart';

abstract class AppRoutes {
  static const welcome    = '/welcome';
  static const onboarding = '/onboarding';
  static const dashboard  = '/dashboard';
  static const character  = '/character';
  static const aiMentor   = '/mentor';
}

@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  final isLoggedIn = ref.watch(isAuthenticatedProvider);
  final onboardingState = ref.watch(onboardingCompleteProvider);
  final hasOnboarded = onboardingState.valueOrNull ?? false;

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final loc = state.matchedLocation;

      // Not logged in → welcome
      if (!isLoggedIn) {
        return loc == AppRoutes.welcome ? null : AppRoutes.welcome;
      }

      // Logged in but not onboarded → onboarding
      if (!hasOnboarded) {
        return loc == AppRoutes.onboarding ? null : AppRoutes.onboarding;
      }

      // Logged in + onboarded but on welcome/onboarding → dashboard
      if (loc == AppRoutes.welcome || loc == AppRoutes.onboarding) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.welcome,
        name: 'welcome',
        builder: (_, __) => const WelcomePage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (_, __) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (_, __) => const DashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.character,
        name: 'character',
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('Character Sheet — Phase 6')),
        ),
      ),
      GoRoute(
        path: AppRoutes.aiMentor,
        name: 'aiMentor',
        builder: (_, __) => const Scaffold(
          body: Center(child: Text('AI Ментор — Phase 7')),
        ),
      ),
    ],
  );
}
