import 'dart:async';

import 'package:b21pdf/features/settings/language/app_translations.dart';
import 'package:b21pdf/features/startup/services/initial_launch_source_service.dart';
import 'package:b21pdf/features/startup/services/active_launch_source_service.dart';
import 'package:b21pdf/core/navigation/app_routes.dart';
import 'package:b21pdf/core/navigation/app_navigator.dart';
import 'package:flutter_add_widget_plugins/flutter_add_widget_plugins.dart';

class ShortcutService {
  static final ShortcutService _instance = ShortcutService();
  static ShortcutService get instance => _instance;

  static const String uninstallType = 'uninstall';

  final QuickActions _quickActions = const QuickActions();
  Future<void>? _initializeFuture;
  String? _pendingType;
  bool _initialized = false;
  bool _launcherFinished = false;

  Future<void> initialize() {
    _initializeFuture ??= _initializeInternal();
    return _initializeFuture!;
  }

  Future<void> _initializeInternal() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    await _quickActions.initialize((String shortcutType) {
      if (!_launcherFinished) {
        _pendingType = shortcutType;
        InitialLaunchSourceService.instance.recordShortcutLaunch(shortcutType);
        return;
      }
      ActiveLaunchSourceService.instance.recordShortcutLaunch(shortcutType);
      unawaited(_routeShortcut(shortcutType, fromColdStart: false));
    });
    await updateShortcuts();
  }

  Future<bool> handlePendingColdStartShortcut() async {
    await initialize();
    _launcherFinished = true;
    final String? shortcutType = _pendingType;
    _pendingType = null;
    if (shortcutType == null || shortcutType.isEmpty) {
      return false;
    }
    return _routeShortcut(shortcutType, fromColdStart: true);
  }

  Future<bool> _routeShortcut(
    String shortcutType, {
    required bool fromColdStart,
  }) async {
    if (shortcutType != uninstallType) {
      return false;
    }
    if (fromColdStart) {
      InitialLaunchSourceService.instance.recordShortcutLaunch(shortcutType);
      await AppNavigator.replaceNamed(routeName: AppRoutes.uninstallRoute);
    } else {
      await AppNavigator.pushNamed(routeName: AppRoutes.uninstallRoute);
    }
    return true;
  }

  Future<void> updateShortcuts() async {
    final locale = AppTranslations.resolveInitialLocale();
    final localeKey = locale.toString();
    final uninstallTitle =
        AppTranslations().keys[localeKey]?['Uninstall'] ?? 'Uninstall';
    await _quickActions.setShortcutItems(<ShortcutItem>[
      ShortcutItem(
        type: uninstallType,
        localizedTitle: uninstallTitle,
        icon: "uninstall_icon",
      ),
    ]);
  }
}
