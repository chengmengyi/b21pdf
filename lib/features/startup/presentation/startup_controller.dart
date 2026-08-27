import 'dart:async';

import 'package:b21pdf/core/ads/ad_service.dart';
import 'package:b21pdf/core/ads/ad_scene.dart';
import 'package:b21pdf/core/ads/ad_placement.dart';
import 'package:b21pdf/core/lifecycle/app_lifecycle_service.dart';
import 'package:b21pdf/core/events/app_event.dart';
import 'package:b21pdf/core/events/app_event_type.dart';
import 'package:b21pdf/features/startup/services/initial_launch_source_service.dart';
import 'package:b21pdf/features/startup/services/startup_interaction_gate.dart';
import 'package:b21pdf/features/onboarding/services/onboarding_coordinator.dart';
import 'package:b21pdf/features/shortcuts/services/shortcut_service.dart';
import 'package:b21pdf/core/analytics/analytics_event.dart';
import 'package:b21pdf/core/analytics/analytics_service.dart';
import 'package:b21pdf/core/presentation/base_controller.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_boom_notification_plugins/flutter_boom_notification_plugins.dart';
import 'package:flutter_pdf_ad_plugins/flutter_pdf_ad_plugins.dart';
import 'package:get/get.dart';

class StartupController extends BaseController
    with GetSingleTickerProviderStateMixin {
  static const String progressUpdateId = 'startup_progress';
  static const Duration launchDuration = Duration(seconds: 15);

  late final AnimationController progressController;
  late AdScene launchAdScene;
  late AdPlacement launchAdPosId;
  Duration newUserOpenAdCheckTime = const Duration(seconds: 12);
  bool navigationStarted = false;

  final Stopwatch _adCheckStopwatch = Stopwatch();
  Timer? _adCheckTimer;
  bool _checkingAd = false;
  bool _inBackground = false;

  double get progressValue => progressController.value;

  bool get _useNewLaunchAd => AdService.instance.loadNewLaunchAd;

  @override
  void onInit() {
    super.onInit();
    StartupInteractionGate.instance.markLauncherStarted();
    _resolveLaunchAdContext();
    AdService.instance.trackAdOpportunity(
      adScene: launchAdScene,
      adPosId: launchAdPosId,
    );
    progressController =
        AnimationController(vsync: this, duration: launchDuration)
          ..addListener(notifyProgressChanged)
          ..addStatusListener(onProgressAnimationStatusChanged)
          ..forward();
    _adCheckStopwatch.start();
    _adCheckTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => _checkLaunchAdCache(),
    );
  }

  void _resolveLaunchAdContext() {
    if (_useNewLaunchAd) {
      launchAdScene = AdScene.pr_new_launch;
      launchAdPosId = AdPlacement.pr_new_open;
      return;
    }

    final String notificationPayload =
        InitialLaunchSourceService.instance.notificationPayload ?? '';
    if (notificationPayload.isNotEmpty) {
      launchAdScene = AdScene.pr_launch;
      launchAdPosId =
          notificationPayload == LocalNotificationPayload.media.value
          ? AdPlacement.pr_open_mediapop
          : AdPlacement.pr_open_noti;
      return;
    }

    final String quickActionType =
        InitialLaunchSourceService.instance.quickActionType ?? '';
    if (quickActionType.isNotEmpty) {
      launchAdScene = AdScene.pr_exit;
      launchAdPosId = AdPlacement.unload_1;
      return;
    }

    launchAdScene = AdScene.pr_launch;
    launchAdPosId = AdPlacement.pr_open_cold;
  }

  void notifyProgressChanged() {
    update([progressUpdateId]);
  }

  void onProgressAnimationStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed || navigationStarted) {
      return;
    }
    navigationStarted = true;
    _adCheckTimer?.cancel();
    _handleLaunchAdDeadline();
  }

  Future<void> _checkLaunchAdCache() async {
    if (navigationStarted || _inBackground || _checkingAd) {
      return;
    }
    _checkingAd = true;
    final AdScene scene = _resolveCurrentAdScene();
    final AdPlacement posId = _resolvePlacementForScene(scene);
    final bool hasAd = await _hasCachedLaunchAd(scene);
    _checkingAd = false;
    if (!hasAd || navigationStarted) {
      return;
    }
    navigationStarted = true;
    await _showResolvedLaunchAd(scene, posId);
  }

  AdScene _resolveCurrentAdScene() {
    if (_useNewLaunchAd && _adCheckStopwatch.elapsed < newUserOpenAdCheckTime) {
      return AdScene.pr_new_launch;
    }
    if (_useNewLaunchAd) {
      return AdScene.pr_launch;
    }
    return launchAdScene;
  }

  AdPlacement _resolvePlacementForScene(AdScene scene) {
    if (scene == AdScene.pr_new_launch) {
      return AdPlacement.pr_new_open;
    }
    if (_useNewLaunchAd && scene == AdScene.pr_launch) {
      return AdPlacement.pr_open_cold;
    }
    return launchAdPosId;
  }

  Future<bool> _hasCachedLaunchAd(AdScene scene) async {
    try {
      final AdInfoBean? cachedAd = await FlutterPdfAdPlugins.instance
          .getAvailableCachedAdInfo<AdScene>(scene);
      return cachedAd != null;
    } catch (_) {
      return false;
    }
  }

  Future<void> _handleLaunchAdDeadline() async {
    if (_useNewLaunchAd) {
      if (newUserOpenAdCheckTime >= launchDuration) {
        final bool hasNewAd = await _hasCachedLaunchAd(AdScene.pr_new_launch);
        if (hasNewAd) {
          await _showResolvedLaunchAd(
            AdScene.pr_new_launch,
            AdPlacement.pr_new_open,
          );
          return;
        }
      }
      final bool hasFallbackAd = await _hasCachedLaunchAd(AdScene.pr_launch);
      if (hasFallbackAd) {
        await _showResolvedLaunchAd(
          AdScene.pr_launch,
          AdPlacement.pr_open_cold,
        );
        return;
      }
    } else if (await _hasCachedLaunchAd(launchAdScene)) {
      await _showResolvedLaunchAd(launchAdScene, launchAdPosId);
      return;
    }
    await completeStartup();
  }

  Future<void> _showResolvedLaunchAd(AdScene scene, AdPlacement posId) async {
    _adCheckTimer?.cancel();
    _adCheckStopwatch.stop();
    if (progressController.isAnimating) {
      progressController.stop(canceled: false);
    }
    StartupInteractionGate.instance.markLauncherAdWaiting(
      adScene: scene,
      adPosId: posId,
    );
    final bool? didShowAd = await AdService.instance.showCachedAd(
      adScene: scene,
      adPosId: posId,
      uploadChance: false,
    );
    if (didShowAd != true) {
      StartupInteractionGate.instance.markLauncherAdNotShown();
    }
    await completeStartup();
  }

  Future<void> completeStartup() async {
    AdService.instance.preloadScene(AdScene.pr_user_use);
    AnalyticsService.instance.trackEvent(
      pointType: AnalyticsEvent.app_launch_result,
    );
    var result = await ShortcutService.instance
        .handlePendingColdStartShortcut();
    if (result) {
      return;
    }
    OnboardingCoordinator.instance.openLanguageSelection();
  }

  @override
  bool subscribesToAppEvents() => true;

  @override
  // ignore: avoid_renaming_method_parameters
  void onAppEvent(AppEvent event) {
    if (event.type == AppEventType.newOpenAdCheckTime) {
      final int seconds = event.intValue ?? 0;
      if (seconds > 0) {
        newUserOpenAdCheckTime = Duration(seconds: seconds);
      }
      return;
    }
    if (event.type != AppEventType.appLifecycle) {
      return;
    }
    _inBackground = event.intValue == 1;
    if (_inBackground) {
      _adCheckStopwatch.stop();
      progressController.stop(canceled: false);
    } else {
      _adCheckStopwatch.start();
      if (!progressController.isCompleted && !progressController.isAnimating) {
        progressController.forward();
      }
    }
  }

  @override
  void onClose() {
    AppLifecycleService.instance.startObservingLifecycle();
    StartupInteractionGate.instance.markLauncherClosed();
    _adCheckTimer?.cancel();
    _adCheckStopwatch.stop();
    progressController
      ..removeListener(notifyProgressChanged)
      ..removeStatusListener(onProgressAnimationStatusChanged)
      ..dispose();
    super.onClose();
  }
}
