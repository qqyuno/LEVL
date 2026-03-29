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

  // --- Sphere colors (for quest cards & icons) ---
  static const sphereDiscipline = Color(0xFF4A6FA5);  // blue — дисциплина
  static const sphereKnowledge  = Color(0xFF4A8C6F);  // green — знания
  static const sphereRelations  = Color(0xFFC47E6B);  // pink — отношения
  static const sphereEnergy     = Color(0xFFC47E2E);  // orange — энергия
  static const sphereWill       = Color(0xFF7B6FA5);  // purple — воля
  static const sphereWisdom     = Color(0xFF4A8C8C);  // teal — мудрость

  // Aliases for backward compatibility (dashboard uses these)
  static const skillDiscipline = sphereDiscipline;
  static const skillKnowledge  = sphereKnowledge;
  static const skillRelations  = sphereRelations;
  static const skillEnergy     = sphereEnergy;
  static const skillWill       = sphereWill;
  static const skillWisdom     = sphereWisdom;

  // --- Status ---
  static const success = Color(0xFF2E8B57);
  static const error   = Color(0xFFB01030);
  static const warning = Color(0xFFCC8800);
}
