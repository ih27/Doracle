import 'dart:async';
import '../events/entitlement_event.dart';

class EventBusService {
  // Stream controller for entitlement events
  final _entitlementController = StreamController<EntitlementEvent>.broadcast();

  // Stream getter for subscribers
  Stream<EntitlementEvent> get entitlementStream =>
      _entitlementController.stream;

  // Method to emit entitlement events
  void emitEntitlementEvent(EntitlementEvent event) {
    _entitlementController.add(event);
  }

  // Dispose method to clean up resources
  void dispose() {
    _entitlementController.close();
  }
}
