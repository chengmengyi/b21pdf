import 'package:b21pdf/core/config/app_config.dart';
import 'package:b21pdf/core/ads/ad_service.dart';
import 'package:b21pdf/core/user/user_eligibility_service.dart';
import 'package:b21pdf/core/firebase/firebase_service.dart';
import 'package:b21pdf/features/settings/language/app_translations.dart';
import 'package:b21pdf/features/startup/services/initial_launch_source_service.dart';
import 'package:b21pdf/features/shortcuts/services/shortcut_service.dart';
import 'package:b21pdf/core/navigation/app_routes.dart';
import 'package:b21pdf/core/analytics/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:b21pdf/features/notifications/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await GetStorage.init();
  await InitialLaunchSourceService.instance.initialize();
  FirebaseService.instance.initialize();
  AdService.instance.initialize();
  await ShortcutService.instance.initialize();
  UserEligibilityService.instance.initializeAttribution();
  final Locale initialLocale = AppTranslations.resolveInitialLocale();
  NotificationService.instance.initialize(requestPermission: true);
  AnalyticsService.instance.trackInstall();
  NotificationService.instance.trackInitialNotificationEvent();

  runApp(PdfApplication(initialLocale: initialLocale));
}

class PdfApplication extends StatelessWidget {
  const PdfApplication({super.key, required this.initialLocale});

  final Locale initialLocale;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 780),
      builder: (BuildContext context, Widget? child) => RefreshConfiguration(
        springDescription: const SpringDescription(
          mass: 0.8,
          stiffness: 150,
          damping: 20.0,
        ),
        child: GetMaterialApp(
          title: AppConfig.applicationName,
          enableLog: true,
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          translations: AppTranslations(),
          locale: initialLocale,
          fallbackLocale: AppTranslations.fallbackLocale,
          supportedLocales: AppTranslations.supportedLocales,
          initialRoute: AppRoutes.launcherRoute,
          getPages: AppRoutes.pages,
          defaultTransition: Transition.rightToLeft,
          localizationsDelegates: const [
            RefreshLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (BuildContext context, Widget? widget) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.0)),
              child: widget ?? const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }
}
