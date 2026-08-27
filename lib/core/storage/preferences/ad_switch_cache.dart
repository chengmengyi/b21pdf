import 'package:b21pdf/core/storage/preference_keys.dart';

abstract final class AdSwitchCache {
  static String readConfig() {
    return getStorage.read<String>(PreferenceKeys.adSwitch) ?? '';
  }

  static Future<void> saveConfig(String config) {
    return getStorage.write(PreferenceKeys.adSwitch, config);
  }
}
