import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextTheme textThemeDefault = TextTheme(
  displayLarge:
      GoogleFonts.notoNaskhArabic(fontSize: 126, fontWeight: FontWeight.w300),
  displayMedium:
      GoogleFonts.notoNaskhArabic(fontSize: 79, fontWeight: FontWeight.w300),
  displaySmall:
      GoogleFonts.notoNaskhArabic(fontSize: 63, fontWeight: FontWeight.w400),
  headlineMedium:
      GoogleFonts.notoNaskhArabic(fontSize: 45, fontWeight: FontWeight.w400),
  headlineSmall:
      GoogleFonts.notoNaskhArabic(fontSize: 32, fontWeight: FontWeight.w400),
  titleLarge:
      GoogleFonts.notoNaskhArabic(fontSize: 26, fontWeight: FontWeight.w500),
  titleMedium:
      GoogleFonts.notoNaskhArabic(fontSize: 21, fontWeight: FontWeight.w400),
  titleSmall:
      GoogleFonts.notoNaskhArabic(fontSize: 18, fontWeight: FontWeight.w500),
  bodyLarge:
      GoogleFonts.ibmPlexSansArabic(fontSize: 17, fontWeight: FontWeight.w400),
  bodyMedium:
      GoogleFonts.ibmPlexSansArabic(fontSize: 15, fontWeight: FontWeight.w400),
  labelLarge:
      GoogleFonts.ibmPlexSansArabic(fontSize: 15, fontWeight: FontWeight.w500),
  bodySmall:
      GoogleFonts.ibmPlexSansArabic(fontSize: 12, fontWeight: FontWeight.w400),
  labelSmall:
      GoogleFonts.ibmPlexSansArabic(fontSize: 10, fontWeight: FontWeight.w400),
);

const defaultLightColorScheme = ColorScheme(
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

const defaultDarkColorScheme = ColorScheme(
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
