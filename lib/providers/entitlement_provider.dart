import 'package:flutter/foundation.dart';
import '../services/revenuecat_service.dart';
import '../services/event_bus_service.dart';
import '../events/entitlement_event.dart';

class EntitlementProvider extends ChangeNotifier {
  final RevenueCatService _revenueCatService;
  final EventBusService _eventBusService;
  bool _isInitialized = false;
  bool _isInitializing = false;

  EntitlementProvider(this._revenueCatService, this._eventBusService) {
    _revenueCatService.addListener(_onRevenueCatChanged);
  }

  bool get isEntitled => _revenueCatService.isEntitled;
  String? get currentSubscriptionPlan =>
      _revenueCatService.currentSubscriptionPlan;
  bool get isInitialized => _isInitialized;

  void _onRevenueCatChanged() {
    notifyListeners();
    _emitEntitlementEvent();
  }

  void _emitEntitlementEvent() {
    _eventBusService.emitEntitlementEvent(
      EntitlementEvent(
        isEntitled: isEntitled,
        subscriptionPlan: currentSubscriptionPlan,
      ),
    );
  }

  Future<void> checkEntitlementStatus() async {
    if (_isInitializing) {
      return; // Prevent multiple simultaneous initializations
    }
    if (_isInitialized) return; // Don't reinitialize if already done

    _isInitializing = true;
    try {
      await _revenueCatService.ensureInitialized();
      await _revenueCatService.getEntitlementStatus();
      _isInitialized = true;
      _emitEntitlementEvent();
      notifyListeners();
    } catch (e) {
      debugPrint('Error checking entitlement status: $e');
      _isInitialized = false;
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }

  @override
  void dispose() {
    _revenueCatService.removeListener(_onRevenueCatChanged);
    super.dispose();
  }
}
