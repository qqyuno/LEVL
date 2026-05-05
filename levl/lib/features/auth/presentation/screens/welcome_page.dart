import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class WelcomePage extends ConsumerStatefulWidget {
  const WelcomePage({super.key});

  @override
  ConsumerState<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends ConsumerState<WelcomePage>
    with TickerProviderStateMixin {
  // Controllers
  late final AnimationController _scanCtrl;
  late final AnimationController _logoCtrl;
  late final AnimationController _lineCtrl;
  late final AnimationController _taglineCtrl;
  late final AnimationController _buttonsCtrl;

  // Animations
  late final Animation<double> _scanAnim;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _lineWidth;
  late final Animation<double> _taglineFade;
  late final Animation<Offset> _taglineSlide;
  late final Animation<double> _buttonsFade;
  late final Animation<Offset> _buttonsSlide;

  @override
  void initState() {
    super.initState();

    // Scan line — 400ms
    _scanCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _scanAnim = Tween(begin: -0.05, end: 1.05).animate(
      CurvedAnimation(parent: _scanCtrl, curve: Curves.easeInOut),
    );

    // Logo — 700ms
    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _logoFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _logoCtrl,
          curve: const Interval(0.0, 0.7, curve: Curves.easeOut)),
    );
    _logoScale = Tween(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutCubic),
    );

    // Gold underline — 450ms
    _lineCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _lineWidth = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _lineCtrl, curve: Curves.easeOutCubic),
    );

    // Tagline — 600ms
    _taglineCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _taglineFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeOut),
    );
    _taglineSlide =
        Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeOutCubic),
    );

    // Buttons — 700ms
    _buttonsCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _buttonsFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonsCtrl, curve: Curves.easeOut),
    );
    _buttonsSlide =
        Tween(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _buttonsCtrl, curve: Curves.easeOutCubic),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    // 1. Scan line
    await _scanCtrl.forward();
    if (!mounted) return;

    // 2. Logo
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    // 3. Underline draws
    await _lineCtrl.forward();
    if (!mounted) return;

    // 4. Tagline
    _taglineCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    // 5. Buttons
    _buttonsCtrl.forward();
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    _logoCtrl.dispose();
    _lineCtrl.dispose();
    _taglineCtrl.dispose();
    _buttonsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AsyncLoading;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Subtle radial glow behind logo
          Positioned(
            top: size.height * 0.25,
            left: size.width * 0.5 - 120,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gold.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Scan line
          AnimatedBuilder(
            animation: _scanAnim,
            builder: (_, __) => Positioned(
              top: size.height * _scanAnim.value,
              left: 0,
              right: 0,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.gold.withValues(alpha: 0.6),
                      AppColors.gold.withValues(alpha: 0.9),
                      AppColors.gold.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // Logo + underline
                  FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: Column(
                        children: [
                          Text(
                            'LEVL',
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: 64,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              letterSpacing: 8,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Animated gold underline
                          AnimatedBuilder(
                            animation: _lineWidth,
                            builder: (_, __) => Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: _lineWidth.value,
                                child: Container(
                                  height: 1,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.gold,
                                        AppColors.gold.withValues(alpha: 0.3),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tagline
                  FadeTransition(
                    opacity: _taglineFade,
                    child: SlideTransition(
                      position: _taglineSlide,
                      child: Column(
                        children: [
                          Text(
                            'Система не ждёт.',
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              color: Colors.white.withValues(alpha: 0.45),
                              fontStyle: FontStyle.italic,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Но ты можешь начать.',
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              color: Colors.white.withValues(alpha: 0.25),
                              fontStyle: FontStyle.italic,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  FadeTransition(
                    opacity: _taglineFade,
                    child: SlideTransition(
                      position: _taglineSlide,
                      child: const _ValueStack(),
                    ),
                  ),

                  const Spacer(flex: 4),

                  // Auth buttons
                  FadeTransition(
                    opacity: _buttonsFade,
                    child: SlideTransition(
                      position: _buttonsSlide,
                      child: Column(
                        children: [
                          // Error
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

                          _AuthButton(
                            label: 'Войти через Google',
                            icon: Icons.g_mobiledata,
                            onTap: isLoading
                                ? null
                                : () => ref
                                    .read(authNotifierProvider.notifier)
                                    .signInWithGoogle(),
                          ),
                          const SizedBox(height: 12),

                          _AuthButton(
                            label: 'Войти через Apple',
                            icon: Icons.apple,
                            filled: true,
                            onTap: isLoading
                                ? null
                                : () => ref
                                    .read(authNotifierProvider.notifier)
                                    .signInWithApple(),
                          ),

                          const SizedBox(height: 28),

                          GestureDetector(
                            onTap: isLoading
                                ? null
                                : () => ref
                                    .read(authNotifierProvider.notifier)
                                    .signInAnonymously(),
                            child: Text(
                              'Войти как гость',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.3),
                                decoration: TextDecoration.underline,
                                decorationColor:
                                    Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          if (isLoading)
                            const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: AppColors.gold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Footer
                  FadeTransition(
                    opacity: _buttonsFade,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: Text(
                        'LEVL — персональная система роста',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.15),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueStack extends StatelessWidget {
  const _ValueStack();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _ValueLine(text: '3 точных действия в день'),
        SizedBox(height: 8),
        _ValueLine(text: 'Под твою цель и текущий ресурс'),
        SizedBox(height: 8),
        _ValueLine(text: 'Прогресс, который видно'),
      ],
    );
  }
}

class _ValueLine extends StatelessWidget {
  final String text;
  const _ValueLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_rounded, size: 16, color: AppColors.gold),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.72),
                height: 1.2,
              ),
            ),
          ),
        ],
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
      height: 54,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 22),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          backgroundColor:
              filled ? Colors.white : Colors.white.withValues(alpha: 0.04),
          foregroundColor: filled ? const Color(0xFF0A0A0A) : Colors.white,
          side: BorderSide(
            color: filled ? Colors.white : Colors.white.withValues(alpha: 0.15),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
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
