import 'package:b21pdf/core/permissions/presentation/permission_rationale_controller.dart';
import 'package:b21pdf/core/presentation/center_dialog.dart';
import 'package:b21pdf/shared/widgets/localized_text_view.dart';
import 'package:b21pdf/shared/widgets/tap_guard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionRationaleDialog
    extends CenterDialog<PermissionRationaleController> {
  final Permission permission;
  PermissionRationaleDialog({required this.permission});

  @override
  PermissionRationaleController createController() =>
      PermissionRationaleController(permission: permission);

  @override
  Widget buildDialog(
    BuildContext context,
    PermissionRationaleController controller,
  ) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 28.w, right: 28.w),
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        top: 16.h,
        bottom: 16.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.w),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LocalizedTextView(
            "Permission Required".tr,
            fontSize: 20.sp,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Color(0xffF3F5F7),
              borderRadius: BorderRadius.circular(8.w),
              border: Border.all(width: 0.5.w, color: Color(0xffEBEBEB)),
            ),
            child: LocalizedTextView(
              controller.buildPermissionMessage(),
              fontSize: 14.sp,
              color: Color(0xff4B4D56),
            ),
          ),
          SizedBox(height: 20.h),
          TapGuardView(
            onPressed: controller.onAllowPressed,
            child: Container(
              width: double.infinity,
              height: 48.h,
              alignment: Alignment.center,
              margin: EdgeInsets.only(left: 24.w, right: 24.w),
              decoration: BoxDecoration(
                color: Color(0xff8C69F3),
                borderRadius: BorderRadius.circular(12.w),
              ),
              child: LocalizedTextView(
                "Allow".tr,
                fontSize: 16.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          TapGuardView(
            onPressed: () {
              controller.onLaterPressed();
            },
            child: LocalizedTextView(
              'Later'.tr,
              fontSize: 14.sp,
              color: const Color(0xff858C92),
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}
