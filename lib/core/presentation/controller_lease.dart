import 'package:get/get.dart';

final class ControllerLease<T extends GetxController> {
  ControllerLease._(this.controller, this.tag, this.ownsRegistration);

  final T controller;
  final String? tag;
  final bool ownsRegistration;

  static ControllerLease<T> acquire<T extends GetxController>({
    required T Function() createController,
    String? tag,
    bool permanent = false,
  }) {
    if (Get.isRegistered<T>(tag: tag)) {
      return ControllerLease<T>._(Get.find<T>(tag: tag), tag, false);
    }

    return ControllerLease<T>._(
      Get.put<T>(createController(), tag: tag, permanent: permanent),
      tag,
      !permanent,
    );
  }

  void release() {
    if (ownsRegistration && Get.isRegistered<T>(tag: tag)) {
      Get.delete<T>(tag: tag);
    }
  }
}
