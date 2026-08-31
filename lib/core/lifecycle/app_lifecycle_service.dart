import 'dart:async';

import 'package:b21pdf/core/ads/ad_service.dart';
import 'package:b21pdf/core/ads/ad_scene.dart';
import 'package:b21pdf/core/ads/ad_placement.dart';
import 'package:b21pdf/core/events/app_event.dart';
import 'package:b21pdf/core/events/app_event_type.dart';
import 'package:b21pdf/core/events/app_event_bus.dart';
import 'package:b21pdf/core/overlay/overlay_service.dart';
import 'package:b21pdf/features/startup/services/active_launch_source_service.dart';
import 'package:b21pdf/features/notifications/services/notification_service.dart';
import 'package:b21pdf/core/storage/preferences/last_open_ad_close_time.dart';
import 'package:flutter_app_lifecycle/app_state_observer.dart';
import 'package:flutter_app_lifecycle/flutter_app_lifecycle.dart';
import 'package:flutter_pdf_ad_plugins/flutter_pdf_ad_plugins.dart';

class AppLifecycleService {
  AppLifecycleService._();

  static final AppLifecycleService instance = AppLifecycleService._();
  int hotLaunchCooldownSeconds = 3;
  bool observerStarted = false, _appIsBack = false;
  bool _suppressNextHotLaunch = false;

  bool get shouldSuppressClickHotLaunch => _appIsBack;

  void suppressNextForegroundAd() {
    _suppressNextHotLaunch = true;
    _appIsBack = false;
  }

  bool _consumeForegroundAdSuppression() {
    if (!_suppressNextHotLaunch) {
      return false;
    }
    _suppressNextHotLaunch = false;
    _appIsBack = false;
    ActiveLaunchSourceService.instance.clear();
    return true;
  }

  void startObservingLifecycle() {
    if (observerStarted) {
      return;
    }
    observerStarted = true;
    FlutterAppLifecycle.instance.setCallObserver(
      AppStateObserver(
        call: (bool inBackground) {
          AppEventBus.instance.publish(
            AppEvent(
              type: AppEventType.appLifecycle,
              intValue: inBackground ? 1 : 0,
            ),
          );
          if (inBackground) {
            _onAppBackgrounded();
          } else {
            unawaited(_onAppForegrounded());
          }
        },
      ),
    );
  }

  void _onAppBackgrounded() {
    _appIsBack = true;
  }

  Future<void> _onAppForegrounded() async {
    OverlayService.instance.closeTimerOverlay();
    if (!_appIsBack && !_suppressNextHotLaunch) {
      return;
    }
    if (_consumeForegroundAdSuppression()) {
      return;
    }
    if (!_appIsBack) {
      return;
    }
    _appIsBack = false;
    unawaited(NotificationService.instance.trackPendingNotificationEvents());
    final LaunchSource? source = ActiveLaunchSourceService.instance
        .consumeLaunchSource();
    if (source == null) {
      showLifecycleAd(AdScene.pr_launch, AdPlacement.pr_open_hot);
      return;
    }
    switch (source.type) {
      case LaunchSourceType.notification:
        return;
      case LaunchSourceType.quickAction:
        showLifecycleAd(AdScene.pr_exit, AdPlacement.unload_1);
    }
  }

  Future<void> showLifecycleAd(AdScene adScene, AdPlacement positionId) async {
    final int lastOpenAdCloseTime = LastOpenAdCloseTime.readTime();
    final int hotCooldownMs = hotLaunchCooldownSeconds * 1000;
    if (DateTime.now().millisecondsSinceEpoch - lastOpenAdCloseTime <
        hotCooldownMs) {
      return;
    }
    await FlutterPdfAdPlugins.instance.closeFullScreenAdAndWait();
    AdService.instance.showCachedAd(adScene: adScene, adPosId: positionId);
  }
}
