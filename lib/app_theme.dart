import 'package:flutter/material.dart';

ThemeData buildLightAppTheme() {
  return _buildAppTheme(
    brightness: Brightness.light,
    pageBackground: const Color(0xFFF2F6FF),
    surface: Colors.white,
    onSurface: const Color(0xFF07152F),
    surfaceVariant: const Color(0xFFEAF0FF),
  );
}

ThemeData buildDarkAppTheme() {
  return _buildAppTheme(
    brightness: Brightness.dark,
    pageBackground: const Color(0xFF050B18),
    surface: const Color(0xFF0D172B),
    onSurface: const Color(0xFFF4F7FF),
    surfaceVariant: const Color(0xFF14213A),
  );
}

ThemeData _buildAppTheme({
  required Brightness brightness,
  required Color pageBackground,
  required Color surface,
  required Color onSurface,
  required Color surfaceVariant,
}) {
  const seedColor = Color(0xFF4C74FF);
  final isDark = brightness == Brightness.dark;
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
  ).copyWith(
    primary: seedColor,
    secondary: const Color(0xFF00B8D9),
    surface: surface,
    onSurface: onSurface,
    surfaceContainerHighest: surfaceVariant,
    onSurfaceVariant:
        isDark ? const Color(0xFFB9C4D8) : const Color(0xFF5C6678),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: pageBackground,
    fontFamily: 'Roboto',
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: TextStyle(
        color: onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
      contentTextStyle: TextStyle(
        color: colorScheme.onSurfaceVariant,
        fontSize: 15,
        height: 1.35,
      ),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: pageBackground,
      foregroundColor: onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.26 : 0.14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: onSurface.withValues(alpha: isDark ? 0.08 : 0.06),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF101C33) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      prefixIconColor: seedColor,
      labelStyle: TextStyle(
        color: onSurface.withValues(alpha: 0.78),
        fontWeight: FontWeight.w700,
      ),
      hintStyle: TextStyle(color: onSurface.withValues(alpha: 0.42)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: onSurface.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: seedColor, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.6),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        backgroundColor: seedColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: seedColor.withValues(alpha: 0.28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 15,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        foregroundColor: onSurface,
        side: BorderSide(color: onSurface.withValues(alpha: 0.14)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      elevation: 0,
      backgroundColor: surface,
      indicatorColor: seedColor.withValues(alpha: isDark ? 0.22 : 0.13),
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.36 : 0.08),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          color: selected ? seedColor : onSurface.withValues(alpha: 0.62),
          fontSize: 12,
          fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? seedColor : onSurface.withValues(alpha: 0.60),
          size: selected ? 25 : 23,
        );
      }),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor:
          isDark ? const Color(0xFF17243D) : const Color(0xFF07152F),
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
