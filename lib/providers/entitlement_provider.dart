import 'package:flutter/foundation.dart';
import '../services/revenuecat_service.dart';

class EntitlementProvider with ChangeNotifier {
  final RevenueCatService _revenueCatService;

  EntitlementProvider(this._revenueCatService) {
    _revenueCatService.addListener(_onEntitlementChanged);
  }

  bool get isEntitled => _revenueCatService.isEntitled;
  String? get currentSubscriptionPlan =>
      _revenueCatService.currentSubscriptionPlan;

  void _onEntitlementChanged() {
    notifyListeners();
  }

  void refreshEntitlementStatus() {
    _revenueCatService.getEntitlementStatus();
    _onEntitlementChanged();
  }

  @override
  void dispose() {
    _revenueCatService.removeListener(_onEntitlementChanged);
    super.dispose();
  }
}
