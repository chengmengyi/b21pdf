import 'package:b21pdf/core/presentation/controller_lease.dart';
import 'package:b21pdf/core/presentation/base_controller.dart';
import 'package:flutter/material.dart';

abstract class BaseTab extends StatefulWidget {
  const BaseTab({super.key});
}

abstract class BaseSectionState<T extends BaseController, M extends BaseTab>
    extends State<M>
    with AutomaticKeepAliveClientMixin<M> {
  late final ControllerLease<T> controllerLease;

  String? get controllerTag => null;

  bool get permanentController => false;

  bool get keepAlive => true;

  T createController();

  Widget buildContent(BuildContext context, T controller);

  @override
  void initState() {
    super.initState();
    controllerLease = ControllerLease.acquire<T>(
      createController: createController,
      tag: controllerTag,
      permanent: permanentController,
    );
  }

  @override
  void dispose() {
    controllerLease.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return buildContent(context, controllerLease.controller);
  }

  @override
  bool get wantKeepAlive => keepAlive;
}
