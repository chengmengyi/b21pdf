import 'package:b21pdf/core/storage/preference_keys.dart';

abstract final class LastAdShowTimeCache {
  static int readTime() {
    return getStorage.read<int>(PreferenceKeys.lastAdShowTime) ?? 0;
  }

  static Future<void> saveTime({required int timestamp}) {
    return getStorage.write(PreferenceKeys.lastAdShowTime, timestamp);
  }
}
