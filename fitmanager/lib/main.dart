import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FitManagerThemeController.load();
  runApp(const TaurusGymApp());
}

class TaurusGymApp extends StatelessWidget {
  const TaurusGymApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: FitManagerThemeController.mode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Taurus GYM',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: fitManagerTheme(fitManagerLightPalette, Brightness.light),
          darkTheme: fitManagerTheme(fitManagerDarkPalette, Brightness.dark),
          home: const SplashScreen(next: LoginScreen()),
        );
      },
    );
  }
}
