import 'dart:io';

import 'package:b21pdf/features/pdf_tools/presentation/image_selection/image_selection_controller.dart';
import 'package:b21pdf/core/presentation/base_screen.dart';
import 'package:b21pdf/shared/widgets/asset_picture_view.dart';
import 'package:b21pdf/shared/widgets/localized_text_view.dart';
import 'package:b21pdf/shared/widgets/tap_guard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ImageSelectionScreen extends BaseScreen<ImageSelectionController> {
  const ImageSelectionScreen({super.key});

  @override
  ImageSelectionController createController() {
    return ImageSelectionController();
  }

  @override
  Color get navigationBarColor => Colors.white;

  @override
  Widget buildContent(
    BuildContext context,
    ImageSelectionController controller,
  ) {
    return GetBuilder<ImageSelectionController>(
      builder: (ImageSelectionController controller) => Column(
        children: [
          _buildTitleBar(controller),
          _buildMainContent(controller),
          _buildBottomBar(controller),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ImageSelectionController controller) => Container(
    width: double.infinity,
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
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 8.h),
        SizedBox(
          height: 78.h,
          child: ListView.separated(
            controller: controller.thumbnailController,
            itemCount: controller.imagePaths.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, index) {
              final page = index + 1;
              return TapGuardView(
                onPressed: () {
                  controller.selectImage(index);
                },
                child: Container(
                  width: 60.w,
                  decoration: BoxDecoration(
                    color: const Color(0xffF3F5F7),
                    borderRadius: BorderRadius.circular(3.w),
                    border: Border.all(
                      width: 2.w,
                      color: controller.selectedIndex == index
                          ? const Color(0xff067bf2)
                          : const Color(0xffEBEBEB),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3.w),
                          child: Image.file(
                            File(controller.imagePaths[index]),
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.w,
                            vertical: 1.h,
                          ),
                          color: Colors.black54,
                          child: Text(
                            '$page',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => SizedBox(width: 8.w),
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            TapGuardView(
              onPressed: controller.onReplacePressed,
              child: Container(
                width: 92.w,
                height: 64.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color(0xffF5F6F9),
                  borderRadius: BorderRadius.circular(16.w),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AssetPictureView(
                      "pdf_tools/rescan",
                      width: 24.w,
                      height: 24.w,
                    ),
                    SizedBox(height: 4.h),
                    LocalizedTextView(
                      "Retake".tr,
                      fontSize: 14.sp,
                      color: Color(0xff242C3C),
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12.w),
            TapGuardView(
              onPressed: controller.onAddPressed,
              child: Container(
                width: 92.w,
                height: 64.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color(0xffF5F6F9),
                  borderRadius: BorderRadius.circular(16.w),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AssetPictureView(
                      "pdf_tools/add_page",
                      width: 24.w,
                      height: 24.w,
                    ),
                    SizedBox(height: 4.h),
                    LocalizedTextView(
                      "Add".tr,
                      fontSize: 14.sp,
                      color: Color(0xff242C3C),
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: TapGuardView(
                onPressed: () {
                  controller.onSavePressed();
                },
                child: Container(
                  width: double.infinity,
                  height: 64.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(0xffD12629),
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AssetPictureView(
                        "common/confirm_white",
                        width: 22.w,
                        height: 22.w,
                      ),
                      SizedBox(height: 2.w),
                      LocalizedTextView(
                        "Save PDF".tr,
                        fontSize: 14.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
      ],
    ),
  );

  Widget _buildMainContent(ImageSelectionController controller) => Expanded(
    child: Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(12.w),
      margin: EdgeInsets.only(left: 8.w, right: 8.w, top: 8.h),
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
      child: PageView.builder(
        controller: controller.pageController,
        itemCount: controller.imagePaths.length,
        onPageChanged: controller.onPageChanged,
        itemBuilder: (_, int index) {
          return Image.file(
            File(controller.imagePaths[index]),
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          );
        },
      ),
    ),
  );

  Widget _buildTitleBar(ImageSelectionController controller) => Container(
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
                    width: 33.w,
                    height: 33.w,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
