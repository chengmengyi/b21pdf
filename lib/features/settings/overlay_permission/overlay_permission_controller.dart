import 'package:b21pdf/core/config/app_config.dart';
import 'package:b21pdf/features/onboarding/services/onboarding_coordinator.dart';
import 'package:b21pdf/core/navigation/app_routes.dart';
import 'package:b21pdf/core/navigation/app_navigator.dart';
import 'package:b21pdf/core/presentation/base_controller.dart';
import 'package:flutter_boom_notification_plugins/flutter_boom_notification_plugins.dart';
import 'package:get/get.dart';

class OverlayPermissionController extends BaseController {
  bool permissionRequestRunning = false;

  Future<void> onContinuePressed() async {
    if (permissionRequestRunning) {
      return;
    }
    permissionRequestRunning = true;
    try {
      final bool hasPermission = await FlutterBoomNotificationPlugins.instance
          .checkOverlayPermission();
      if (hasPermission) {
        openNotificationPermissionScreen();
        return;
      }
      final bool permissionGranted = await FlutterBoomNotificationPlugins
          .instance
          .requestOverlayPermission(
            title: 'Almost there! Unlock your full potential'.tr,
            desc: 'Find {n} below and toggle the switch to ON.'.tr,
            overlayPermissionGuideLayout: 'overlay_layout',
          );
      if (permissionGranted) {
        openNotificationPermissionScreen();
      }
    } finally {
      permissionRequestRunning = false;
    }
  }

  void onLaterPressed() {
    openNotificationPermissionScreen();
  }

  void openNotificationPermissionScreen() {
    OnboardingCoordinator.instance.openLanguageSelection();
  }
}
