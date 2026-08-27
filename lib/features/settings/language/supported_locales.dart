import 'dart:ui';

import 'package:b21pdf/core/storage/preferences/locale_selected.dart';

class SupportedLocale {
  const SupportedLocale({
    required this.name,
    required this.icon,
    required this.locale,
  });

  final String name;
  final String icon;
  final Locale locale;
}

abstract final class LocaleUtilities {
  static const Locale fallbackLocale = Locale('en');

  static const List<SupportedLocale> languageList = [
    SupportedLocale(
      name: 'English',
      icon: 'languages/flags/english',
      locale: Locale('en'),
    ),
    SupportedLocale(
      name: 'Français',
      icon: 'languages/flags/french',
      locale: Locale('fr'),
    ),
    SupportedLocale(
      name: '日本語',
      icon: 'languages/flags/japanese',
      locale: Locale('ja'),
    ),
    SupportedLocale(
      name: '한국어',
      icon: 'languages/flags/korean',
      locale: Locale('ko'),
    ),
    SupportedLocale(
      name: 'Deutsch',
      icon: 'languages/flags/german',
      locale: Locale('de'),
    ),
    SupportedLocale(
      name: 'Español',
      icon: 'languages/flags/spanish',
      locale: Locale('es'),
    ),
    SupportedLocale(
      name: 'Italiano',
      icon: 'languages/flags/italian',
      locale: Locale('it'),
    ),
    SupportedLocale(
      name: 'Português',
      icon: 'languages/flags/portuguese',
      locale: Locale('pt'),
    ),
    SupportedLocale(
      name: 'Русский',
      icon: 'languages/flags/russian',
      locale: Locale('ru'),
    ),
    SupportedLocale(
      name: '繁體中文',
      icon: 'languages/flags/chinese_traditional',
      locale: Locale('zh', 'TW'),
    ),
    SupportedLocale(
      name: '简体中文',
      icon: 'languages/flags/chinese_simplified',
      locale: Locale('zh', 'CN'),
    ),
    SupportedLocale(
      name: 'العربية',
      icon: 'languages/flags/arabic',
      locale: Locale('ar'),
    ),
  ];

  static Locale initialLocale() {
    final savedTag = LocaleSelected.readLanguage();
    if (savedTag.isNotEmpty) {
      return matchLocale(_parseLocale(savedTag));
    }
    return matchLocale(PlatformDispatcher.instance.locale);
  }

  static Locale matchLocale(Locale locale) {
    for (final item in languageList) {
      if (isSameLocale(item.locale, locale)) {
        return item.locale;
      }
    }
    if (locale.languageCode == 'zh') {
      final useTraditional =
          const {'TW', 'HK', 'MO'}.contains(locale.countryCode) ||
          locale.scriptCode == 'Hant';
      return Locale('zh', useTraditional ? 'TW' : 'CN');
    }
    for (final item in languageList) {
      if (item.locale.languageCode == locale.languageCode) {
        return item.locale;
      }
    }
    return fallbackLocale;
  }

  static bool isSameLocale(Locale? left, Locale right) =>
      left?.languageCode == right.languageCode &&
      left?.countryCode == right.countryCode;

  static String localeTag(Locale locale) => locale.toLanguageTag();

  static Locale _parseLocale(String tag) {
    final parts = tag.replaceAll('_', '-').split('-');
    return Locale(
      parts.first.toLowerCase(),
      parts.length > 1 ? parts[1].toUpperCase() : null,
    );
  }
}
