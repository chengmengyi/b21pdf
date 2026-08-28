import 'package:b21pdf/features/home_widget/services/home_widget_service.dart';
import 'package:b21pdf/core/analytics/analytics_event.dart';
import 'package:b21pdf/core/analytics/analytics_service.dart';
import 'package:b21pdf/features/library/presentation/document_list/document_list.dart';
import 'package:b21pdf/features/library/presentation/library_tab/library_tab_controller.dart';
import 'package:b21pdf/core/presentation/base_tab.dart';
import 'package:b21pdf/shared/widgets/asset_picture_view.dart';
import 'package:b21pdf/shared/widgets/localized_text_view.dart';
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
    return GetBuilder<LibraryTabController>(
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
    height: 28.h,
    child: ListView.separated(
      itemCount: DocumentCategory.values.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        var type = DocumentCategory.values[index];
        final b16SelectedQxmvza = index == b16controllerVqmxze.b16SelectedTabIndexQmvnza;
        return B16TapGuardViewMfwqke(
          b16OnPressedJkcxwu: () {
            b16controllerVqmxze.clickTabItem(type);
          },
          b16ChildHnqvsa: Container(
            padding: EdgeInsets.only(left: 12.w, right: 12.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.w),
              color: b16SelectedQxmvza ? null : Colors.white,
              gradient: b16SelectedQxmvza
                  ? LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xffFF8E71), Color(0xffA77FF1)],
              )
                  : null,
              border: Border.all(width: 1.w, color: Color(0xffEBEBEB)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AssetPictureView(
                  "home/${b16SelectedQxmvza ? type.iconSel : type.iconUns}",
                  width: 16.w,
                  height: 16.w,
                ),
                SizedBox(width: 2.w),
                LocalizedTextView(
                  type.name.tr,
                  fontSize: 14.sp,
                  color: b16SelectedQxmvza?Colors.black:Color(0xffA7B2BD),
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) =>
          SizedBox(width: 8.w),
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
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            AssetPictureView(
              "home/home_files_bg",
              width: 28.w,
              height: 20.w,
            ),
            LocalizedTextView(
              "Files".tr,
              fontSize: 32.sp,
              color: Color(0xff07080E),
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          height: 46.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 5,
                offset: const Offset(0, -0.5),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(width: 12.w),
              AssetPictureView("common/search", width: 24.w, height: 24.w),
              SizedBox(width: 8.w),
              Expanded(
                child: TextField(
                  enabled: true,
                  textAlign: TextAlign.left,
                  controller: controller.textEditingController,
                  textInputAction: TextInputAction.search,
                  style: TextStyle(fontSize: 16.sp, color: Color(0xff202326)),
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
                      fontSize: 16.sp,
                      color: Color(0xffA1A1A1),
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: controller.updateFileSearchQuery,
                  onSubmitted: controller.updateFileSearchQuery,
                ),
              ),
              SizedBox(width: 12.w),
            ],
          ),
        ),
      ],
    ),
  );
}
