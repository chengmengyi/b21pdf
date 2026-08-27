import 'package:b21pdf/core/ads/ad_service.dart';
import 'package:b21pdf/core/ads/ad_scene.dart';
import 'package:b21pdf/core/ads/ad_placement.dart';
import 'package:b21pdf/features/feedback/presentation/rating_dialog.dart';
import 'package:b21pdf/core/user/user_eligibility_service.dart';
import 'package:b21pdf/features/notifications/services/notification_service.dart';
import 'package:b21pdf/core/navigation/app_routes.dart';
import 'package:b21pdf/core/navigation/app_navigator.dart';
import 'package:b21pdf/core/analytics/analytics_event.dart';
import 'package:b21pdf/core/analytics/analytics_service.dart';
import 'package:b21pdf/features/library/presentation/library_tab/library_tab.dart';
import 'package:b21pdf/features/library/presentation/tools_tab/tools_tab.dart';
import 'package:b21pdf/core/presentation/base_controller.dart';
import 'package:flutter/cupertino.dart';

enum HomeTab {
  files('Files', 'home/library_tab_selected', 'home/library_tab_unselected'),
  tools('Tools', 'home/tools_tab_selected', 'home/tools_tab_unselected');

  const HomeTab(this.text, this.iconSelected, this.iconUnselected);

  final String text;
  final String iconSelected;
  final String iconUnselected;
}

class HomeController extends BaseController {
  static const String tabUpdateId = 'dashboard_tab';

  int tabIndex = 0;
  bool _canExitAfterComment = false, _showOpenNotificationPage = true;

  final List<Widget> pages = const [LibraryTab(), ToolsTab()];

  @override
  void onInit() {
    super.onInit();
    AnalyticsService.instance.trackEvent(
      pointType: AnalyticsEvent.page_view,
      parameters: {"page": "file"},
    );
    NotificationService.instance.initialize(requestPermission: true);
  }

  Future<bool> onSystemBackRequested() async {
    if (_canExitAfterComment) {
      return true;
    }
    if (UserEligibilityService.instance.isEligibleUser) {
      await AdService.instance.showCachedAd(
        adScene: AdScene.pr_exit,
        adPosId: AdPlacement.pr_exit_app,
      );
    }
    final bool? canExitNextTime = await AppNavigator.showBottomSheet<bool>(
      child: const RatingDialog(),
      dismissible: false,
    );
    if (canExitNextTime == true) {
      _canExitAfterComment = true;
    }
    return false;
  }

  void onTabSelected(HomeTab tab, BuildContext context) {
    if (tabIndex == tab.index) {
      return;
    }
    if (tabIndex == 0) {
      AnalyticsService.instance.trackEvent(
        pointType: AnalyticsEvent.page_view,
        parameters: {"page": "file"},
      );
    } else if (tabIndex == 1) {
      AnalyticsService.instance.trackEvent(
        pointType: AnalyticsEvent.page_view,
        parameters: {"page": "tools"},
      );
    }
    tabIndex = tab.index;
    update([tabUpdateId]);
    AdService.instance.showCachedAd(
      adScene: AdScene.pr_user_use,
      adPosId: AdPlacement.pr_down_int,
      adHostContext: context,
    );
    _promptForNotificationPermissionIfNeeded();
  }

  _promptForNotificationPermissionIfNeeded() async {
    if (!_showOpenNotificationPage) {
      return;
    }
    var result = await NotificationService.instance.hasNotificationPermission();
    if (result) {
      return;
    }
    AppNavigator.pushNamed(
      routeName: AppRoutes.notificationRoute,
      arguments: {"fromHome": true},
    );
    _showOpenNotificationPage = false;
  }
}
