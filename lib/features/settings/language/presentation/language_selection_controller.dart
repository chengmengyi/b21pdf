import 'package:b21pdf/features/settings/language/app_translations.dart';
import 'package:b21pdf/features/settings/language/supported_locales.dart';
import 'package:b21pdf/features/onboarding/services/onboarding_coordinator.dart';
import 'package:b21pdf/core/analytics/analytics_event.dart';
import 'package:b21pdf/core/analytics/analytics_service.dart';
import 'package:b21pdf/core/presentation/base_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LanguageSelectionController extends BaseController {
  final ScrollController languageScrollController = ScrollController();
  late SupportedLocale selectedLanguage;
  bool _hasScrolled = false;

  List<SupportedLocale> get languageList => LocaleUtilities.languageList;

  @override
  void onInit() {
    super.onInit();
    AnalyticsService.instance.trackEvent(
      pointType: AnalyticsEvent.lang_select_view,
    );
    final initialLocale = LocaleUtilities.initialLocale();
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

  void onLanguagePressed(SupportedLocale item) {
    selectedLanguage = item;
    update();
  }

  void scrollToSelectedLanguage() {
    if (_hasScrolled || !languageScrollController.hasClients) {
      return;
    }
    final index = languageList.indexWhere(isSelected);
    _hasScrolled = true;
    if (index <= 0) return;
    final targetOffset = index * 56.h;
    languageScrollController.animateTo(
      targetOffset.clamp(
        0.0,
        languageScrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> onOkPressed() async {
    AnalyticsService.instance.trackEvent(
      pointType: AnalyticsEvent.lang_select_click,
    );
    await AppTranslations.selectLanguage(selectedLanguage.locale);
    OnboardingCoordinator.instance.toPageOpenNotificationPermission();
  }

  @override
  void onClose() {
    languageScrollController.dispose();
    super.onClose();
  }
}
