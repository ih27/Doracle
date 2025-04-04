import 'package:flutter/foundation.dart';

@immutable
class EntitlementEvent {
  final bool isEntitled;
  final String? subscriptionPlan;

  const EntitlementEvent({
    required this.isEntitled,
    this.subscriptionPlan,
  });
}
