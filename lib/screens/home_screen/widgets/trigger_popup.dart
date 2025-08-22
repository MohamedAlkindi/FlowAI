import 'package:flow_ai/cubits/app_cubit.dart';
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
        alignment: Alignment.centerLeft,
        child: Text(
          t.t("setCustomTrigger"),
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
            Text(
              "${t.t("currentSettings")}: ${widget.currentStart} ${t.t("text")} ${widget.currentEnd}",
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _startController,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
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
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
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
              child: Text(
                t.t("cancel"),
                style: const TextStyle(fontSize: 15),
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all(const Color(0xFF1A1A2E)),
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
                homeScreenCubit.prefixTrigger =
                    start.isNotEmpty ? start : widget.currentStart;
                homeScreenCubit.suffixTrigger =
                    end.isNotEmpty ? end : widget.currentEnd;

                if (context.mounted) {
                  showSnackBar(
                    t.t("done"),
                    context: context,
                  );
                  Navigator.pop(context);
                }
              },
              child: Text(
                t.t("save"),
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
