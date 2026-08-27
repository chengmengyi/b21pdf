import 'package:b21pdf/core/storage/preference_keys.dart';

class LocaleSelected {
  const LocaleSelected._();

  static Future<void> saveLanguage(String languageTag) async {
    await getStorage.write(PreferenceKeys.languageSelectedfj, languageTag);
  }

  static String readLanguage() {
    return getStorage.read<String>(PreferenceKeys.languageSelectedfj) ?? '';
  }
}
