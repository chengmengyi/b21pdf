import 'package:b21pdf/core/ads/ad_scene.dart';
import 'package:b21pdf/core/ads/ad_placement.dart';

class StartupInteractionGate {
  StartupInteractionGate._();

  static final StartupInteractionGate instance = StartupInteractionGate._();

  bool _launcherAlive = true;
  bool _launcherAdShown = false;
  AdScene? _pendingAdScene;
  AdPlacement? _pendingAdPosId;

  bool get canHandleNotificationClick => !_launcherAlive || _launcherAdShown;

  void markLauncherStarted() {
    _launcherAlive = true;
    _launcherAdShown = false;
    _clearPendingAd();
  }

  void markLauncherAdWaiting({
    required AdScene adScene,
    required AdPlacement adPosId,
  }) {
    _launcherAdShown = false;
    _pendingAdScene = adScene;
    _pendingAdPosId = adPosId;
  }

  void markLauncherAdShownIfMatched({
    required AdScene adScene,
    required AdPlacement adPosId,
  }) {
    if (!_launcherAlive ||
        _pendingAdScene != adScene ||
        _pendingAdPosId != adPosId) {
      return;
    }
    _launcherAdShown = true;
    _clearPendingAd();
  }

  void markLauncherAdNotShown() {
    _launcherAdShown = false;
    _clearPendingAd();
  }

  void markLauncherClosed() {
    _launcherAlive = false;
    _clearPendingAd();
  }

  void _clearPendingAd() {
    _pendingAdScene = null;
    _pendingAdPosId = null;
  }
}
