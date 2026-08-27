import 'dart:async';
import 'dart:io';

import 'package:b21pdf/core/storage/preferences/locale_selected.dart';
import 'package:b21pdf/features/library/presentation/document_sort/document_sort_bottom_sheet.dart';
import 'package:b21pdf/features/library/presentation/document_sort/document_sort_controller.dart';
import 'package:b21pdf/core/ads/ad_service.dart';
import 'package:b21pdf/core/ads/ad_scene.dart';
import 'package:b21pdf/core/ads/ad_placement.dart';
import 'package:b21pdf/core/user/user_eligibility_service.dart';
import 'package:b21pdf/core/events/app_event.dart';
import 'package:b21pdf/core/events/app_event_type.dart';
import 'package:b21pdf/core/events/app_event_bus.dart';
import 'package:b21pdf/features/documents/data/demo_document_repository.dart';
import 'package:b21pdf/core/permissions/permission_service.dart';
import 'package:b21pdf/core/navigation/app_routes.dart';
import 'package:b21pdf/core/navigation/app_navigator.dart';
import 'package:b21pdf/core/storage/preferences/document_sort_cache.dart';
import 'package:b21pdf/core/analytics/analytics_event.dart';
import 'package:b21pdf/core/analytics/analytics_service.dart';
import 'package:b21pdf/features/library/presentation/library_tab/library_tab_controller.dart';
import 'package:b21pdf/core/presentation/base_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_preview_file/flutter_preview_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:device_info_plus/device_info_plus.dart';

enum DocumentListState { noPermission, loading, loaded }

class DocumentListController extends BaseController {
  static const int nativeAdInterval = 4;
  static const Duration _nativeAdRefreshDuration = Duration(seconds: 10);
  static const Duration _scrollIdleDuration = Duration(milliseconds: 280);

  final DocumentCategory type;
  final RefreshController refreshController = RefreshController();
  final ScrollController scrollController = ScrollController();
  final Set<int> _visibleNativeAdIndexes = <int>{};
  Timer? _scrollIdleTimer;
  Timer? _nativeAdRefreshTimer;
  DocumentListState listState = DocumentListState.loading;
  List<FileToolsFileInfo> allFiles = [];
  List<FileToolsFileInfo> visibleFiles = [];
  FileToolsFileInfo? demoFileInfo;
  String searchText = '';
  bool loadingFiles = false;
  bool hasLoadedFiles = false;
  bool appInForeground = true;
  int? activeNativeAdIndex;
  int? _lastChanceNativeAdIndex;
  int nativeAdRefreshKey = 0;
  int _latestListItemCount = 0;
  bool _isListScrolling = false;
  bool _isRefreshingNativeAd = false;
  bool _nativeAdSwitchEnabled = false;
  late SortType sortType;

  DocumentListController({required this.type});

  Future<Permission> _resolveRequiredStoragePermission() async {
    if (!Platform.isAndroid) return Permission.storage;
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt >= 30
        ? Permission.manageExternalStorage
        : Permission.storage;
  }

  @override
  void onInit() {
    sortType = SortType.values.firstWhere(
      (item) => item.name == DocumentSortCache.readSortName(type.name),
      orElse: () => SortType.dateNew,
    );
    super.onInit();
    scrollController.addListener(_handleScroll);
    unawaited(_initializeNativeAdSwitch());
  }

  Future<void> _initializeNativeAdSwitch() async {
    _nativeAdSwitchEnabled = await AdService.instance.isPlacementEnabled(
      AdPlacement.pr_main_banner1,
    );
    if (isClosed) return;
    if (!_nativeAdSwitchEnabled) {
      _clearActiveNativeAd();
    }
    update();
  }

  bool get canShowNativeAd =>
      _nativeAdSwitchEnabled &&
      UserEligibilityService.instance.isEligibleUser &&
      visibleFiles.length >= nativeAdInterval;

  bool isNativeAdIndex(int index) => (index + 1) % (nativeAdInterval + 1) == 0;

  int fileIndexFromListIndex(int index) =>
      index - (index + 1) ~/ (nativeAdInterval + 1);

