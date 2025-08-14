import 'package:flow_ai/cubits/app_cubit.dart';
import 'package:flow_ai/l10n/l10n.dart';
import 'package:flow_ai/screens/home_screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildBottomSection({
  required AppLocalizations t,
  required int length,
  required int currentPage,
  required PageController pageController,
  required BuildContext context,
}) {
  return Container(
    padding: const EdgeInsets.all(40.0),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentPage == index
                    ? const Color(0xFFE94560)
                    : Colors.grey[600],
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              if (currentPage < length - 1) {
                pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                completeOnboarding(context, context.mounted);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE94560),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              currentPage < length - 1 ? t.t('next') : t.t('get_started'),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        if (currentPage < length - 1) ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => completeOnboarding(context, context.mounted),
            child: Text(
              t.t('skip'),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

Future<void> completeOnboarding(BuildContext context, bool mounted) async {
  final appCubit = context.read<AppCubit>();
  await appCubit.markFirstLaunchComplete();

  if (!mounted) return;

  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => const HomeScreen()),
  );
}
