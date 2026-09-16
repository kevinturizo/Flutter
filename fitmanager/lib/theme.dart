import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FitManagerPalette {
  const FitManagerPalette({
    required this.bg,
    required this.surface,
    required this.card,
    required this.border,
    required this.accent,
    required this.accentDark,
    required this.accentBg,
    required this.gold,
    required this.text,
    required this.textSub,
    required this.textDim,
    required this.green,
    required this.greenBg,
    required this.red,
    required this.yellow,
    required this.sidebar,
    required this.button,
    required this.buttonText,
  });

  final Color bg;
  final Color surface;
  final Color card;
  final Color border;
  final Color accent;
  final Color accentDark;
  final Color accentBg;
  final Color gold;
  final Color text;
  final Color textSub;
  final Color textDim;
  final Color green;
  final Color greenBg;
  final Color red;
  final Color yellow;
  final Color sidebar;
  final Color button;
  final Color buttonText;
}

const fitManagerDarkPalette = FitManagerPalette(
  bg: Color(0xFF1C1D21),
  surface: Color(0xFF24252A),
  card: Color(0xFF2C2D33),
  border: Color(0xFF3A3B42),
  accent: Color(0xFFC92F35),
  accentDark: Color(0xFF8F1F24),
  accentBg: Color(0xFF351B1E),
  gold: Color(0xFFD4AF37),
  text: Color(0xFFECECED),
  textSub: Color(0xFFA3A4AC),
  textDim: Color(0xFF696A72),
  green: Color(0xFF22C55E),
  greenBg: Color(0xFF193825),
  red: Color(0xFFEF4444),
  yellow: Color(0xFFFBBF24),
  sidebar: Color(0xFF202126),
  button: Color(0xFF34353C),
  buttonText: Color(0xFFF2F2F2),
);

const fitManagerLightPalette = FitManagerPalette(
  bg: Color(0xFFE7E7EA),
  surface: Color(0xFFF4F4F6),
  card: Color(0xFFFFFFFF),
  border: Color(0xFFD7D7DB),
  accent: Color(0xFFC92F35),
  accentDark: Color(0xFF8F1F24),
  accentBg: Color(0xFFFFEAEC),
  gold: Color(0xFF9A6A12),
  text: Color(0xFF212226),
  textSub: Color(0xFF5C5D64),
  textDim: Color(0xFF8B8C92),
  green: Color(0xFF168A43),
  greenBg: Color(0xFFE3F5E9),
  red: Color(0xFFA52329),
  yellow: Color(0xFFB7791F),
  sidebar: Color(0xFFF4F4F6),
  button: Color(0xFFFFFFFF),
  buttonText: Color(0xFF212226),
);

class FitManagerThemeController {
  static const _prefKey = 'fitmanager_theme_mode';
  static final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.dark);

  static FitManagerPalette get palette =>
      mode.value == ThemeMode.light ? fitManagerLightPalette : fitManagerDarkPalette;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    mode.value = prefs.getString(_prefKey) == 'light' ? ThemeMode.light : ThemeMode.dark;
  }

  static Future<void> toggle() async {
    mode.value = mode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, mode.value == ThemeMode.light ? 'light' : 'dark');
  }
}

Color get kBg => FitManagerThemeController.palette.bg;
Color get kSurface => FitManagerThemeController.palette.surface;
Color get kCard => FitManagerThemeController.palette.card;
Color get kBorder => FitManagerThemeController.palette.border;
Color get kAccent => FitManagerThemeController.palette.accent;
Color get kAccentDark => FitManagerThemeController.palette.accentDark;
Color get kAccentBg => FitManagerThemeController.palette.accentBg;
Color get kGold => FitManagerThemeController.palette.gold;
Color get kText => FitManagerThemeController.palette.text;
Color get kTextSub => FitManagerThemeController.palette.textSub;
Color get kTextDim => FitManagerThemeController.palette.textDim;
Color get kGreen => FitManagerThemeController.palette.green;
Color get kGreenBg => FitManagerThemeController.palette.greenBg;
Color get kRed => FitManagerThemeController.palette.red;
Color get kYellow => FitManagerThemeController.palette.yellow;
Color get kSidebar => FitManagerThemeController.palette.sidebar;
Color get kButton => FitManagerThemeController.palette.button;
Color get kButtonText => FitManagerThemeController.palette.buttonText;

ThemeData fitManagerTheme(FitManagerPalette palette, Brightness brightness) {
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: palette.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: palette.accent,
      brightness: brightness,
      primary: palette.accent,
      surface: palette.surface,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: palette.sidebar,
      foregroundColor: palette.text,
      elevation: 0,
      iconTheme: IconThemeData(color: palette.textSub),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.card,
      labelStyle: TextStyle(color: palette.textSub),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: palette.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: palette.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: palette.accent, width: 1.8),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: palette.accent,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: palette.text,
        side: BorderSide(color: palette.border),
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: palette.accent),
    ),
    dividerTheme: DividerThemeData(color: palette.border, thickness: 1),
    cardTheme: CardThemeData(
      color: palette.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: palette.border),
      ),
    ),
  );
}
