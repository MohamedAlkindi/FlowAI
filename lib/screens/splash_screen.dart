import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/app_cubit.dart';
import '../cubits/app_states.dart';
import 'welcome_screen.dart';
import 'home_screen.dart';
import '../l10n/l10n.dart';

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
    final showWelcome =
        state is AppLoaded ? state.preferences.isFirstLaunch : true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (_) =>
              showWelcome ? const WelcomeScreen() : const HomeScreen()),
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
              'AppIcons/app_icon.png',
              width: 120,
              height: 120,
            ),

            // Container(
            //   width: 120,
            //   height: 120,
            //   decoration: BoxDecoration(
            //     color: const Color(0xFF16213E),
            //     borderRadius: BorderRadius.circular(30),
            //     boxShadow: [
            //       BoxShadow(
            //         color: const Color(0xFF0F3460).withValues(alpha: 0.3),
            //         blurRadius: 20,
            //         offset: const Offset(0, 10),
            //       ),
            //     ],
            //   ),
            //   child: const Icon(
            //     Icons.auto_awesome,
            //     size: 60,
            //     color: Color(0xFFE94560),
            //   ),
            // ),
            // const SizedBox(height: 30),
            // Text(
            //   t.t('app_title'),
            //   style: GoogleFonts.poppins(
            //     fontSize: 32,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.white,
            //     letterSpacing: 1.2,
            //   ),
            // ),
            const SizedBox(height: 10),
            Text(
              t.t('ai_tagline'),
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[400],
                letterSpacing: 0.5,
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
