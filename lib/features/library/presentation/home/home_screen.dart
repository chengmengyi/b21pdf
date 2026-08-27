import 'package:b21pdf/features/pdf_tools/services/image_import_service.dart';
import 'package:b21pdf/features/library/presentation/home/home_controller.dart';
import 'package:b21pdf/core/presentation/base_screen.dart';
import 'package:b21pdf/shared/widgets/asset_picture_view.dart';
import 'package:b21pdf/shared/widgets/localized_text_view.dart';
import 'package:b21pdf/shared/widgets/tap_guard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class HomeScreen extends BaseScreen<HomeController> {
  const HomeScreen({super.key});

  @override
  HomeController createController() {
    return HomeController();
  }

  @override
  Color get navigationBarColor => Colors.white;

  @override
  bool get resizeToAvoidBottomInset => false;

  @override
  Future<bool> canPopRoute(HomeController controller) =>
      controller.onSystemBackRequested();

  @override
  Widget buildContent(BuildContext context, HomeController controller) {
    return GetBuilder<HomeController>(
      id: HomeController.tabUpdateId,
      builder: (HomeController controller) {
        return Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: controller.tabIndex,
                children: controller.pages,
              ),
            ),
            buildBottomNavigation(controller, context),
          ],
        );
      },
    );
  }

  Widget buildBottomNavigation(
    HomeController controller,
    BuildContext context,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 92.h,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          AssetPictureView(
            "home/bottom_navigation_background",
            width: double.infinity,
            height: double.infinity,
          ),
          Row(
            children: [
              itemWidget(HomeTab.files, controller, context),
              TapGuardView(
                onPressed: () {
                  ImageImportService.instance.scanDocuments();
                },
                child: AssetPictureView(
                  'home/scan_action',
                  width: 96.w,
                  height: 80.w,
                ),
              ),
              itemWidget(HomeTab.tools, controller, context),
            ],
          ),
        ],
      ),
    );
  }

  Widget itemWidget(
    HomeTab type,
    HomeController controller,
    BuildContext context,
  ) {
    final bool selected = controller.tabIndex == type.index;
    return Expanded(
      child: TapGuardView(
        onPressed: () {
          controller.onTabSelected(type, context);
        },
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AssetPictureView(
                selected ? type.iconSelected : type.iconUnselected,
                width: 33.w,
                height: 33.w,
              ),
              LocalizedTextView(
                type.text.tr,
                fontSize: 12.sp,
                color: selected
                    ? const Color(0xff2897F3)
                    : const Color(0xff9C9FAE),
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
