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
      title: Center(
        child: Text(
          t.t("setCustomTrigger"),
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "${t.t("currentSettings")}: ${widget.currentStart} ${t.t("text")} ${widget.currentEnd}",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _startController,
            decoration: InputDecoration(
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
            decoration: InputDecoration(
              fillColor: Colors.white,
              labelText: t.t("endTrigger"),
              floatingLabelBehavior: FloatingLabelBehavior.never,
              hintText: "/",
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.t("cancel")),
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(const Color(0xFF1A1A2E)),
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

            showSnackBar(
              t.t("done"),
              context: context,
            );
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(t.t("save")),
        ),
      ],
    );
  }
}
