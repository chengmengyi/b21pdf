import 'package:b21pdf/features/settings/language/presentation/language_picker_bottom_sheet.dart';
import 'package:b21pdf/core/navigation/app_navigator.dart';
import 'package:b21pdf/core/presentation/base_controller.dart';
import 'package:b21pdf/features/settings/language/supported_locales.dart';
import 'package:get/get.dart';

class ToolsTabController extends BaseController {
  String get currentLanguageName {
    final locale = LocaleUtilities.matchLocale(
      Get.locale ?? LocaleUtilities.initialLocale(),
    );
    return LocaleUtilities.languageList
        .firstWhere((item) => LocaleUtilities.isSameLocale(item.locale, locale))
        .name;
  }

  Future<void> onChangeLanguagePressed() async {
    await AppNavigator.showBottomSheet(child: LanguagePickerBottomSheet());
    update();
  }
}