  void syncNativeAdListState(int itemCount) {
    _latestListItemCount = itemCount;
    _visibleNativeAdIndexes.removeWhere((index) => index >= itemCount);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isClosed || _isRefreshingNativeAd) return;
      if (!canShowNativeAd || itemCount <= 0) {
        _clearActiveNativeAd();
      } else if (activeNativeAdIndex == null ||
          activeNativeAdIndex! >= itemCount) {
        _activateNativeAd();
      } else {
        _startNativeAdRefreshTimer();
      }
    });
  }

  void prepareNativeAdSlot(int listIndex) {
    if (canShowNativeAd &&
        activeNativeAdIndex == listIndex &&
        _lastChanceNativeAdIndex != listIndex) {
      _lastChanceNativeAdIndex = listIndex;
      _uploadNativeAdChance();
    }
  }

  void updateNativeAdVisibility(int index, bool visible) {
    if (isClosed) return;
    final bool changed = visible
        ? _visibleNativeAdIndexes.add(index)
        : _visibleNativeAdIndexes.remove(index);
    if (!changed) return;
    if (!visible && activeNativeAdIndex == index) {
      activeNativeAdIndex = null;
      if (_lastChanceNativeAdIndex == index) {
        _lastChanceNativeAdIndex = null;
      }
      _stopNativeAdRefreshTimer();
      update();
    }
    if (visible &&
        appInForeground &&
        !_isListScrolling &&
        !_isRefreshingNativeAd) {
      _activateNativeAd();
    }
  }

  void _handleScroll() {
    if (isClosed || !canShowNativeAd) return;
    _isListScrolling = true;
    _scrollIdleTimer?.cancel();
    _stopNativeAdRefreshTimer();
    _scrollIdleTimer = Timer(_scrollIdleDuration, () {
      if (isClosed || !canShowNativeAd) return;
      _isListScrolling = false;
      _activateNativeAd();
    });
  }

  void _activateNativeAd() {
    if (!appInForeground || _visibleNativeAdIndexes.isEmpty) {
      _stopNativeAdRefreshTimer();
      return;
    }
    final List<int> visibleIndexes =
        _visibleNativeAdIndexes
            .where((index) => index < _latestListItemCount)
            .toList()
          ..sort();
    if (visibleIndexes.isEmpty) return;
    final int index = visibleIndexes.first;
    if (activeNativeAdIndex != index) {
      activeNativeAdIndex = index;
      update();
    }
    _startNativeAdRefreshTimer();
  }

  bool _canRefreshNativeAd() {
    final int? activeIndex = activeNativeAdIndex;
    return !isClosed &&
        appInForeground &&
        !_isRefreshingNativeAd &&
        !_isListScrolling &&
        activeIndex != null &&
        _visibleNativeAdIndexes.contains(activeIndex) &&
        canShowNativeAd;
  }

  bool _canContinueNativeAdRefresh(int index) =>
      !isClosed &&
      appInForeground &&
      !_isListScrolling &&
      _visibleNativeAdIndexes.contains(index) &&
      canShowNativeAd;

  void _startNativeAdRefreshTimer() {
    if (!_canRefreshNativeAd()) return;
    _nativeAdRefreshTimer ??= Timer.periodic(
      _nativeAdRefreshDuration,
      (_) => unawaited(_refreshActiveNativeAd()),
    );
  }

  void _stopNativeAdRefreshTimer() {
    _nativeAdRefreshTimer?.cancel();
    _nativeAdRefreshTimer = null;
  }

  void _clearActiveNativeAd() {
    _stopNativeAdRefreshTimer();
    _lastChanceNativeAdIndex = null;
    if (activeNativeAdIndex != null) {
      activeNativeAdIndex = null;
      update();
    }
  }

  Future<void> _refreshActiveNativeAd() async {
    if (!_canRefreshNativeAd()) return;
    final int refreshIndex = activeNativeAdIndex!;
    _isRefreshingNativeAd = true;
    _uploadNativeAdChance();
    try {
      activeNativeAdIndex = null;
      update();
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(Duration.zero);
      if (!_canContinueNativeAdRefresh(refreshIndex)) return;
      final AdService adService = AdService.instance;
      if (!await adService.hasDocumentListNativeAd()) {
        await adService.loadDocumentListNativeAd();
      }
      if (!_canContinueNativeAdRefresh(refreshIndex)) return;
      nativeAdRefreshKey++;
      activeNativeAdIndex = refreshIndex;
      update();
    } finally {
      _isRefreshingNativeAd = false;
      if (appInForeground &&
          !_isListScrolling &&
          canShowNativeAd &&
          activeNativeAdIndex == null) {
        _activateNativeAd();
      }
    }
  }

  void _uploadNativeAdChance() {
    if (!_nativeAdSwitchEnabled) return;
    AdService.instance.trackAdOpportunity(
      adScene: AdScene.pr_ban1,
      adPosId: AdPlacement.pr_main_banner1,
    );
  }

  @override
  void onReady() {
    super.onReady();
    loadFiles();
  }

  Future<void> loadFiles({
    bool showLoading = true,
    bool forceReload = false,
  }) async {
    if (loadingFiles || (hasLoadedFiles && !forceReload)) {
      refreshController.refreshCompleted();
      return;
    }
    final permission = await _resolveRequiredStoragePermission();
    if (!await permission.isGranted) {
      await _prepareDemoFile();
      listState = DocumentListState.noPermission;
      refreshController.refreshCompleted();
      update();
      return;
    }
    loadingFiles = true;
    if (showLoading) {
      listState = DocumentListState.loading;
      update();
    }
    try {
      allFiles = await FlutterPreviewFile.queryFileList(
        FileToolsDocumentType.values[type.index],
      );
      _sortFiles();
      _applySearch();
      if (visibleFiles.isEmpty) {
        await _prepareDemoFile();
      }
      hasLoadedFiles = true;
      listState = DocumentListState.loaded;
    } finally {
      loadingFiles = false;
      refreshController.refreshCompleted();
      update();
    }
  }

  void refreshFiles() {
    loadFiles(showLoading: false, forceReload: true);
  }

  void onRequestPermissionPressed() {
    AppEventBus.instance.publish(
      AppEvent(type: AppEventType.storagePermissionRequest),
    );
  }

  void _sortFiles() {
    allFiles.sort((left, right) {
      switch (sortType) {
        case SortType.dateNew:
          return (right.updateTime ?? 0).compareTo(left.updateTime ?? 0);
        case SortType.dateOld:
          return (left.updateTime ?? 0).compareTo(right.updateTime ?? 0);
        case SortType.nameAZ:
          return (left.name ?? '').toLowerCase().compareTo(
            (right.name ?? '').toLowerCase(),
          );
        case SortType.nameZA:
          return (right.name ?? '').toLowerCase().compareTo(
            (left.name ?? '').toLowerCase(),
          );
      }
    });
  }

  void _applySearch() {
    final keyword = searchText.trim().toLowerCase();
    visibleFiles = keyword.isEmpty
        ? List<FileToolsFileInfo>.from(allFiles)
        : allFiles
              .where(
                (file) => (file.name ?? '').toLowerCase().contains(keyword),
              )
              .toList();
  }

  Future<void> _prepareDemoFile() async {
    demoFileInfo = await DemoDocumentRepository.instance.loadDemoDocument();
  }

  Future<void> onSortPressed() async {
    final permissionType = await _resolveRequiredStoragePermission();
    final permission = await PermissionService.instance.requestPermission(
      permission: permissionType,
    );
    if (!permission.isGranted) return;
    final selected = await AppNavigator.showBottomSheet<SortType>(
      child: DocumentSortBottomSheet(selectedType: sortType),
    );
    if (selected == null) return;
    sortType = selected;
    await DocumentSortCache.writeSortName(
      tabName: type.name,
      sortName: selected.name,
    );
    _sortFiles();
    _applySearch();
    update();
  }

  Future<void> onDeleteFilePressed() async {
    final permissionType = await _resolveRequiredStoragePermission();
    final permission = await PermissionService.instance.requestPermission(
      permission: permissionType,
    );
    if (!permission.isGranted) return;
    AppNavigator.pushNamed(
      routeName: AppRoutes.deleteFileRoute,
      arguments: {'files': visibleFiles},
    );
  }

  void onFileItemPressed(FileToolsFileInfo fileInfo) {
    final String? routeName = switch (fileInfo.type) {
      FileToolsDocumentType.pdf => AppRoutes.previewPdfRoute,
      FileToolsDocumentType.word => AppRoutes.previewWordRoute,
      FileToolsDocumentType.excel => AppRoutes.previewExcelRoute,
      _ => null,
    };
    if (routeName == null) return;
    AnalyticsService.instance.trackEvent(pointType: AnalyticsEvent.editorEntry);
    AppNavigator.pushNamed(routeName: routeName, arguments: {'file': fileInfo});
  }

  @override
  bool subscribesToAppEvents() => true;

  @override
  void onAppEvent(AppEvent event) async {
    if (event.type == AppEventType.appLifecycle) {
      appInForeground = event.intValue != 1;
      if (appInForeground) {
        _activateNativeAd();
      } else {
        _stopNativeAdRefreshTimer();
      }
    } else if (event.type == AppEventType.fileSearch) {
      final permission = await _resolveRequiredStoragePermission();
      if (!await permission.isGranted) return;
      searchText = event.stringValue ?? '';
      _applySearch();
      update();
    } else if (event.type == AppEventType.fileListRefresh) {
      loadFiles(forceReload: true);
    } else if (event.type == AppEventType.storagePermissionGranted) {
      loadFiles();
    } else if (event.type == AppEventType.refreshBUserState) {
      update();
    }
  }

  runDebugActions() {
    if (!kDebugMode) {
      return;
    }
  }

  @override
  void onClose() {
    _stopNativeAdRefreshTimer();
    _scrollIdleTimer?.cancel();
    _scrollIdleTimer = null;
    scrollController.removeListener(_handleScroll);
    scrollController.dispose();
    refreshController.dispose();
    super.onClose();
  }
}
