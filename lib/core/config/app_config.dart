import 'package:flutter/foundation.dart';

class AppConfig {
  static const String applicationName = "Ai FileMaster";
  static const String secretKey = "B21Key";
  static String appsFlyerKey = kDebugMode ? "Ed2FymhzHg3qqYpyH8Z9Eg" : "a67D6na3iQchqMcfxtzDTP";

  static const String clockEndpoint = "https://guilford.pdfreaderscanner.net/josef/bleat";

  static const localReferrerConfigDebug = "assets/config/attribution/referrer_debug.json";
  static const localReferrerConfigRelease = "assets/config/attribution/referrer_release.json";
  static String localReferrerConfig = kDebugMode ? localReferrerConfigDebug : localReferrerConfigRelease;

  static const localAdConfigDebug = "assets/config/ads/placements_debug.json";
  static const localAdConfigRelease = "assets/config/ads/placements_release.json";
  static String localAdConfig = kDebugMode ? localAdConfigDebug : localAdConfigRelease;

  static const localAdSwitchDebug = "assets/config/ads/switches_debug.json";
  static const localAdSwitchRelease = "assets/config/ads/switches_release.json";
  static String localAdSwitch = kDebugMode ? localAdSwitchDebug : localAdSwitchRelease;

  static const tbaEndpointDebug = "https://test-cocoon.pdfreaderscanner.net/talky/tattle/hobart";
  static const tbaEndpointRelease = "https://cocoon.pdfreaderscanner.net/watkins/mastic/backup";
  static String tbaEndpoint = kDebugMode ? tbaEndpointDebug : tbaEndpointRelease;

  static const _b17DefaultNotificationConfigDebug = "assets/config/notifications/default_debug.json";
  static const _b17DefaultNotificationConfigRelease = "assets/config/notifications/default_release.json";
  static String defaultNotificationConfig = kDebugMode ? _b17DefaultNotificationConfigDebug : _b17DefaultNotificationConfigRelease;

  static const String fieldMappingConfig = "assets/config/notifications/field_mapping.json";

  static const String notificationConfigUrl="https://prod.pdfreaderscanner.net/ErneG/yLNjNp/drLrVME";

  static const String riskUrl="https://ip-prod.pdfreaderscanner.net/api/csnake";
}
