import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'core/theme/theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/presentation/auth_wrapper.dart';
import 'features/parcel_feed/bloc/parcel_bloc.dart';
import 'features/parcel_feed/bloc/parcel_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()..add(AuthStarted())),
        BlocProvider(create: (_) => ParcelBloc()..add(LoadParcels())),
      ],
      child: MaterialApp(
        title: 'CeylonDash',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: AppTextStyles.fontFamily,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: const ColorScheme.light(
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
        home: const AuthWrapper(),
      ),
    );
  }
}