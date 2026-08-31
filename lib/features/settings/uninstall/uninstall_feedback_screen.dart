import 'dart:async';

import 'package:b21pdf/core/ads/ad_service.dart';
import 'package:b21pdf/core/ads/ad_scene.dart';
import 'package:b21pdf/core/ads/ad_placement.dart';
import 'package:b21pdf/core/user/user_eligibility_service.dart';
import 'package:b21pdf/features/settings/uninstall/uninstall_feedback_controller.dart';
import 'package:b21pdf/core/presentation/base_screen.dart';
import 'package:b21pdf/shared/widgets/asset_picture_view.dart';
import 'package:b21pdf/shared/widgets/localized_text_view.dart';
import 'package:b21pdf/shared/widgets/media_padding_view.dart';
import 'package:b21pdf/shared/widgets/tap_guard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class UninstallFeedbackScreen extends BaseScreen<UninstallFeedbackController> {
  const UninstallFeedbackScreen({super.key});

  @override
  UninstallFeedbackController createController() {
    return UninstallFeedbackController();
  }

  @override
  Color get navigationBarColor => Colors.white;

  @override
  Widget buildContent(
    BuildContext context,
    UninstallFeedbackController controller,
  ) {
    return Column(
      children: [
        _buildTitleSection(controller),
        SizedBox(height: 8.h),
        _buildContentSection(controller),
        _buildBottomSection(controller),
        _buildNativeAd(),
      ],
    );
  }

  Widget _buildNativeAd() {
    if (!UserEligibilityService.instance.isEligibleUser) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 14.h),
      child: const _UninstallNativeAd(),
    );
  }

  Widget _buildContentSection(UninstallFeedbackController controller) =>
      Expanded(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GetBuilder<UninstallFeedbackController>(
                  id: UninstallFeedbackController.reasonBuilderId,
                  builder: (builder) => MediaPaddingView(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: builder.reasonList.length,
                      itemBuilder: (context, index) {
                        final bool selected =
                            builder.selectedReasonIndex == index;
                        return TapGuardView(
                          onPressed: () {
                            builder.onReasonPressed(index);
                          },
                          child: Container(
                            width: double.infinity,
                            height: 48.h,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(left: 16.w, right: 16.w),
                            child: Row(
                              children: [
                                Expanded(
                                  child: LocalizedTextView(
                                    builder.reasonList[index].tr,
                                    fontSize: 14.sp,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                AssetPictureView(
                                  selected
                                      ? "common/radio_selected"
                                      : "common/radio_unselected",
                                  width: 20.w,
                                  height: 20.w,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          Container(
                            width: double.infinity,
                            height: 0.5.h,
                            color: Color(0xffEBEBEB),
                          ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 120.h,
                  padding: EdgeInsets.all(16.w),
                  margin: EdgeInsets.only(left: 16.w, right: 16.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.w),
                    border: Border.all(width: 0.5.w, color: Color(0xffEBEBEB)),
                  ),
                  child: TextField(
                    textAlign: TextAlign.start,
                    enabled: true,
                    controller: controller.textEditingController,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF1A1D22),
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      isCollapsed: true,
                      hintText:
                          'Please enter the reason for uninstalling All PDF'.tr,
                      hintStyle: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFFB2B2B2),
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildBottomSection(UninstallFeedbackController controller) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      TapGuardView(
        onPressed: controller.onNoUninstallPressed,
        child: Container(
          width: double.infinity,
          height: 50.h,
          alignment: Alignment.center,
          margin: EdgeInsets.only(left: 34.w, right: 34.w),
          decoration: BoxDecoration(
            color: Color(0xff8C69F3),
            borderRadius: BorderRadius.circular(16.w),
          ),
          child: LocalizedTextView(
            "Don't uninstall for now".tr,
            fontSize: 16.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      SizedBox(height: 14.h),
      TapGuardView(
        onPressed: () {
          controller.onUninstallPressed();
        },
        child: LocalizedTextView(
          "Uninstall".tr,
          fontSize: 16.sp,
          color: Color(0xff8E9091),
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );

  Widget _buildTitleSection(UninstallFeedbackController controller) =>
      Container(
        width: double.infinity,
        color: Colors.white,
        child: SafeArea(
          top: true,
          bottom: false,
          child: SizedBox(
            width: double.infinity,
            height: 44.h,
            child: Stack(
              children: [
                TapGuardView(
                  onPressed: controller.onNoUninstallPressed,
                  child: Container(
                    width: 44.w,
                    height: 44.h,
                    alignment: Alignment.center,
                    child: AssetPictureView(
                      "navigation/close",
                      width: 24.w,
                      height: 24.w,
                    ),
                  ),
                ),
                Align(
                  child: Container(
                    margin: EdgeInsets.only(left: 44.w, right: 44.w),
                    child: LocalizedTextView(
                      "Uninstall reason".tr,
                      fontSize: 18.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _UninstallNativeAd extends StatefulWidget {
  const _UninstallNativeAd();

  @override
  State<_UninstallNativeAd> createState() => _UninstallNativeAdState();
}

class _UninstallNativeAdState extends State<_UninstallNativeAd> {
  static const Duration _retryDuration = Duration(milliseconds: 500);

  Timer? _retryTimer;
  Widget? _adWidget;
  bool _checkingAd = false;
  bool _canShowAd = false;

  @override
  void initState() {
    super.initState();
    unawaited(_initializeNativeAd());
  }

  Future<void> _initializeNativeAd() async {
    final AdService adService = AdService.instance;
    final bool canShowAd = await adService.isPlacementEnabled(
      AdPlacement.unload_nat1,
    );
    if (!mounted || !canShowAd) return;
    setState(() => _canShowAd = true);
    adService.trackAdOpportunity(
      adScene: AdScene.pr_ban2,
      adPosId: AdPlacement.unload_nat1,
    );
    unawaited(_attachNativeAdWidget());
    _retryTimer = Timer.periodic(
      _retryDuration,
      (_) => unawaited(_attachNativeAdWidget()),
    );
  }

  Future<void> _attachNativeAdWidget() async {
    if (_adWidget != null || _checkingAd) {
      return;
    }
    _checkingAd = true;
    try {
      final Widget? adWidget = await AdService.instance.buildCachedNativeAd(
        adScene: AdScene.pr_ban2,
        adPosId: AdPlacement.unload_nat1,
      );
      if (!mounted || adWidget == null) {
        return;
      }
      _retryTimer?.cancel();
      _retryTimer = null;
      setState(() => _adWidget = adWidget);
    } finally {
      _checkingAd = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_canShowAd) return const SizedBox.shrink();
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child:
          _adWidget ??
          const AssetPictureView(
            'ads/native_ad_placeholder',
            width: double.infinity,
          ),
    );
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _retryTimer = null;
    super.dispose();
  }
}
