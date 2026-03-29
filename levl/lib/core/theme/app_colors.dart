import 'package:flutter/material.dart';

abstract class AppColors {
  // --- Backgrounds ---
  static const background = Color(0xFFF8F8F6);       // тёплый белый
  static const surface = Color(0xFFFFFFFF);           // карточки
  static const surfaceElevated = Color(0xFFF0F0ED);   // elevated элементы

  // --- Text ---
  static const textPrimary = Color(0xFF0A0A0A);       // почти чёрный
  static const textSecondary = Color(0xFF6B6B68);     // приглушённый
  static const textDisabled = Color(0xFFB0B0AB);

  // --- Brand / Accent ---
  static const gold = Color(0xFFB8962E);              // ТОЛЬКО за заслуги — никогда декоративно
  static const goldLight = Color(0xFFD4AF4A);         // hover / shimmer

  // --- Dividers ---
  static const divider = Color(0xFFE2E2DE);

  // --- Skill category colors ---
  static const skillDiscipline = Color(0xFF2D6DB5);   // blue — дисциплина
  static const skillKnowledge  = Color(0xFF5B47C4);   // purple — знания
  static const skillRelations  = Color(0xFF2E8B57);   // green — отношения
  static const skillEnergy     = Color(0xFFD4541A);   // orange — энергия
  static const skillWill       = Color(0xFFB01030);   // crimson — воля
  static const skillWisdom     = Color(0xFF138080);   // teal — мудрость

  // --- Status ---
  static const success = Color(0xFF2E8B57);
  static const error   = Color(0xFFB01030);
  static const warning = Color(0xFFCC8800);
}
