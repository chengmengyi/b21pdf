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
      contentList3: [
        TimerOverlayContent(
          title: 'Home'.tr,
          subtitle: 'home_func',
          button: "",
        ),
        TimerOverlayContent(
          title: 'Scan'.tr,
          subtitle: 'scan_func',
          button: "",
        ),
        TimerOverlayContent(
          title: 'Word To PDF'.tr,
          subtitle: 'word_func',
          button: "",
        ),
        TimerOverlayContent(
          title: 'Image To PDF'.tr,
          subtitle: 'image_func',
          button: "",
        ),
      ],
    );
  }

  Future<bool> hasOverlayPermission() async {
    if (!Platform.isAndroid) return true;
    return _plugin.checkOverlayPermission();
  }

  Future<bool> requestOverlayPermission() async {
    if (!Platform.isAndroid) return true;
    return _plugin.requestOverlayPermission(
      title: 'Almost there! Unlock your full potential:'.tr,
      desc: 'Find {n} below and toggle the switch to ON.'.tr,
      overlayPermissionGuideLayout: 'overlay_layout',
    );
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

  Future<TimerOverlayReflectionConfig> _buildTimerReflectionConfig() async {
    return TimerOverlayReflectionConfig(
      secret: AppConfig.secretKey,
      settingsClass: "v1:dAEFsfP2edryQkeq:yHRx65uFGONzJaP0159bSApAwHYMIxSJWNOwCtQ80/LenhXim6GppJ8=",
      canDrawOverlaysMethod: "v1:g6VvlG8n9LxLY2hs:sdyiPWrSZU/LCnV7Ud3W6TX78419p8l7T6jwHG2W0A==",
      contextGetSystemServiceMethod: "v1:yVyVhO5TNCgo04Qw:FRPK76iUJ89ovdwSuvmo/1fHEEiklHnIob3C6Kr3flE=",
      windowServiceName: "v1:7NC1ephQZiVDqvyv:cb2phGOndkLs2oSZAr8dUXW/rLPNEA==",
      windowManagerLayoutParamsClass: "v1:bRD0QYhdVpudm/C8:wJnajmKhVtWYwAjCGI/DlSH+1g4QwaTrQyx9dzmj/xiAqYN3rEeBUKA3uRke+HsVYBPZRlwVWQ==",
      viewGroupLayoutParamsClass: "v1:Xx0XubpxA3b2FeoG:fdst/jP4LFBOROhbAXDNsXg6bAIpU1D1SbVgc/UnGIm+PsDJzbRHlaj52ggAJSSOHcbt",
      windowManagerClass: "v1:ELN+pglL2kBneUIj:s+bgOAG5wha3KpWsIwfNLiXAuG5Le/MsU/bj27wWvv1K7QL3wLNUfMJL",
      addViewMethod: "v1:kof9soyPjviwQ/CJ:miLYJJte20sO5UCmQqg/hxpE0he8NRg=",
      removeViewMethod: "v1:knjaJPiyeTpJDvuJ:DXzWr888Oc1uS3pFInJ4dQtUOCt57qw20uo=",
      gravityField: "v1:Z2u+SRrQiZLUAtYe:S2ki8zxr5b6zn+8VEVHeIqBvI6B2IQ4=",
      xField: "v1:ISaP4Nkkv9CxZ/fa:+ok94P0MIX6dOEMLyGn9wFM=",
      yField: "v1:SEaESyk+LO+ByN2c:MvEDS3vzfcFmuCstyUv5Cgs=",
    );
  }

  Future<ProcessingOverlayReflectionConfig>
  _buildProcessingReflectionConfig() async {
    return ProcessingOverlayReflectionConfig(
      secret: AppConfig.secretKey,
      settingsClass: "v1:EAZMRGFKYMyIUckE:fiQzEbp/e7mjISeL1VD3lTzb/KhA6f977se+wvAyQdDD7Hj06ljOatE=",
      canDrawOverlaysMethod: "v1:MJUvHOKYqw07CS/3:f3AVdzxeXWMbPgweDuWk/mkEHo0GUvJ2CLcvkMyMRw==",
      contextGetSystemServiceMethod: "v1:tCGei+N8ttmOKeJF:qrb86VvdF//B4tVww8HGBxS8X4K1xdyCxldbaD1M64E=",
      windowServiceName: "v1:xZz4CTvV1AbTYnlI:k1q1aFZqfDnTanLsMhtdOfHSax+jNQ==",
      windowManagerLayoutParamsClass: "v1:SaYuVWaMy0EwbGHG:WAC5/hmM6PkLoacBqFzM6tMurWf5+kQM57B5dUKArW4NOio9128Lrlp8jqRHb/omijpgUOnvKA==",
      viewGroupLayoutParamsClass: "v1:/wNAjuiVtU7CFYiB:MyVKSihIux0k0CUKl3/osDzY9ZsBZQJMvBm59MZ91nEWwLhS3lmLsTqR0M7WIKx8gnfU",
      windowManagerClass: "v1:T5TeIWLHNjB02PoU:msAXGLj5sizQBz/3XKP7f6bE93xCA90bUs/2kn1/jtz+7EWnUE6U/Dt0",
      addViewMethod: "v1:z8s73dnYbAxnIN1N:EnzeuR2o2v5D9rDBHHKpW4ji9MXYz3I=",
      removeViewMethod: "v1:P7B2qQY9iwNF4K0r:4sj0OLZjLvJ3Ovc1dwhlP3kDglYlzPacwJE=",
      updateViewLayoutMethod: "v1:Ue2Ebqg5yhciK4hx:dR7SXJRT5goCCDnF6GCDUJcHRwxBH+8swggUcFHN3Nc=",
      gravityField: "v1:alAeJLRsqYOgBv9Y:2Hu+eTVmfylHGaeEs4iwdXohpWvumtM=",
      xField: "v1:12PAjdtJm2OI5OYR:+R/vHuDiy8ZeDlCkP23h/vM=",
      yField: "v1:VvocWjkIjzAMkSJw:gdl8SIxhRW/rbq9wCnR0HhY=",
    );
  }
}
