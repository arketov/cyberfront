//lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.bg,
    required this.panel,
    required this.panel2,
    required this.pink,
    required this.blue,
    required this.line,
    required this.muted,
    required this.muted2,
    required this.blurBlack,
    required this.blurSigma
  });

  final Color bg;
  final Color panel;
  final Color panel2;

  final Color pink;
  final Color blue;
  final Color line;

  final Color muted;
  final Color muted2;
  final Color blurBlack;
  final double blurSigma;

  @override
  AppPalette copyWith({
    Color? bg,
    Color? panel,
    Color? panel2,
    Color? pink,
    Color? blue,
    Color? line,
    Color? muted,
    Color? muted2,
    Color? blurBlack,
    double? blurSigma,
  }) {
    return AppPalette(
      bg: bg ?? this.bg,
      panel: panel ?? this.panel,
      panel2: panel2 ?? this.panel2,
      pink: pink ?? this.pink,
      blue: blue ?? this.blue,
      line: line ?? this.line,
      muted: muted ?? this.muted,
      muted2: muted2 ?? this.muted2,
      blurBlack: blurBlack ?? this.blurBlack,
      blurSigma: blurSigma ?? this.blurSigma
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      bg: Color.lerp(bg, other.bg, t)!,
      panel: Color.lerp(panel, other.panel, t)!,
      panel2: Color.lerp(panel2, other.panel2, t)!,
      pink: Color.lerp(pink, other.pink, t)!,
      blue: Color.lerp(blue, other.blue, t)!,
      line: Color.lerp(line, other.line, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      muted2: Color.lerp(muted2, other.muted2, t)!,
        blurBlack: Color.lerp(blurBlack, other.blurBlack,t)!,
        blurSigma: other.blurSigma
    );
  }
}

class AppTheme {
  AppTheme._();

  // Brand / UI colors
  static const _bg = Color(0xFF000000);
  static const _panel = Color(0xFF070707);
  static const _panel2 = Color(0xFF0B0B0B);

  static const _pink = Color(0xFFFF2BD6);
  static const _blue = Color(0xFF083BFF); // редко
  static const _line = Color(0x24FFFFFF); // ~14%

  static const _text = Color(0xFFFFFFFF);
  static const _muted = Color(0xB3FFFFFF); // ~70%
  static const _muted2 = Color(0x73FFFFFF); // ~45%

  static const _blurBlack = Color(0xBE000000);

  static const _blurSigma = 12.0;

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: _pink,
      brightness: Brightness.dark,
    ).copyWith(
      primary: _pink,
      onPrimary: const Color(0xFF120014),
      secondary: _blue,
      onSecondary: _text,
      surface: _panel,
      onSurface: _text,
      outline: _line,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: _bg,

      // Если добавишь Inter/RussoOne в pubspec — просто поменяй fontFamily.
      fontFamily: 'Inter',

      extensions: const <ThemeExtension<dynamic>>[
        AppPalette(
            bg: _bg,
            panel: _panel,
            panel2: _panel2,
            pink: _pink,
            blue: _blue,
            line: _line,
            muted: _muted,
            muted2: _muted2,
            blurBlack: _blurBlack,
            blurSigma: _blurSigma
        ),
      ],

      appBarTheme: const AppBarTheme(
        backgroundColor: _bg,
        foregroundColor: _text,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
          color: _text,
        ),
      ),

      // ✅ ВАЖНО: CardThemeData / DialogThemeData
      cardTheme: CardThemeData(
        color: _panel,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: _line, width: 1),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF050505),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: _line, width: 1),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
          color: _text,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          height: 1.4,
          color: _muted,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _pink,
          foregroundColor: const Color(0xFF120014),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: _pink, width: 1),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _text,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: const BorderSide(color: _line, width: 1),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF060606),
        hintStyle: const TextStyle(color: Color(0x59FFFFFF)),
        labelStyle: const TextStyle(
          color: _muted2,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _line, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _line, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _blue, width: 1.2),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF060606),
        selectedColor: const Color(0x24FF2BD6),
        disabledColor: const Color(0x33060606),
        side: const BorderSide(color: _line, width: 1),
        labelStyle: const TextStyle(color: _muted, fontWeight: FontWeight.w800),
        secondaryLabelStyle: const TextStyle(color: _text, fontWeight: FontWeight.w800),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),

      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _line, width: 1),
        ),
        tileColor: _panel2,
        textColor: _text,
        iconColor: _muted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      dividerTheme: const DividerThemeData(
        color: Color(0x1AFFFFFF),
        thickness: 1,
        space: 24,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xD6000000),
        selectedItemColor: _text,
        unselectedItemColor: _muted2,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: _pink, brightness: Brightness.light),
  );
}
