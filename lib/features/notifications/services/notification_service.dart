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
        pointType: AnalyticsEvent.storageSystemResult,
        parameters: {"open": (await hasNotificationPermission()) ? 1 : 0},
      );
      AnalyticsService.instance.trackEvent(
        pointType: AnalyticsEvent.pushGuideView,
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
      mergeText: 'Search'.tr,
      importText: 'Scan'.tr,
      convertText: 'Convert'.tr,
      homeIcon: 'func',
      mergeIcon: 'func',
      importIcon: 'func_word',
      convertIcon: 'func_pdf',
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
        mediaSessionClass:
            "v1:weCjDsQop8UwHcaw:BbR0cTQy9xTtS5uWoSt/f1FtfsTpTCqyCCjQRweWivi3grKkNlTNDNbRSPNrvxa1nSq7NiMuRpDPpTcH1D9gsJ4egQ==",
        mediaSessionTokenClass:
            "v1:+6buhCvyJDZnNUK0:yiGrEcs+AtyIA6at7Hz1j8zhlS+HxWMzhpt0TDeWHUZrNt1ApQkWkMQDDAuPYWaYYS7qG4kIHR38B1IzzTiWq4OGjunqjXP0zg==",
        mediaSessionTag:
            "v1:tJ62Eqh6vvrm8faL:1uTsAxBfrSc0rAmPmQrsKB1lYjDmC6fuwp8cKJ3/+Q==",
        playbackStateClass:
            "v1:u36QDcBcuO1gULRk:11n8F+t5H6jb6llYNAqhsQWooQhAURVLHkKfvRt1HReLM0dT2Y/1cZo7Kbn7ZzHaYkMXV9imENkn9pU5wkdaxjkG1VU=",
        playbackStateBuilderClass:
            "v1:pt5eSFUXFsyALbuz:xIzGa5FlJ8SdY0RqDM+AVO9P47fuPsgLFoO1VTJWq/Zusif8d0zb7/yTxjPDpue59tzwY+lNIXMiPAoPUB/ozn7Pn2ieimCO9ZdQmw==",
        mediaStyleClass:
            "v1:roe0Fj8+JMBYx19l:wo9Wp7b1mpFmUCJQh9XfuD+QbM/qgBhNaqQdbThtnrfDlOPCx/qaTP4WxhRsBDnNe/1pesuXtrxgwhFQjJtlqw==",
        setFlagsMethod: "v1:h+Gu5FfsttLG9bu7:U7SGcNPGvTvShly/ELri0DxWOADGLqXW",
        setActiveMethod:
            "v1:1pPOnn6sUXaqPB4w:U2JaNg+sjknqO1gAZF/aQDKaA6VSXIYkog==",
        setPlaybackStateMethod:
            "v1:tls75fKukeGpEG3o:paUcyoc8gjffLxvgjRHLAqzLamEDqxQ58L0MKb6LFmE=",
        getSessionTokenMethod:
            "v1:edvWEuXOpfuXKzQN:atgi4DKIMa87SC0I/TyqUgi6FhQbtu6NhqMaiFvhgw==",
        setStateMethod: "v1:ch10n6ORAXX3GTHR:j4pOtzs8NUhmv9RLs2tCRPszVCc3EjRk",
        buildMethod: "v1:BYz/1zTGxzZJAfr6:migf3KcINrwYRsSgexhjcrNVQuwr",
        setMediaSessionMethod:
            "v1:b5HfXmOyTtT1fJwr:/UF7xuWORAbHQQD75UzMHrUJHdPj2wPSQDSe7/Jv1Q==",
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
        //zh-CN
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
        url: "https://prod.pdfutilitydocforge.com/LGZXGfupyG/HmtKKNYmqW/aARzBe",
        headers: {
          "imp": kDebugMode
              ? "com.docforge.pdfutility"
              : await FlutterTbaInfo.instance.getBundleId(),
          // "imp":await FlutterTbaInfo.instance.getBundleId(),
          "udz": kDebugMode
              ? "0.0.1"
              : await FlutterTbaInfo.instance.getAppVersion(),
        },
        body: {
          "iSrc": deviceLanguage,
          "DgTaa": await FlutterTbaInfo.instance.getDistinctId(),
          "pnsKCAj": countryCode,
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
      pointType: AnalyticsEvent.informC,
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
