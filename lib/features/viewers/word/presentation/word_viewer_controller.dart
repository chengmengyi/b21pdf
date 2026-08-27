import 'dart:io';

import 'package:b21pdf/core/ads/ad_service.dart';
import 'package:b21pdf/core/ads/ad_scene.dart';
import 'package:b21pdf/core/ads/ad_placement.dart';
import 'package:b21pdf/core/user/user_eligibility_service.dart';
import 'package:b21pdf/core/navigation/app_navigator.dart';
import 'package:b21pdf/core/analytics/analytics_event.dart';
import 'package:b21pdf/core/analytics/analytics_service.dart';
import 'package:b21pdf/core/presentation/base_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_preview_file/flutter_preview_file.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class WordViewerController extends BaseController {
  late final WordFileController wordController;
  FileToolsFileInfo fileInfo = Get.arguments['file'] as FileToolsFileInfo;
  bool canLoadViewer = false;

  String get fileName {
    if ((fileInfo.name ?? '').isNotEmpty) {
      return fileInfo.name!;
    }
    return (fileInfo.path ?? '').split(Platform.pathSeparator).last;
  }

  bool get isEditing => wordController.isEditing;
  bool get isSaving => wordController.saving;

  @override
  void onInit() {
    super.onInit();
    wordController = WordFileController(filePath: fileInfo.path ?? '');
    wordController.addListener(_onViewerStateChanged);
  }

  @override
  void onReady() {
    super.onReady();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 160));
      canLoadViewer = true;
      update();
      await wordController.initialize();
    });
  }

  void _onViewerStateChanged() => update();
  Future<void> onEditPressed() async {
    if (isSaving) return;
    isEditing
        ? await wordController.cancelEditing()
        : await wordController.enterEditMode();
  }

  Future<void> onSavePressed() async {
    if (!isEditing || isSaving) return;
    try {
      AnalyticsService.instance.trackEvent(
        pointType: AnalyticsEvent.editorSaveClick,
      );
      await wordController.save();
      final path = fileInfo.path ?? '';
      final stat = await File(path).stat();
      fileInfo = fileInfo.copyWith(
        size: stat.size,
        updateTime: stat.modified.millisecondsSinceEpoch,
      );
      Fluttertoast.showToast(msg: 'Saved successfully'.tr);
    } catch (error) {
      Fluttertoast.showToast(msg: '$error');
    }
  }

  void onBackPressed() {
    AppNavigator.back();
    if (UserEligibilityService.instance.isEligibleUser) {
      AdService.instance.showCachedAd(
        adScene: AdScene.pr_exit,
        adPosId: AdPlacement.pr_readback,
      );
    }
  }

  @override
  void onClose() {
    wordController.removeListener(_onViewerStateChanged);
    wordController.dispose();
    super.onClose();
  }
}
