import 'package:flutter/material.dart';

abstract class AppColors {
  // --- Backgrounds ---
  static const background = Color(0xFF0D0D0F);      // deep dark
  static const surface = Color(0xFF1A1A1F);          // card surface
  static const surfaceElevated = Color(0xFF242428);  // elevated elements

  // --- Text ---
  static const textPrimary = Color(0xFFE8E8E2);      // warm white
  static const textSecondary = Color(0xFF8A8A82);    // muted
  static const textDisabled = Color(0xFF4A4A46);

  // --- Brand / Accent ---
  static const gold = Color(0xFFB8962E);             // EARNED ONLY — never decorative
  static const goldLight = Color(0xFFD4AF4A);        // hover / shimmer

  // --- Dividers ---
  static const divider = Color(0xFF2A2A2F);

  // --- Skill category colors ---
  static const skillDiscipline = Color(0xFF4A90D9);  // blue — дисциплина
  static const skillKnowledge  = Color(0xFF7B68EE);  // purple — знания
  static const skillRelations  = Color(0xFF50C878);  // green — отношения
  static const skillEnergy     = Color(0xFFFF6B35);  // orange — энергия
  static const skillWill       = Color(0xFFDC143C);  // crimson — воля
  static const skillWisdom     = Color(0xFF20B2AA);  // teal — мудрость

  // --- Status ---
  static const success = Color(0xFF50C878);
  static const error   = Color(0xFFDC143C);
  static const warning = Color(0xFFFFB347);
}
