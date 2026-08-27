import 'package:b21pdf/features/pdf_tools/presentation/task_progress/pdf_task_progress_controller.dart';
import 'package:b21pdf/core/presentation/base_screen.dart';
import 'package:b21pdf/shared/widgets/asset_picture_view.dart';
import 'package:b21pdf/shared/widgets/localized_text_view.dart';
import 'package:b21pdf/shared/widgets/lottie_widget.dart';
import 'package:b21pdf/shared/widgets/tap_guard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class PdfTaskProgressScreen extends BaseScreen<PdfTaskProgressController> {
  const PdfTaskProgressScreen({super.key});

  @override
  PdfTaskProgressController createController() {
    return PdfTaskProgressController();
  }

  @override
  Widget buildContent(
    BuildContext context,
    PdfTaskProgressController controller,
  ) {
    return GetBuilder<PdfTaskProgressController>(
      builder: (PdfTaskProgressController controller) => Column(
        children: [
          _buildTitleBar(controller),
          SizedBox(height: 100.h),
          AssetPictureView(
            "pdf_tools/conversion_progress",
            width: 114.w,
            height: 114.w,
          ),
          SizedBox(height: 20.h),
          LocalizedTextView(
            'PDF Merging...'.tr,
            fontSize: 24.sp,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: 12.h),
          LocalizedTextView(
            'Please do not close the app.'.tr,
            fontSize: 14.sp,
            color: Color(0xff555978),
            fontWeight: FontWeight.w500,
          ),
          Spacer(),
          LocalizedTextView(
            'Processed {current}/{total} images'.tr
                .replaceAll('{current}', '${controller.processedCount}')
                .replaceAll('{total}', '${controller.imagePaths.length}'),
            fontSize: 14.sp,
            color: Color(0xff4B5156),
            fontWeight: FontWeight.w500,
          ),
          SizedBox(height: 12.h),
          Container(
            margin: EdgeInsets.only(left: 20.w, right: 20.w),
            child: LayoutBuilder(
              builder: (context, bc) {
                var maxWidth = bc.maxWidth;
                return Container(
                  width: double.infinity,
                  height: 6.h,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: Color(0xffD12629).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                  child: Container(
                    width: maxWidth * controller.progress,
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: Color(0xffD12629),
                      borderRadius: BorderRadius.circular(8.w),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 25.h),
          LocalizedTextView(
            "${controller.progressPercent}%",
            fontSize: 20.sp,
            color: Color(0xff242C3C),
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: 68.h),
        ],
      ),
    );
  }

  Widget _buildTitleBar(PdfTaskProgressController controller) => Container(
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
