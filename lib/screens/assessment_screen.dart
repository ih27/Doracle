import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/owner_model.dart';
import '../models/pet_model.dart';
import '../config/theme.dart';
import '../repositories/compatibility_data_repository.dart';
import '../config/dependency_injection.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  _AssessmentScreenState createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final CompatibilityDataRepository _repository =
      getIt<CompatibilityDataRepository>();
  Map<String, Map<String, dynamic>> _improvementPlans = {};

  @override
  void initState() {
    super.initState();
    _loadImprovementPlans();
  }

  Future<void> _loadImprovementPlans() async {
    final plans = await _repository.loadImprovementPlans();
    setState(() {
      _improvementPlans = plans;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                _improvementPlans.isEmpty
                    ? _buildEmptyState()
                    : _buildImprovementPlansList(),
              ],
            ),
          ),
        ),
      ),
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

  Widget _buildImprovementPlansList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _improvementPlans.length,
      itemBuilder: (context, index) {
        String planId = _improvementPlans.keys.elementAt(index);
        Map<String, dynamic> planData = _improvementPlans[planId]!;
        return _buildImprovementPlanCard(planId, planData);
      },
    );
  }

  Widget _buildImprovementPlanCard(
      String planId, Map<String, dynamic> planData) {
    dynamic entity1 = planData['entity1'];
    dynamic entity2 = planData['entity2'];
    String plan = planData['plan'];

    return Card(
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
                            _getEntityImage(entity1),
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
                              _getEntityImage(entity2),
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
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
    );
  }

  String _getEntityImage(dynamic entity) {
    if (entity is Pet) {
      switch (entity.species.toLowerCase()) {
        case 'dog':
          return 'assets/images/dog.png';
        case 'cat':
          return 'assets/images/cat.png';
        case 'bird':
          return 'assets/images/bird.png';
        default:
          return 'assets/images/fish.png';
      }
    } else {
      switch ((entity as Owner).gender.toLowerCase()) {
        case 'male':
          return 'assets/images/owner_he.png';
        case 'female':
          return 'assets/images/owner_she.png';
        default:
          return 'assets/images/owner_other.png';
      }
    }
  }
}
