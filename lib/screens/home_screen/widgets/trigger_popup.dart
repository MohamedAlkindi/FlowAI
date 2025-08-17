import 'package:flow_ai/cubits/app_cubit.dart';
import 'package:flow_ai/utils/show_snackbar.dart';
import 'package:flow_ai/utils/trigger_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TriggerPopup extends StatefulWidget {
  final String currentStart;
  final String currentEnd;
  final AppCubit cubit;

  const TriggerPopup({
    super.key,
    required this.currentStart,
    required this.currentEnd,
    required this.cubit,
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
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E),
      title: Center(
        child: const Text(
          "Set Custom Trigger",
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
            "Current: ${widget.currentStart} text ${widget.currentEnd}",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _startController,
            decoration: const InputDecoration(
              fillColor: Colors.white,
              labelText: "Start Trigger",
              floatingLabelBehavior: FloatingLabelBehavior.never,
              hintText: "/ai",
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            maxLength: 1,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            controller: _endController,
            decoration: const InputDecoration(
              fillColor: Colors.white,
              labelText: "End Trigger",
              floatingLabelBehavior: FloatingLabelBehavior.never,
              hintText: "/",
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(const Color(0xFF1A1A2E)),
          ),
          onPressed: () async {
            final start = _startController.text.trim();
            final end = _endController.text.trim();
            await TriggerUtil.setTriggers(
              startTrigger: start.isNotEmpty ? start : null,
              endTrigger: end.isNotEmpty ? end : null,
            );

            widget.cubit.saveUserTriggers(start, end);
            showSnackBar(
              "Done!",
              context: context,
            );
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
