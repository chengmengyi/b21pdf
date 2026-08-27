import 'package:b21pdf/core/storage/preference_keys.dart';

class ReferrerConfig {
  const ReferrerConfig._();

  static Future<void> save(String config) async {
    await getStorage.write(PreferenceKeys.referrerConfig, config);
  }

  static String read() {
    return getStorage.read<String>(PreferenceKeys.referrerConfig) ?? '';
  }
}
