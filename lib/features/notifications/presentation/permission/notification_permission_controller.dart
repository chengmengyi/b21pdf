import 'package:b21pdf/features/onboarding/services/onboarding_coordinator.dart';
import 'package:b21pdf/core/events/app_event.dart';
import 'package:b21pdf/core/events/app_event_type.dart';
import 'package:b21pdf/core/navigation/app_navigator.dart';
import 'package:b21pdf/core/analytics/analytics_event.dart';
import 'package:b21pdf/core/analytics/analytics_service.dart';
import 'package:b21pdf/core/presentation/base_controller.dart';
import 'package:app_settings/app_settings.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationPermissionController extends BaseController {
  bool _waitingSettings = false;
  bool _enteredBackground = false;
  bool _checkingPermission = false;

  @override
  void onInit() {
    super.onInit();
    AnalyticsService.instance.trackEvent(
      pointType: AnalyticsEvent.pushGuideView,
      parameters: {"show_type": "secondary"},
    );
  }

  Future<void> onUpdatePressed() async {
    AnalyticsService.instance.trackEvent(
      pointType: AnalyticsEvent.pushGuideClick,
      parameters: {"state": "turn_on"},
    );
    _waitingSettings = true;
    _enteredBackground = false;
    await AppSettings.openAppSettings(type: AppSettingsType.notification);
  }

  void onLaterPressed() {
    AnalyticsService.instance.trackEvent(
      pointType: AnalyticsEvent.pushGuideClick,
      parameters: {"state": "later"},
    );
    _toNextPage();
  }

  @override
  bool subscribesToAppEvents() => true;

  @override
  void onAppEvent(AppEvent event) {
    if (event.type != AppEventType.appLifecycle || !_waitingSettings) {
      return;
    }

    if (event.intValue == 1) {
      _enteredBackground = true;
      return;
    }

    if (event.intValue == 0 && _enteredBackground && !_checkingPermission) {
      _checkNotificationPermission();
    }
  }

  Future<void> _checkNotificationPermission() async {
    _checkingPermission = true;
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final PermissionStatus permissionStatus =
        await Permission.notification.status;
    final bool permissionGranted =
        permissionStatus.isGranted || permissionStatus.isLimited;

    _waitingSettings = false;
    _enteredBackground = false;
    _checkingPermission = false;
    if (permissionGranted) {
      _toNextPage();
    }
  }

  _toNextPage() {
    var fromHome = AppNavigator.routeArguments()["fromHome"] ?? false;
    if (fromHome) {
      AppNavigator.back();
    } else {
      OnboardingCoordinator.instance.openHome();
    }
  }
}
