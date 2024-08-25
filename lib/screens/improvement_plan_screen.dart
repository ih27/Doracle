import 'package:flutter/material.dart';
import 'dart:convert';
import '../config/theme.dart';
import '../repositories/compatibility_data_repository.dart';
import '../config/dependency_injection.dart';
import '../helpers/compatibility_utils.dart';
import '../helpers/show_snackbar.dart';

class ImprovementPlanScreen extends StatefulWidget {
  final String planId;

  const ImprovementPlanScreen({super.key, required this.planId});

  @override
  _ImprovementPlanScreenState createState() => _ImprovementPlanScreenState();
}

class _ImprovementPlanScreenState extends State<ImprovementPlanScreen> {
  final CompatibilityDataRepository _repository =
      getIt<CompatibilityDataRepository>();

  late Future<PlanData> _planFuture;
  late Map<int, bool> _checklist;

  @override
  void initState() {
    super.initState();
    _planFuture = _loadPlanAndChecklist();
  }

  Future<PlanData> _loadPlanAndChecklist() async {
    final planData = await _repository.loadImprovementPlan(widget.planId);
    final checklist = await _repository.loadChecklist(widget.planId);
    setState(() {
      _checklist = checklist;
    });
    return PlanData(
      plan: json.decode(planData['plan']),
      entity1: planData['entity1'],
      entity2: planData['entity2'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PlanData>(
      future: _planFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Some "ewwroar" occured :('));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No plan data available.'));
        }

        final planData = snapshot.data!;

        return Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: _buildDayCardList(planData),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressBar() {
    int completedDays = _checklist.values.where((v) => v).length;
    double progress = completedDays / 10;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text('Progress: $completedDays / 10 days'),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.alternateColor,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCardList(PlanData planData) {
    final plan = planData.plan;
    final entity1 = planData.entity1;
    final entity2 = planData.entity2;
    final introduction = plan['introduction'] as String? ?? 'Start your 10-day journey!';
    final days = plan['compatibility_improvement_plan'] as List<dynamic>;
    final conclusion = plan['conclusion'] as String? ?? 'Congratulations on completing the plan!';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '10-Day Improvement Plan',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 25),
            _buildEntityInfo(entity1, entity2),
            const SizedBox(height: 8),
            Text(
              introduction,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
            ),
            const SizedBox(height: 25),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: days.length,
              separatorBuilder: (context, index) => const SizedBox(height: 15),
              itemBuilder: (context, index) => _buildDayCard(days[index]),
            ),
            const SizedBox(height: 16),
            Text(
              conclusion,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntityInfo(dynamic entity1, dynamic entity2) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Row(
        children: [
          SizedBox(
            width: 170,
            child: Stack(
              children: [
                _buildEntityAvatar(entity1, isFirst: true),
                Align(
                  alignment: const AlignmentDirectional(1, 0),
                  child: _buildEntityAvatar(entity2),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(15, 0, 0, 0),
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
    );
  }

  Widget _buildEntityAvatar(dynamic entity, {bool isFirst = false}) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppTheme.alternateColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.primaryColor,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          getEntityImage(entity),
          width: 300,
          height: 200,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildDayCard(Map<String, dynamic> data) {
    int dayNumber = data['day'] as int;
    bool isChecked = _checklist[dayNumber] ?? false;

    return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.primaryColor,
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.65,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Day $dayNumber: ',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppTheme.secondaryColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            TextSpan(
                              text: data['title'],
                              style: const TextStyle(
                                color: AppTheme.secondaryColor,
                              ),
                            )
                          ],
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.secondaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      _buildInfoRow('Task', data['task']),
                      _buildInfoRow('Purpose', data['benefit']),
                      _buildInfoRow('Tip', data['tip']),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _toggleChecklistItem(dayNumber),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppTheme.primaryColor,
                        width: 2,
                      ),
                      image: isChecked
                          ? const DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage('assets/images/check.png'),
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildInfoRow(String label, String content) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
          ),
          TextSpan(
            text: content,
            style: const TextStyle(
              color: AppTheme.primaryColor,
            ),
          )
        ],
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              letterSpacing: 0,
            ),
      ),
    );
  }

  void _toggleChecklistItem(int dayNumber) async {
    setState(() {
      _checklist[dayNumber] = !(_checklist[dayNumber] ?? false);
    });
    try {
      await _repository.saveChecklistItem(
          widget.planId, dayNumber, _checklist[dayNumber]!);
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, 'Failed to save progress.');
      }
    }
  }

  void _resetChecklist() async {
    setState(() {
      _checklist.clear();
    });
    try {
      for (int i = 1; i <= 10; i++) {
        await _repository.saveChecklistItem(widget.planId, i, false);
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, 'Failed to reset progress.');
      }
    }
  }
}

class PlanData {
  final Map<String, dynamic> plan;
  final dynamic entity1;
  final dynamic entity2;

  PlanData({required this.plan, required this.entity1, required this.entity2});
}
