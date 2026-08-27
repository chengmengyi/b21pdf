import 'dart:async';

import 'package:flutter/material.dart';

class SwitchView extends StatefulWidget {
  const SwitchView({super.key});

  @override
  State<SwitchView> createState() => _SwitchState();
}

class _SwitchState extends State<SwitchView> {
  static const Duration toggleInterval = Duration(milliseconds: 600);

  Timer? toggleTimer;
  bool switchEnabled = false;

  @override
  void initState() {
    super.initState();
    toggleTimer = Timer.periodic(toggleInterval, (Timer timer) {
      if (mounted) {
        setState(() {
          switchEnabled = !switchEnabled;
        });
      }
    });
  }

  @override
  void dispose() {
    toggleTimer?.cancel();
    toggleTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: switchEnabled,
      onChanged: null,
      thumbColor: WidgetStatePropertyAll(
        switchEnabled ? Colors.white : const Color(0xfff5f5f5),
      ),
      trackColor: WidgetStatePropertyAll(
        switchEnabled ? const Color(0xffD12629) : const Color(0xffc8cdd2),
      ),
    );
  }
}
