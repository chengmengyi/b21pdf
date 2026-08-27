import 'package:b21pdf/core/storage/preference_keys.dart';

abstract final class LastOpenAdCloseTime {
  static int readTime() {
    return getStorage.read<int>(PreferenceKeys.lastOpenAdCloseTime) ?? 0;
  }

  static Future<void> saveTime(int timestamp) {
    return getStorage.write(PreferenceKeys.lastOpenAdCloseTime, timestamp);
  }
}
