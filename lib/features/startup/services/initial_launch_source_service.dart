import 'package:flutter_boom_notification_plugins/flutter_boom_notification_plugins.dart';

class InitialLaunchSourceService {
  static final InitialLaunchSourceService _instance =
      InitialLaunchSourceService();
  static InitialLaunchSourceService get instance => _instance;

  String? notificationPayload;
  String? quickActionType;

  void recordShortcutLaunch(String shortcutType) {
    quickActionType = shortcutType;
  }

  Future<void> initialize() async {
    await _initializeNotificationLaunchSource();
  }

  Future<void> _initializeNotificationLaunchSource() async {
    var localNotificationAppLaunchDetails = await FlutterBoomNotificationPlugins
        .instance
        .getNotificationAppLaunchDetails();
    if (localNotificationAppLaunchDetails.didNotificationLaunchApp == true) {
      notificationPayload =
          localNotificationAppLaunchDetails.notificationResponse?.payload ??
          localNotificationAppLaunchDetails
              .notificationResponse
              ?.payloadType
              ?.name;
    }
  }
}
