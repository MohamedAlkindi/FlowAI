import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/app_cubit.dart';
import '../cubits/app_states.dart';
import '../l10n/l10n.dart';
import 'home_screen/home_screen.dart';
import 'welcome_screen/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final cubit = context.read<AppCubit>();
    await cubit.loadPreferences();
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    final state = cubit.state;
    final showWelcome = state is AppLoaded
        ? state.preferences.isFirstLaunch
        : true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            showWelcome ? const WelcomeScreen() : const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/app_icons/app_icon.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 15),
            Text(
              t.t('ai_tagline'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE94560)),
            ),
          ],
        ),
      ),
    );
  }
}
