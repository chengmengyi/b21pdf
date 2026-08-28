import 'package:b21pdf/core/config/app_config.dart';
import 'package:b21pdf/features/home_widget/presentation/home_widget_controller.dart';
import 'package:b21pdf/features/home_widget/services/home_widget_service.dart';
import 'package:b21pdf/core/presentation/controller_widget.dart';
import 'package:b21pdf/shared/widgets/asset_picture_view.dart';
import 'package:b21pdf/shared/widgets/localized_text_view.dart';
import 'package:b21pdf/shared/widgets/media_padding_view.dart';
import 'package:b21pdf/shared/widgets/tap_guard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

class HomeWidgetBottomSheet extends ControllerWidget<HomeWidgetController> {
  const HomeWidgetBottomSheet({super.key});

  @override
  HomeWidgetController createController() => HomeWidgetController();

  @override
  Widget buildContent(BuildContext context, HomeWidgetController controller) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.w),
          topRight: Radius.circular(20.w),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LocalizedTextView(
              'Add Widget'.tr,
              fontSize: 20.sp,
              color: Color(0xff07080E),
              fontWeight: FontWeight.w500,
            ),
            SizedBox(height: 10.h),
            LocalizedTextView(
              'Add widget with one click to open files'.tr,
              fontSize: 14.sp,
              color: const Color(0xff525759),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12.h),
            _buildContentSection(),
            SizedBox(height: 20.h),
            TapGuardView(
              onPressed: () {
                controller.onAddPressed();
              },
              child: Container(
                width: double.infinity,
                height: 48.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color(0xff8C69F3),
                  borderRadius: BorderRadius.circular(16.w),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AssetPictureView(
                      "home_widget/add_action",
                      width: 24.w,
                      height: 24.w,
                    ),
                    SizedBox(width: 8.w),
                    LocalizedTextView(
                      "Add".tr,
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection() => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Color(0xffF5F5F9),
      borderRadius: BorderRadius.circular(16.w),
      border: Border.all(width: 1.w, color: Color(0xffFFFFFF)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 5,
          offset: const Offset(0, -0.5),
        ),
      ],
    ),
    child: Container(
      margin: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            height: 40.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.w),
            ),
            child: Row(
              children: [
                SizedBox(width: 12.w),
                AssetPictureView("common/search", width: 22.w, height: 22.w),
                SizedBox(width: 8.w),
                LocalizedTextView(
                  "Search...".tr,
                  fontSize: 16.sp,
                  color: Color(0xffA1A1A1),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          MediaPaddingView(
            child: MasonryGridView.count(
              crossAxisCount: 4,
              mainAxisSpacing: 0,
              crossAxisSpacing: 8.w,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: InsertWidgetType.values.length,
              itemBuilder: (BuildContext context, int index) {
                var type = InsertWidgetType.values[index];
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    AssetPictureView(type.bgIcon, width: double.infinity, height: 80.h),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AssetPictureView(type.icon, width: 36.w, height: 36.w),
                        SizedBox(height: 4.h),
                        LocalizedTextView(
                          type.text.tr,
                          fontSize: 12.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
