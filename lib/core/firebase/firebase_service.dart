import 'dart:convert';

import 'package:b21pdf/core/lifecycle/app_lifecycle_service.dart';
import 'package:b21pdf/core/config/app_config.dart';
import 'package:b21pdf/core/ads/ad_service.dart';
import 'package:b21pdf/core/user/user_eligibility_service.dart';
import 'package:b21pdf/core/events/app_event.dart';
import 'package:b21pdf/core/events/app_event_type.dart';
import 'package:b21pdf/core/events/app_event_bus.dart';
import 'package:b21pdf/features/notifications/services/notification_service.dart';
import 'package:b21pdf/core/storage/preferences/ad_switch_cache.dart';
import 'package:b21pdf/core/storage/preferences/firebase_ad_config_cache.dart';
import 'package:b21pdf/core/overlay/overlay_service.dart';
import 'package:b21pdf/core/storage/preferences/referrer_config.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_custom_facebook/flutter_custom_facebook.dart';
import 'package:flutter_pdf_ad_plugins/flutter_pdf_ad_plugins.dart';

class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  FirebaseRemoteConfig? _remoteConfig;
  FirebaseAnalytics? _analytics;

  bool _facebookInitialized = false;

  int adCooldownSeconds = 30, secondaryAdCooldownSeconds = 180;
  bool supportsKoreanNotifications = false;
  String adConfigSource = "local";

  Future<void> initialize() async {
    if (FirebaseAdConfigCache.readConfig().isNotEmpty) {
      adConfigSource = "remote";
    }
    try {
      await Firebase.initializeApp();
      _analytics ??= FirebaseAnalytics.instance;
      _remoteConfig = FirebaseRemoteConfig.instance;
      await _remoteConfig?.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(seconds: 1),
        ),
      );
      await _remoteConfig?.fetchAndActivate();
      applyRemoteConfiguration();
    } catch (error) {
      await Future.delayed(const Duration(milliseconds: 1000));
      return initialize();
    }
  }

  void applyRemoteConfiguration() {
    final int openCooldown = _remoteConfig?.getInt('new_op_cd') ?? 0;
    if (openCooldown > 0) {
      AppEventBus.instance.publish(
        AppEvent(type: AppEventType.newOpenAdCheckTime, intValue: openCooldown),
      );
    }

    final String pdfAdConfig = _remoteConfig?.getString('pdf_ad_17') ?? '';
    if (pdfAdConfig.isNotEmpty) {
      adConfigSource = "remote";
      FirebaseAdConfigCache.saveConfig(pdfAdConfig);
      AdService.instance.refreshRemoteAdConfig();
    }

    final String facebookAdConfig = _remoteConfig?.getString('pdf_adfb') ?? '';
    if (facebookAdConfig.isNotEmpty) {
      AdService.instance.updateFacebookPlacementConfig(facebookAdConfig);
    }

    applyAdCooldownConfiguration();

    final String referrerConfig = _remoteConfig?.getString('pr_refer') ?? '';
    if (referrerConfig.isNotEmpty) {
      ReferrerConfig.save(referrerConfig);
      UserEligibilityService.instance.applyReferrerConfig();
    }

    final String riskConfig = _remoteConfig?.getString('risk_control') ?? '';
    if (riskConfig.isNotEmpty) {
      UserEligibilityService.instance.initializeRiskControl(riskConfig);
    }

    final String overlayTimingConfig =
        _remoteConfig?.getString('float_time') ?? '';
    if (overlayTimingConfig.isNotEmpty) {
      OverlayService.instance.updateTimerConfiguration(overlayTimingConfig);
    }

    _initializeFacebook();

    final int koreanPushMode =
        _remoteConfig?.getInt('krsamsung_push_time') ?? 0;
    if (koreanPushMode > 0) {
      supportsKoreanNotifications = koreanPushMode == 1;
      NotificationService.instance.initialize();
    }
    _persistFeatureSwitchConfig();

    var remoteTimeout = _remoteConfig?.getInt("isk_time") ?? 0;
    if (remoteTimeout > 0) {
      FlutterPdfAdPlugins.instance.updateAdRequestTimeoutSeconds(remoteTimeout);
    }

    final int hotLaunchCooldown = _remoteConfig?.getInt("cd_hot") ?? 0;
    if (hotLaunchCooldown > 0) {
      AppLifecycleService.instance.hotLaunchCooldownSeconds = hotLaunchCooldown;
    }
    _loadAdEngagementConfig();
  }

  void _persistFeatureSwitchConfig() {
    try {
      final String switchConfig =
          _remoteConfig?.getString('switch_config') ?? '';
      if (switchConfig.isNotEmpty) {
        AdSwitchCache.saveConfig(switchConfig);
      }
    } catch (_) {}
  }

  void _loadAdEngagementConfig() {
    try {
      final String adEngagementConfig =
          _remoteConfig?.getString("ad_config") ?? "";
      if (adEngagementConfig.isNotEmpty) {
        final dynamic config = jsonDecode(adEngagementConfig);
        final dynamic maximumShows = config["ad_show"];
        final dynamic maximumClicks = config["ad_click"];
        FlutterPdfAdPlugins.instance.setMaxShowAndClickNum(
          maxShowNum: maximumShows,
          maxClickNum: maximumClicks,
        );
      }
    } catch (_) {}
  }

  void applyAdCooldownConfiguration() {
    final int remoteCooldown = _remoteConfig?.getInt('kc_cd') ?? 0;
    if (remoteCooldown > 0) {
      adCooldownSeconds = remoteCooldown;
    }
    final int secondaryCooldown = _remoteConfig?.getInt('a_kc_cd') ?? 0;
    if (secondaryCooldown > 0) {
      secondaryAdCooldownSeconds = secondaryCooldown;
    }
  }

  Future<void> _initializeFacebook() async {
    if (_facebookInitialized) {
      return;
    }
    final String facebookConfig = _remoteConfig?.getString('pr_fb') ?? '';
    if (facebookConfig.isEmpty) {
      return;
    }
    try {
      final dynamic facebookJson = jsonDecode(facebookConfig);
      final bool initialized = await FlutterCustomFacebook.instance
          .initFaceBook(
            facebookId: facebookJson['app_id'],
            facebookToken: facebookJson['token'],
            facebookAppName: AppConfig.applicationName,
          );
      _facebookInitialized = initialized;
    } catch (_) {}
  }

  Future<void> logFacebookPurchase(double amount, String currency) async {
    try {
      if (!_facebookInitialized) {
        return;
      }
      FlutterCustomFacebook.instance.logPurchase(
        amount: amount,
        currency: currency,
      );
    } catch (_) {}
  }

  Future<void> logAnalyticsEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      if (Firebase.apps.isEmpty) {
        await initialize();
      }
      _analytics ??= FirebaseAnalytics.instance;
      await _analytics?.logEvent(name: name, parameters: parameters);
    } catch (_) {}
  }
}
