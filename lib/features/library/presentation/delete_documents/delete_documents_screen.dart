import 'package:b21pdf/core/navigation/app_navigator.dart';
import 'package:b21pdf/features/library/presentation/delete_documents/delete_documents_controller.dart';
import 'package:b21pdf/core/presentation/base_screen.dart';
import 'package:b21pdf/shared/widgets/asset_picture_view.dart';
import 'package:b21pdf/shared/widgets/localized_text_view.dart';
import 'package:b21pdf/shared/widgets/media_padding_view.dart';
import 'package:b21pdf/shared/widgets/tap_guard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_preview_file/flutter_preview_file.dart';
import 'package:get/get.dart';

class DeleteDocumentsScreen extends BaseScreen<DeleteDocumentsController> {
  const DeleteDocumentsScreen({super.key});

  @override
  DeleteDocumentsController createController() {
    return DeleteDocumentsController();
  }

  @override
  Widget buildContent(
    BuildContext context,
    DeleteDocumentsController controller,
  ) {
    return GetBuilder<DeleteDocumentsController>(
      init: controller,
      builder: (controller) => Column(
        children: [
          _buildTitleSection(controller),
          _buildContentSection(controller),
        ],
      ),
    );
  }

  _buildContentSection(DeleteDocumentsController controller) => Expanded(
    child: Container(
      width: double.infinity,
      height: double.infinity,
      margin: EdgeInsets.only(top: 8.h),
      color: Colors.white,
      child: Column(
        children: [
          _buildLanguageList(controller),
          _buildBottomSection(controller),
        ],
      ),
    ),
  );

  _buildLanguageList(DeleteDocumentsController controller) => Expanded(
    child: MediaPaddingView(
      child: ListView.separated(
        itemCount: controller.files.length,
        itemBuilder: (context, index) {
          final file = controller.files[index];
          return TapGuardView(
            onPressed: () {
              controller.onItemPressed(file);
            },
            child: Container(
              width: double.infinity,
              height: 68.h,
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(left: 16.w, right: 16.w),
              padding: EdgeInsets.only(left: 16.w, right: 16.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.w),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    _fileBackgroundColor(file).withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  AssetPictureView(
                    controller.isSelected(file)
                        ? "common/radio_selected"
                        : "common/radio_unselected",
                    width: 24.w,
                    height: 24.w,
                  ),
                  SizedBox(width: 12.w),
                  AssetPictureView(
                    controller.resolveFileIcon(file),
                    width: 40.w,
                    height: 40.w,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LocalizedTextView(
                          file.name ?? '',
                          fontSize: 14.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                        LocalizedTextView(
                          _formatFileMetadata(file),
                          fontSize: 10.sp,
                          color: Color(0xff9C9FAE),
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
        },
        separatorBuilder: (BuildContext context, int index) =>
            SizedBox(height: 6.h),
      ),
    ),
  );

  Color _fileBackgroundColor(FileToolsFileInfo file) => switch (file.type) {
    FileToolsDocumentType.word => const Color(0xff2C90FE),
    FileToolsDocumentType.excel => const Color(0xff01C87C),
    _ => const Color(0xffF85758),
  };

  String _formatFileMetadata(FileToolsFileInfo file) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(
      file.updateTime ?? 0,
    );
    final String dateText =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final double size = (file.size ?? 0) / 1024 / 1024;
    return '$dateText｜${size.toStringAsFixed(1)}M';
  }

  _buildBottomSection(DeleteDocumentsController controller) => Container(
    width: double.infinity,
    height: 60.h,
    alignment: Alignment.center,
    padding: EdgeInsets.only(left: 16.w, right: 16.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(12.w),
        topRight: Radius.circular(12.w),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 5,
          offset: const Offset(0, -0.5),
        ),
      ],
    ),
    child: TapGuardView(
      onPressed: () {
        controller.onDeletePressed();
      },
      child: Container(
        width: double.infinity,
        height: 44.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Color(0xffD12629),
          borderRadius: BorderRadius.circular(22.w),
        ),
        child: LocalizedTextView(
          "Delete".tr,
          fontSize: 16.sp,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );

  _buildTitleSection(DeleteDocumentsController controller) => Container(
    width: double.infinity,
    color: Colors.white,
    child: SafeArea(
      top: true,
      bottom: false,
      child: Container(
        width: double.infinity,
        height: 44.h,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 16.w, right: 16.w),
        child: Row(
          children: [
            TapGuardView(
              onPressed: controller.onSelectAllPressed,
              child: LocalizedTextView(
                "Select All".tr,
                fontSize: 14.sp,
                color: Color(0xffD12629),
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: Center(
                child: LocalizedTextView(
                  '{n} Selected'.tr.replaceAll(
                    '{n}',
                    controller.selectedPaths.length.toString(),
                  ),
                  fontSize: 16.sp,
                  color: Color(0xff242C3C),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TapGuardView(
              onPressed: () {
                AppNavigator.backWithExitAd<void>();
              },
              child: LocalizedTextView(
                "Cancel".tr,
                fontSize: 14.sp,
                color: Color(0xff9C9FAE),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
