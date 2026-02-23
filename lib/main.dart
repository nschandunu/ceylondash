import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added for the bypass
import 'firebase_options.dart';
import 'features/parcel_feed/presentation/screens/parcel_feed_screen.dart';
import 'core/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // --- DEVELOPER BYPASS START ---
  // This automatically logs in the user so you don't need a login screen yet.
  const devEmail = "testmail@example.com";
  const devPassword = "123456";
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: devEmail,
      password: devPassword,
    );
    debugPrint(
      "✅ Firebase Auth: Dev Login Successful! "
      "UID: ${FirebaseAuth.instance.currentUser?.uid}",
    );
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found' || e.code == 'INVALID_LOGIN_CREDENTIALS') {
      // User was deleted from Firebase Auth — recreate it for local dev.
      // IMPORTANT: After this runs, update the `firebaseUid` field in your
      // MongoDB `users` collection to match the new UID printed below.
      try {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: devEmail,
          password: devPassword,
        );
        debugPrint(
          "✅ Firebase Auth: Dev user recreated. "
          "New UID: ${credential.user?.uid}\n"
          "⚠️  Update your MongoDB users document: "
          '{ firebaseUid: "${credential.user?.uid}" }',
        );
      } on FirebaseAuthException catch (createErr) {
        debugPrint("❌ Firebase Auth Create Error: ${createErr.message}");
      }
    } else {
      debugPrint("❌ Firebase Auth Error (${e.code}): ${e.message}");
    }
  } catch (e) {
    debugPrint("❌ General Auth Error: $e");
  }
  // --- DEVELOPER BYPASS END ---

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CeylonDash',
      debugShowCheckedModeBanner: false, // Cleaner look on the emulator
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
      // Since you're logged in now, ParcelFeedScreen should load your data
      home: const ParcelFeedScreen(),
    );
  }
}