import 'package:flow_ai/cubits/app_cubit.dart';
import 'package:flow_ai/cubits/app_states.dart';
import 'package:flow_ai/l10n/l10n.dart';
import 'package:flow_ai/screens/home_screen/cubit/home_screen_cubit.dart';
import 'package:flow_ai/utils/show_snackbar.dart';
import 'package:flow_ai/utils/trigger_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TriggerPopup extends StatefulWidget {
  final String currentStart;
  final String currentEnd;

  const TriggerPopup({
    super.key,
    required this.currentStart,
    required this.currentEnd,
  });
  @override
  State<TriggerPopup> createState() => _TriggerPopupState();
}

class _TriggerPopupState extends State<TriggerPopup> {
  late TextEditingController _startController;
  late TextEditingController _endController;
  @override
  void initState() {
    super.initState();
    _startController = TextEditingController();
    _endController = TextEditingController();
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    var appCubit = context.read<AppCubit>();
    var homeScreenCubit = context.read<HomeScreenCubit>();
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E),
      title: Align(
        alignment: Alignment.center,
        child: Text(
          t.t("settings_title"),
          style: const TextStyle(
            fontSize: 22, // Slightly larger
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Language selection (same idea as welcome screen)
            Text(
              t.t('choose_language_title'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            BlocBuilder<AppCubit, AppState>(
              builder: (context, state) {
                String? selected = state is AppLoaded
                    ? state.preferences.localeCode
                    : null;
                selected ??= Localizations.localeOf(context).languageCode;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22223A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[700]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selected,
                      dropdownColor: const Color(0xFF22223A),
                      iconEnabledColor: Colors.white,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
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
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 10),
            Text(
              "${t.t("currentSettings")}: ${widget.currentStart} ${t.t("text")} ${widget.currentEnd}",
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _startController,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                fillColor: Colors.white,
                labelText: t.t("startTrigger"),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                hintText: "/ai",
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              maxLength: 1,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              controller: _endController,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                fillColor: Colors.white,
                labelText: t.t("endTrigger"),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                hintText: "/",
              ),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t.t("cancel"), style: const TextStyle(fontSize: 15)),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  const Color(0xFF1A1A2E),
                ),
              ),
              onPressed: () async {
                final start = _startController.text.trim();
                final end = _endController.text.trim();
                await TriggerUtil.setTriggers(
                  startTrigger: start.isNotEmpty ? start : null,
                  endTrigger: end.isNotEmpty ? end : null,
                );
                // Save the new triggers in the app state
                appCubit.saveUserTriggers(start, end);

                // Update the HomeScreenCubit with the new triggers
                homeScreenCubit.prefixTrigger = start.isNotEmpty
                    ? start
                    : widget.currentStart;
                homeScreenCubit.suffixTrigger = end.isNotEmpty
                    ? end
                    : widget.currentEnd;

                if (context.mounted) {
                  showSnackBar(t.t("done"), context: context);
                  Navigator.pop(context);
                }
              },
              child: Text(
                t.t("save"),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
