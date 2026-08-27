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
    requestBody['newfound'] = <String, dynamic>{
      'boo': referrerData['build'],
      'inertia': referrerData['referrer_url'],
      'scot': referrerData['install_version'],
      'ellipsis': referrerData['user_agent'],
      'awaken': 'dunbar',
      'isabella': referrerData['referrer_click_timestamp_seconds'],
      'senile': referrerData['install_begin_timestamp_seconds'],
      'diploma': referrerData['referrer_click_timestamp_server_seconds'],
      'pogrom': referrerData['install_begin_timestamp_server_seconds'],
      'cossack': referrerData['install_first_seconds'],
      'satin': referrerData['last_update_seconds'],
      'degas': referrerData['google_play_instant'],
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
    requestBody['threaten'] = "moser";
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
    requestBody['nutrient'] = <String, dynamic>{
      'crystal': revenue * 1000000,
      'demurred': currency,
      'furrow': adNetwork,
      'chapman': adInfo.adPlat ?? '',
      'allen': adInfo.adId ?? '',
      'deportee': positionId?.name ?? '',
      'blitz': adScene.name,
      'reflect': precision,
      'dionysus': adInfo.adType,
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
    requestBody['threaten'] = pointType.name;
    parameters?.forEach((String key, dynamic value) {
      requestBody['$key~glory'] = value;
    });
    if (null != userGroup) {
      requestBody["bequeath"] = userGroup;
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
    return <String, dynamic>{
      'harlem': <String, dynamic>{
        'pershing': await FlutterTbaInfo.instance.getBundleId(),
        'andersen': await FlutterTbaInfo.instance.getAppVersion(),
        'zagging': await FlutterTbaInfo.instance.getDistinctId(),
        "prophecy": DateTime.now().millisecondsSinceEpoch,
        "quicken": await FlutterTbaInfo.instance.getBrand(),
        "midrange": await FlutterTbaInfo.instance.getDeviceModel(),
        "carnal": await FlutterTbaInfo.instance.getOsVersion(),
        "decisive": await FlutterTbaInfo.instance.getSystemLanguage(),
        "bondage": await FlutterTbaInfo.instance.getIdfa(),
        "archae": await FlutterTbaInfo.instance.getIdfv(),
        "europa": await FlutterTbaInfo.instance.getGaid(),
      },
      'mandamus': <String, dynamic>{
        'span': Platform.isAndroid ? "haggle" : "not",
        "bahama": await FlutterTbaInfo.instance.getLogId(),
        "typology": await FlutterTbaInfo.instance.getManufacturer(),
        "defector": await FlutterTbaInfo.instance.getOperator(),
        "ring": await FlutterTbaInfo.instance.getAndroidId(),
        "tipple": await FlutterTbaInfo.instance.getOsCountry(),
      },
    };
  }

  Future<Map<String, String>> buildRequestHeaders() async {
    return <String, String>{
      'defector': await FlutterTbaInfo.instance.getOperator(),
    };
  }

  Future<String> buildEndpointUrl() async {
    final String s = await FlutterTbaInfo.instance.getSystemLanguage();
    return '${AppConfig.tbaEndpoint}?decisive=$s';
  }

  addUserGroup(int userGroup) async {
    trackEvent(
      pointType: AnalyticsEvent.quad,
      parameters: {"zagging": await FlutterTbaInfo.instance.getDistinctId()},
      userGroup: {"user_group": userGroup},
    );
  }

  setEligibleUser(bool newEligibilityState) async {
    trackEvent(
      pointType: AnalyticsEvent.quad,
      parameters: {"zagging": await FlutterTbaInfo.instance.getDistinctId()},
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
      pointType: AnalyticsEvent.quad,
      parameters: {"zagging": await FlutterTbaInfo.instance.getDistinctId()},
      userGroup: {"life_time": isInstalledToday ? "d0" : "d1"},
    );
  }
}
