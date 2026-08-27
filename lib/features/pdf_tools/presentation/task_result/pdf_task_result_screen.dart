import 'package:b21pdf/features/pdf_tools/presentation/task_result/pdf_task_result_controller.dart';
import 'package:b21pdf/core/presentation/base_screen.dart';
import 'package:b21pdf/shared/widgets/asset_picture_view.dart';
import 'package:b21pdf/shared/widgets/localized_text_view.dart';
import 'package:b21pdf/shared/widgets/tap_guard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class PdfTaskResultScreen extends BaseScreen<PdfTaskResultController> {
  const PdfTaskResultScreen({super.key});

  @override
  PdfTaskResultController createController() {
    return PdfTaskResultController();
  }

  @override
  Color get navigationBarColor => Colors.white;

  @override
  Widget buildContent(
    BuildContext context,
    PdfTaskResultController controller,
  ) {
    return Column(
      children: [
        _buildTitleBar(controller),
        SizedBox(height: 80.h),
        AssetPictureView(
          "pdf_tools/conversion_complete",
          width: 196.w,
          height: 125.w,
        ),
        SizedBox(height: 20.h),
        LocalizedTextView(
          'Success!'.tr,
          fontSize: 24.sp,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        SizedBox(height: 8.h),
        LocalizedTextView(
          'Your file is ready'.tr,
          fontSize: 16.sp,
          color: Color(0xff555978),
          fontWeight: FontWeight.w500,
        ),
        Spacer(),
        _infoWidget(controller),
        SizedBox(height: 18.h),
        _buildBottomSection(controller),
        SizedBox(height: 46.h),
      ],
    );
  }

  Widget _buildBottomSection(PdfTaskResultController controller) =>
      TapGuardView(
        onPressed: controller.onOpenPressed,
        child: Container(
          width: double.infinity,
          height: 46.h,
          alignment: Alignment.center,
          margin: EdgeInsets.only(left: 16.w, right: 16.w),
          decoration: BoxDecoration(
            color: Color(0xffD12629),
            borderRadius: BorderRadius.circular(42.w),
          ),
          child: LocalizedTextView(
            "Open".tr,
            fontSize: 18.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  Widget _infoWidget(PdfTaskResultController controller) => Container(
    width: double.infinity,
    height: 72.h,
    alignment: Alignment.centerLeft,
    padding: EdgeInsets.only(left: 16.w, right: 16.w),
    margin: EdgeInsets.only(left: 40.w, right: 40.w),
    decoration: BoxDecoration(
      color: Color(0xffF3F3F4),
      borderRadius: BorderRadius.circular(8.w),
    ),
    child: Row(
      children: [
        AssetPictureView("branding/pdf_logo", width: 42.w, height: 42.w),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LocalizedTextView(
                controller.fileName,
                fontSize: 14.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
              ),
              LocalizedTextView(
                controller.fileDetail,
                fontSize: 12.sp,
                color: Color(0xff858C92),
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildTitleBar(PdfTaskResultController controller) => Container(
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
