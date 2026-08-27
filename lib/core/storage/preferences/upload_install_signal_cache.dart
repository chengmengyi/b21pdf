import 'package:b21pdf/core/storage/preference_keys.dart';

abstract final class UploadInstallSignalCache {
  static bool readEnabled() {
    return getStorage.read<bool>(PreferenceKeys.uploadInstallEvent) ?? true;
  }

  static Future<void> saveEnabled(bool enabled) {
    return getStorage.write(PreferenceKeys.uploadInstallEvent, enabled);
  }
}
