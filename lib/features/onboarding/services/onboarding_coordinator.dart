import 'package:b21pdf/features/notifications/services/notification_service.dart';
import 'package:b21pdf/core/navigation/app_routes.dart';
import 'package:b21pdf/core/navigation/app_navigator.dart';
import 'package:b21pdf/core/storage/preferences/locale_selected.dart';
import 'package:b21pdf/features/settings/language/presentation/language_selection_controller.dart';
import 'package:b21pdf/features/notifications/presentation/permission/notification_permission_controller.dart';
import 'package:flutter_boom_notification_plugins/flutter_boom_notification_plugins.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class OnboardingCoordinator {
  static final OnboardingCoordinator _instance = OnboardingCoordinator();
  static OnboardingCoordinator get instance => _instance;

  //语言选择页没有点确定----启动app：悬浮窗->语言选择页->通知->首页
  //语言选择页点确定----启动app：悬浮窗->通知->首页
  openOverlaySelection()async{
    var checkOverlayPermission = await FlutterBoomNotificationPlugins.instance.checkOverlayPermission();
    if(!checkOverlayPermission){
      AppNavigator.replaceNamed<void>(
        routeName:
        AppRoutes.overlayPermissionRoute,
      );
      return;
    }
    openLanguageSelection();
  }

  //语言选择页没有点确定----启动app：语言选择页->通知->首页
  //语言选择页点确定----启动app：通知->首页
  openLanguageSelection() {
    if (LocaleSelected.readLanguage().isEmpty) {
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
