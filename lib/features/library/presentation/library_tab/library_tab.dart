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
  State<LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState
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
            SizedBox(height: 16.h),
            _buildCategoryTabs(controller),
            if (controller.showAddWidget) _buildAddWidgetBanner(),
            SizedBox(height: 12.h),
            _buildTabPages(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPages(LibraryTabController controller) => Expanded(
    child: PageView.builder(
      controller: controller.pageController,
      itemCount: DocumentCategory.values.length,
      onPageChanged: (int index) => controller.onPageChanged(index, context),
      itemBuilder: (BuildContext context, int index) =>
          DocumentList(type: DocumentCategory.values[index]),
    ),
  );

  Widget _buildCategoryTabs(LibraryTabController controller) => SizedBox(
    width: double.infinity,
    height: 28.h,
    child: ListView.separated(
      itemCount: DocumentCategory.values.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        final DocumentCategory category = DocumentCategory.values[index];
        final bool isSelected = index == controller.selectedTabIndex;
        return TapGuardView(
          onPressed: () {
            controller.selectCategory(category);
          },
          child: Container(
            padding: EdgeInsets.only(left: 12.w,right: 12.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.w),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xffE8EEF4),Color(0xffFFFFFF)]
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AssetPictureView(
                  "home/${isSelected ? category.selectedIcon : category.unselectedIcon}",
                  width: 16.w,
                  height: 16.w,
                ),
                SizedBox(width: 4.w),
                LocalizedTextView(
                  category.label.tr,
                  fontSize: 14.sp,
                  color: isSelected ? Colors.black : const Color(0xffA7B2BD),
                  fontWeight: FontWeight.bold,
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

  Widget _buildAddWidgetBanner() => Stack(
    alignment: Alignment.bottomLeft,
    children: [
      Container(
        width: double.infinity,
        height: 56.h,
        margin: EdgeInsets.only(top: 8.h),
        padding: EdgeInsets.only(left: 68.w, right: 16.w),
        decoration: BoxDecoration(
          color: const Color(0xffFFECB8),
          borderRadius: BorderRadius.circular(28.w),
        ),
        child: Row(
          children: [
            SizedBox(width: 8.w),
            Expanded(
              child: LocalizedTextView(
                "To access features instantly, add the widget!".tr,
                fontSize: 14.sp,
                color: Color(0xff07080E),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.w),
                ),
                child: LocalizedTextView(
                  "Grant".tr,
                  fontSize: 14.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      AssetPictureView(
        "home_widget/add_widget_banner",
        width: 64.w,
        height: 64.w,
      ),
    ],
  );

  Widget _buildHeader(LibraryTabController controller) => SafeArea(
    top: true,
    bottom: false,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            AssetPictureView("home/home_files_bg", width: 28.w, height: 20.w),
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
