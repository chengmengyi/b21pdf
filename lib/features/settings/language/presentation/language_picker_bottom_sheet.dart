import 'package:b21pdf/features/settings/language/presentation/language_picker_controller.dart';
import 'package:b21pdf/features/settings/language/supported_locales.dart';
import 'package:b21pdf/core/navigation/app_navigator.dart';
import 'package:b21pdf/core/presentation/controller_widget.dart';
import 'package:b21pdf/shared/widgets/asset_picture_view.dart';
import 'package:b21pdf/shared/widgets/localized_text_view.dart';
import 'package:b21pdf/shared/widgets/media_padding_view.dart';
import 'package:b21pdf/shared/widgets/tap_guard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LanguagePickerBottomSheet
    extends ControllerWidget<LanguagePickerController> {
  const LanguagePickerBottomSheet({super.key});

  @override
  LanguagePickerController createController() => LanguagePickerController();
  @override
  Widget buildContent(
    BuildContext context,
    LanguagePickerController controller,
  ) => GetBuilder<LanguagePickerController>(
    init: controller,
    global: false,
    builder: (controller) => Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.w),
          topRight: Radius.circular(16.w),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTitleSection(),
          _buildContentSection(controller),
          SizedBox(height: 12.h),
        ],
      ),
    ),
  );

  Widget _buildContentSection(LanguagePickerController controller) => Container(
    width: double.infinity,
    height: 448.h,
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: Color(0xffF5F7F9),
      borderRadius: BorderRadius.circular(12.w),
    ),
    child: MediaPaddingView(
      child: ListView.builder(
        controller: controller.languageScrollController,
        itemCount: controller.languageList.length,
        itemBuilder: (context, index) {
          final SupportedLocale item = controller.languageList[index];
          final selected = controller.isSelected(item);
          return TapGuardView(
            onPressed: () => controller.onLanguagePressed(item),
            child: Container(
              width: double.infinity,
              height: 56.h,
              padding: EdgeInsets.only(left: 12.w,right: 12.w),
              decoration: BoxDecoration(
                color: selected?Colors.white:null,
                borderRadius: BorderRadius.circular(4.w),
              ),
              child: Row(
                children: [
                  AssetPictureView(item.icon, width: 32.w, height: 32.w),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: LocalizedTextView(
                      item.name,
                      fontSize: 14.sp,
                      color: const Color(0xff060E23),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  AssetPictureView(
                    selected
                        ? 'common/radio_selected'
                        : 'common/radio_unselected',
                    width: 20.w,
                    height: 20.w,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );

  Widget _buildTitleSection() => SizedBox(
    width: double.infinity,
    height: 56.h,
    child: Stack(
      children: [
        Align(
          child: LocalizedTextView(
            'App Language'.tr,
            fontSize: 20.sp,
            color: Color(0xff07080E),
            fontWeight: FontWeight.bold,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TapGuardView(
            onPressed: AppNavigator.back,
            child: AssetPictureView(
              'navigation/close',
              width: 24.w,
              height: 24.w,
            ),
          ),
        ),
      ],
    ),
  );
}
