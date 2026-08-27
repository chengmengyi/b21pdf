import 'package:b21pdf/features/library/presentation/tools_tab/tools_tab_controller.dart';
import 'package:b21pdf/features/home_widget/services/home_widget_service.dart';
import 'package:b21pdf/features/pdf_tools/services/image_import_service.dart';
import 'package:b21pdf/core/presentation/base_tab.dart';
import 'package:b21pdf/shared/widgets/asset_picture_view.dart';
import 'package:b21pdf/shared/widgets/localized_text_view.dart';
import 'package:b21pdf/shared/widgets/tap_guard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ToolsTab extends BaseTab {
  const ToolsTab({super.key});

  @override
  State<ToolsTab> createState() => _UtilitiesSectionState();
}

class _UtilitiesSectionState
    extends BaseSectionState<ToolsTabController, ToolsTab> {
  @override
  ToolsTabController createController() {
    return ToolsTabController();
  }

  @override
  Widget buildContent(BuildContext context, ToolsTabController controller) {
    return GetBuilder<ToolsTabController>(
      init: controller,
      global: false,
      builder: (controller) => Stack(
        children: [
          AssetPictureView(
            "home/library_header_background",
            width: double.infinity,
            height: 232.h,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleSection(),
                SizedBox(height: 10.h),
                _toolsWidget(),
                Container(
                  width: double.infinity,
                  height: 8.h,
                  color: Color(0xffF3F3F4),
                ),
                _systemWidget(),
                Container(
                  width: double.infinity,
                  height: 8.h,
                  color: Color(0xffF3F3F4),
                ),
                _preferenceWidget(controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolsWidget() => Container(
    width: double.infinity,
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.w),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LocalizedTextView(
              "PDF tools".tr,
              fontSize: 16.sp,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: TapGuardView(
                onPressed: () {
                  ImageImportService.instance.scanDocuments();
                },
                child: Container(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AssetPictureView(
                        "pdf_tools/scan_to_pdf",
                        width: 42.w,
                        height: 42.h,
                      ),
                      SizedBox(height: 2.w),
                      LocalizedTextView(
                        "Scan To PDF".tr,
                        fontSize: 12.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: TapGuardView(
                onPressed: () {
                  ImageImportService.instance.pickImages();
                },
                child: Container(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AssetPictureView(
                        "pdf_tools/image_to_pdf",
                        width: 42.w,
                        height: 42.h,
                      ),
                      SizedBox(height: 2.w),
                      LocalizedTextView(
                        "Image To PDF".tr,
                        fontSize: 12.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _systemWidget() => Container(
    width: double.infinity,
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(color: Colors.white),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LocalizedTextView(
              "System".tr,
              fontSize: 16.sp,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
        SizedBox(height: 12.h),
        TapGuardView(
          onPressed: () {
            HomeWidgetService.instance.openWidgetPicker();
          },
          child: Container(
            width: double.infinity,
            height: 64.h,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                AssetPictureView(
                  "pdf_tools/add_home_widget",
                  width: 38.w,
                  height: 38.w,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: LocalizedTextView(
                    "Add Widget".tr,
                    fontSize: 14.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                    left: 30.w,
                    right: 30.w,
                    top: 6.h,
                    bottom: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xffD12629),
                    borderRadius: BorderRadius.circular(38.w),
                  ),
                  child: LocalizedTextView(
                    "Add".tr,
                    fontSize: 12.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _preferenceWidget(ToolsTabController controller) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(color: Colors.white),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 8.w),
            LocalizedTextView(
              "Preference".tr,
              fontSize: 14.sp,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
        SizedBox(height: 12.h),
        TapGuardView(
          onPressed: () {
            controller.onChangeLanguagePressed();
          },
          child: Container(
            width: double.infinity,
            height: 56.h,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                AssetPictureView(
                  "languages/language_icon",
                  width: 38.w,
                  height: 38.w,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: LocalizedTextView(
                    "App Language".tr,
                    fontSize: 14.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                LocalizedTextView(
                  controller.currentLanguageName,
                  fontSize: 10.sp,
                  color: Color(0xff9C9FAE),
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(width: 4.w),
                AssetPictureView(
                  "navigation/chevron_right",
                  width: 25.w,
                  height: 25.w,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildTitleSection() => SafeArea(
    top: true,
    bottom: false,
    child: Container(
      margin: EdgeInsets.only(left: 16.w),
      child: LocalizedTextView(
        "Tools & Settings".tr,
        fontSize: 25.sp,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
