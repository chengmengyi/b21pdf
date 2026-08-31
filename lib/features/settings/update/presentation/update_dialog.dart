import 'package:b21pdf/features/settings/update/presentation/update_controller.dart';
import 'package:b21pdf/core/presentation/center_dialog.dart';
import 'package:b21pdf/shared/widgets/asset_picture_view.dart';
import 'package:b21pdf/shared/widgets/localized_text_view.dart';
import 'package:b21pdf/shared/widgets/tap_guard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class UpdateDialog extends CenterDialog<UpdateController> {
  const UpdateDialog({super.key});

  @override
  UpdateController createController() => UpdateController();

  @override
  Widget buildDialog(BuildContext context, UpdateController controller) {
    return Container(
      width: double.infinity,
      height: 400.h,
      margin: EdgeInsets.only(left: 28.w, right: 28.w),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          AssetPictureView(
            "feedback/update_dialog_background",
            width: double.infinity,
            height: 400.h,
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(left: 16.w,right: 16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // LocalizedTextView(
                //   "New version coming soon!".tr,
                //   fontSize: 20.sp,
                //   color: Colors.black,
                //   fontWeight: FontWeight.bold,
                // ),
                // SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.w),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.topCenter,
                      colors: [Color(0xffFFFFFF),Color(0xffE1E8FF)],
                    ),
                  ),
                  child: LocalizedTextView(
                    "Your feedback has been received! This information is vital to us. We are continuously optimizing the product experience, and a new version will be launched soon. Please stay with us!"
                        .tr,
                    fontSize: 14.sp,
                    color: Color(0xff4B5156),
                  ),
                ),
                SizedBox(height: 12.h),
                TapGuardView(
                  onPressed: controller.onContinueUsingPressed,
                  child: Container(
                    width: double.infinity,
                    height: 48.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.w),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xff8C69F3), Color(0xff4F29D9)],
                      ),
                    ),
                    child: LocalizedTextView(
                      "Continue using for free".tr,
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                TapGuardView(
                  onPressed: controller.onLeaveAnywayPressed,
                  child: LocalizedTextView(
                    "Leave anyway".tr,
                    fontSize: 14.sp,
                    color: Color(0xff6A73A2),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 12.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
