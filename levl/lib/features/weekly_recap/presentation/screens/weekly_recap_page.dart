import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/analytics/product_analytics.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/weekly_recap_provider.dart';
import '../widgets/weekly_recap_content.dart';

class WeeklyRecapPage extends ConsumerStatefulWidget {
  const WeeklyRecapPage({super.key});

  @override
  ConsumerState<WeeklyRecapPage> createState() => _WeeklyRecapPageState();
}

class _WeeklyRecapPageState extends ConsumerState<WeeklyRecapPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      unawaited(
        ref
            .read(productAnalyticsProvider)
            .track(ProductEvent.weeklyRecapOpened),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final recap = ref.watch(weeklyRecapProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 12, 0),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Назад',
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: Text(
                      'Итоги недели',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: recap.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
                error: (_, __) => _RecapError(
                  onRetry: () => ref.invalidate(weeklyRecapProvider),
                ),
                data: (value) => WeeklyRecapContent(
                  recap: value,
                  onPrimaryAction: () {
                    if (value.routeNodes >= 5) {
                      context.go(AppRoutes.lifeMap);
                    } else {
                      context.go(AppRoutes.dashboard);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecapError extends StatelessWidget {
  const _RecapError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.history_toggle_off_rounded,
              size: 34,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            const Text('Не удалось собрать неделю'),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Повторить')),
          ],
        ),
      ),
    );
  }
}
