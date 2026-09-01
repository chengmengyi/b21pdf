import 'dart:async';
import 'dart:convert';

import 'package:b21pdf/core/storage/preferences/locale_selected.dart';
import 'package:b21pdf/core/ads/ad_scene.dart';
import 'package:b21pdf/core/ads/ad_placement.dart';
import 'package:b21pdf/core/lifecycle/app_lifecycle_service.dart';
import 'package:b21pdf/core/user/user_eligibility_service.dart';
import 'package:b21pdf/core/firebase/firebase_service.dart';
import 'package:b21pdf/features/startup/services/initial_launch_source_service.dart';
import 'package:b21pdf/core/config/app_config.dart';
import 'package:b21pdf/features/startup/services/startup_interaction_gate.dart';
import 'package:b21pdf/core/analytics/analytics_event.dart';
import 'package:b21pdf/core/analytics/analytics_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boom_notification_plugins/flutter_boom_notification_plugins.dart';
import 'package:flutter_tba_info/flutter_tba_info.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  bool _initialized = false;

  Future<void> initialize({bool requestPermission = false}) async {
    if (_initialized) {
      return;
    }
    final bool canInitialize = await _isInitializationAllowed();
    if (!canInitialize) {
      return;
    }
    _initializeListeners();
    await _initializeLocalInfo();
    await _initializeTbaInfo();
    updateNewFileNotificationText();
    await _scheduleLocalNotifications();
    _initializeFcm();
    await _initializeBroadcasts();
    await initializeMediaNotification();
    _initializeShortcutNotification();
    _initialized = true;
    if (requestPermission) {
      await Permission.notification.request();
      AnalyticsService.instance.trackEvent(
        pointType: AnalyticsEvent.storage_system_result,
        parameters: {"open": (await hasNotificationPermission()) ? 1 : 0},
      );
      AnalyticsService.instance.trackEvent(
        pointType: AnalyticsEvent.push_guide_view,
        parameters: {"show_type": "system"},
      );
    }
  }

  Future<bool> hasNotificationPermission() async {
    var permissionStatus = await Permission.notification.status;
    var isGranted = permissionStatus.isGranted || permissionStatus.isLimited;
    return isGranted;
  }

  Future<void> _initializeTbaInfo() async {
    final Map<String, String> headerMap = Map<String, String>.from(
      await AnalyticsService.instance.buildRequestHeaders(),
    );
    final String requestUrl = await AnalyticsService.instance
        .buildEndpointUrl();
    final Map<String, dynamic> pushPayload = await AnalyticsService.instance
        .createEventPayload(
          pointType: AnalyticsEvent.push,
          parameters: {'sourse': "local"},
        );
    FlutterBoomNotificationPlugins.instance.configureNativePushReporting(
      enabled: true,
      url: requestUrl,
      headers: headerMap,
      payloadTemplate: pushPayload,
      distinctIdKey: "zagging",
      logIdKey: "bahama",
      clientTsKey: "prophecy",
      notificationSourceKey: "sourse~glory",
      packageKey: "pershing",
    );
  }

  void _initializeShortcutNotification() {
    FlutterBoomNotificationPlugins.instance.showPersistentShortcutNotification(
      homeText: 'Home'.tr,
      mergeText: 'Scan'.tr,
      importText: 'Word To PDF'.tr,
      convertText: 'Image To PDF'.tr,
      homeIcon: 'home_func',
      mergeIcon: 'scan_func',
      importIcon: 'word_func',
      convertIcon: 'image_func',
    );
  }

  Future<void> initializeMediaNotification() async {
    final bool canInitialize = await _isInitializationAllowed();
    if (!canInitialize) {
      return;
    }
    FlutterBoomNotificationPlugins.instance.periodicallyShowMediaWithDuration(
      reflectionConfig: MediaReflectionConfig(
        secret: AppConfig.secretKey,
        mediaSessionClass: "v1:6AKOSUXUDogHnRMs:IMAXK4bhru3xfhQt8DmFrqFu2/BY6ZWpP20xdKxLioRgSMRaHASr3XsehsQt7Aw4TH5/5Ke62f5sLwdLI0hDg/MmBw==",
        mediaSessionTokenClass: "v1:+Jsls86LBVurNr/6:P6JRwDMgjDNCCvlbpdSpYTHfAAXSXab6HyvwQMo+14tfmaW7KMIL+TVkpBlyv15hGbyOYXer5yJ7UULny+rmu/qD+4agy4YcjQ==",
        mediaSessionTag: "v1:1pLWh7SfJXO9W7xq:l3xpZ8s1rxDpZ2lYgdD2Zzq4wWU4iQzcW7ifJ4nmeg==",
        playbackStateClass: "v1:fgU/tMyIZi90Rs8u:zE++NEPc7KT/rwFD6RNrithmrQR6FCnpLguzWL7zKKRg082tFltgN8yCesNfFq/9jhrCLiUPl7Mib7qhYv5Aw83G4WY=",
        playbackStateBuilderClass: "v1:KwTSnPA7iezATect:vFGZzYRj1JqTvuQA2NaQOTLToOxBYMPWnZDw0kBsIukBxGTVq3T02T34jS97x63xE0MmvWFZ1Nrzc1jSX26PtVC7MQsZZmMPtllyVQ==",
        mediaStyleClass: "v1:rhRmFoNd5T+HTsjX:v0fy1ZrKyQ0tz4grndD0H41/LJBV2+Dai4q+jEs9wOL18RiMYDO+8ZIJ4gImqQwatVyw4vhzViPZrg3/Ugdk5g==",
        setFlagsMethod: "v1:RPFjnwd/wFEl2LmM:blkRGkt3IvrmYPoG5dM4JuxP3fa69C7v",
        setActiveMethod: "v1:8Rf4/mcN8qKaGHoB:gVziCmbqF3ag8VH5mUaKrb1TnGwwqM6oSQ==",
        setPlaybackStateMethod: "v1:SJHbgj+FRKAl22ND:qOd6fTuufkjbKQ9R4P1+N9nhncG1lQrBSZ+8q/ntsQg=",
        getSessionTokenMethod: "v1:ujKZSMdcblDmCFrW:Ls3DWlSYqRC7aaFBssa1lzw/FMx+rqWZCei6ls+tzg==",
        setStateMethod: "v1:jShUhNXxeil+8bEF:8n7R2OdRkTVGGfTMLCjLX1eRHTRkmgZ0",
        buildMethod: "v1:AVCyG+vI7Gn8OeFM:VREyQOqi5/7xpgybKOxQQqtDVOy1",
        setMediaSessionMethod: "v1:EfzL/aI4rUBtp1JH:SzkDrz2a048TDJObT5i6WzwQTJgBSfb/Uw1I84juOg==",
      ),
      mediaBackgroundImageName: 'large_notice_picture',
    );
  }

  Future<void> _initializeBroadcasts() async {
    FlutterBoomNotificationPlugins.instance.registerBroadcastNotifications();
  }

  void _initializeFcm() {
    FlutterBoomNotificationPlugins.instance.subscribeToTopic(
      channelId: 'fcm_notice_channel',
      channelName: 'fcm_notice_channel_name',
      priority: Priority.max,
      importance: Importance.max,
      style: 'beauty',
      beautyButton: 'Claim',
    );
  }

  Future<void> _scheduleLocalNotifications() async {
    FlutterBoomNotificationPlugins.instance.periodicallyShowLocalWithDuration();
  }

  void updateNewFileNotificationText() {
    FlutterBoomNotificationPlugins.instance.setGalleryImageNotificationInfo(
      title: 'You have a new file.'.tr,
    );
  }

  Future<void> _initializeLocalInfo() async {
    await FlutterBoomNotificationPlugins.instance.initNotification(
      icon: 'small_logo',
      channelId: 'notice_channel',
      channelName: 'notice_channel_name',
      channelDescription: 'PDF notifications',
      customLayout: AndroidCustomNotificationLayout(
        smallLayoutName: 'small_notice_layout',
        bigLayoutName: 'large_notice_layout',
        actionText: 'Check'.tr,
      ),
      showMedia: true,
      config: await _buildNotificationConfig(),
    );
  }

  Future<NotificationInitConfig> _buildNotificationConfig() async {
    final String defaultNotificationConfig = await rootBundle.loadString(
      AppConfig.defaultNotificationConfig,
    );
    final String fieldMappingConfig = await rootBundle.loadString(
      AppConfig.fieldMappingConfig,
    );
    var deviceLanguage = "", countryCode = "";
    var languageXpe = LocaleSelected.readLanguage();
    if (languageXpe.isNotEmpty) {
      try {
        var list = languageXpe.split("-");
        deviceLanguage = list.first;
        countryCode = list.last;
      } catch (_) {}
    }
    if (deviceLanguage.isEmpty) {
      deviceLanguage = await FlutterBoomNotificationPlugins.instance
          .getDeviceLanguage();
    }
    if (countryCode.isEmpty) {
      countryCode = await FlutterBoomNotificationPlugins.instance
          .getCountryCode();
    }
    return NotificationInitConfig(
      defaultConfig: defaultNotificationConfig,
      request: NotificationConfigRequest(
        url: AppConfig.notificationConfigUrl,
        headers: {
          "ijxf": kDebugMode ? "com.pdftool.reader.scanner" : await FlutterTbaInfo.instance.getBundleId(),
          "sdume": kDebugMode ? "0.0.1" : await FlutterTbaInfo.instance.getAppVersion(),
        },
        body: {
          "eflVeMLBB": deviceLanguage,
          "JFz": await FlutterTbaInfo.instance.getDistinctId(),
          "HMCb": countryCode,
        },
      ),
      fieldMapping: jsonDecode(fieldMappingConfig),
    );
  }

  void _initializeListeners() {
    FlutterBoomNotificationPlugins.instance.setListeners(
      onNotificationClicked: (LocalNotificationEvent event) {
        final AppLifecycleService lifecycleService =
            AppLifecycleService.instance;
        if (lifecycleService.shouldSuppressClickHotLaunch) {
          lifecycleService.suppressNextForegroundAd();
        }
        if (!StartupInteractionGate.instance.canHandleNotificationClick) {
          return;
        }
        final String payload = event.payload ?? event.payloadType?.name ?? '';
        _trackNotificationClick(payload);
        unawaited(
          lifecycleService.showLifecycleAd(
            AdScene.pr_launch,
            payload == 'media'
                ? AdPlacement.pr_open_mediapop
                : AdPlacement.pr_open_noti,
          ),
        );
      },
      onNotificationDisplayed: (LocalNotificationEvent event) {
        _trackNotificationImpression(
          event.payload ?? event.payloadType?.name ?? '',
        );
      },
      onTimerOverlayClicked: (TimerOverlayClickEvent event) {},
      onProcessingOverlayClicked: () {},
    );
  }

  Future<void> refreshNotificationLanguage() async {
    final bool canInitialize = await _isInitializationAllowed();
    if (!canInitialize) {
      return;
    }
    await FlutterBoomNotificationPlugins.instance.refreshNotificationConfig(
      config: await _buildNotificationConfig(),
    );
    _initializeShortcutNotification();
    updateNewFileNotificationText();
  }

  Future<void> showAdFollowUpNotification() async {
    final bool canInitialize = await _isInitializationAllowed();
    if (!canInitialize) {
      return;
    }
    await FlutterBoomNotificationPlugins.instance.show(
      id: _generateNotificationId(),
      title: "Continue viewing PDF".tr,
      body: "Continue viewing PDF".tr,
      payload: LocalNotificationPayload.local,
    );
  }

  int _generateNotificationId() {
    return DateTime.now().microsecondsSinceEpoch % 2147483647;
  }

  void trackInitialNotificationEvent() {
    if (InitialLaunchSourceService.instance.notificationPayload != null) {
      _trackNotificationClick(
        InitialLaunchSourceService.instance.notificationPayload ?? '',
      );
    }
    trackPendingNotificationEvents();
  }

  Future<void> trackPendingNotificationEvents() async {
    for (final LocalNotificationPayload payload
        in LocalNotificationPayload.values) {
      final int displayedCount = await FlutterBoomNotificationPlugins.instance
          .consumeDisplayedNotificationCount(payload: payload);
      if (displayedCount > 0) {
        for (int index = 0; index < displayedCount; index++) {
          _trackNotificationImpression(payload.value);
        }
      }
    }
  }

  void _trackNotificationClick(String? eventSource) {
    AnalyticsService.instance.trackEvent(
      pointType: AnalyticsEvent.inform_c,
      parameters: {'sourse': eventSource},
    );
  }

  void _trackNotificationImpression(String eventSource) {
    AnalyticsService.instance.trackEvent(
      pointType: AnalyticsEvent.push,
      parameters: {'sourse': eventSource},
    );
  }

  Future<bool> _isInitializationAllowed() async {
    if (!UserEligibilityService.instance.isEligibleUser) {
      return false;
    }
    final bool samsungDevice = await FlutterBoomNotificationPlugins.instance
        .isSamsungDevice();
    final bool koreanLocale = await FlutterBoomNotificationPlugins.instance
        .isKoreanLocale();
    if (samsungDevice &&
        koreanLocale &&
        !FirebaseService.instance.supportsKoreanNotifications) {
      return false;
    }
    return true;
  }
}
