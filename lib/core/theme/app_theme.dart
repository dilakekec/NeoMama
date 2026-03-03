import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  
  static const double radiusS = 12;
  static const double radiusM = 16;
  static const double radiusL = 18;
  static const double radiusXL = 22;


  static Color a(Color c, double o) => c.withAlpha((o * 255).round());

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
    );

    final cs = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.warm,
      surface: AppColors.surface,
    );

    final tt = GoogleFonts.nunitoTextTheme(base.textTheme).copyWith(
      titleLarge: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      titleMedium: base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      bodySmall: base.textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.25,
      ),
    );

    return base.copyWith(
      colorScheme: cs,
      scaffoldBackgroundColor: AppColors.bgTopLeft,
      textTheme: tt,

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),

      dividerTheme: DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXL),
          side: BorderSide(color: AppColors.border, width: 1),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusL),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusL),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusL),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusL),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      iconTheme: IconThemeData(color: AppColors.inkSoft),
    );
  }

  static ThemeData dark() {
    const darkSurface = Color(0xFF161B24);
    const darkCard = Color(0xFF1B2230);
    const darkBg = Color(0xFF10141C);
    const darkBorder = Color(0x22FFFFFF);

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
    );

    final cs = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.warm,
      surface: darkSurface,
      onSurface: const Color(0xFFE8ECF5),
      onSurfaceVariant: const Color(0xFFB7C0D4),
    );

    final tt = GoogleFonts.nunitoTextTheme(base.textTheme).apply(
      bodyColor: cs.onSurface,
      displayColor: cs.onSurface,
    ).copyWith(
      titleLarge: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      titleMedium: base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      bodySmall: base.textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.25,
      ),
    );

    return base.copyWith(
      colorScheme: cs,
      scaffoldBackgroundColor: darkBg,
      textTheme: tt,

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),

      dividerTheme: DividerThemeData(
        color: darkBorder,
        thickness: 1,
        space: 1,
      ),

      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXL),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusL),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusL),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusL),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusL),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      iconTheme: IconThemeData(color: cs.onSurfaceVariant),
    );
  }
}
