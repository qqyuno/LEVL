# Plan 1.4 — Riverpod + GoRouter Setup

**Phase:** 1 — Foundation
**Goal:** Подключить Riverpod (ProviderScope) и GoRouter с auth-guard.

## Files to Create

### `lib/core/router/app_router.dart`
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

// Route names
abstract class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const dashboard = '/dashboard';
  static const character = '/character';
  static const aiMentor = '/mentor';
}

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  // Will watch auth state in Phase 2 — placeholder for now
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Onboarding — Phase 3')),
        ),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Dashboard — Phase 4')),
        ),
      ),
    ],
  );
}

// Temporary splash screen
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('LEVL', style: TextStyle(fontSize: 32)),
      ),
    );
  }
}
```

### `lib/main.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const ProviderScope(child: LevlApp()));
}

class LevlApp extends ConsumerWidget {
  const LevlApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'LEVL',
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

## Steps
1. Создать `lib/core/router/app_router.dart` с placeholder-роутами
2. Обновить `lib/main.dart` — ProviderScope + GoRouter + AppTheme
3. Запустить `build_runner` для генерации `app_router.g.dart`
```bash
cd levl
flutter pub run build_runner build --delete-conflicting-outputs
```

## Verification
- [ ] `main.dart` использует `ProviderScope` как корень
- [ ] `MaterialApp.router` с `AppTheme.light`
- [ ] `app_router.g.dart` сгенерирован
- [ ] `flutter run` запускает приложение без ошибок
- [ ] На экране отображается SplashScreen с текстом "LEVL"
