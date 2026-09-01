import 'dart:io';

import 'package:b21pdf/core/ads/ad_scene.dart';
import 'package:b21pdf/core/ads/ad_placement.dart';
import 'package:b21pdf/core/config/app_config.dart';
import 'package:b21pdf/core/storage/preferences/upload_install_signal_cache.dart';
import 'package:b21pdf/core/analytics/analytics_event.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_pdf_ad_plugins/bean/ad_info_bean.dart';
import 'package:flutter_tba_info/flutter_tba_info.dart';

class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService _instance = AnalyticsService._();
  static AnalyticsService get instance => _instance;

  final Dio _dioClient = Dio();

  Future<void> trackInstall() async {
    incrementLifetimeDays();
    trackSession();
    if (!UploadInstallSignalCache.readEnabled()) {
      return;
    }

    final Map<String, dynamic> requestBody = await _buildCommonPayload();
    final Map<dynamic, dynamic> referrerData = await FlutterTbaInfo.instance
        .getReferrerMap();
    requestBody['captive'] = <String, dynamic>{
      'hall': referrerData['build'],
      'genial': referrerData['install_begin_timestamp_seconds'],
      'renal': referrerData['install_begin_timestamp_server_seconds'],
      'inbreed': referrerData['install_first_seconds'],
      'hubbell': referrerData['install_version'],
      'puberty': referrerData['last_update_seconds'],
      "hoax":"hopkins",
      'harrow': referrerData['referrer_click_timestamp_seconds'],
      'holdover': referrerData['referrer_click_timestamp_server_seconds'],
      'grasp': referrerData['referrer_url'],
      'ogden': referrerData['user_agent'],
    };

    final bool uploaded = await _sendWithRetry(
      body: requestBody,
      eventType: 'install',
      eventName: 'install',
    );
    if (uploaded) {
      await UploadInstallSignalCache.saveEnabled(false);
    }
  }

  Future<void> trackSession() async {
    final Map<String, dynamic> requestBody = await _buildCommonPayload();
    requestBody['osgood'] = {};
    await _sendWithRetry(
      body: requestBody,
      eventType: 'session',
      eventName: 'session',
    );
  }

  Future<void> trackAdRevenue({
    required AdInfoBean adInfo,
    required AdScene adScene,
    required AdPlacement? positionId,
    required double revenue,
    required String currency,
    required String adNetwork,
    required String precision,
  }) async {
    final Map<String, dynamic> requestBody = await _buildCommonPayload();
    requestBody['mitchell'] = <String, dynamic>{
      'aaa': revenue * 1000000,
      'payoff': currency,
      'thered': adNetwork,
      'nomadic': adInfo.adPlat ?? '',
      'gothic': adInfo.adId ?? '',
      'larval': positionId?.name ?? '',
      'surtax': adScene.name,
      'use': precision,
      'della': adInfo.adType,
    };
    await _sendWithRetry(
      body: requestBody,
      eventType: 'ad',
      eventName: adScene.name,
    );
  }

  Future<void> trackEvent({
    required AnalyticsEvent pointType,
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? userGroup,
  }) async {
    var requestBody = await createEventPayload(
      pointType: pointType,
      parameters: parameters,
      userGroup: userGroup,
    );
    await _sendWithRetry(
      body: requestBody,
      eventType: 'point',
      eventName: pointType.name,
    );
  }

  Future<Map<String, dynamic>> createEventPayload({
    required AnalyticsEvent pointType,
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? userGroup,
  }) async {
    final Map<String, dynamic> requestBody = await _buildCommonPayload();
    requestBody['t'] = pointType.name;
    parameters?.forEach((String key, dynamic value) {
      requestBody['$key&senate'] = value;
    });
    if (null != userGroup) {
      requestBody["ds"] = userGroup;
    }
    return requestBody;
  }

  Future<bool> _sendWithRetry({
    required Map<String, dynamic> body,
    required String eventType,
    required String eventName,
  }) async {
    final Map<String, dynamic> headers = await buildRequestHeaders();
    final String requestUrl = await buildEndpointUrl();

    for (int attempt = 1; attempt <= 5; attempt++) {
      try {
        debugPrint(
          'tba-$eventType-$eventName-'
          '请求前-$body-',
        );
        final Response<dynamic> response = await _dioClient.post<dynamic>(
          requestUrl,
          data: body,
          options: Options(
            headers: headers,
            contentType: Headers.jsonContentType,
          ),
        );
        final int? statusCode = response.statusCode;
        if (statusCode != null && statusCode >= 200 && statusCode < 300) {
          debugPrint(
            'tba-$eventType-$eventName-'
            '请求结果-true-$body-${response.data}',
          );
          return true;
        }
        debugPrint(
          'tba-$eventType-$eventName-'
          '请求结果-false-$body-${response.data}',
        );
      } catch (requestError) {
        debugPrint(
          'tba-$eventType-$eventName-'
          '请求结果-false-$body-$requestError',
        );
      }

      if (attempt < 5) {
        await Future<void>.delayed(const Duration(seconds: 1));
      }
    }
    return false;
  }

  Future<Map<String, dynamic>> _buildCommonPayload() async {
    return {
      "shrift": await FlutterTbaInfo.instance.getAndroidId(),
      "prolix": await FlutterTbaInfo.instance.getAppVersion(),
      "estoppal": await FlutterTbaInfo.instance.getBrand(),
      "famine": await FlutterTbaInfo.instance.getBundleId(),
      "cortical": DateTime.now().millisecondsSinceEpoch,
      "omega": await FlutterTbaInfo.instance.getDeviceModel(),
      "newcomer": await FlutterTbaInfo.instance.getDistinctId(),
      "canticle": await FlutterTbaInfo.instance.getGaid(),
      "quality": await FlutterTbaInfo.instance.getIdfa(),
      "sanford": await FlutterTbaInfo.instance.getIdfv(),
      "kemp": await FlutterTbaInfo.instance.getLogId(),
      "locutor": await FlutterTbaInfo.instance.getManufacturer(),
      "caste": await FlutterTbaInfo.instance.getOperator(),
      "gratuity": Platform.isAndroid?"attain":"ho",
      "turnover": await FlutterTbaInfo.instance.getOsCountry(),
      "peat": await FlutterTbaInfo.instance.getOsVersion(),
      "scythe": await FlutterTbaInfo.instance.getSystemLanguage(),
    };
  }

  Future<Map<String, String>> buildRequestHeaders() async {
    return <String, String>{
      'peat': await FlutterTbaInfo.instance.getOsVersion(),
    };
  }

  Future<String> buildEndpointUrl() async {
    return '${AppConfig.tbaEndpoint}?newcomer=${await FlutterTbaInfo.instance.getDistinctId()}&caste=${await FlutterTbaInfo.instance.getOperator()}';
  }

  addUserGroup(int userGroup) async {
    trackEvent(
      pointType: AnalyticsEvent.lancelot,
      parameters: {"newcomer": await FlutterTbaInfo.instance.getDistinctId()},
      userGroup: {"user_group": userGroup},
    );
  }

  setEligibleUser(bool newEligibilityState) async {
    trackEvent(
      pointType: AnalyticsEvent.lancelot,
      parameters: {"newcomer": await FlutterTbaInfo.instance.getDistinctId()},
      userGroup: {"user_bv": newEligibilityState ? 1 : 0},
    );
  }

  Future<void> incrementLifetimeDays() async {
    final Map<dynamic, dynamic> referrerMap = await FlutterTbaInfo.instance
        .getReferrerMap();
    final dynamic installFirstSeconds = referrerMap["install_first_seconds"];
    final int? installTimestamp = int.tryParse('$installFirstSeconds');
    bool isInstalledToday = false;
    if (installTimestamp != null && installTimestamp > 0) {
      final int installMilliseconds = installTimestamp < 100000000000
          ? installTimestamp * 1000
          : installTimestamp;
      final DateTime installDate = DateTime.fromMillisecondsSinceEpoch(
        installMilliseconds,
      );
      final DateTime now = DateTime.now();
      isInstalledToday =
          installDate.year == now.year &&
          installDate.month == now.month &&
          installDate.day == now.day;
    }
    trackEvent(
      pointType: AnalyticsEvent.lancelot,
      parameters: {"newcomer": await FlutterTbaInfo.instance.getDistinctId()},
      userGroup: {"life_time": isInstalledToday ? "d0" : "d1"},
    );
  }
}
