import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/parcel_feed/presentation/screens/parcel_feed_screen.dart';
import 'core/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: AppTextStyles.fontFamily,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.light(
          primary: AppColors.cyan,
          secondary: AppColors.cyanAccent,
          surface: AppColors.white,
          onPrimary: AppColors.white,
          onSecondary: AppColors.cyanDark,
          onSurface: AppColors.textPrimary,
        ),
        textTheme: const TextTheme(
          displayLarge: AppTextStyles.heading1,
          displayMedium: AppTextStyles.heading2,
          displaySmall: AppTextStyles.heading3,
          headlineMedium: AppTextStyles.trackingCode,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
          labelLarge: AppTextStyles.labelLarge,
          labelMedium: AppTextStyles.labelMedium,
          titleLarge: AppTextStyles.summaryNumber,
          titleMedium: AppTextStyles.summaryLabel,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.cyan),
          titleTextStyle: AppTextStyles.heading2,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.cyan,
          foregroundColor: AppColors.white,
        ),
      ),
      home: const ParcelFeedScreen(),
    );
  }
}
