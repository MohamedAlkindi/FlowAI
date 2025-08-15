import 'package:flow_ai/l10n/localizations/localizations_delegates.dart';
import 'package:flow_ai/l10n/localizations/supported_locales.dart';
import 'package:flow_ai/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubits/app_cubit.dart';
import 'screens/splash_screen.dart';
import 'package:flow_ai/supabase_initialize.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubit(),
      child: MaterialApp(
        title: 'FlowAI',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: localizationsDelegates,
        supportedLocales: supportedLocales,
        theme: ThemeData(
          primarySwatch: Colors.red,
          scaffoldBackgroundColor: const Color(0xFF1A1A2E),
          appBarTheme: appbarTheme(),
          elevatedButtonTheme: elevatedButtonThemeData(),
          textButtonTheme: textButtonThemeData(),
          inputDecorationTheme: inputDecorationTheme(),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
