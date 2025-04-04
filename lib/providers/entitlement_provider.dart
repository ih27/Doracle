import 'package:flutter/foundation.dart';
import '../services/revenuecat_service.dart';
import '../services/event_bus_service.dart';
import '../events/entitlement_event.dart';

class EntitlementProvider extends ChangeNotifier {
  final RevenueCatService _revenueCatService;
  final EventBusService _eventBusService;

  EntitlementProvider(this._revenueCatService, this._eventBusService) {
    _revenueCatService.addListener(_onEntitlementChanged);
  }

  bool get isEntitled => _revenueCatService.isEntitled;
  String? get currentSubscriptionPlan =>
      _revenueCatService.currentSubscriptionPlan;

  Future<void> checkEntitlementStatus() async {
    await _revenueCatService.getEntitlementStatus();
  }

  void _onEntitlementChanged() {
    notifyListeners();
    // Emit event through event bus
    _eventBusService.emitEntitlementEvent(
      EntitlementEvent(
        isEntitled: isEntitled,
        subscriptionPlan: currentSubscriptionPlan,
      ),
    );
  }

  @override
  void dispose() {
    _revenueCatService.removeListener(_onEntitlementChanged);
    super.dispose();
  }
}
