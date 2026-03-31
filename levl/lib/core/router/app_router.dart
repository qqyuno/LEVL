import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../theme/app_colors.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/welcome_page.dart';
import '../../features/dashboard/presentation/screens/dashboard_page.dart';
import '../../features/character/presentation/screens/character_page.dart';
import '../../features/ai_mentor/presentation/screens/chat_page.dart';
import '../../features/onboarding/presentation/screens/onboarding_page.dart';
import '../../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../../shared/widgets/level_up_overlay.dart';

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

      // --- Main app with bottom navigation ---
      ShellRoute(
        builder: (context, state, child) => _MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            name: 'dashboard',
            builder: (_, __) => const DashboardPage(),
          ),
          GoRoute(
            path: AppRoutes.character,
            name: 'character',
            builder: (_, __) => const CharacterPage(),
          ),
          GoRoute(
            path: AppRoutes.aiMentor,
            name: 'aiMentor',
            builder: (_, __) => const ChatPage(),
          ),
        ],
      ),
    ],
  );
}

/// Shell widget with bottom navigation bar.
class _MainShell extends StatelessWidget {
  final Widget child;
  const _MainShell({required this.child});

  static const _tabs = [
    AppRoutes.dashboard,
    AppRoutes.character,
    AppRoutes.aiMentor,
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _tabs.indexOf(location).clamp(0, 2);

    return Scaffold(
      body: Stack(
        children: [
          child,
          const LevelUpOverlay(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            context.go(_tabs[index]);
          },
          backgroundColor: AppColors.background,
          elevation: 0,
          indicatorColor: AppColors.textPrimary.withValues(alpha: 0.08),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.home, color: AppColors.textPrimary),
              label: 'Путь',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.person, color: AppColors.textPrimary),
              label: 'Персонаж',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.auto_awesome, color: AppColors.gold),
              label: 'Система',
            ),
          ],
        ),
      ),
    );
  }
}
