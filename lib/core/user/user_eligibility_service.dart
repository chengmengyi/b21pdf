import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:b21pdf/core/ads/ad_service.dart';
import 'package:b21pdf/core/events/app_event.dart';
import 'package:b21pdf/core/events/app_event_type.dart';
import 'package:b21pdf/core/events/app_event_bus.dart';
import 'package:b21pdf/core/config/app_config.dart';
import 'package:b21pdf/core/overlay/overlay_service.dart';
import 'package:b21pdf/features/notifications/services/notification_service.dart';
import 'package:b21pdf/core/storage/preferences/referrer_config.dart';
import 'package:b21pdf/core/analytics/analytics_event.dart';
import 'package:b21pdf/core/analytics/analytics_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_check_af_new/callback/request_callback.dart';
import 'package:flutter_check_af_new/flutter_check_af_new.dart';
import 'package:flutter_check_af_new/request_af/request_af_callback.dart';
import 'package:flutter_check_af_new/request_cloak/request_cloak_callback.dart';
import 'package:flutter_check_af_new/request_referrer/request_referrer_callback.dart';
import 'package:flutter_pdf_ad_plugins/flutter_pdf_ad_plugins.dart';
import 'package:flutter_pdf_risk_control_plugins/callbacks/flutter_pdf_risk_control_callback.dart';
import 'package:flutter_pdf_risk_control_plugins/flutter_pdf_risk_control_plugins.dart';
import 'package:flutter_pdf_risk_control_plugins/models/flutter_pdf_risk_control_ip_config.dart';
import 'package:flutter_pdf_risk_control_plugins/utils/flutter_pdf_risk_control_tag.dart';
import 'package:flutter_tba_info/flutter_tba_info.dart';

class UserEligibilityService {
  UserEligibilityService._();
  static final UserEligibilityService instance = UserEligibilityService._();

  bool _isEligibleUser = false;

  bool get isEligibleUser {
    if (kDebugMode) {
      return true;
    }
    return _isEligibleUser;
  }

  Future<void> initializeAttribution() async {
    applyReferrerConfig();
    refreshEligibilityState();
    final String distinctId = await FlutterTbaInfo.instance.getDistinctId();
    FlutterCheckAf.instance.init(
      afKey: AppConfig.appsFlyerKey,
      afAppId: "",
      distinctId: distinctId,
      clockUrl: AppConfig.clockEndpoint,
      cloakWhiteKey: 'eurasia',
      cloakData: <String, dynamic>{
        'pershing': await FlutterTbaInfo.instance.getBundleId(),
        'span': Platform.isAndroid ? 'haggle' : 'not',
        'andersen': await FlutterTbaInfo.instance.getAppVersion(),
        'zagging': distinctId,
        'prophecy': DateTime.now().millisecondsSinceEpoch,
      },
      requestCallback: RequestCallback(
        requestAfCallback: RequestAfCallback(
          startRequestAf: () {
            AnalyticsService.instance.trackEvent(
              pointType: AnalyticsEvent.af_req,
            );
          },
          requestSuccess: (bool isAttributedUser, String afStr) {
            AnalyticsService.instance.trackEvent(
              pointType: AnalyticsEvent.af_suc,
              parameters: {
                //adj_user：【0】【1】，对应【黑名单用户】【自然量用户】
                "af_user": isAttributedUser ? 1 : 0,
                "af_info": afStr,
              },
            );
            FlutterPdfAdPlugins.instance.updateAdjustAttribution(
              network: afStr,
            );
            refreshEligibilityState();
          },
          firstRequestAfB: () {},
          startAfSuccess: () {
            AnalyticsService.instance.trackEvent(
              pointType: AnalyticsEvent.start_af_suc,
            );
          },
          startAfFail: (int code, String msg) {
            AnalyticsService.instance.trackEvent(
              pointType: AnalyticsEvent.start_af_fail,
              parameters: {"code": code, "msg": msg},
            );
          },
        ),
        requestCloakCallback: RequestCloakCallback(
          startRequestCloak: () {
            AnalyticsService.instance.trackEvent(
              pointType: AnalyticsEvent.cloak_req,
            );
          },
          requestSuccess: (bool isAllowedUser) {
            AnalyticsService.instance.trackEvent(
              pointType: AnalyticsEvent.cloak_suc,
              parameters: {
                //cloak_user：【0】【1】，对应【黑名单用户】【自然量用户】
                "cloak_user": isAllowedUser ? 1 : 0,
              },
            );
            refreshEligibilityState();
          },
        ),
        requestReferrerCallback: RequestReferrerCallback(
          startRequestReferrer: () {
            AnalyticsService.instance.trackEvent(
              pointType: AnalyticsEvent.referrer_req,
            );
          },
          requestSuccess: (String referrer) {
            _trackReferrerResult(referrer);
            FlutterPdfAdPlugins.instance.updateInstallReferrer(
              referrer: referrer,
            );
            refreshEligibilityState();
          },
        ),
      ),
    );
  }

