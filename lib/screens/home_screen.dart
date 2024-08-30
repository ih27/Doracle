import 'package:flutter/material.dart';
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
  final DailyHoroscopeService _horoscopeService = getIt<DailyHoroscopeService>();
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
      setState(() {
        // This will trigger a rebuild of the pet sections
      });
    }
  }

  Future<void> _loadData() async {
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
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Align(
                alignment: AlignmentDirectional.topCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
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
                        const SizedBox(height: 10),
                        _buildCurrentUserSection(),
                        const SizedBox(height: 10),
                        ..._petManager.entities.map(_buildPetSection),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      },
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
    );
    return _buildOwnerSection(currentUser);
  }

  Widget _buildOwnerSection(Owner owner) {
    return FutureBuilder<String>(
      future: _horoscopeService.getHoroscopeForOwner(owner, _petManager.entities),
      builder: (context, snapshot) {
        final horoscope = snapshot.data ?? 'Loading daily vibe...';
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: AppTheme.alternateColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryColor,
                  width: 5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(75),
                child: Image.asset(
                  getEntityImage(owner),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'You',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              horoscope,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPetSection(Pet pet) {
    return FutureBuilder<String>(
      future: _horoscopeService.getHoroscopeForPet(pet),
      builder: (context, snapshot) {
        final horoscope = snapshot.data ?? 'Loading daily vibe...';
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              horoscope,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        );
      },
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
}