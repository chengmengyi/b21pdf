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

class ExcelViewerController extends BaseController {
  late final ExcelFileController excelController;
  FileToolsFileInfo fileInfo = Get.arguments['file'] as FileToolsFileInfo;
  bool canLoadViewer = false;
  String get fileName {
    if ((fileInfo.name ?? '').isNotEmpty) {
      return fileInfo.name!;
    }
    return (fileInfo.path ?? '').split(Platform.pathSeparator).last;
  }

  bool get isEditing => excelController.isEditing;
  bool get isSaving => excelController.saving;
  @override
  void onInit() {
    super.onInit();
    excelController = ExcelFileController(filePath: fileInfo.path ?? '');
    excelController.addListener(_onViewerStateChanged);
  }

  @override
  void onReady() {
    super.onReady();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 160));
      canLoadViewer = true;
      update();
      await excelController.initialize();
    });
  }

  void _onViewerStateChanged() => update();
  Future<void> onEditPressed() async {
    if (isSaving) return;
    isEditing
        ? await excelController.cancelEditing()
        : await excelController.enterEditMode();
  }

  Future<void> onSavePressed() async {
    if (!isEditing || isSaving) return;
    try {
      AnalyticsService.instance.trackEvent(
        pointType: AnalyticsEvent.editor_save_click,
      );
      await excelController.save();
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
    excelController.removeListener(_onViewerStateChanged);
    excelController.dispose();
    super.onClose();
  }
}
