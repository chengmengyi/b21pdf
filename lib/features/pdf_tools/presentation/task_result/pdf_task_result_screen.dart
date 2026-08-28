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
        SizedBox(height: 100.h),
        AssetPictureView(
          "pdf_tools/conversion_complete",
          width: 80.w,
          height: 80.w,
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
          fontSize: 14.sp,
          color: Color(0xff525759),
          fontWeight: FontWeight.w500,
        ),
        SizedBox(height: 52.h),
        _infoWidget(controller),
        Spacer(),
        _buildBottomSection(controller),
      ],
    );
  }

  Widget _buildBottomSection(PdfTaskResultController controller) => Container(
    width: double.infinity,
    height: 88.h,
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
          onPressed: controller.onOpenPressed,
          child: Container(
            width: double.infinity,
            height: 48.h,
            alignment: Alignment.center,
            margin: EdgeInsets.only(left: 16.w, right: 16.w),
            decoration: BoxDecoration(
              color: Color(0xff8C69F3),
              borderRadius: BorderRadius.circular(16.w),
            ),
            child: LocalizedTextView(
              "Open".tr,
              fontSize: 18.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
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
      borderRadius: BorderRadius.circular(12.w),
      border: Border.all(
        width: 0.5.w,
        color: Color(0xffEBEBEB),
      ),
    ),
    child: Row(
      children: [
        AssetPictureView("branding/pdf_logo", width: 32.w, height: 32.w),
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
                color: Color(0xff8E9091),
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
                    width: 24.w,
                    height: 24.w,
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
