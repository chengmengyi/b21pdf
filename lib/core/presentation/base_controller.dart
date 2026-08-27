import 'dart:async';

import 'package:b21pdf/core/events/app_event.dart';
import 'package:b21pdf/core/events/app_event_bus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class BaseController extends GetxController {
  StreamSubscription<AppEvent>? eventSubscriptiond;

  @override
  void onInit() {
    super.onInit();
    if (subscribesToAppEvents()) {
      eventSubscriptiond = AppEventBus.instance.subscribe(
        eventCallback: onAppEvent,
      );
    }
  }

  bool subscribesToAppEvents() => false;

  void onAppEvent(AppEvent event) {}

  @override
  void onClose() {
    if (subscribesToAppEvents()) {
      eventSubscriptiond?.cancel();
      eventSubscriptiond = null;
    }
    super.onClose();
  }
}
