import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gymassist/screens/auth/login_screen.dart';
import 'package:gymassist/screens/auth/signup_screen.dart';
import 'package:gymassist/screens/dashboard/home_wrapper.dart';
import 'package:gymassist/screens/trainer/home/trainee_list_screen.dart';
import 'package:gymassist/screens/trainer/profile/trainer_profile.dart';
import 'package:gymassist/splash.dart';
import 'package:gymassist/utils/utils.dart';
import 'routes/app_routes.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const FitbuddyApp());
}

class FitbuddyApp extends StatelessWidget {
  const FitbuddyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fitbuddy',
            theme: ThemeData(
        primaryColor: AppColors.background,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.inputField,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: AppColors.textSecondary),
          prefixIconColor: AppColors.accent,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textSecondary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.background,
          ),
        ),
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.signup: (context) => const SignUpScreen(),
        AppRoutes.homeWrapper: (context) => const HomeWrapper(),
        AppRoutes.trainerProfile: (context) => const TrainerProfileScreen(),
        AppRoutes.traineeList: (context) => const TraineeListScreen(),

      },
    );
  }
}
