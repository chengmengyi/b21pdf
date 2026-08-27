import 'package:b21pdf/core/navigation/app_navigator.dart';
import 'package:b21pdf/core/presentation/controller_lease.dart';
import 'package:b21pdf/core/presentation/base_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class BaseScreen<T extends BaseController> extends StatefulWidget {
  const BaseScreen({super.key});

  String? get controllerTag => null;

  bool get permanentController => false;

  bool get resizeToAvoidBottomInset => true;

  bool get useSafeBottom => true;

  Future<bool> canPopRoute(T controller) async {
    AppNavigator.backWithExitAd<void>();
    return false;
  }

  Color get backgroundColor => Colors.white;

  Color get navigationBarColor => Colors.white;

  SystemUiOverlayStyle get systemUiOverlayStyle => SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarDividerColor: Colors.transparent,
  );

  T createController();

  Widget buildContent(BuildContext context, T controller);

  @override
  State<BaseScreen<T>> createState() => _BasePageState<T>();
}

class _BasePageState<T extends BaseController> extends State<BaseScreen<T>> {
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: widget.systemUiOverlayStyle,
      child: WillPopScope(
        onWillPop: () async {
          return widget.canPopRoute(controllerLease.controller);
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            backgroundColor: widget.backgroundColor,
            resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
            body: SafeArea(
              top: false,
              bottom: widget.useSafeBottom,
              child: widget.buildContent(context, controllerLease.controller),
            ),
          ),
        ),
      ),
    );
  }
}
