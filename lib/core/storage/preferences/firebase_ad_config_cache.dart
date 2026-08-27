import 'package:b21pdf/core/storage/preference_keys.dart';

abstract final class FirebaseAdConfigCache {
  static String readConfig() {
    return getStorage.read<String>(PreferenceKeys.firebaseAdConfig) ?? '';
  }

  static Future<void> saveConfig(String config) {
    return getStorage.write(PreferenceKeys.firebaseAdConfig, config);
  }
}
