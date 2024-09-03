import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../helpers/compatibility_utils.dart';
import '../helpers/iap_utils.dart';
import '../providers/entitlement_provider.dart';
import '../repositories/compatibility_data_repository.dart';
import '../config/dependency_injection.dart';
import '../services/user_service.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  _AssessmentScreenState createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final CompatibilityDataRepository _repository =
      getIt<CompatibilityDataRepository>();
  final UserService _userService = getIt<UserService>();
  Map<String, Map<String, dynamic>> _improvementPlans = {};
  Map<String, String> _cachedPrices = {};

  @override
  void initState() {
    super.initState();
    _loadImprovementPlans();
    _fetchPricesIfNeeded();
  }

  Future<void> _loadImprovementPlans() async {
    final plans = await _repository.loadImprovementPlans();
    setState(() {
      _improvementPlans = plans;
    });
  }

  Future<void> _fetchPricesIfNeeded() async {
    final updatedPrices = await IAPUtils.fetchSubscriptionPrices(_cachedPrices);
    setState(() {
      _cachedPrices = updatedPrices;
    });
  }

  void _navigateToImprovementPlan(
      EntitlementProvider entitlementProvider, String planId) async {
    final canAccess = entitlementProvider.isEntitled ||
        await _repository.planWasOpened(planId);

    if (!mounted) return;
    if (canAccess) {
      navigateToImprovementPlan(context, planId);
    } else {
      _showIAPOverlay(context, planId);
    }
  }

  void _showIAPOverlay(BuildContext overlayContext, String planId) {
    IAPUtils.showIAPOverlay(overlayContext, _cachedPrices,
        (subscriptionType) => _handlePurchase(subscriptionType, planId));
  }

  Future<void> _handlePurchase(String subscriptionType, String planId) async {
    bool success = await IAPUtils.handlePurchase(context, subscriptionType);
    if (success) {
      await _userService.updateSubscriptionHistory(subscriptionType);

      // Mark the plan as opened and navigate to it
      await _repository.markPlanAsOpened(planId);
      if (mounted) {
        navigateToImprovementPlan(context, planId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EntitlementProvider>(
      builder: (context, entitlementProvider, child) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Assessment',
                        style:
                            Theme.of(context).textTheme.displayMedium?.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _improvementPlans.isEmpty
                        ? _buildEmptyState()
                        : _buildImprovementPlansList(entitlementProvider),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Improvement plans will appear here after you run compatibility checks for pets or pets and owners.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }

  Widget _buildImprovementPlansList(EntitlementProvider entitlementProvider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _improvementPlans.length,
      itemBuilder: (context, index) {
        String planId = _improvementPlans.keys.elementAt(index);
        Map<String, dynamic> planData = _improvementPlans[planId]!;
        return _buildImprovementPlanCard(entitlementProvider, planId, planData);
      },
    );
  }

  Widget _buildImprovementPlanCard(EntitlementProvider entitlementProvider,
      String planId, Map<String, dynamic> planData) {
    dynamic entity1 = planData['entity1'];
    dynamic entity2 = planData['entity2'];
    String plan = planData['plan'];

    return FutureBuilder<bool>(
      future: _repository.planWasOpened(planId),
      builder: (context, snapshot) {
        bool canAccess =
            entitlementProvider.isEntitled || (snapshot.data ?? false);

        return GestureDetector(
          onTap: () => _navigateToImprovementPlan(entitlementProvider, planId),
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppTheme.primaryColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Stack(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppTheme.alternateColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.primaryColor,
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.asset(
                                  getEntityImage(entity1),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppTheme.alternateColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.primaryColor,
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Image.asset(
                                    getEntityImage(entity2),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          '${entity1.name} & ${entity2.name}',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      if (!canAccess)
                        const Icon(Icons.lock, color: AppTheme.primaryColor),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    json.decode(plan)['introduction'] ?? '',
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
