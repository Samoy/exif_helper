import 'package:flutter/material.dart';

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF0353DA),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFDBE1FF),
  onPrimaryContainer: Color(0xFF00174B),
  secondary: Color(0xFF595E72),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFDDE1F9),
  onSecondaryContainer: Color(0xFF161B2C),
  tertiary: Color(0xFF745470),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFFFD6F8),
  onTertiaryContainer: Color(0xFF2B122B),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  background: Color(0xFFFEFBFF),
  onBackground: Color(0xFF1B1B1F),
  surface: Color(0xFFFEFBFF),
  onSurface: Color(0xFF1B1B1F),
  surfaceVariant: Color(0xFFE2E2EC),
  onSurfaceVariant: Color(0xFF45464F),
  outline: Color(0xFF757680),
  onInverseSurface: Color(0xFFF2F0F4),
  inverseSurface: Color(0xFF303034),
  inversePrimary: Color(0xFFB4C5FF),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF0353DA),
  outlineVariant: Color(0xFFC5C6D0),
  scrim: Color(0xFF000000),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFB4C5FF),
  onPrimary: Color(0xFF002A78),
  primaryContainer: Color(0xFF003EA8),
  onPrimaryContainer: Color(0xFFDBE1FF),
  secondary: Color(0xFFC1C5DD),
  onSecondary: Color(0xFF2B3042),
  secondaryContainer: Color(0xFF414659),
  onSecondaryContainer: Color(0xFFDDE1F9),
  tertiary: Color(0xFFE2BBDB),
  onTertiary: Color(0xFF422741),
  tertiaryContainer: Color(0xFF5A3D58),
  onTertiaryContainer: Color(0xFFFFD6F8),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  background: Color(0xFF1B1B1F),
  onBackground: Color(0xFFE4E2E6),
  surface: Color(0xFF1B1B1F),
  onSurface: Color(0xFFE4E2E6),
  surfaceVariant: Color(0xFF45464F),
  onSurfaceVariant: Color(0xFFC5C6D0),
  outline: Color(0xFF8F909A),
  onInverseSurface: Color(0xFF1B1B1F),
  inverseSurface: Color(0xFFE4E2E6),
  inversePrimary: Color(0xFF0353DA),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFFB4C5FF),
  outlineVariant: Color(0xFF45464F),
  scrim: Color(0xFF000000),
);

final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: lightColorScheme,
);

final darkTheme = ThemeData(
  colorScheme: darkColorScheme,
  useMaterial3: true
);
