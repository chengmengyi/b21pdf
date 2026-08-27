import 'package:b21pdf/core/presentation/controller_lease.dart';
import 'package:b21pdf/core/presentation/base_controller.dart';
import 'package:flutter/material.dart';

abstract class CenterDialog<T extends BaseController> extends StatefulWidget {
  const CenterDialog({super.key});

  String? get controllerTag => null;

  bool get permanentController => false;

  bool get allowBackDismiss => false;

  bool get dismissKeyboard => true;

  EdgeInsets get contentPadding => const EdgeInsets.all(16);

  T createController();

  Widget buildDialog(BuildContext context, T controller);

  @override
  State<CenterDialog<T>> createState() => _CenterPopupState<T>();
}

class _CenterPopupState<T extends BaseController>
    extends State<CenterDialog<T>> {
  static const Duration keyboardMotion = Duration(milliseconds: 180);

  late final ControllerLease<T> controllerLease;

  @override
  void initState() {
    super.initState();
    controllerLease = ControllerLease.acquire<T>(
      createController: widget.createController,
      tag: widget.controllerTag,
      permanent: widget.permanentController,
    );
  }

  @override
  void dispose() {
    controllerLease.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets keyboardInsets = MediaQuery.viewInsetsOf(context);
    return PopScope(
      canPop: widget.allowBackDismiss,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: widget.dismissKeyboard
            ? () => FocusManager.instance.primaryFocus?.unfocus()
            : null,
        child: Material(
          type: MaterialType.transparency,
          child: SafeArea(
            child: Center(
              child: widget.buildDialog(context, controllerLease.controller),
            ),
          ),
        ),
      ),
    );
  }
}
