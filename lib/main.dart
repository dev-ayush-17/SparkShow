import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home/home_screen.dart';
import 'utils/constants.dart';
import 'services/firebase_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase (safe — won't crash if credentials are placeholders yet)
  await FirebaseInitializer.initialize();

  runApp(const FireworksShowcaseApp());
}

class FireworksShowcaseApp extends StatelessWidget {
  const FireworksShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: AppColors.background,
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          ),
          color: AppColors.surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
