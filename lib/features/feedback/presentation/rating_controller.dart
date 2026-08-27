import 'package:b21pdf/core/ads/ad_service.dart';
import 'package:b21pdf/core/ads/ad_scene.dart';
import 'package:b21pdf/core/ads/ad_placement.dart';
import 'package:b21pdf/core/user/user_eligibility_service.dart';
import 'package:b21pdf/core/navigation/app_navigator.dart';
import 'package:b21pdf/core/analytics/analytics_event.dart';
import 'package:b21pdf/core/analytics/analytics_service.dart';
import 'package:b21pdf/core/presentation/base_controller.dart';
import 'package:flutter_tba_info/flutter_tba_info.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class RatingController extends BaseController {
  static const String starBuilderId = 'comment_rating_builder';

  int starCount = 0;
  bool _closingDialog = false;

  @override
  void onInit() {
    super.onInit();
    AnalyticsService.instance.trackEvent(pointType: AnalyticsEvent.ratingPopV);
  }

  void onStarPressed(int index) {
    starCount = index + 1;
    update(<Object>[starBuilderId]);
  }

  Future<void> onRateUsPressed() async {
    starCount = 5;
    update(<Object>[starBuilderId]);
    AnalyticsService.instance.trackEvent(pointType: AnalyticsEvent.ratingPopC);
    await _openGooglePlay();
  }

  Future<void> onClosePressed() async {
    if (_closingDialog) {
      return;
    }
    _closingDialog = true;
    if (Get.isBottomSheetOpen == true) {
      AppNavigator.back<bool>(result: false);
    }
  }

  Future<void> _openGooglePlay() async {
    final String packageName = await FlutterTbaInfo.instance.getBundleId();
    final Uri marketUri = Uri.parse('market://details?id=$packageName');
    final Uri webUri = Uri.https(
      'play.google.com',
      '/store/apps/details',
      <String, String>{'id': packageName},
    );
    if (await canLaunchUrl(marketUri)) {
      await launchUrl(marketUri, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
    if (Get.isBottomSheetOpen == true) {
      AppNavigator.back<bool>(result: true);
    }
  }
}
