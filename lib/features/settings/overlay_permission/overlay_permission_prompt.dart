import 'dart:async';

import 'package:b21pdf/core/presentation/controller_widget.dart';
import 'package:b21pdf/features/settings/overlay_permission/overlay_permission_prompt_controller.dart';
import 'package:b21pdf/shared/widgets/asset_picture_view.dart';
import 'package:b21pdf/shared/widgets/localized_text_view.dart';
import 'package:b21pdf/shared/widgets/pulse_view.dart';
import 'package:b21pdf/shared/widgets/tap_guard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class OverlayPermissionPrompt
    extends ControllerWidget<OverlayPermissionPromptController> {
  const OverlayPermissionPrompt({
    super.key,
    required this.onSettingsComplete,
    required this.onLater,
  });

  final FutureOr<void> Function() onSettingsComplete;
  final FutureOr<void> Function() onLater;

  @override
  OverlayPermissionPromptController createController() {
    return OverlayPermissionPromptController(
      onSettingsComplete: onSettingsComplete,
      onLater: onLater,
    );
  }

  @override
  Widget buildContent(
    BuildContext context,
    OverlayPermissionPromptController controller,
  ) {
    return PopScope(
      canPop: false,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.w)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.w)),
              child: AssetPictureView(
                'permissions/overlay_permission_prompt',
                width: double.infinity,
                height: 177.h,
                fit: BoxFit.fill,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(26.w, 26.h, 26.w, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  LocalizedTextView(
                    'Please accept overlay permission to continue.'.tr,
                    fontSize: 14.sp,
                    color: const Color(0xff1A1D22),
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: 16.h),
                  PulseView(
                    child: TapGuardView(
                      onPressed: controller.openSettings,
                      child: Container(
                        width: double.infinity,
                        height: 46.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xff2897F3),
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                        child: LocalizedTextView(
                          'GO SETTING'.tr,
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            TapGuardView(
              onPressed: controller.continueWithoutPermission,
              child: LocalizedTextView(
                'Later'.tr,
                fontSize: 14.sp,
                color: const Color(0xff7B7B7B),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }
}
