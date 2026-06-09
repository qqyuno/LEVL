import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// A single wearable item card shown in the reward shop / character screen.
class RewardItemCard extends StatefulWidget {
  final String svgAsset;
  final String name;
  final String subtitle;
  final int xpCost;       // 0 = already unlocked
  final bool owned;
  final bool equipped;
  final VoidCallback? onTap;

  const RewardItemCard({
    super.key,
    required this.svgAsset,
    required this.name,
    required this.subtitle,
    required this.xpCost,
    this.owned = false,
    this.equipped = false,
    this.onTap,
  });

  @override
  State<RewardItemCard> createState() => _RewardItemCardState();
}

class _RewardItemCardState extends State<RewardItemCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _shimmer = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locked = !widget.owned;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.equipped
                ? AppColors.gold
                : AppColors.divider,
            width: widget.equipped ? 1.5 : 1,
          ),
          boxShadow: widget.equipped
              ? [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Preview area ---
            Expanded(
              child: Stack(
                children: [
                  // Dark gradient bg
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(19),
                      ),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1C1C1C), Color(0xFF0A0A0A)],
                      ),
                    ),
                  ),

                  // Shimmer on gold stripe
                  if (!locked)
                    AnimatedBuilder(
                      animation: _shimmer,
                      builder: (_, __) => Positioned.fill(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(19),
                          ),
                          child: ShaderMask(
                            blendMode: BlendMode.srcATop,
                            shaderCallback: (bounds) => LinearGradient(
                              begin: Alignment(_shimmer.value - 1, 0),
                              end: Alignment(_shimmer.value, 0),
                              colors: [
                                Colors.transparent,
                                AppColors.gold.withValues(alpha: 0.06),
                                Colors.transparent,
                              ],
                            ).createShader(bounds),
                            child: const ColoredBox(color: Colors.white),
                          ),
                        ),
                      ),
                    ),

                  // SVG shirt
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ColorFiltered(
                        colorFilter: locked
                            ? const ColorFilter.matrix([
                                0.2, 0, 0, 0, 0,
                                0, 0.2, 0, 0, 0,
                                0, 0, 0.2, 0, 0,
                                0, 0, 0, 0.5, 0,
                              ])
                            : const ColorFilter.matrix([
                                1, 0, 0, 0, 0,
                                0, 1, 0, 0, 0,
                                0, 0, 1, 0, 0,
                                0, 0, 0, 1, 0,
                              ]),
                        child: SvgPicture.asset(
                          widget.svgAsset,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  // Lock overlay
                  if (locked)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(19),
                          ),
                          color: Colors.black.withValues(alpha: 0.45),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.lock_rounded,
                                  color: Colors.white54,
                                  size: 22),
                              const SizedBox(height: 6),
                              Text(
                                '${widget.xpCost} XP',
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.gold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Equipped badge
                  if (widget.equipped)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'НА СЕБЕ',
                          style: GoogleFonts.dmSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // --- Info row ---
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.subtitle,
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: AppColors.textDisabled,
                          ),
                        ),
                      ),
                      if (widget.owned && !widget.equipped)
                        Icon(Icons.check_circle_outline_rounded,
                            size: 14, color: AppColors.success),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Demo widget — shows how the PRO shirt card looks.
/// Drop this anywhere to preview: RewardItemCardDemo()
class RewardItemCardDemo extends StatelessWidget {
  const RewardItemCardDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Гардероб',
                  style: GoogleFonts.dmSerifDisplay(
                      fontSize: 28, color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              Text(
                'Зарабатывай XP — разблокируй предметы.',
                style: GoogleFonts.dmSans(
                    fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 180,
                height: 240,
                child: RewardItemCard(
                  svgAsset: 'assets/character/shirt_pro.svg',
                  name: 'Монохром PRO',
                  subtitle: 'Сезон 1 · Эксклюзив',
                  xpCost: 2500,
                  owned: false,
                  equipped: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
