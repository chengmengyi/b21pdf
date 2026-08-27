import 'package:b21pdf/core/presentation/controller_lease.dart';
import 'package:b21pdf/core/presentation/base_controller.dart';
import 'package:flutter/widgets.dart';

abstract class ControllerWidget<T extends BaseController>
    extends StatefulWidget {
  const ControllerWidget({super.key});

  String? get controllerTag => null;

  bool get permanentController => false;

  T createController();

  Widget buildContent(BuildContext context, T controller);

  @override
  State<ControllerWidget<T>> createState() => _ControllerWidgetState<T>();
}

class _ControllerWidgetState<T extends BaseController>
    extends State<ControllerWidget<T>> {
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
    return widget.buildContent(context, controllerLease.controller);
  }
}
