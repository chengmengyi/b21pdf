import 'dart:async';

import 'package:b21pdf/core/ads/ad_service.dart';
import 'package:b21pdf/features/library/presentation/document_list/document_list_controller.dart';
import 'package:b21pdf/features/library/presentation/library_tab/library_tab_controller.dart';
import 'package:b21pdf/core/presentation/base_tab.dart';
import 'package:b21pdf/shared/widgets/asset_picture_view.dart';
import 'package:b21pdf/shared/widgets/localized_text_view.dart';
import 'package:b21pdf/shared/widgets/media_padding_view.dart';
import 'package:b21pdf/shared/widgets/refresh_view.dart';
import 'package:b21pdf/shared/widgets/tap_guard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdf_ad_plugins/flutter_pdf_ad_plugins.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_preview_file/flutter_preview_file.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';

class DocumentList extends BaseTab {
  final DocumentCategory type;
  const DocumentList({super.key, required this.type});

  @override
  State<DocumentList> createState() => _DocumentsListSectionState();
}

class _DocumentsListSectionState
    extends BaseSectionState<DocumentListController, DocumentList> {
  @override
  String get controllerTag => 'files_${widget.type.name}';

  @override
  DocumentListController createController() {
    return DocumentListController(type: widget.type);
  }

  @override
  Widget buildContent(BuildContext context, DocumentListController controller) {
    return GetBuilder<DocumentListController>(
      init: controller,
      global: false,
      builder: (controller) {
        return Column(
          children: [
            _buildSortControls(controller),
            SizedBox(height: 8.h),
            _buildContentSection(controller),
          ],
        );
      },
    );
  }

  Widget _buildSortControls(DocumentListController controller) => Row(
    children: [
      Expanded(
        child: TapGuardView(
          onPressed: () {
            controller.runDebugActions();
          },
          child: LocalizedTextView(
            "Local Storage".tr,
            fontSize: 18.sp,
            color: Colors.black,
            fontWeight: FontWeight.bold,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      SizedBox(width: 8.w),
      TapGuardView(
        onPressed: () {
          controller.onSortPressed();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AssetPictureView(
              "document_library/sort_menu",
              width: 22.w,
              height: 22.w,
            ),
            SizedBox(width: 4.w),
            LocalizedTextView(
              "Sort".tr,
              fontSize: 12.sp,
              color: Color(0xff555978),
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
      SizedBox(width: 12.w),
      TapGuardView(
        onPressed: () {
          controller.onDeleteFilePressed();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AssetPictureView(
              "document_library/select_documents",
              width: 22.w,
              height: 22.w,
            ),
            SizedBox(width: 4.w),
            LocalizedTextView(
              "Select".tr,
              fontSize: 12.sp,
              color: Color(0xff555978),
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildContentSection(DocumentListController controller) => Expanded(
    child: Container(
      width: double.infinity,
      height: double.infinity,
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: switch (controller.listState) {
        DocumentListState.noPermission => _buildDemoDocumentEmptyState(
          controller: controller,
          emptyWidget: _buildPermissionRequiredState(controller),
        ),
        DocumentListState.loading => _buildLoadingState(),
        DocumentListState.loaded =>
          controller.visibleFiles.isEmpty
              ? _buildDemoDocumentEmptyState(
                  controller: controller,
                  emptyWidget: _buildNoFilesState(controller),
                )
              : _buildDocumentListViewport(controller),
      },
    ),
  );

  Widget _buildDocumentListViewport(DocumentListController controller) =>
      MediaPaddingView(
        child: RefreshView(
          enableLoadMore: false,
          controller: controller.refreshController,
          scrollController: controller.scrollController,
          onRefresh: controller.refreshFiles,
          child: _buildFileList(controller),
        ),
      );

  Widget _buildFileList(DocumentListController controller) {
    final bool canShowNativeAd = controller.canShowNativeAd;
    final int nativeAdCount = canShowNativeAd
        ? controller.visibleFiles.length ~/
              DocumentListController.nativeAdInterval
        : 0;
    final int itemCount = controller.visibleFiles.length + nativeAdCount;
    controller.syncNativeAdListState(itemCount);
    return ListView.separated(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (canShowNativeAd && controller.isNativeAdIndex(index)) {
          return _buildNativeAdSlot(
            controller: controller,
            listIndex: index,
            showNativeAd: controller.activeNativeAdIndex == index,
          );
        }
        final int fileIndex = canShowNativeAd
            ? controller.fileIndexFromListIndex(index)
            : index;
        final file = controller.visibleFiles[fileIndex];
        return _buildFileItem(controller, file);
      },
      separatorBuilder: (BuildContext context, int index) =>
          SizedBox(height: 8.h),
    );
  }

  Widget _buildNativeAdSlot({
    required DocumentListController controller,
    required int listIndex,
    required bool showNativeAd,
  }) {
    controller.prepareNativeAdSlot(listIndex);
    return VisibilityDetector(
      key: ValueKey('document_inline_ad_${listIndex}_vke'),
      onVisibilityChanged: (info) => controller.updateNativeAdVisibility(
        listIndex,
        info.visibleFraction > 0,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 68.h,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          child: showNativeAd
              ? KeyedSubtree(
                  key: ValueKey(
                    'document_native_ad_${listIndex}_${controller.nativeAdRefreshKey}_vke',
                  ),
                  child: const _DocumentsNativeAdContent(),
                )
              : const AssetPictureView(
                  'ads/native_ad_placeholder',
                  width: double.infinity,
                ),
        ),
      ),
    );
  }

  String _fileIcon(FileToolsFileInfo file) => switch (file.type) {
    FileToolsDocumentType.pdf => 'branding/pdf_logo',
    FileToolsDocumentType.excel => 'branding/excel_logo',
    _ => 'branding/word_logo',
  };

  Color _fileBackgroundColor(FileToolsFileInfo file) => switch (file.type) {
    FileToolsDocumentType.word => const Color(0xff2C90FE),
    FileToolsDocumentType.excel => const Color(0xff01C87C),
    _ => const Color(0xffF85758),
  };

  String _formatFileMetadata(FileToolsFileInfo file) {
    final date = DateTime.fromMillisecondsSinceEpoch(file.updateTime ?? 0);
    final dateText =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final size = (file.size ?? 0) / 1024 / 1024;
    return '$dateText | ${size.toStringAsFixed(1)}M';
  }

  Widget _buildFileItem(
    DocumentListController controller,
    FileToolsFileInfo file,
  ) {
    return TapGuardView(
      onPressed: () => controller.onFileItemPressed(file),
      child: Container(
        width: double.infinity,
        height: 68.h,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.w),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              _fileBackgroundColor(file).withOpacity(0.08),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            AssetPictureView(_fileIcon(file), width: 40.w, height: 40.w),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LocalizedTextView(
                    file.name ?? '',
                    fontSize: 14.sp,
                    color: Color(0xff242C3C),
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                  LocalizedTextView(
                    _formatFileMetadata(file),
                    fontSize: 10.sp,
                    color: const Color(0xff9C9FAE),
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoDocumentEmptyState({
    required DocumentListController controller,
    required Widget emptyWidget,
  }) {
    final FileToolsFileInfo? demoFile = controller.demoFileInfo;
    if (demoFile == null) {
      return emptyWidget;
    }
    return Column(
      children: [
        _buildFileItem(controller, demoFile),
        Expanded(child: emptyWidget),
      ],
    );
  }

  Widget _buildNoFilesState(DocumentListController controller) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AssetPictureView('branding/pdf_logo', width: 72.w, height: 72.w),
          SizedBox(height: 16.h),
          LocalizedTextView(
            'No files found'.tr,
            fontSize: 18.sp,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: 24.h),
          TapGuardView(
            onPressed: controller.refreshFiles,
            child: Container(
              height: 42.h,
              constraints: BoxConstraints(minWidth: 132.w),
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(21.w),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xffFF8E71), Color(0xffA77FF1)],
                ),
              ),
              child: LocalizedTextView(
                'Try again'.tr,
                fontSize: 14.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() => Center(child: CircularProgressIndicator());

  Widget _buildPermissionRequiredState(DocumentListController controller) =>
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AssetPictureView(
            "document_library/storage_permission",
            width: 75.w,
            height: 75.w,
          ),
          SizedBox(height: 16.h),
          LocalizedTextView(
            "No permissions granted".tr,
            fontSize: 18.sp,
            color: Color(0xff242C3C),
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: 6.h),
          LocalizedTextView(
            "Permission is required to access all files".tr,
            fontSize: 14.sp,
            color: Color(0xff555978),
          ),
          SizedBox(height: 40.h),
          TapGuardView(
            onPressed: () {
              controller.onRequestPermissionPressed();
            },
            child: Container(
              padding: EdgeInsets.only(
                left: 36.w,
                right: 36.w,
                top: 8.h,
                bottom: 8.h,
              ),
              decoration: BoxDecoration(
                color: Color(0xffD12629),
                borderRadius: BorderRadius.circular(42.w),
              ),
              child: LocalizedTextView(
                "Go to settings".tr,
                fontSize: 16.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
}

class _DocumentsNativeAdContent extends StatefulWidget {
  const _DocumentsNativeAdContent();

  @override
  State<_DocumentsNativeAdContent> createState() =>
      _DocumentsNativeAdContentState();
}

class _DocumentsNativeAdContentState extends State<_DocumentsNativeAdContent> {
  Widget? _buildNativeAd;

  @override
  void initState() {
    super.initState();
    unawaited(_attachNativeAdWidget());
  }

  Future<void> _attachNativeAdWidget() async {
    final Widget? adWidget = await AdService.instance.takeDocumentListNativeAd(
      loadIfNeeded: true,
      reloadAfterTake: true,
      disposeDelay: Duration.zero,
    );
    if (adWidget == null) return;
    if (!mounted) {
      try {
        await FlutterPdfAdPlugins.instance.disposeTakenAdWidget(adWidget);
      } catch (_) {}
      return;
    }
    setState(() => _buildNativeAd = adWidget);
  }

  @override
  Widget build(BuildContext context) =>
      _buildNativeAd ??
      const AssetPictureView(
        'ads/native_ad_placeholder',
        width: double.infinity,
      );
}
