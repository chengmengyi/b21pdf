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
        SizedBox(height: 120.h),
        AssetPictureView(
          "permissions/notification_illustration",
          width: 256.w,
          height: 208.h,
        ),
        Spacer(),
        LocalizedTextView(
          "This app has an update".tr,
          fontSize: 20.sp,
          color: Color(0xff242C3C),
          fontWeight: FontWeight.bold,
        ),
        SizedBox(height: 10.h),
        LocalizedTextView(
          "Please upgrade to enjoy the latest functions.".tr,
          fontSize: 16.sp,
          color: Color(0xff555978),
          fontWeight: FontWeight.w500,
        ),
        SizedBox(height: 20.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          margin: EdgeInsets.symmetric(horizontal: 30.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.w),
            color: Color(0xffF3F3F4),
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
                      fontSize: 14.sp,
                      color: Color(0xff242C3C),
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                    LocalizedTextView(
                      "All notifications".tr,
                      fontSize: 12.sp,
                      color: Color(0xff9C9FAE),
                    ),
                  ],
                ),
              ),
              const SwitchView(),
            ],
          ),
        ),
        SizedBox(height: 30.h),
        PulseView(
          child: TapGuardView(
            onPressed: () {
              controller.onUpdatePressed();
            },
            child: Container(
              width: double.infinity,
              height: 46.h,
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Color(0xffD12629),
                borderRadius: BorderRadius.circular(42.w),
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
            color: const Color(0xff555978),
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 25.h),
      ],
    );
  }
}
