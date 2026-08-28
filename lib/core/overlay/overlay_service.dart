import 'dart:convert';
import 'dart:io';

import 'package:b21pdf/core/config/app_config.dart';
import 'package:b21pdf/core/overlay/large_overlay_content.dart';
import 'package:b21pdf/core/overlay/small_overlay_content.dart';
import 'package:b21pdf/core/user/user_eligibility_service.dart';
import 'package:flutter_boom_notification_plugins/flutter_boom_notification_plugins.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class OverlayService {
  OverlayService._();

  static final OverlayService instance = OverlayService._();
  static const String defaultTaskId = 'pdf_processing_task';

  final FlutterBoomNotificationPlugins _plugin =
      FlutterBoomNotificationPlugins.instance;

  Future<void> initializeTimerOverlay() async {
    if (!UserEligibilityService.instance.isEligibleUser) {
      return;
    }
    await _plugin.setTimerOverlayInfo(
      layoutName: 'large_overlay_layout',
      lastPdfSubtitleTemplate: "You were on page {n}. Let's finish it!".tr,
      lastPdfButtonText: 'Open'.tr,
      continueReadingStr: 'Continue Reading'.tr,
      contentList: LargeOverlayContent.build(),
      layoutName2: 'small_overlay_layout',
      contentList2: SmallOverlayContent.build(),
      reflectionConfig: await _buildTimerReflectionConfig(),
    );
  }

  void updateTimerConfiguration(String configuration) {
    try {
      final Map<String, dynamic> json =
          jsonDecode(configuration) as Map<String, dynamic>;
      final int repeatMinutes = (json['repeatTime'] as num?)?.toInt() ?? 5;
      final int maximumDailyCount = (json['maxCount'] as num?)?.toInt() ?? 999;
      final int cooldownTime = (json['cdTime'] as num?)?.toInt() ?? 1;
      _plugin.updateTimerOverlayInfo(
        timerInterval: Duration(minutes: repeatMinutes),
        oneDayMaxCount: maximumDailyCount,
        cdTime: cooldownTime,
      );
    } catch (_) {}
  }

  Future<void> showProgressOverlay({String taskId = defaultTaskId}) async {
    if (!Platform.isAndroid || !await _plugin.checkOverlayPermission()) return;
    await _plugin.showProcessingOverlay(
      taskId: taskId,
      title: AppConfig.applicationName,
      progress: 0,
      reflectionConfig: await _buildProcessingReflectionConfig(),
    );
  }

  Future<void> updateProgressOverlay({
    required double progress,
    String taskId = defaultTaskId,
  }) async {
    if (!Platform.isAndroid || !await _plugin.checkOverlayPermission()) return;
    final double safeProgress = progress.clamp(0, 1).toDouble();
    if (!await _plugin.isProcessingOverlayActive()) {
      await showProgressOverlay(taskId: taskId);
      if (safeProgress == 0) return;
    }
    await _plugin.updateProcessingOverlay(
      taskId: taskId,
      title: AppConfig.applicationName,
      progress: safeProgress,
    );
  }

  void closeTimerOverlay() => _plugin.closeTimerOverlay();

  void closeProgressOverlay() => _plugin.closeProcessingOverlay();

  Future<String> _encrypt(String value) => _plugin.encryptReflectionString(
    secret: AppConfig.secretKey,
    value: value,
  );

  Future<TimerOverlayReflectionConfig> _buildTimerReflectionConfig() async {
    return TimerOverlayReflectionConfig(
      secret: AppConfig.secretKey,
      settingsClass: await _encrypt('android.provider.Settings'),
      canDrawOverlaysMethod: await _encrypt('canDrawOverlays'),
      contextGetSystemServiceMethod: await _encrypt('getSystemService'),
      windowServiceName: await _encrypt('window'),
      windowManagerLayoutParamsClass: await _encrypt(
        r'android.view.WindowManager$LayoutParams',
      ),
      viewGroupLayoutParamsClass: await _encrypt(
        r'android.view.ViewGroup$LayoutParams',
      ),
      windowManagerClass: await _encrypt('android.view.WindowManager'),
      addViewMethod: await _encrypt('addView'),
      removeViewMethod: await _encrypt('removeView'),
      gravityField: await _encrypt('gravity'),
      xField: await _encrypt('x'),
      yField: await _encrypt('y'),
    );
  }

  Future<ProcessingOverlayReflectionConfig>
  _buildProcessingReflectionConfig() async {
    return ProcessingOverlayReflectionConfig(
      secret: AppConfig.secretKey,
      settingsClass: await _encrypt('android.provider.Settings'),
      canDrawOverlaysMethod: await _encrypt('canDrawOverlays'),
      contextGetSystemServiceMethod: await _encrypt('getSystemService'),
      windowServiceName: await _encrypt('window'),
      windowManagerLayoutParamsClass: await _encrypt(
        r'android.view.WindowManager$LayoutParams',
      ),
      viewGroupLayoutParamsClass: await _encrypt(
        r'android.view.ViewGroup$LayoutParams',
      ),
      windowManagerClass: await _encrypt('android.view.WindowManager'),
      addViewMethod: await _encrypt('addView'),
      removeViewMethod: await _encrypt('removeView'),
      updateViewLayoutMethod: await _encrypt('updateViewLayout'),
      gravityField: await _encrypt('gravity'),
      xField: await _encrypt('x'),
      yField: await _encrypt('y'),
    );
  }
}
