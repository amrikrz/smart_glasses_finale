import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class C {
  static const bg = Color(0xFFEEF0FB);
  static const card = Colors.white;
  static const ink = Color(0xFF1B1F36);
  static const muted = Color(0xFF8A90A6);
  static const border = Color(0xFFE3E6F3);
  static const primary = Color(0xFF5C6BC0);
  static const primarySoft = Color(0xFFE6E9F8);
  static const green = Color(0xFF22A06B);
  static const greenSoft = Color(0xFFDDF5E8);
  static const orange = Color(0xFFF59E0B);
  static const orangeSoft = Color(0xFFFFF1DB);
  static const purple = Color(0xFF7C4DDB);
  static const purpleSoft = Color(0xFFEFE8FD);
  static const red = Color(0xFFE5484D);
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: C.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: C.primary,
        primary: C.primary,
        surface: C.card,
      ),
    );
    Color tint(Set<WidgetState> s) =>
        s.contains(WidgetState.selected) ? C.primary : C.muted;

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme)
          .apply(bodyColor: C.ink, displayColor: C.ink),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        height: 68,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
              fontSize: 11,
              fontWeight:
                  s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
              color: tint(s),
            )),
        iconTheme: WidgetStateProperty.resolveWith(
            (s) => IconThemeData(size: 24, color: tint(s))),
      ),
    );
  }
}