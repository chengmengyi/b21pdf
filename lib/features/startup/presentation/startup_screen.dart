import 'package:b21pdf/features/startup/presentation/startup_controller.dart';
import 'package:b21pdf/core/presentation/base_screen.dart';
import 'package:b21pdf/shared/widgets/asset_picture_view.dart';
import 'package:b21pdf/shared/widgets/localized_text_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class StartupScreen extends BaseScreen<StartupController> {
  const StartupScreen({super.key});

  @override
  StartupController createController() {
    return StartupController();
  }

  @override
  Widget buildContent(BuildContext context, StartupController controller) {
    return Column(
      children: [
        SizedBox(height: 160.h),
        AssetPictureView('branding/app_logo', width: 88.w, height: 88.w),
        SizedBox(height: 20.h),
        LocalizedTextView(
          'Your pocket file pro'.tr,
          fontSize: 16.sp,
          color: Color(0xff07080E),
          fontWeight: FontWeight.bold,
        ),
        const Spacer(),
        GetBuilder<StartupController>(
          id: StartupController.progressUpdateId,
          builder: (StartupController controller) {
            return buildProgressIndicator(controller.progressValue);
          },
        ),
        SizedBox(height: 120.h),
      ],
    );
  }

  Widget buildProgressIndicator(double progress) {
    final double safeProgress = progress.clamp(0.0, 1.0);
    return Container(
      width: double.infinity,
      height: 12.h,
      margin: EdgeInsets.symmetric(horizontal: 50.w),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints box) {
          final double trackWidth = box.maxWidth - 4.w;
          return Container(
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: const Color(0xffF5F7F9),
              borderRadius: BorderRadius.circular(6.w),
            ),
            child: Container(
              width: trackWidth * safeProgress,
              height: 8.h,
              decoration: BoxDecoration(
                color: Color(0xffCF251F),
                borderRadius: BorderRadius.circular(4.w),
              ),
            ),
          );
        },
      ),
    );
  }
}
