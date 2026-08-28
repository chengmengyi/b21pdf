import 'dart:io';

import 'package:b21pdf/features/viewers/word/presentation/word_viewer_controller.dart';
import 'package:b21pdf/core/presentation/base_screen.dart';
import 'package:b21pdf/shared/widgets/asset_picture_view.dart';
import 'package:b21pdf/shared/widgets/localized_text_view.dart';
import 'package:b21pdf/shared/widgets/tap_guard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_preview_file/flutter_preview_file.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class WordViewerScreen extends BaseScreen<WordViewerController> {
  const WordViewerScreen({super.key});
  @override
  WordViewerController createController() => WordViewerController();

  @override
  Color get navigationBarColor => Colors.white;

  @override
  Future<bool> canPopRoute(WordViewerController controller) async {
    controller.onBackPressed();
    return false;
  }

  @override
  Widget buildContent(BuildContext context, WordViewerController controller) =>
      GetBuilder<WordViewerController>(
        init: controller,
        global: false,
        builder: (controller) => Column(
          children: [
            _buildTitleBar(controller),
            _buildMainContent(controller),
            _buildBottomBar(controller),
          ],
        ),
      );

  Widget _buildMainContent(WordViewerController controller) => Expanded(
    child: Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(12.w),
      margin: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 5,
            offset: const Offset(0, -0.5),
          ),
        ],
      ),
      child: !controller.canLoadViewer
          ? const Center(child: CircularProgressIndicator())
          : WordFileView(
              controller: controller.wordController,
              autoInitialize: false,
              loadingBuilder: (_) =>
                  const Center(child: CircularProgressIndicator()),
              messageBuilder: (_, message) => Center(
                child: LocalizedTextView(
                  File(controller.fileInfo.path ?? '').existsSync()
                      ? 'Preview unavailable'.tr
                      : 'File not found'.tr,
                ),
              ),
            ),
    ),
  );

  Widget _buildBottomBar(WordViewerController controller) => Padding(
    padding: EdgeInsets.all(8.w),
    child: Row(
      children: [
        Expanded(
          child: _buildActionButton(
            text: controller.isSaving
                ? 'Saving...'.tr
                : (controller.isEditing ? 'Cancel'.tr : 'Edit'.tr),
            onTap: controller.onEditPressed,
            color: controller.isEditing
                ? const Color(0xff858C92)
                : const Color(0xffF7AD00),
          ),
        ),
        if (controller.isEditing) SizedBox(width: 8.w),
        if (controller.isEditing)
          Expanded(
            child: _buildActionButton(
              text: controller.isSaving ? 'Saving...'.tr : 'Save'.tr,
              onTap: controller.onSavePressed,
              color: const Color(0xffF7AD00),
            ),
          ),
      ],
    ),
  );
  Widget _buildActionButton({
    required String text,
    required VoidCallback onTap,
    required Color color,
  }) => TapGuardView(
    onPressed: onTap,
    child: Container(
      height: 44.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: LocalizedTextView(
        text,
        fontSize: 16.sp,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
  Widget _buildTitleBar(WordViewerController controller) => Container(
    width: double.infinity,
    color: Colors.white,
    child: SafeArea(
      top: true,
      bottom: false,
      child: SizedBox(
        height: 44.h,
        child: Stack(
          children: [
            TapGuardView(
              onPressed: controller.onBackPressed,
              child: SizedBox(
                width: 44.w,
                height: 44.h,
                child: Center(
                  child: AssetPictureView(
                    'navigation/back',
                    width: 24.w,
                    height: 24.w,
                  ),
                ),
              ),
            ),
            Align(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 52.w),
                child: LocalizedTextView(
                  controller.fileName,
                  fontSize: 18.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
