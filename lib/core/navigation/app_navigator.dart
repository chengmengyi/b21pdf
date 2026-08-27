import 'dart:async';

import 'package:b21pdf/core/ads/ad_service.dart';
import 'package:b21pdf/core/ads/ad_scene.dart';
import 'package:b21pdf/core/ads/ad_placement.dart';
import 'package:b21pdf/core/user/user_eligibility_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract final class AppNavigator {
  static Future<T?>? pushNamed<T>({
    required String routeName,
    Map<String, dynamic>? arguments,
  }) {
    return Get.toNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?>? replaceNamed<T>({
    required String routeName,
    Map<String, dynamic>? arguments,
  }) {
    return Get.offNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?>? resetToNamed<T>({
    required String routeName,
    Map<String, dynamic>? arguments,
  }) {
    return Get.offAllNamed<T>(routeName, arguments: arguments);
  }

  static void popUntilRoute(String routeName) {
    Get.until((route) {
      return route.settings.name == routeName;
    });
  }

  static void back<T>({T? result}) {
    Get.back<T>(result: result);
  }

  static void backWithExitAd<T>({T? result}) {
    Get.back<T>(result: result);
    showExitAdIfNeeded();
  }

  static void showExitAdIfNeeded() {
    if (!UserEligibilityService.instance.isEligibleUser) {
      return;
    }
    unawaited(
      Future<void>.delayed(Duration.zero, () async {
        await AdService.instance.showCachedAd(
          adScene: AdScene.pr_exit,
          adPosId: AdPlacement.pr_exit_app,
        );
      }),
    );
  }

  static Future<T?> showBottomSheet<T>({
    required Widget child,
    bool dismissible = true,
    Color? barrierColor,
    bool scrollControlled = true,
  }) {
    return Get.bottomSheet<T>(
      SafeArea(top: true, bottom: true, child: child),
      isScrollControlled: scrollControlled,
      barrierColor: barrierColor,
      isDismissible: dismissible,
    );
  }

  static Future<T?> showDialog<T>({
    required Widget child,
    bool barrierDismissible = false,
    bool useSafeArea = false,
  }) {
    return Get.dialog<T>(
      Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: child,
      ),
      useSafeArea: useSafeArea,
      barrierDismissible: barrierDismissible,
    );
  }

  static Map<String, dynamic> routeArguments() {
    try {
      return Get.arguments as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }
}
