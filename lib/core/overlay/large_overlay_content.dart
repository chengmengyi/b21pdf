import 'package:flutter_boom_notification_plugins/flutter_boom_notification_plugins.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class LargeOverlayContent {
  const LargeOverlayContent._();

  static List<TimerOverlayContent> build() => <TimerOverlayContent>[
    TimerOverlayContent(
      title: 'Still working on your file...'.tr,
      subtitle:
          'Your PDF is almost ready in the background. Tap to jump back and save it, or let me finish the heavy lifting for you.'
              .tr,
      button: 'Check'.tr,
    ),
    TimerOverlayContent(
      title: 'Still reading?'.tr,
      subtitle:
          "You left off on page 12. Don't lose your spot-tap to get back to your file instantly!"
              .tr,
      button: 'Check'.tr,
    ),
  ];
}
