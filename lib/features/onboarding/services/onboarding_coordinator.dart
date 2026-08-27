import 'package:b21pdf/features/notifications/services/notification_service.dart';
import 'package:b21pdf/core/navigation/app_routes.dart';
import 'package:b21pdf/core/navigation/app_navigator.dart';
import 'package:b21pdf/core/storage/preferences/locale_selected.dart';
import 'package:b21pdf/features/settings/language/presentation/language_selection_controller.dart';
import 'package:b21pdf/features/notifications/presentation/permission/notification_permission_controller.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class OnboardingCoordinator {
  static final OnboardingCoordinator _instance = OnboardingCoordinator();
  static OnboardingCoordinator get instance => _instance;

  //语言选择页没有点确定----启动app：悬浮窗->语言选择页->通知->首页
  //语言选择页点确定----启动app：悬浮窗->通知->首页
  //这个包测试一下没有悬浮窗的
  // toPageAfterLauncher()async{
  //   var checkOverlayPermission = await FlutterLocalNotificationPlugins.instance.checkOverlayPermission();
  //   if(!checkOverlayPermission){
  //     AppNavigator.replaceNamed<void>(
  //       routeName:
  //       AppRoutes.overlayPermissionRoute,
  //     );
  //     return;
  //   }
  //   toPageAfterOverlay();
  // }

  //语言选择页没有点确定----启动app：语言选择页->通知->首页
  //语言选择页点确定----启动app：通知->首页
  openLanguageSelection() {
    if (LocaleSelected.readLanguage().isEmpty) {
      // AppNavigator.replaceNamed<void>(
      //   routeName:
      //   AppRoutes.chooseLanguageRoute,
      // );
      if (Get.isRegistered<LanguageSelectionController>()) {
        AppNavigator.popUntilRoute(AppRoutes.chooseLanguageRoute);
      } else {
        AppNavigator.replaceNamed<void>(
          routeName: AppRoutes.chooseLanguageRoute,
        );
      }
      return;
    }
    toPageOpenNotificationPermission();
  }

  toPageOpenNotificationPermission() async {
    var result = await NotificationService.instance.hasNotificationPermission();
    if (!result) {
      // AppNavigator.replaceNamed<void>(
      //   routeName:
      //   AppRoutes.notificationRoute,
      // );
      if (Get.isRegistered<NotificationPermissionController>()) {
        AppNavigator.popUntilRoute(AppRoutes.notificationRoute);
      } else {
        AppNavigator.replaceNamed<void>(routeName: AppRoutes.notificationRoute);
      }
      return;
    }
    openHome();
  }

  openHome() {
    AppNavigator.replaceNamed<void>(routeName: AppRoutes.homeRoute);
  }
}
