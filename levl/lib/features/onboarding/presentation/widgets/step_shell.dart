import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Shared cinematic wrapper for onboarding steps.
/// Staggered fade-in: chapter label → title → subtitle → content.
class StepShell extends StatefulWidget {
  final String chapter; // "01", "02", ...
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? footer;
  final EdgeInsets? padding;
  final bool scrollable;

  const StepShell({
    super.key,
    required this.chapter,
    required this.title,
    required this.subtitle,
    required this.child,
    this.footer,
    this.padding,
    this.scrollable = true,
  });

  @override
  State<StepShell> createState() => _StepShellState();
}

class _StepShellState extends State<StepShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _chapterFade;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _chapterFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );
    _titleFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.1, 0.55, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.1, 0.55, curve: Curves.easeOutCubic),
    ));
    _subtitleFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.25, 0.7, curve: Curves.easeOut),
    );
    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.25, 0.7, curve: Curves.easeOutCubic),
    ));
    _contentFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
    ));

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = widget.padding ??
        const EdgeInsets.fromLTRB(24, 32, 24, 16);

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeTransition(
          opacity: _chapterFade,
          child: Row(
            children: [
              Container(
                width: 24,
                height: 1,
                color: AppColors.gold.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 10),
              Text(
                'ГЛАВА ${widget.chapter}',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  letterSpacing: 2.4,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FadeTransition(
          opacity: _titleFade,
          child: SlideTransition(
            position: _titleSlide,
            child: Text(
              widget.title,
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 32,
                height: 1.15,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        FadeTransition(
          opacity: _subtitleFade,
          child: SlideTransition(
            position: _subtitleSlide,
            child: Text(
              widget.subtitle,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.55,
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
      ],
    );

    final content = FadeTransition(
      opacity: _contentFade,
      child: SlideTransition(
        position: _contentSlide,
        child: widget.child,
      ),
    );

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        content,
        if (widget.footer != null) ...[
          const SizedBox(height: 24),
          FadeTransition(
            opacity: _contentFade,
            child: Center(child: widget.footer!),
          ),
        ],
      ],
    );

    if (widget.scrollable) {
      return SingleChildScrollView(
        padding: padding,
        physics: const BouncingScrollPhysics(),
        child: body,
      );
    }
    return Padding(padding: padding, child: body);
  }
}

/// Small italic quote shown at the bottom of some steps.
class StepQuote extends StatelessWidget {
  final String text;
  const StepQuote(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 1,
          color: AppColors.textDisabled,
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppColors.textDisabled,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 16,
          height: 1,
          color: AppColors.textDisabled,
        ),
      ],
    );
  }
}
