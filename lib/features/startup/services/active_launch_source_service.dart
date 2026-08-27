enum LaunchSourceType { notification, quickAction }

class LaunchSource {
  const LaunchSource({required this.type, this.payload, this.quickActionType});

  final LaunchSourceType type;
  final String? payload;
  final String? quickActionType;
}

class ActiveLaunchSourceService {
  ActiveLaunchSourceService._();

  static final ActiveLaunchSourceService _instance =
      ActiveLaunchSourceService._();
  static ActiveLaunchSourceService get instance => _instance;

  LaunchSource? _pendingSource;

  void recordNotificationLaunch(String payload) {
    _pendingSource = LaunchSource(
      type: LaunchSourceType.notification,
      payload: payload,
    );
  }

  void recordShortcutLaunch(String shortcutType) {
    _pendingSource = LaunchSource(
      type: LaunchSourceType.quickAction,
      quickActionType: shortcutType,
    );
  }

  LaunchSource? consumeLaunchSource() {
    final LaunchSource? source = _pendingSource;
    _pendingSource = null;
    return source;
  }

  clear() {
    _pendingSource = null;
  }
}
