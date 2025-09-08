import 'package:flow_ai/cubits/app_cubit.dart';
import 'package:flow_ai/cubits/app_states.dart';
import 'package:flow_ai/l10n/localizations/localizations_delegates.dart';
import 'package:flow_ai/l10n/localizations/supported_locales.dart';
import 'package:flow_ai/screens/home_screen/cubit/home_screen_cubit.dart';
import 'package:flow_ai/supabase_initialize.dart';
import 'package:flow_ai/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AppCubit()),
        BlocProvider(create: (context) => HomeScreenCubit()),
      ],
      child: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          Locale? locale;
          if (state is AppLoaded && state.preferences.localeCode != null) {
            locale = Locale(state.preferences.localeCode!);
          }
          return MaterialApp(
            title: 'FlowAI',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: localizationsDelegates,
            supportedLocales: supportedLocales,
            localeResolutionCallback: (deviceLocale, supported) {
              // If a saved locale is set, use it (handled by locale property).
              if (locale != null) return locale;

              // No saved locale: decide from device locale.
              final deviceCode = deviceLocale?.languageCode;
              if (deviceCode == 'en' || deviceCode == 'ar') {
                // Match device en/ar exactly from supported list
                return supported.firstWhere(
                  (l) => l.languageCode == deviceCode,
                  orElse: () => const Locale('en'),
                );
              }

              // Device language is neither en nor ar → fallback to English
              return const Locale('en');
            },
            locale: locale,
            theme: ThemeData(
              primarySwatch: Colors.red,
              scaffoldBackgroundColor: const Color(0xFF1A1A2E),
              appBarTheme: appbarTheme(),
              elevatedButtonTheme: elevatedButtonThemeData(),
              textButtonTheme: textButtonThemeData(),
              inputDecorationTheme: inputDecorationTheme(),
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
