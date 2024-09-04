import 'package:flutter/material.dart';
import 'package:styled_divider/styled_divider.dart';
import '../config/theme.dart';
import '../entities/entity_manager.dart';
import '../helpers/compatibility_utils.dart';
import '../models/owner_model.dart';
import '../models/pet_model.dart';
import '../config/dependency_injection.dart';
import '../services/daily_horoscope_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PetManager _petManager = getIt<PetManager>();
  final OwnerManager _ownerManager = getIt<OwnerManager>();
  final DailyHoroscopeService _horoscopeService =
      getIt<DailyHoroscopeService>();
  late Future<void> _dataLoadingFuture;

  @override
  void initState() {
    super.initState();
    _dataLoadingFuture = _loadData();
    _petManager.addListener(_onPetManagerUpdate);
  }

  @override
  void dispose() {
    _petManager.removeListener(_onPetManagerUpdate);
    super.dispose();
  }

  void _onPetManagerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _addNewPet() async {
    final result = await Navigator.pushNamed(context, '/pet/create');
    if (result != null && result is Pet) {
      await _petManager.addEntity(result);
    }
  }

  Future<void> _loadData() async {
    // DEBUGGING
    // await _horoscopeService.clearData();
    await _petManager.loadEntities();
    await _ownerManager.loadEntities();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayName = _getDayName(now);
    final date = _formatDate(now);

    return FutureBuilder<void>(
      future: _dataLoadingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(dayName, date),
                  const SizedBox(height: 10),
                  _buildCurrentUserSection(),
                  const SizedBox(height: 10),
                  ..._petManager.entities.expand((pet) => [
                        _buildPetSection(pet),
                        const SizedBox(height: 10),
                      ]),
                  _buildAddPetSection(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildHeader(String dayName, String date) {
    return Center(
      child: Column(
        children: [
          Text(
            dayName,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppTheme.primaryColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
          ),
          Text(
            date,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppTheme.primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentUserSection() {
    Owner? currentUser = _ownerManager.entities.firstOrNull;
    currentUser ??= Owner(
      id: 'default',
      name: 'Default User',
      gender: 'Other',
      activityLevel: 2,
      interactionLevel: 2,
      groomingCommitment: 2,
      noiseTolerance: 2,
      birthdate: '01/01/1970',
      birthtime: '13:13',
      livingSituation: 'Other',
      workSchedule: 'Full-time away',
      petExperience: 'First-time',
      petReason: 'Other',
    );
    return _buildOwnerSection(currentUser);
  }

  Widget _buildOwnerSection(Owner owner) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _horoscopeService.getHoroscopeForOwner(owner),
      builder: (context, snapshot) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.primaryColor,
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOwnerHeader(owner),
                const SizedBox(height: 10),
                _buildOwnerHoroscopeContent(snapshot),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOwnerHoroscopeContent(
      AsyncSnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return _buildLoadingIndicator('Loading daily vibe...');
    } else if (snapshot.hasError) {
      return _buildErrorWidget();
    } else {
      final horoscope = snapshot.data ?? {};
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDailyVibe(horoscope['dailyVibe']),
          const StyledDivider(
            thickness: 2,
            color: AppTheme.primaryColor,
            lineStyle: DividerLineStyle.dashed,
          ),
          const SizedBox(height: 5),
          _buildHoroscopeSection(
              '💖 Relationships', horoscope['relationships']),
          const SizedBox(height: 5),
          _buildHoroscopeSection(
              '💼 Work & Productivity', horoscope['workAndProductivity']),
          const SizedBox(height: 5),
          _buildHoroscopeSection(
              '🏡 Home & Self-Care', horoscope['homeAndSelfCare']),
          const SizedBox(height: 5),
          _buildHoroscopeSection(
              '💪 Health & Wellness', horoscope['healthAndWellness']),
          const SizedBox(height: 5),
          _buildCosmicInsight(horoscope['cosmicInsight']),
        ],
      );
    }
  }

  Widget _buildOwnerHeader(Owner owner) {
    return Row(
      children: [
        Container(
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
            borderRadius: BorderRadius.circular(50),
            child: Image.asset(
              getEntityImage(owner),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 15),
        Text(
          'You',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.secondaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildDailyVibe(Map<String, dynamic>? dailyVibe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Vibe',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.secondaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          '${dailyVibe?['theme'] ?? ''} ${dailyVibe?['emoji'] ?? ''}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontSize: 16,
              ),
        ),
      ],
    );
  }

  Widget _buildHoroscopeSection(
      String title, Map<String, dynamic>? sectionData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.secondaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
        ),
        if (sectionData != null) ...[
          if (sectionData['morning'] != null)
            _buildHoroscopeItem('Morning', sectionData['morning']),
          if (sectionData['evening'] != null)
            _buildHoroscopeItem('Evening', sectionData['evening']),
          if (sectionData['keyAdvice'] != null)
            _buildHoroscopeItem('Key Advice', sectionData['keyAdvice']),
          if (sectionData['productivityTip'] != null)
            _buildHoroscopeItem(
                'Productivity Tip', sectionData['productivityTip']),
          if (sectionData['homeTask'] != null)
            _buildHoroscopeItem('Home Task', sectionData['homeTask']),
          if (sectionData['selfCareActivity'] != null)
            _buildHoroscopeItem(
                'Self-Care Activity', sectionData['selfCareActivity']),
          if (sectionData['nutritionAdvice'] != null)
            _buildHoroscopeItem(
                'Nutrition Advice', sectionData['nutritionAdvice']),
          if (sectionData['exerciseOrWellnessSuggestion'] != null)
            _buildHoroscopeItem('Exercise/Wellness Suggestion',
                sectionData['exerciseOrWellnessSuggestion']),
        ],
      ],
    );
  }

  Widget _buildHoroscopeItem(String time, String? content) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$time: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
          ),
          TextSpan(
            text: content ?? '',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryColor,
                  fontSize: 16,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCosmicInsight(String? cosmicInsight) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.yaleBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            Text(
              '🔮 Cosmic Insight',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.naplesYellow,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              cosmicInsight ?? '',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryBackground,
                    fontSize: 16,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPetSection() {
    return GestureDetector(
      onTap: _addNewPet,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryColor,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
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
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(
                    'assets/images/plus.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Text(
                'Add Your Pet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetSection(Pet pet) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _horoscopeService.getHoroscopeForPet(pet),
      builder: (context, snapshot) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.primaryColor,
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPetHeader(pet),
                const SizedBox(height: 10),
                _buildPetHoroscopeContent(snapshot),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPetHoroscopeContent(
      AsyncSnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return _buildLoadingIndicator('Loading daily vibe...');
    } else if (snapshot.hasError) {
      return _buildErrorWidget();
    } else {
      final horoscope = snapshot.data ?? {};
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDailyVibe(horoscope['dailyVibe']),
          const StyledDivider(
            thickness: 2,
            color: AppTheme.primaryColor,
            lineStyle: DividerLineStyle.dashed,
          ),
          const SizedBox(height: 5),
          _buildPetHoroscopeSection(
              '🦴 Playtime & Bonding', horoscope['playtimeAndBonding']),
          const SizedBox(height: 5),
          _buildPetHoroscopeSection(
              '🏠 Home Adventures', horoscope['homeAdventures']),
          const SizedBox(height: 5),
          _buildPetHoroscopeSection(
              '🍖 Treats & Naps', horoscope['treatsAndNaps']),
          const SizedBox(height: 5),
          _buildPetHoroscopeSection(
              '🐕 Walkies & Exercise', horoscope['walkiesAndExercise']),
          const SizedBox(height: 5),
          _buildPetHoroscopeSection(
              '🌟 Quick Boosters', horoscope['quickBoosters']),
          const SizedBox(height: 5),
          _buildCosmicInsight(horoscope['cosmicCanineWisdom']),
          if (horoscope['message'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                horoscope['message'],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
        ],
      );
    }
  }

  Widget _buildPetHeader(Pet pet) {
    return Row(
      children: [
        Container(
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
            borderRadius: BorderRadius.circular(50),
            child: Image.asset(
              getEntityImage(pet),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 15),
        Text(
          pet.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.secondaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildPetHoroscopeSection(String title, dynamic sectionData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.secondaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
        ),
        if (sectionData != null) ...[
          if (sectionData is Map<String, dynamic>) ...[
            if (sectionData['morning'] != null)
              _buildHoroscopeItem('Morning', sectionData['morning']),
            if (sectionData['evening'] != null)
              _buildHoroscopeItem('Evening', sectionData['evening']),
            if (sectionData['todaysSnack'] != null)
              _buildHoroscopeItem('Today\'s Snack', sectionData['todaysSnack']),
            if (sectionData['napSpot'] != null)
              _buildHoroscopeItem('Nap Spot', sectionData['napSpot']),
            if (title == '🌟 Quick Boosters') ...[
              if (sectionData['luckyToy'] != null)
                _buildHoroscopeItem('Lucky Toy', sectionData['luckyToy']),
              if (sectionData['powerMove'] != null)
                _buildHoroscopeItem('Power Move', sectionData['powerMove']),
              if (sectionData['goodDeed'] != null)
                _buildHoroscopeItem('Good Deed', sectionData['goodDeed']),
            ],
          ] else if (sectionData is List) ...[
            for (var item in sectionData)
              Text(
                item,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontSize: 16,
                    ),
              ),
          ],
        ],
      ],
    );
  }

  String _getDayName(DateTime date) {
    const List<String> days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[date.weekday - 1];
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildLoadingIndicator(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryColor,
                  fontSize: 16,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Text(
        'Failed to load horoscope',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.error,
              fontSize: 16,
            ),
      ),
    );
  }
}
