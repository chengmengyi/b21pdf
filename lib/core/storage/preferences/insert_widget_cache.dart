import 'package:b21pdf/core/storage/preference_keys.dart';

abstract final class InsertWidgetCache {
  static bool readAdded() {
    return getStorage.read<bool>(PreferenceKeys.addWidget) ?? false;
  }

  static Future<void> saveAdded(bool added) {
    return getStorage.write(PreferenceKeys.addWidget, added);
  }
}
