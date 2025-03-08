import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../repositories/compatibility_data_repository.dart';
import '../config/dependency_injection.dart';
import '../helpers/compatibility_utils.dart';
import '../services/unified_analytics_service.dart';

class LastResultsScreen extends StatefulWidget {
  const LastResultsScreen({super.key});

  @override
  _LastResultsScreenState createState() => _LastResultsScreenState();
}

class _LastResultsScreenState extends State<LastResultsScreen> {
  final CompatibilityDataRepository _compatibilityDataRepository =
      getIt<CompatibilityDataRepository>();
  final UnifiedAnalyticsService _analytics = getIt<UnifiedAnalyticsService>();
  List<Map<String, dynamic>> _compatibilityScores = [];

  @override
  void initState() {
    super.initState();

    _analytics.logScreenView(screenName: 'last_results_screen');

    _loadCompatibilityScores();
  }

  Future<void> _loadCompatibilityScores() async {
    final scores =
        await _compatibilityDataRepository.loadAllCompatibilityScores();
    setState(() {
      _compatibilityScores = scores;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Align(
            alignment: AlignmentDirectional.topCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: Text(
                        'Latest Compatibility Results',
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.displayMedium?.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontSize: 22,
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _compatibilityScores.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 15),
                      itemBuilder: (context, index) {
                        final score = _compatibilityScores[index];
                        return _buildCompatibilityResultCard(score);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibilityResultCard(Map<String, dynamic> score) {
    final overallScore = ((score['scores']['overall'] as double) * 100).toInt();
    final timestamp = score['timestamp'] as DateTime;
    final entity1 = score['entity1'];
    final entity2 = score['entity2'];

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/result',
          arguments: {
            'entity1': entity1,
            'entity2': entity2,
            'scores': score['scores'],
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppTheme.primaryColor,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildEntityAvatar(entity1),
              _buildScoreContainer(overallScore, timestamp),
              _buildEntityAvatar(entity2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEntityAvatar(dynamic entity) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.12,
            height: MediaQuery.of(context).size.width * 0.12,
            decoration: BoxDecoration(
              color: AppTheme.alternateColor,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(getEntityImage(entity)),
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryColor,
                width: 2,
              ),
            ),
          ),
          Text(
            entity.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.primaryColor,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreContainer(int overallScore, DateTime timestamp) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      height: MediaQuery.of(context).size.height * 0.1,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryColor,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            '${timestamp.day}/${timestamp.month}/${timestamp.year}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  letterSpacing: 0,
                ),
          ),
          Text(
            '$overallScore%',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: getColorFor(overallScore / 100),
                  fontSize: 35,
                  letterSpacing: 0,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
