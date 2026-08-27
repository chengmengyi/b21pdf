import 'package:b21pdf/features/library/presentation/document_sort/document_sort_controller.dart';
import 'package:b21pdf/core/navigation/app_navigator.dart';
import 'package:b21pdf/core/presentation/controller_widget.dart';
import 'package:b21pdf/shared/widgets/asset_picture_view.dart';
import 'package:b21pdf/shared/widgets/localized_text_view.dart';
import 'package:b21pdf/shared/widgets/media_padding_view.dart';
import 'package:b21pdf/shared/widgets/tap_guard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class DocumentSortBottomSheet extends ControllerWidget<DocumentSortController> {
  final SortType selectedType;
  DocumentSortBottomSheet({required this.selectedType});

  @override
  DocumentSortController createController() =>
      DocumentSortController(selectedType: selectedType);

  @override
  Widget buildContent(BuildContext context, DocumentSortController controller) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.w),
          topRight: Radius.circular(16.w),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [_buildTitleSection(), _buildLanguageList(controller)],
      ),
    );
  }

  _buildLanguageList(DocumentSortController controller) => MediaPaddingView(
    child: ListView.builder(
      shrinkWrap: true,
      itemCount: SortType.values.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        var type = SortType.values[index];
        final bool selected = type == controller.selectedType;
        return TapGuardView(
          onPressed: () {
            controller.onSortPressed(type);
          },
          child: Container(
            width: double.infinity,
            height: 56.h,
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(left: 16.w, right: 16.w),
            padding: EdgeInsets.only(left: 16.w, right: 16.w),
            decoration: BoxDecoration(
              color: selected ? null : Colors.white,
              borderRadius: BorderRadius.circular(8.w),
              gradient: selected
                  ? LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xffD12629).withOpacity(0.1),
                        Colors.transparent,
                      ],
                    )
                  : null,
            ),
            child: Row(
              children: [
                AssetPictureView(
                  selected ? type.iconVxe : type.icon,
                  width: 24.w,
                  height: 24.w,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: LocalizedTextView(
                    type.text.tr,
                    fontSize: 16.sp,
                    color: selected
                        ? const Color(0xffD12629)
                        : const Color(0xff242C3C),
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                if (selected)
                  AssetPictureView(
                    "document_library/sort_selection",
                    width: 24.w,
                    height: 24.w,
                  ),
              ],
            ),
          ),
        );
      },
    ),
  );

  _buildTitleSection() => SizedBox(
    width: double.infinity,
    height: 56.h,
    child: Stack(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.only(left: 16.w),
            child: LocalizedTextView(
              "Sort By".tr,
              fontSize: 16.sp,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            margin: EdgeInsets.only(right: 16.w),
            child: TapGuardView(
              onPressed: () {
                AppNavigator.back();
              },
              child: AssetPictureView(
                "navigation/close",
                width: 24.w,
                height: 24.w,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
