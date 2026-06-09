import 'package:flutter/material.dart';
import '../models/pet_status.dart';

class AppColors {
  static const Color background = Color(0xFFF8FBFA);
  static const Color surface = Colors.white;
  static const Color card = Colors.white;
  static const Color brand = Color(0xFF13952F);
  static const Color brandDark = Color(0xFF0D7C28);
  static const Color brandSoft = Color(0xFFEAF8EF);
  static const Color mintLight = Color(0xFFF2FBF6);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE6EAEF);
  static const Color danger = Color(0xFFEF4444);
  static const Color emergency = Color(0xFFDC2626);
  static const Color caution = Color(0xFFF59E0B);
  static const Color interest = Color(0xFFF59E0B);
  static const Color invalid = Color(0xFF6D4BC3);
  static const Color blue = Color(0xFF3B82F6);
  static const Color orange = Color(0xFFF97316);

  static Color status(PetStatus status) {
    switch (status) {
      case PetStatus.normal:
        return const Color(0xFF13952F);
      case PetStatus.interest:
        return interest;
      case PetStatus.caution:
        return caution;
      case PetStatus.danger:
        return danger;
      case PetStatus.emergency:
        return emergency;
      case PetStatus.invalid:
        return invalid;
    }
  }

  static Color statusSoft(PetStatus status) {
    switch (status) {
      case PetStatus.normal:
        return const Color(0xFFEAF8EF);
      case PetStatus.interest:
        return const Color(0xFFFFF7E6);
      case PetStatus.caution:
        return const Color(0xFFFFF1D6);
      case PetStatus.danger:
        return const Color(0xFFFFE7E7);
      case PetStatus.emergency:
        return const Color(0xFFFFE1E1);
      case PetStatus.invalid:
        return const Color(0xFFF2ECFF);
    }
  }
}
