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
          topLeft: Radius.circular(16.w),
          topRight: Radius.circular(16.w),
        ),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          AssetPictureView(
            "home_widget/picker_background",
            width: double.infinity,
            height: 198.h,
          ),
          Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LocalizedTextView(
                  'Add Widget'.tr,
                  fontSize: 18.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: 10.h),
                LocalizedTextView(
                  'Add widget with one click to open files'.tr,
                  fontSize: 14.sp,
                  color: const Color(0xff555978),
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
                      color: Color(0xffD12629),
                      borderRadius: BorderRadius.circular(24.w),
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
        ],
      ),
    );
  }

  Widget _buildContentSection() => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.w),
      border: Border.all(width: 1.w, color: Color(0xffCAD5E0)),
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
          Row(
            children: [
              AssetPictureView('branding/app_logo', width: 20.w, height: 20.w),
              SizedBox(width: 8.w),
              LocalizedTextView(
                AppConfig.applicationName,
                fontSize: 12.sp,
                color: Color(0xff242C3C),
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            height: 42.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.w),
              border: Border.all(width: 2.w, color: Color(0xff242C3C)),
            ),
            child: Row(
              children: [
                SizedBox(width: 12.w),
                LocalizedTextView(
                  "Search...".tr,
                  fontSize: 14.sp,
                  color: Color(0xff555978),
                ),
                Spacer(),
                AssetPictureView("common/search", width: 22.w, height: 22.w),
                SizedBox(width: 12.w),
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
                return Column(
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
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
