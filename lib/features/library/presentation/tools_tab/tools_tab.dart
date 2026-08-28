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
            height: 140.h,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleSection(),
                SizedBox(height: 32.h,),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xffF5F7F9),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.w),
                        topRight: Radius.circular(12.w),
                      ),
                    ),
                    child: Column(
                      children: [
                        _toolsWidget(),
                        _systemWidget(),
                        _preferenceWidget(controller),
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

  Widget _toolsWidget() => Container(
    width: double.infinity,
    padding: EdgeInsets.all(16.w),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AssetPictureView(
              "pdf_tools/pdf_tool_icon",
              width: 24.w,
              height: 24.h,
            ),
            SizedBox(width: 4.w,),
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
                child: SizedBox(
                  width: double.infinity,
                  height: 72.h,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AssetPictureView(
                        "pdf_tools/pdf_tool_bg",
                        width: double.infinity,
                        height: 72.h,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AssetPictureView(
                            "pdf_tools/scan_to_pdf",
                            width: 60.w,
                            height: 60.h,
                          ),
                          SizedBox(height: 2.w),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              LocalizedTextView(
                                "Scan To".tr,
                                fontSize: 14.sp,
                                color: Color(0xff525759),
                              ),
                              LocalizedTextView(
                                "PDF",
                                fontSize: 18.sp,
                                color: Color(0xff07080E),
                                fontWeight: FontWeight.bold,
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: TapGuardView(
                onPressed: () {
                  ImageImportService.instance.pickImages();
                },
                child: SizedBox(
                  width: double.infinity,
                  height: 72.h,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AssetPictureView(
                        "pdf_tools/pdf_tool_bg",
                        width: double.infinity,
                        height: 72.h,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AssetPictureView(
                            "pdf_tools/image_to_pdf",
                            width: 60.w,
                            height: 60.h,
                          ),
                          SizedBox(height: 2.w),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              LocalizedTextView(
                                "Image To".tr,
                                fontSize: 14.sp,
                                color: Color(0xff525759),
                              ),
                              LocalizedTextView(
                                "PDF",
                                fontSize: 18.sp,
                                color: Color(0xff07080E),
                                fontWeight: FontWeight.bold,
                              )
                            ],
                          ),
                        ],
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
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AssetPictureView(
              "pdf_tools/set_icon",
              width: 24.w,
              height: 24.w,
            ),
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
            height: 56.h,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 12.w,right: 12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.w),
            ),
            child: Row(
              children: [
                AssetPictureView(
                  "pdf_tools/add_home_widget",
                  width: 32.w,
                  height: 32.w,
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
                AssetPictureView(
                  "pdf_tools/add_widget_icon",
                  width: 24.w,
                  height: 24.w,
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
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AssetPictureView(
              "pdf_tools/per_icon",
              width: 24.w,
              height: 24.w,
            ),
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
            padding: EdgeInsets.only(left: 12.w,right: 12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.w),
            ),
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
                    color: Color(0xff07080E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                LocalizedTextView(
                  controller.currentLanguageName,
                  fontSize: 12.sp,
                  color: Color(0xff8E9091),
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
      margin: EdgeInsets.only(left: 16.w,top: 10.h),
      child: LocalizedTextView(
        "Tools & Settings".tr,
        fontSize: 28.sp,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