  Future<void> initializeRiskControl(String riskConfig) async {
    FlutterPdfRiskControlPlugins.instance.initPdfRiskControl(
      riskConfigJson: riskConfig,
      ipConfig: FlutterPdfRiskControlIpConfig(
        requestUrl: 'https://ip-prod.pdfreaderscanner.net/api/csnake',
        requestData: <String, String>{
          'aape': await FlutterTbaInfo.instance.getAndroidId(),
        },
        riskResultKey: 'bcat',
        decryptCode: 67,
      ),
      callback: FlutterPdfRiskControlCallback(
        onUploadSessionRisk: (Map<String, int> riskSummary) {},
        onPdfRiskDetected: (FlutterPdfRiskControlTag riskTag) {
          AnalyticsService.instance.trackEvent(
            pointType: AnalyticsEvent.risk_control,
            //type：vpn、root、sim、simulator、googleplay、developer、ip
            parameters: {"risk_type": riskTag.name},
          );
          refreshEligibilityState();
        },
      ),
    );
  }

  Future<void> applyReferrerConfig() async {
    try {
      final String configText = await loadReferrerConfig();
      final dynamic configJson = jsonDecode(configText);
      final dynamic referrerValues = configJson['ilve'];
      final List<String> referrerList = <String>[];
      if (referrerValues is List) {
        for (final dynamic value in referrerValues) {
          if (value is String) {
            referrerList.add(value);
          }
        }
      }
      FlutterCheckAf.instance.updateReferrerList(
        configJson['door'] == 0,
        referrerList,
      );
    } catch (_) {}
  }

  Future<String> loadReferrerConfig() async {
    final String storedConfig = ReferrerConfig.read();
    if (storedConfig.isNotEmpty) {
      return storedConfig;
    }
    return rootBundle.loadString(AppConfig.localReferrerConfig);
  }

  void refreshEligibilityState() {
    final bool checkResult = FlutterCheckAf.instance.checkUser();
    final bool hasSavedRisk = FlutterPdfRiskControlPlugins.instance
        .hasSavedPdfRisk();
    if (kDebugMode) {
      debugPrint(
        'refresh_b_user_state checkUser:$checkResult '
        'hasSavedPdfRisk:$hasSavedRisk',
      );
    }
    final bool newEligibilityState = checkResult && !hasSavedRisk;
    AnalyticsService.instance.setEligibleUser(newEligibilityState);
    if (_isEligibleUser == newEligibilityState) {
      return;
    }
    _isEligibleUser = newEligibilityState;
    AppEventBus.instance.publish(
      AppEvent(
        type: AppEventType.refreshBUserState,
        boolValue: newEligibilityState,
      ),
    );

    NotificationService.instance.initialize();
    AdService.instance.preloadEligibleUserAds();
    if (newEligibilityState) {
      unawaited(
        OverlayService.instance.initializeTimerOverlay(),
      );
    }
  }

  Future<void> _trackReferrerResult(String referrer) async {
    try {
      final String configText = await loadReferrerConfig();
      final dynamic json = jsonDecode(configText);
      final dynamic ilve = json["ilve"];
      if (ilve is List) {
        int referrerUser = 0;
        for (final dynamic value in ilve) {
          if (value is String && referrer.contains(value)) {
            referrerUser = 1;
            break;
          }
        }
        AnalyticsService.instance.trackEvent(
          pointType: AnalyticsEvent.reffer_suc,
          parameters: {"reffer_info": referrer, "reffer_user": referrerUser},
        );
      } else {
        AnalyticsService.instance.trackEvent(
          pointType: AnalyticsEvent.reffer_suc,
          parameters: {"reffer_info": referrer, "reffer_user": "list is empty"},
        );
      }
    } catch (e) {
      AnalyticsService.instance.trackEvent(
        pointType: AnalyticsEvent.reffer_suc,
        parameters: {"reffer_info": referrer, "reffer_user": "error"},
      );
    }
  }
}
