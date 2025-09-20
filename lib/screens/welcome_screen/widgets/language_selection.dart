import 'package:flow_ai/cubits/app_cubit.dart';
import 'package:flow_ai/cubits/app_states.dart';
import 'package:flow_ai/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class LanguageSelection extends StatelessWidget {
  const LanguageSelection({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text(
            '🌐',
            style: const TextStyle(fontSize: 80),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            t.t('choose_language_title'),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          BlocBuilder<AppCubit, AppState>(
            builder: (context, state) {
              String? selected = state is AppLoaded
                  ? state.preferences.localeCode
                  : null;
              selected ??= Localizations.localeOf(context).languageCode;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF22223A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selected,
                    dropdownColor: const Color(0xFF22223A),
                    iconEnabledColor: Colors.white,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'en',
                        child: Text(t.t('language_english')),
                      ),
                      DropdownMenuItem(
                        value: 'ar',
                        child: Text(t.t('language_arabic')),
                      ),
                    ],
                    onChanged: (val) {
                      context.read<AppCubit>().setLocale(val);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
