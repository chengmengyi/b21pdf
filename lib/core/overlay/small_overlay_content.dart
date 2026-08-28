import 'package:flutter_boom_notification_plugins/flutter_boom_notification_plugins.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class SmallOverlayContent {
  const SmallOverlayContent._();

  static List<TimerOverlayContent> build() => <TimerOverlayContent>[
    TimerOverlayContent(
      title: 'Pending Documents'.tr,
      subtitle: 'You have documents waiting for your attention.'.tr,
      button: 'View Now'.tr,
      button2: 'Later'.tr,
    ),
    TimerOverlayContent(
      title: 'Files Awaiting You'.tr,
      subtitle:
          'There are some files ready for your review. Shall we take a look?'
              .tr,
      button: 'Open Files'.tr,
      button2: 'Later'.tr,
    ),
    TimerOverlayContent(
      title: 'New Documents'.tr,
      subtitle: 'You have pending files to handle.'.tr,
      button: 'Review'.tr,
    ),
  ];
}
