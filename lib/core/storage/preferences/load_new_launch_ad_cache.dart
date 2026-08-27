import 'package:b21pdf/core/storage/preference_keys.dart';

abstract final class LoadNewLaunchAdCache {
  static bool readEnabled() {
    return getStorage.read<bool>(PreferenceKeys.loadNewLaunchAd) ?? true;
  }

  static Future<void> saveEnabled(bool enabled) {
    return getStorage.write(PreferenceKeys.loadNewLaunchAd, enabled);
  }
}
