import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

const textThemeDefault = TextTheme(
  displayLarge: TextStyle(
    fontFamily: "ibmPlexSansArabic",
    fontSize: 100,
    fontWeight: FontWeight.w300,
  ),
  displayMedium: TextStyle(
    fontFamily: "ibmPlexSansArabic",
    fontSize: 62,
    fontWeight: FontWeight.w300,
  ),
  displaySmall: TextStyle(
      fontFamily: "ibmPlexSansArabic",
      fontSize: 50,
      fontWeight: FontWeight.w400),
  headlineMedium: TextStyle(
    fontFamily: "ibmPlexSansArabic",
    fontSize: 35,
    fontWeight: FontWeight.w400,
  ),
  headlineSmall: TextStyle(
      fontFamily: "ibmPlexSansArabic",
      fontSize: 25,
      fontWeight: FontWeight.w400),
  titleLarge: TextStyle(
    fontFamily: "ibmPlexSansArabic",
    fontSize: 21,
    fontWeight: FontWeight.w500,
  ),
  titleMedium: TextStyle(
    fontFamily: "ibmPlexSansArabic",
    fontSize: 17,
    fontWeight: FontWeight.w400,
  ),
  titleSmall: TextStyle(
    fontFamily: "ibmPlexSansArabic",
    fontSize: 15,
    fontWeight: FontWeight.w500,
  ),
  bodyLarge: TextStyle(
    fontFamily: "NotoNaskhArabic",
    fontSize: 16,
    fontWeight: FontWeight.w400,
  ),
  bodyMedium: TextStyle(
    fontFamily: "NotoNaskhArabic",
    fontSize: 14,
    fontWeight: FontWeight.w400,
  ),
  labelLarge: TextStyle(
    fontFamily: "NotoNaskhArabic",
    fontSize: 14,
    fontWeight: FontWeight.w500,
  ),
  bodySmall: TextStyle(
    fontFamily: "NotoNaskhArabic",
    fontSize: 12,
    fontWeight: FontWeight.w400,
  ),
  labelSmall: TextStyle(
    fontFamily: "NotoNaskhArabic",
    fontSize: 10,
    fontWeight: FontWeight.w400,
  ),
);

// Default (Grey)

const greyLightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF000000),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFF000000),
  onPrimaryContainer: Color(0xFFFFFFFF),
  secondary: Color(0xFF8A8B8B),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFCFE6F2),
  onSecondaryContainer: Color(0xFF081E26),
  tertiary: Color(0xFFBBE9FF),
  onTertiary: Color(0xFF001F29),
  // tertiary: Color(0xFFBBBDBD),
  // onTertiary: Color(0xFF000000),
  tertiaryContainer: Color(0xFFBBBDBD),
  onTertiaryContainer: Color(0xFF001F29),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  background: Color(0xFFFBFCFE),
  onBackground: Color(0xFF191C1E),
  surface: Color(0xFFFBFCFE),
  onSurface: Color(0xFF191C1E),
  surfaceVariant: Color(0xFFDCE4E9),
  onSurfaceVariant: Color(0xFF40484C),
  outline: Color(0xFF70787D),
  onInverseSurface: Color(0xFFEFF1F3),
  inverseSurface: Color(0xFF2E3132),
  inversePrimary: Color(0xFF0D1E24),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF4B4B4B),
  outlineVariant: Color(0xFFC0C8CC),
  scrim: Color(0xFF000000),
);

const greyDarkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFFFFFFF),
  onPrimary: Color(0xFF000000),
  primaryContainer: Color(0xFFEEE9E2),
  onPrimaryContainer: Color(0xFF000000),
  secondary: Color(0xFFFFFFFF),
  onSecondary: Color(0xFF8A8B8B),
  secondaryContainer: Color(0xFF081E26),
  onSecondaryContainer: Color(0xFFCFE6F2),
  tertiary: Color(0xFF001F29),
  onTertiary: Color(0xFFBBE9FF),
  // tertiary: Color(0xFFBBBDBD),
  // onTertiary: Color(0xFF000000),
  tertiaryContainer: Color(0xFF001F29),
  onTertiaryContainer: Color(0xFFBAEAFF),
  error: Color(0xFFFFDAD6),
  errorContainer: Color(0xFFBA1A1A),
  onError: Color(0xFF410002),
  onErrorContainer: Color(0xFFFFFFFF),
  background: Color(0xFF191C1E),
  onBackground: Color(0xFFFBFCFE),
  surface: Color(0xFF191C1E),
  onSurface: Color(0xFFFBFCFE),
  surfaceVariant: Color(0xFF40484C),
  onSurfaceVariant: Color(0xFFDCE4E9),
  outline: Color(0xFF8A9296),
  onInverseSurface: Color(0xFF191C1E),
  inverseSurface: Color(0xFFE1E3E4),
  inversePrimary: Color(0xFF006782),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFFD3D3D3),
  outlineVariant: Color(0xFF40484C),
  scrim: Color(0xFF000000),
);

