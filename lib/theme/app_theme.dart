import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF120B22);
  static const surface = Color(0xFF1C1332);
  static const surfaceAlt = Color(0xFF241A3D);
  static const primary = Color(0xFF7B5CFA);
  static const primaryDim = Color(0xFF4A3B8A);
  static const gold = Color(0xFFF3C24B);
  static const success = Color(0xFF3ECF8E);
  static const danger = Color(0xFFEF5A6F);
  static const warning = Color(0xFFF3A24B);
  static const textPrimary = Color(0xFFF5F3FA);
  static const textSecondary = Color(0xFFA79DC2);
  static const divider = Color(0xFF2D2247);
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      fontFamily: 'Georgia', // swap for a serif/premium font in the real project
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.gold,
        surface: AppColors.surface,
      ),
      cardColor: AppColors.surface,
      dividerColor: AppColors.divider,
      textTheme: const TextTheme(
        headlineSmall: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 20),
        titleMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
        bodyMedium: TextStyle(color: AppColors.textPrimary, fontSize: 14),
        bodySmall: TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 20),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
    );
  }
}

/// Standard rounded card used across every screen.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: child,
    );
  }
}