import 'package:event_bus/event_bus.dart';

class SessionExpirationEvent {
  SessionExpirationEvent._create();

  static SessionExpirationEvent _sessionExpirationEvent;
  EventBus _eventBus;

  factory SessionExpirationEvent() {
    if (_sessionExpirationEvent == null) {
      _sessionExpirationEvent = SessionExpirationEvent._create();
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