// Green

const greenLightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF006D36),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFF93F8AD),
  onPrimaryContainer: Color(0xFF00210C),
  secondary: Color(0xFF506352),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFD3E8D3),
  onSecondaryContainer: Color(0xFF0E1F12),
  tertiary: Color(0xFF006A60),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFF74F8E5),
  onTertiaryContainer: Color(0xFF00201C),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  background: Color(0xFFFCFDF7),
  onBackground: Color(0xFF191C19),
  surface: Color(0xFFFCFDF7),
  onSurface: Color(0xFF191C19),
  surfaceVariant: Color(0xFFDDE5DA),
  onSurfaceVariant: Color(0xFF414941),
  outline: Color(0xFF717971),
  onInverseSurface: Color(0xFFF0F1EC),
  inverseSurface: Color(0xFF2E312E),
  inversePrimary: Color(0xFF77DB93),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF006D36),
  outlineVariant: Color(0xFFC1C9BF),
  scrim: Color(0xFF000000),
);

const greenDarkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF77DB93),
  onPrimary: Color(0xFF003919),
  primaryContainer: Color(0xFF005227),
  onPrimaryContainer: Color(0xFF93F8AD),
  secondary: Color(0xFFB7CCB7),
  onSecondary: Color(0xFF233426),
  secondaryContainer: Color(0xFF394B3B),
  onSecondaryContainer: Color(0xFFD3E8D3),
  tertiary: Color(0xFF53DBC9),
  onTertiary: Color(0xFF003731),
  tertiaryContainer: Color(0xFF005048),
  onTertiaryContainer: Color(0xFF74F8E5),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  background: Color(0xFF191C19),
  onBackground: Color(0xFFE2E3DE),
  surface: Color(0xFF191C19),
  onSurface: Color(0xFFE2E3DE),
  surfaceVariant: Color(0xFF414941),
  onSurfaceVariant: Color(0xFFC1C9BF),
  outline: Color(0xFF8B938A),
  onInverseSurface: Color(0xFF191C19),
  inverseSurface: Color(0xFFE2E3DE),
  inversePrimary: Color(0xFF006D36),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF77DB93),
  outlineVariant: Color(0xFF414941),
  scrim: Color(0xFF000000),
);

// Blue

const blueLightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF006782),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFBBE9FF),
  onPrimaryContainer: Color(0xFF001F29),
  secondary: Color(0xFF4C616B),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFCFE6F2),
  onSecondaryContainer: Color(0xFF081E26),
  tertiary: Color(0xFF006782),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFBAEAFF),
  onTertiaryContainer: Color(0xFF001F29),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  background: Color(0xFFFBFCFE),
  onBackground: Color(0xFF191C1E),
  surface: Color(0xFFFBFCFE),
  onSurface: Color(0xFF191C1E),
  surfaceVariant: Color(0xFFDCE4E9),
  onSurfaceVariant: Color(0xFF40484C),
  outline: Color(0xFF70787D),
  onInverseSurface: Color(0xFFEFF1F3),
  inverseSurface: Color(0xFF2E3132),
  inversePrimary: Color(0xFF61D4FF),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF006782),
  outlineVariant: Color(0xFFC0C8CC),
  scrim: Color(0xFF000000),
);

const blueDarkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF61D4FF),
  onPrimary: Color(0xFF003545),
  primaryContainer: Color(0xFF004D63),
  onPrimaryContainer: Color(0xFFBBE9FF),
  secondary: Color(0xFFB4CAD5),
  onSecondary: Color(0xFF1E333C),
  secondaryContainer: Color(0xFF354A53),
  onSecondaryContainer: Color(0xFFCFE6F2),
  tertiary: Color(0xFF60D4FE),
  onTertiary: Color(0xFF003545),
  tertiaryContainer: Color(0xFF004D62),
  onTertiaryContainer: Color(0xFFBAEAFF),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  background: Color(0xFF191C1E),
  onBackground: Color(0xFFE1E3E4),
  surface: Color(0xFF191C1E),
  onSurface: Color(0xFFE1E3E4),
  surfaceVariant: Color(0xFF40484C),
  onSurfaceVariant: Color(0xFFC0C8CC),
  outline: Color(0xFF8A9296),
  onInverseSurface: Color(0xFF191C1E),
  inverseSurface: Color(0xFFE1E3E4),
  inversePrimary: Color(0xFF006782),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF61D4FF),
  outlineVariant: Color(0xFF40484C),
  scrim: Color(0xFF000000),
);

