import 'dart:io';

import 'package:b21pdf/core/ads/ad_service.dart';
import 'package:b21pdf/core/ads/ad_scene.dart';
import 'package:b21pdf/core/ads/ad_placement.dart';
import 'package:b21pdf/core/user/user_eligibility_service.dart';
import 'package:b21pdf/core/analytics/analytics_event.dart';
import 'package:b21pdf/core/analytics/analytics_service.dart';
import 'package:b21pdf/core/presentation/base_controller.dart';
import 'package:b21pdf/core/events/app_event.dart';
import 'package:b21pdf/core/events/app_event_type.dart';
import 'package:b21pdf/core/events/app_event_bus.dart';
import 'package:b21pdf/core/permissions/permission_service.dart';
import 'package:b21pdf/core/storage/preferences/insert_widget_cache.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';

enum DocumentCategory {
  all("All"),
  pdf("PDF"),
  word("Word"),
  excel("Excel");

  final String name;
  const DocumentCategory(this.name);
}

class LibraryTabController extends BaseController
    with GetSingleTickerProviderStateMixin {
  TextEditingController textEditingController = TextEditingController();
  late final TabController tabController;
  int selectedTabIndex = 0;
  bool showAddWidget = !InsertWidgetCache.readAdded();
  bool requestingStoragePermission = false;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(
      length: DocumentCategory.values.length,
      vsync: this,
    )..addListener(onSelectedTabChanged);
  }

  @override
  void onReady() {
    super.onReady();
    requestDocumentStoragePermission();
  }

  void onTabBarPressed() {
    AnalyticsService.instance.trackEvent(
      pointType: AnalyticsEvent.fileFilterClick,
    );
  }

  void onSelectedTabChanged() {
    final int index = tabController.index;
    if (selectedTabIndex == index) return;
    selectedTabIndex = index;
    update();
    final BuildContext? context = Get.context;
    if (context == null) return;
    AdService.instance.showCachedAd(
      adScene: AdScene.pr_user_use,
      adPosId: AdPlacement.pr_up_int,
      adHostContext: context,
    );
  }

  void updateFileSearchQuery(String keyword) => AppEventBus.instance.publish(
    AppEvent(type: AppEventType.fileSearch, stringValue: keyword),
  );

  @override
  bool subscribesToAppEvents() => true;

  @override
  void onAppEvent(AppEvent event) {
    if (event.type == AppEventType.widgetAdded) {
      showAddWidget = false;
      update();
    } else if (event.type == AppEventType.storagePermissionRequest) {
      requestDocumentStoragePermission();
    }
  }

  Future<void> requestDocumentStoragePermission() async {
    if (requestingStoragePermission) return;
    requestingStoragePermission = true;
    try {
      final Permission permission = await _resolveRequiredStoragePermission();
      final PermissionResult result = await PermissionService.instance
          .requestPermission(permission: permission);
      if (result.isShowPermissionAd) {
        AnalyticsService.instance.trackEvent(
          pointType: AnalyticsEvent.storageAuthClick,
        );
        if (UserEligibilityService.instance.isEligibleUser) {
          AdService.instance.showCachedAd(
            adScene: AdScene.pr_launch,
            adPosId: AdPlacement.pr_permission_open,
          );
        }
      }
      if (!result.isGranted) return;
      AppEventBus.instance.publish(
        AppEvent(type: AppEventType.storagePermissionGranted),
      );
    } finally {
      requestingStoragePermission = false;
    }
  }

  Future<Permission> _resolveRequiredStoragePermission() async {
    if (!Platform.isAndroid) return Permission.storage;
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt >= 30
        ? Permission.manageExternalStorage
        : Permission.storage;
  }

  void runDebugActions() async {
    if (!kDebugMode) {
      return;
    }
    // AppNavigator.showBottomSheet(child: RatingDialog());
    // AnalyticsService.instance.incrementLifetimeDays();
  }

  @override
  void onClose() {
    textEditingController.dispose();
    tabController
      ..removeListener(onSelectedTabChanged)
      ..dispose();
    super.onClose();
  }
}
