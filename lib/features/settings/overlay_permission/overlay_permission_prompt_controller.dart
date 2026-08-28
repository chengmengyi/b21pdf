import 'dart:async';

import 'package:b21pdf/core/analytics/analytics_event.dart';
import 'package:b21pdf/core/analytics/analytics_service.dart';
import 'package:b21pdf/core/navigation/app_navigator.dart';
import 'package:b21pdf/core/overlay/overlay_service.dart';
import 'package:b21pdf/core/presentation/base_controller.dart';
import 'package:get/get.dart';

class OverlayPermissionPromptController extends BaseController {
  OverlayPermissionPromptController({
    required this.onSettingsComplete,
    required this.onLater,
  });

  final FutureOr<void> Function() onSettingsComplete;
  final FutureOr<void> Function() onLater;
  bool _handlingAction = false;

  @override
  void onInit() {
    super.onInit();
    AnalyticsService.instance.trackEvent(
      pointType: AnalyticsEvent.float_pop_view,
    );
  }

  Future<void> openSettings() async {
    if (_handlingAction) return;
    _handlingAction = true;
    AnalyticsService.instance.trackEvent(
      pointType: AnalyticsEvent.float_pop_click,
      parameters: <String, dynamic>{'button': 'open'},
    );
    await OverlayService.instance.requestOverlayPermission();
    _closePrompt();
    await Future<void>.sync(onSettingsComplete);
  }

  Future<void> continueWithoutPermission() async {
    if (_handlingAction) return;
    _handlingAction = true;
    AnalyticsService.instance.trackEvent(
      pointType: AnalyticsEvent.float_pop_click,
      parameters: <String, dynamic>{'button': 'later'},
    );
    _closePrompt();
    await Future<void>.sync(onLater);
  }

  void _closePrompt() {
    if (Get.isBottomSheetOpen == true) {
      AppNavigator.back<void>();
    }
  }
}
