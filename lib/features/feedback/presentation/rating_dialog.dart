import 'package:b21pdf/features/feedback/presentation/rating_controller.dart';
import 'package:b21pdf/core/presentation/controller_widget.dart';
import 'package:b21pdf/shared/widgets/asset_picture_view.dart';
import 'package:b21pdf/shared/widgets/localized_text_view.dart';
import 'package:b21pdf/shared/widgets/media_padding_view.dart';
import 'package:b21pdf/shared/widgets/tap_guard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

class RatingDialog extends ControllerWidget<RatingController> {
  const RatingDialog({super.key});

  @override
  RatingController createController() => RatingController();

  @override
  Widget buildContent(BuildContext context, RatingController controller) {
    return TapGuardView(
      onPressed: () {
        controller.onRateUsPressed();
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.w),
            topRight: Radius.circular(16.w),
          ),
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              margin: EdgeInsets.only(left: 16.w, right: 16.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20.h),
                  AssetPictureView(
                    "branding/app_logo",
                    width: 68.w,
                    height: 68.w,
                  ),
                  SizedBox(height: 16.h),
                  LocalizedTextView(
                    "Enjoying PDF Reader?".tr,
                    fontSize: 20.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 10.h),
                  LocalizedTextView(
                    "Your 5-star rating helps us improve! It only takes a few seconds of your time."
                        .tr,
                    fontSize: 14.sp,
                    color: Color(0xff4B5156),
                  ),
                  SizedBox(height: 10.h),
                  // Selected and unselected rating stars.
                  Container(
                    width: double.infinity,
                    height: 48.w,
                    margin: EdgeInsets.only(left: 20.w, right: 20.w),
                    child: GetBuilder<RatingController>(
                      id: RatingController.starBuilderId,
                      builder: (builder) => MediaPaddingView(
                        child: MasonryGridView.count(
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 5,
                          mainAxisSpacing: 0,
                          crossAxisSpacing: 12.w,
                          itemCount: 5,
                          itemBuilder: (BuildContext context, int index) {
                            final bool selected = index < builder.starCount;
                            return TapGuardView(
                              onPressed: () {
                                builder.onStarPressed(index);
                              },
                              child: AssetPictureView(
                                selected
                                    ? "feedback/star_selected"
                                    : "feedback/star_unselected",
                                width: 48.w,
                                height: 48.w,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TapGuardView(
                    onPressed: controller.onRateUsPressed,
                    child: Container(
                      width: double.infinity,
                      height: 48.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.w),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xffFF8E71), Color(0xffA77FF1)],
                        ),
                      ),
                      child: LocalizedTextView(
                        "Rate Us 5 Stars".tr,
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: TapGuardView(
                onPressed: () {
                  controller.onClosePressed();
                },
                child: Container(
                  width: 44.w,
                  height: 44.w,
                  alignment: Alignment.center,
                  child: AssetPictureView(
                    "navigation/close",
                    height: 24.w,
                    width: 24.w,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
