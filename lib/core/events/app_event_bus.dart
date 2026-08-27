import 'dart:async';

import 'package:b21pdf/core/events/app_event.dart';
import 'package:event_bus/event_bus.dart';

typedef AppEventListener = void Function(AppEvent event);

class AppEventBus {
  static final AppEventBus _instance = AppEventBus();
  static AppEventBus get instance => _instance;

  final EventBus _eventBus = EventBus();

  void publish(AppEvent event) {
    _eventBus.fire(event);
  }

  StreamSubscription<AppEvent> subscribe({
    required AppEventListener eventCallback,
  }) {
    return _eventBus.on<AppEvent>().listen(eventCallback);
  }
}
