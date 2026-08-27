import 'package:b21pdf/features/home_widget/services/home_widget_service.dart';
import 'package:b21pdf/core/analytics/analytics_event.dart';
import 'package:b21pdf/core/analytics/analytics_service.dart';
import 'package:b21pdf/features/library/presentation/document_list/document_list.dart';
import 'package:b21pdf/features/library/presentation/library_tab/library_tab_controller.dart';
import 'package:b21pdf/core/presentation/base_tab.dart';
import 'package:b21pdf/shared/widgets/asset_picture_view.dart';
import 'package:b21pdf/shared/widgets/localized_text_view.dart';
import 'package:b21pdf/shared/widgets/tab_view.dart';
import 'package:b21pdf/shared/widgets/tap_guard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LibraryTab extends BaseTab {
  const LibraryTab({super.key});

  @override
  State<LibraryTab> createState() => _DashboardSectionState();
}

class _DashboardSectionState
    extends BaseSectionState<LibraryTabController, LibraryTab> {
  @override
  LibraryTabController createController() {
    return LibraryTabController();
  }

  @override
  Widget buildContent(BuildContext context, LibraryTabController controller) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        AssetPictureView(
          "home/library_header_background",
          width: double.infinity,
          height: 232.h,
        ),
        GetBuilder<LibraryTabController>(
          init: controller,
          builder: (controller) => Container(
            padding: EdgeInsets.only(left: 16.w, right: 16.w),
            child: Column(
              children: [
                _buildHeader(controller),
                _tabWidget(controller),
                if (controller.showAddWidget) _addSmallWidget(controller),
                SizedBox(height: 12.h),
                _buildTabPages(controller),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabPages(LibraryTabController controller) => Expanded(
    child: TabBarView(
      controller: controller.tabController,
      children: DocumentCategory.values
          .map((DocumentCategory type) => DocumentList(type: type))
          .toList(growable: false),
    ),
  );

  _tabWidget(LibraryTabController controller) => SizedBox(
    width: double.infinity,
    height: 40.h,
    child: TabView(
      tabController: controller.tabController,
      onTap: (int index) {
        controller.onTabBarPressed();
      },
    ),
  );

  _addSmallWidget(LibraryTabController controller) => Container(
    width: double.infinity,
    height: 50.h,
    margin: EdgeInsets.only(top: 8.h),
    padding: EdgeInsets.only(left: 16.w, right: 16.w),
    decoration: BoxDecoration(
      color: Color(0xffFFC21C).withOpacity(0.14),
      borderRadius: BorderRadius.circular(25.w),
    ),
    child: Row(
      children: [
        AssetPictureView(
          "home_widget/add_widget_banner",
          width: 32.w,
          height: 32.w,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: LocalizedTextView(
            "To access features instantly, add the widget!".tr,
            fontSize: 14.sp,
            color: Color(0xff242C3C),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 8.w),
        TapGuardView(
          onPressed: () {
            HomeWidgetService.instance.openWidgetPicker();
          },
          child: Container(
            padding: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              top: 4.h,
              bottom: 4.h,
            ),
            decoration: BoxDecoration(
              color: Color(0xff2897F3),
              borderRadius: BorderRadius.circular(18.w),
            ),
            child: LocalizedTextView(
              "Grant".tr,
              fontSize: 14.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );

  _buildHeader(LibraryTabController controller) => SafeArea(
    top: true,
    bottom: false,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          height: 46.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.w),
            border: Border.all(width: 2.w, color: Color(0xff242C3C)),
          ),
          child: Row(
            children: [
              SizedBox(width: 12.w),
              Expanded(
                child: TextField(
                  enabled: true,
                  textAlign: TextAlign.left,
                  controller: controller.textEditingController,
                  textInputAction: TextInputAction.search,
                  style: TextStyle(fontSize: 14.sp, color: Color(0xff202326)),
                  onTap: () {
                    AnalyticsService.instance.trackEvent(
                      pointType: AnalyticsEvent.search_click,
                    );
                  },
                  decoration: InputDecoration(
                    counterText: '',
                    isCollapsed: true,
                    hintText: "Search...".tr,
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: Color(0xff202326),
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: controller.updateFileSearchQuery,
                  onSubmitted: controller.updateFileSearchQuery,
                ),
              ),
              AssetPictureView("common/search", width: 22.w, height: 22.w),
              SizedBox(width: 12.w),
            ],
          ),
        ),
      ],
    ),
  );
}