// Red

const redLightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF984061),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFFFD9E2),
  onPrimaryContainer: Color(0xFF3E001D),
  secondary: Color(0xFF74565F),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFFFD9E2),
  onSecondaryContainer: Color(0xFF2B151C),
  tertiary: Color(0xFF7C5635),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFFFDCC2),
  onTertiaryContainer: Color(0xFF2E1500),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  background: Color(0xFFFFFBFF),
  onBackground: Color(0xFF201A1B),
  surface: Color(0xFFFFFBFF),
  onSurface: Color(0xFF201A1B),
  surfaceVariant: Color(0xFFF2DDE2),
  onSurfaceVariant: Color(0xFF514347),
  outline: Color(0xFF837377),
  onInverseSurface: Color(0xFFFAEEEF),
  inverseSurface: Color(0xFF352F30),
  inversePrimary: Color(0xFFFFB0C8),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF984061),
  outlineVariant: Color(0xFFD5C2C6),
  scrim: Color(0xFF000000),
);

const redDarkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFFFB0C8),
  onPrimary: Color(0xFF5E1133),
  primaryContainer: Color(0xFF7B2949),
  onPrimaryContainer: Color(0xFFFFD9E2),
  secondary: Color(0xFFE2BDC6),
  onSecondary: Color(0xFF422931),
  secondaryContainer: Color(0xFF5A3F47),
  onSecondaryContainer: Color(0xFFFFD9E2),
  tertiary: Color(0xFFEFBD94),
  onTertiary: Color(0xFF48290C),
  tertiaryContainer: Color(0xFF623F20),
  onTertiaryContainer: Color(0xFFFFDCC2),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  background: Color(0xFF201A1B),
  onBackground: Color(0xFFEBE0E1),
  surface: Color(0xFF201A1B),
  onSurface: Color(0xFFEBE0E1),
  surfaceVariant: Color(0xFF514347),
  onSurfaceVariant: Color(0xFFD5C2C6),
  outline: Color(0xFF9E8C90),
  onInverseSurface: Color(0xFF201A1B),
  inverseSurface: Color(0xFFEBE0E1),
  inversePrimary: Color(0xFF984061),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFFFFB0C8),
  outlineVariant: Color(0xFF514347),
  scrim: Color(0xFF000000),
);

// Yellow

const yellowLightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF755B00),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFFFDF90),
  onPrimaryContainer: Color(0xFF241A00),
  secondary: Color(0xFF695D3F),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFF2E1BB),
  onSecondaryContainer: Color(0xFF231B04),
  tertiary: Color(0xFF7B5800),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFFFDEA4),
  onTertiaryContainer: Color(0xFF261900),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  background: Color(0xFFFFFBFF),
  onBackground: Color(0xFF1E1B16),
  surface: Color(0xFFFFFBFF),
  onSurface: Color(0xFF1E1B16),
  surfaceVariant: Color(0xFFECE1CF),
  onSurfaceVariant: Color(0xFF4C4639),
  outline: Color(0xFF7E7667),
  onInverseSurface: Color(0xFFF7F0E7),
  inverseSurface: Color(0xFF33302A),
  inversePrimary: Color(0xFFECC248),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF755B00),
  outlineVariant: Color(0xFFCFC5B4),
  scrim: Color(0xFF000000),
);

const yellowDarkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFECC248),
  onPrimary: Color(0xFF3D2E00),
  primaryContainer: Color(0xFF584400),
  onPrimaryContainer: Color(0xFFFFDF90),
  secondary: Color(0xFFD5C5A0),
  onSecondary: Color(0xFF392F15),
  secondaryContainer: Color(0xFF51462A),
  onSecondaryContainer: Color(0xFFF2E1BB),
  tertiary: Color(0xFFF6BE48),
  onTertiary: Color(0xFF412D00),
  tertiaryContainer: Color(0xFF5D4200),
  onTertiaryContainer: Color(0xFFFFDEA4),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  background: Color(0xFF1E1B16),
  onBackground: Color(0xFFE8E1D9),
  surface: Color(0xFF1E1B16),
  onSurface: Color(0xFFE8E1D9),
  surfaceVariant: Color(0xFF4C4639),
  onSurfaceVariant: Color(0xFFCFC5B4),
  outline: Color(0xFF989080),
  onInverseSurface: Color(0xFF1E1B16),
  inverseSurface: Color(0xFFE8E1D9),
  inversePrimary: Color(0xFF755B00),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFFECC248),
  outlineVariant: Color(0xFF4C4639),
  scrim: Color(0xFF000000),
);
