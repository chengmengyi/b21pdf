import 'package:b21pdf/features/settings/update/presentation/update_dialog.dart';
import 'package:b21pdf/features/onboarding/services/onboarding_coordinator.dart';
import 'package:b21pdf/core/navigation/app_routes.dart';
import 'package:b21pdf/core/navigation/app_navigator.dart';
import 'package:b21pdf/features/library/presentation/home/home_controller.dart';
import 'package:b21pdf/core/presentation/base_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UninstallFeedbackController extends BaseController {
  static const String reasonBuilderId = 'uninstall_reason_builder';

  TextEditingController textEditingController = TextEditingController();
  int selectedReasonIndex = -1;
  final List<String> reasonList = <String>[
    'Hard to use',
    'Frequent ad interference',
    'Poor PDF reading experience',
    'Too many notifications',
    "Editing features don't meet needs",
    'Phone has built-in PDF tools',
    'Other (Please specify)',
  ];

  void onUninstallPressed() {
    AppNavigator.showDialog(child: const UpdateDialog());
  }

  void onReasonPressed(int index) {
    selectedReasonIndex = index;
    update(<Object>[reasonBuilderId]);
  }

  void onNoUninstallPressed() {
    if (Get.isRegistered<HomeController>()) {
      AppNavigator.popUntilRoute(AppRoutes.homeRoute);
      AppNavigator.showExitAdIfNeeded();
      return;
    }
    OnboardingCoordinator.instance.openOverlaySelection();
    AppNavigator.showExitAdIfNeeded();
  }

  @override
  void onClose() {
    textEditingController.dispose();
    super.onClose();
  }
}
