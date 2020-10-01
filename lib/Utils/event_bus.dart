import 'package:event_bus/event_bus.dart';

class EventProvider {
  EventProvider._create();

  static EventProvider _sessionExpirationEvent;
  EventBus _eventBus;

  factory EventProvider() {
    if (_sessionExpirationEvent == null) {
      _sessionExpirationEvent = EventProvider._create();
    }
    return _sessionExpirationEvent;
  }

  EventBus getSessionEventBus() {
    if (_eventBus == null) {
      _eventBus = EventBus();
    }
    return _eventBus;
  }
}

class ScreenRefresher {
  String screenName;
  dynamic data;

  ScreenRefresher({this.screenName, this.data});
}
