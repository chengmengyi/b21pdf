import 'package:b21pdf/core/config/app_config.dart';
import 'package:b21pdf/features/notifications/presentation/permission/notification_permission_controller.dart';
import 'package:b21pdf/core/presentation/base_screen.dart';
import 'package:b21pdf/shared/widgets/asset_picture_view.dart';
import 'package:b21pdf/shared/widgets/localized_text_view.dart';
import 'package:b21pdf/shared/widgets/pulse_view.dart';
import 'package:b21pdf/shared/widgets/switch_view.dart';
import 'package:b21pdf/shared/widgets/tap_guard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class NotificationPermissionScreen
    extends BaseScreen<NotificationPermissionController> {
  const NotificationPermissionScreen({super.key});

  @override
  NotificationPermissionController createController() {
    return NotificationPermissionController();
  }

  @override
  Widget buildContent(
    BuildContext context,
    NotificationPermissionController controller,
  ) {
    return Column(
      children: [
        AssetPictureView(
          "permissions/notification_illustration",
          width: double.infinity,
          height: 320.h,
        ),
        SizedBox(height: 24.h),
        LocalizedTextView(
          "This app has an update".tr,
          fontSize: 24.sp,
          color: Color(0xff07080E),
          fontWeight: FontWeight.bold,
        ),
        SizedBox(height: 10.h),
        LocalizedTextView(
          "Please upgrade to enjoy the latest functions.".tr,
          fontSize: 14.sp,
          color: Color(0xff8E9091),
          fontWeight: FontWeight.w500,
        ),
        Spacer(),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          margin: EdgeInsets.symmetric(horizontal: 40.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.w),
            color: Color(0xffF5F7F9),
          ),
          child: Row(
            children: [
              AssetPictureView('branding/app_logo', width: 48.w, height: 48.w),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LocalizedTextView(
                      AppConfig.applicationName.tr,
                      fontSize: 16.sp,
                      color: Color(0xff07080E),
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                    LocalizedTextView(
                      "All notifications".tr,
                      fontSize: 12.sp,
                      color: Color(0xff525759),
                    ),
                  ],
                ),
              ),
              const SwitchView(),
            ],
          ),
        ),
        Spacer(),
        PulseView(
          child: TapGuardView(
            onPressed: () {
              controller.onUpdatePressed();
            },
            child: Container(
              width: double.infinity,
              height: 48.h,
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Color(0xff8C69F3),
                borderRadius: BorderRadius.circular(12.w),
              ),
              child: LocalizedTextView(
                'Update now'.tr,
                fontSize: 16.sp,
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
            fontSize: 14.sp,
            color: const Color(0xff525759),
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 25.h),
      ],
    );
  }
}
