import 'package:app_settings/app_settings.dart';
import 'package:b21pdf/core/ads/ad_service.dart';
import 'package:b21pdf/core/ads/ad_scene.dart';
import 'package:b21pdf/core/ads/ad_placement.dart';
import 'package:b21pdf/core/user/user_eligibility_service.dart';
import 'package:b21pdf/features/onboarding/services/onboarding_coordinator.dart';
import 'package:b21pdf/core/navigation/app_routes.dart';
import 'package:b21pdf/core/navigation/app_navigator.dart';
import 'package:b21pdf/features/library/presentation/home/home_controller.dart';
import 'package:b21pdf/core/presentation/base_controller.dart';
import 'package:get/get.dart';

class UpdateController extends BaseController {
  void onContinueUsingPressed() {
    _returnToApp();
  }

  Future<void> onLeaveAnywayPressed() async {
    if (UserEligibilityService.instance.isEligibleUser) {
      await AdService.instance.showCachedAd(
        adScene: AdScene.pr_exit,
        adPosId: AdPlacement.unload_2,
        adHostContext: Get.context,
      );
    }
    _returnToApp();
    await AppSettings.openAppSettings();
  }

  void _returnToApp() {
    if (Get.isRegistered<HomeController>()) {
      AppNavigator.popUntilRoute(AppRoutes.homeRoute);
      return;
    }
    OnboardingCoordinator.instance.openOverlaySelection();
  }
}
