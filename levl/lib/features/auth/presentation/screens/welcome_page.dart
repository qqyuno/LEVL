import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AsyncLoading;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 3),

              // Logo
              Text(
                'LEVL',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 56,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 12),

              // Tagline
              Text(
                'Твоя система. Твой путь.',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const Spacer(flex: 4),

              // Error message
              if (authState is AsyncError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Не удалось войти. Попробуй ещё раз.',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: AppColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Google Sign-In
              _AuthButton(
                label: 'Войти через Google',
                icon: Icons.g_mobiledata,
                onTap: isLoading
                    ? null
                    : () => ref.read(authNotifierProvider.notifier).signInWithGoogle(),
              ),
              const SizedBox(height: 12),

              // Apple Sign-In
              _AuthButton(
                label: 'Войти через Apple',
                icon: Icons.apple,
                onTap: isLoading
                    ? null
                    : () => ref.read(authNotifierProvider.notifier).signInWithApple(),
                filled: true,
              ),

              const SizedBox(height: 24),

              // Guest sign-in
              GestureDetector(
                onTap: isLoading
                    ? null
                    : () => ref.read(authNotifierProvider.notifier).signInAnonymously(),
                child: Text(
                  'Войти как гость',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Loading indicator
              if (isLoading)
                const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textSecondary,
                  ),
                ),

              const Spacer(flex: 2),

              // Footer
              Text(
                'Система ждёт. Начнём.',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.textDisabled,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;

  const _AuthButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 22),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          backgroundColor: filled ? AppColors.textPrimary : AppColors.surface,
          foregroundColor: filled ? AppColors.surface : AppColors.textPrimary,
          side: BorderSide(
            color: filled ? AppColors.textPrimary : AppColors.divider,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
