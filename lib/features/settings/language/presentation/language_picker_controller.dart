import 'package:b21pdf/features/settings/language/app_translations.dart';
import 'package:b21pdf/features/settings/language/supported_locales.dart';
import 'package:b21pdf/core/navigation/app_navigator.dart';
import 'package:b21pdf/core/storage/preferences/locale_selected.dart';
import 'package:b21pdf/core/presentation/base_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LanguagePickerController extends BaseController {
  final ScrollController languageScrollController = ScrollController();
  late SupportedLocale selectedLanguage;
  bool _hasScrolled = false;

  List<SupportedLocale> get languageList => LocaleUtilities.languageList;

  @override
  void onInit() {
    super.onInit();
    final storedLanguage = LocaleSelected.readLanguage();
    final initialLocale = storedLanguage.isEmpty
        ? LocaleUtilities.initialLocale()
        : LocaleUtilities.matchLocale(_parseLocale(storedLanguage));
    selectedLanguage = languageList.firstWhere(
      (item) => LocaleUtilities.isSameLocale(item.locale, initialLocale),
      orElse: () => languageList.first,
    );
  }

  @override
  void onReady() {
    super.onReady();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => scrollToSelectedLanguage(),
    );
  }

  bool isSelected(SupportedLocale item) =>
      LocaleUtilities.isSameLocale(selectedLanguage.locale, item.locale);

  void scrollToSelectedLanguage() {
    if (_hasScrolled || !languageScrollController.hasClients) {
      return;
    }
    _hasScrolled = true;
    final index = languageList.indexWhere(isSelected);
    if (index <= 0) return;
    languageScrollController.animateTo(
      (index * 56.h).clamp(
        0.0,
        languageScrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> onLanguagePressed(SupportedLocale item) async {
    selectedLanguage = item;
    update();
    await AppTranslations.selectLanguage(item.locale);
    AppNavigator.back();
  }

  Locale _parseLocale(String tag) {
    final parts = tag.replaceAll('_', '-').split('-');
    return Locale(
      parts.first.toLowerCase(),
      parts.length > 1 ? parts[1].toUpperCase() : null,
    );
  }

  @override
  void onClose() {
    languageScrollController.dispose();
    super.onClose();
  }
}
