import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff475d92),
      surfaceTint: Color(0xff475d92),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffd9e2ff),
      onPrimaryContainer: Color(0xff2f4578),
      secondary: Color(0xff575e71),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffdce2f9),
      onSecondaryContainer: Color(0xff404659),
      tertiary: Color(0xff545a92),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffdfe0ff),
      onTertiaryContainer: Color(0xff3c4279),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffaf8ff),
      onSurface: Color(0xff1a1b20),
      onSurfaceVariant: Color(0xff44464f),
      outline: Color(0xff757780),
      outlineVariant: Color(0xffc5c6d0),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2f3036),
      inversePrimary: Color(0xffb0c6ff),
      primaryFixed: Color(0xffd9e2ff),
      onPrimaryFixed: Color(0xff001945),
      primaryFixedDim: Color(0xffb0c6ff),
      onPrimaryFixedVariant: Color(0xff2f4578),
      secondaryFixed: Color(0xffdce2f9),
      onSecondaryFixed: Color(0xff151b2c),
      secondaryFixedDim: Color(0xffc0c6dc),
      onSecondaryFixedVariant: Color(0xff404659),
      tertiaryFixed: Color(0xffdfe0ff),
      onTertiaryFixed: Color(0xff0e154b),
      tertiaryFixedDim: Color(0xffbdc2ff),
      onTertiaryFixedVariant: Color(0xff3c4279),
      surfaceDim: Color(0xffdad9e0),
      surfaceBright: Color(0xfffaf8ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff4f3fa),
      surfaceContainer: Color(0xffeeedf4),
      surfaceContainerHigh: Color(0xffe8e7ef),
      surfaceContainerHighest: Color(0xffe2e2e9),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff1c3466),
      surfaceTint: Color(0xff475d92),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff566ca1),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff2f3648),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff666d81),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff2b3167),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff6269a2),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffaf8ff),
      onSurface: Color(0xff0f1116),
      onSurfaceVariant: Color(0xff34363e),
      outline: Color(0xff50525a),
      outlineVariant: Color(0xff6b6d75),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2f3036),
      inversePrimary: Color(0xffb0c6ff),
      primaryFixed: Color(0xff566ca1),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff3d5387),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff666d81),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff4e5467),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff6269a2),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff4a5088),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc6c6cd),
      surfaceBright: Color(0xfffaf8ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff4f3fa),
      surfaceContainer: Color(0xffe8e7ef),
      surfaceContainerHigh: Color(0xffdddce3),
      surfaceContainerHighest: Color(0xffd1d1d8),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff102a5c),
      surfaceTint: Color(0xff475d92),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff31487b),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff252c3d),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff42495b),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff21275c),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff3e457b),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffaf8ff),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff2a2c33),
      outlineVariant: Color(0xff474951),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2f3036),
      inversePrimary: Color(0xffb0c6ff),
      primaryFixed: Color(0xff31487b),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff183163),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff42495b),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff2c3244),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff3e457b),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff272e63),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb8b8bf),
      surfaceBright: Color(0xfffaf8ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff1f0f7),
      surfaceContainer: Color(0xffe2e2e9),
      surfaceContainerHigh: Color(0xffd4d4db),
      surfaceContainerHighest: Color(0xffc6c6cd),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffb0c6ff),
      surfaceTint: Color(0xffb0c6ff),
      onPrimary: Color(0xff152e60),
      primaryContainer: Color(0xff2f4578),
      onPrimaryContainer: Color(0xffd9e2ff),
      secondary: Color(0xffc0c6dc),
      onSecondary: Color(0xff2a3042),
      secondaryContainer: Color(0xff404659),
      onSecondaryContainer: Color(0xffdce2f9),
      tertiary: Color(0xffbdc2ff),
      onTertiary: Color(0xff252b61),
      tertiaryContainer: Color(0xff3c4279),
      onTertiaryContainer: Color(0xffdfe0ff),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff121318),
      onSurface: Color(0xffe2e2e9),
      onSurfaceVariant: Color(0xffc5c6d0),
      outline: Color(0xff8f9099),
      outlineVariant: Color(0xff44464f),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e2e9),
      inversePrimary: Color(0xff475d92),
      primaryFixed: Color(0xffd9e2ff),
      onPrimaryFixed: Color(0xff001945),
      primaryFixedDim: Color(0xffb0c6ff),
      onPrimaryFixedVariant: Color(0xff2f4578),
      secondaryFixed: Color(0xffdce2f9),
      onSecondaryFixed: Color(0xff151b2c),
      secondaryFixedDim: Color(0xffc0c6dc),
      onSecondaryFixedVariant: Color(0xff404659),
      tertiaryFixed: Color(0xffdfe0ff),
      onTertiaryFixed: Color(0xff0e154b),
      tertiaryFixedDim: Color(0xffbdc2ff),
      onTertiaryFixedVariant: Color(0xff3c4279),
      surfaceDim: Color(0xff121318),
      surfaceBright: Color(0xff38393f),
      surfaceContainerLowest: Color(0xff0c0e13),
      surfaceContainerLow: Color(0xff1a1b20),
      surfaceContainer: Color(0xff1e1f25),
      surfaceContainerHigh: Color(0xff282a2f),
      surfaceContainerHighest: Color(0xff33343a),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffd0dcff),
      surfaceTint: Color(0xffb0c6ff),
      onPrimary: Color(0xff062355),
      primaryContainer: Color(0xff7a90c8),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffd6dcf3),
      onSecondary: Color(0xff1f2536),
      secondaryContainer: Color(0xff8a90a5),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffd8daff),
      onTertiary: Color(0xff1a2055),
      tertiaryContainer: Color(0xff868cc8),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff121318),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffdbdce6),
      outline: Color(0xffb0b1bb),
      outlineVariant: Color(0xff8e9099),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e2e9),
      inversePrimary: Color(0xff304679),
      primaryFixed: Color(0xffd9e2ff),
      onPrimaryFixed: Color(0xff000f30),
      primaryFixedDim: Color(0xffb0c6ff),
      onPrimaryFixedVariant: Color(0xff1c3466),
      secondaryFixed: Color(0xffdce2f9),
      onSecondaryFixed: Color(0xff0a1121),
      secondaryFixedDim: Color(0xffc0c6dc),
      onSecondaryFixedVariant: Color(0xff2f3648),
      tertiaryFixed: Color(0xffdfe0ff),
      onTertiaryFixed: Color(0xff030841),
      tertiaryFixedDim: Color(0xffbdc2ff),
      onTertiaryFixedVariant: Color(0xff2b3167),
      surfaceDim: Color(0xff121318),
      surfaceBright: Color(0xff43444a),
      surfaceContainerLowest: Color(0xff06070c),
      surfaceContainerLow: Color(0xff1c1d23),
      surfaceContainer: Color(0xff26282d),
      surfaceContainerHigh: Color(0xff313238),
      surfaceContainerHighest: Color(0xff3c3d43),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffedefff),
      surfaceTint: Color(0xffb0c6ff),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffacc2fd),
      onPrimaryContainer: Color(0xff000a25),
      secondary: Color(0xffedefff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffbcc2d8),
      onSecondaryContainer: Color(0xff050b1b),
      tertiary: Color(0xfff0eeff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffb8befd),
      onTertiaryContainer: Color(0xff000338),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff121318),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffefeffa),
      outlineVariant: Color(0xffc1c2cc),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e2e9),
      inversePrimary: Color(0xff304679),
      primaryFixed: Color(0xffd9e2ff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffb0c6ff),
      onPrimaryFixedVariant: Color(0xff000f30),
      secondaryFixed: Color(0xffdce2f9),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffc0c6dc),
      onSecondaryFixedVariant: Color(0xff0a1121),
      tertiaryFixed: Color(0xffdfe0ff),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffbdc2ff),
      onTertiaryFixedVariant: Color(0xff030841),
      surfaceDim: Color(0xff121318),
      surfaceBright: Color(0xff4f5056),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1e1f25),
      surfaceContainer: Color(0xff2f3036),
      surfaceContainerHigh: Color(0xff3a3b41),
      surfaceContainerHighest: Color(0xff45464c),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.background,
     canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
