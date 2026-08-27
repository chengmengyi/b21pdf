import 'package:b21pdf/core/config/app_config.dart';
import 'package:b21pdf/features/settings/overlay_permission/overlay_permission_controller.dart';
import 'package:b21pdf/core/presentation/base_screen.dart';
import 'package:b21pdf/shared/widgets/asset_picture_view.dart';
import 'package:b21pdf/shared/widgets/localized_text_view.dart';
import 'package:b21pdf/shared/widgets/pulse_view.dart';
import 'package:b21pdf/shared/widgets/switch_view.dart';
import 'package:b21pdf/shared/widgets/tap_guard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class OverlayPermissionScreen extends BaseScreen<OverlayPermissionController> {
  const OverlayPermissionScreen({super.key});

  @override
  OverlayPermissionController createController() {
    return OverlayPermissionController();
  }

  @override
  Widget buildContent(
    BuildContext context,
    OverlayPermissionController controller,
  ) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        AssetPictureView(
          'permissions/overlay_header_background',
          width: double.infinity,
          height: 180.h,
        ),
        Column(
          children: [
            SafeArea(
              top: true,
              bottom: false,
              child: AssetPictureView(
                'permissions/overlay_illustration',
                width: double.infinity,
                height: 272.h,
              ),
            ),
            SizedBox(height: 24.h),
            LocalizedTextView(
              'Unlock Full PDF Potential'.tr,
              fontSize: 24.sp,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 24.h),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LocalizedTextView(
                  'Step 1: find PDF flow in the list below.'.tr,
                  fontSize: 14.sp,
                  color: const Color(0xff4b5156),
                  fontWeight: FontWeight.w500,
                ),
                LocalizedTextView(
                  'Step 2: toggle the switch to ON.'.tr,
                  fontSize: 14.sp,
                  color: const Color(0xff4b5156),
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
            SizedBox(height: 56.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              margin: EdgeInsets.symmetric(horizontal: 40.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.w),
                border: Border.all(
                  width: 0.5.w,
                  color: const Color(0xff000000).withValues(alpha: 0.1),
                ),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  AssetPictureView(
                    'branding/app_logo',
                    width: 48.w,
                    height: 48.w,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: LocalizedTextView(
                      AppConfig.applicationName.tr,
                      fontSize: 16.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SwitchView(),
                ],
              ),
            ),
            const Spacer(),
            PulseView(
              child: TapGuardView(
                onPressed: controller.onContinuePressed,
                child: Container(
                  width: double.infinity,
                  height: 48.h,
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.w),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xff06B3F2), Color(0xff002DF6)],
                    ),
                  ),
                  child: LocalizedTextView(
                    'Continue'.tr,
                    fontSize: 18.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            TapGuardView(
              onPressed: controller.onLaterPressed,
              child: LocalizedTextView(
                'Later'.tr,
                fontSize: 16.sp,
                color: const Color(0xff4b5156),
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 36.h),
          ],
        ),
      ],
    );
  }
}
