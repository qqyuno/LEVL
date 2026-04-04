import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/supabase/supabase_service.dart';
import 'core/notifications/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await initSupabase();
  await NotificationService.instance.init();
  await NotificationService.instance.requestPermission();

  runApp(
    const ProviderScope(
      child: LevlApp(),
    ),
  );
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
