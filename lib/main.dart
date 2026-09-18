import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/localization/app_localizations.dart';
import 'core/localization/language_cubit.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'firebase_options.dart';
import 'login_scanner.dart';
import 'movie_details_screen.dart';
import 'onboarding/onboarding_screen.dart';
import 'resgister_scanner.dart';
import 'screens/home_screen.dart';
import 'search_results_screen.dart';
import 'search_screen.dart';
import 'up_date_profile/fordot_password_screen.dart';
import 'up_date_profile/up_date_profile_screen.dart';

import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ١. بنهيأ الـ Firebase عشان الـ Auth والـ Firestore يشتغلوا في كل الشاشات
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // لو مفيش يوزر مسجل دخول، بنعمل تسجيل مجهول عشان الـ Firestore يقدر يحفظ السجل والمفضلة من غير مشاكل
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  } catch (e) {
    debugPrint("تنبيه في تهيئة الفايربيس: $e");
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool onboardingCompleted = prefs.getBool("onboarding_completed") ?? false;

  // ٢. غلفنا التطبيق بـ MultiBlocProvider عشان نوفر الـ Cubits المسؤولة عن اللغة والثيم في أي مكان
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<LanguageCubit>(
          create: (context) => LanguageCubit(), // للتحكم في العربي والإنجليزي
        ),
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(), // للتحكم في المظهر الفاتح والداكن
        ),
      ],
      child: MovieApp(onboardingCompleted: onboardingCompleted),
    ),
  );
}

class MovieApp extends StatelessWidget {
  final bool onboardingCompleted;

  const MovieApp({super.key, required this.onboardingCompleted});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, Locale>(
      builder: (context, locale) {
        return BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Movies App',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              locale: locale,
              supportedLocales: const [
                Locale('en'),
                Locale('ar'),
              ],
              localizationsDelegates: const [
                AppLocalizationsDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              initialRoute: SplashScreen.routeName,
              routes: {
                SplashScreen.routeName: (context) => const SplashScreen(),
                OnboardingScreen.routeName: (context) => OnboardingScreen(),
                LoginScaner.routeName: (context) => const LoginScaner(),
                RegisterScaner.routeName: (context) => const RegisterScaner(),
                HomeScreen.routeName: (context) => const HomeScreen(),
                MovieDetailsScreen.routeName: (context) =>
                    const MovieDetailsScreen(),
                SearchScreen.routeName: (context) => const SearchScreen(),
                SearchResultsScreen.routeName: (context) =>
                    const SearchResultsScreen(),
                UpDateProfileScreen.routeName: (context) =>
                    const UpDateProfileScreen(),
                ForgetPasswordScreen.routeName: (context) =>
                    const ForgetPasswordScreen(),
              },
            );
          },
        );
      },
    );
  }
}