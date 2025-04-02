import 'package:get_it/get_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../providers/entitlement_provider.dart';
import '../repositories/compatibility_data_repository.dart';
import '../repositories/daily_horoscope_repository.dart';
import '../repositories/firestore_fortune_content_repository.dart';
import '../repositories/firestore_user_repository.dart';
import '../repositories/fortune_content_repository.dart';
import '../repositories/user_repository.dart';
import '../services/adjust_service.dart';
import '../services/ai_prompt_generation_service.dart';
import '../services/analytics_service.dart';
import '../services/auth_service.dart';
import '../services/compatibility_content_service.dart';
import '../services/compatibility_score_service.dart';
import '../services/crashlytics_service.dart';
import '../services/daily_horoscope_service.dart';
import '../services/facebook_app_events_service.dart';
import '../services/haptic_service.dart';
import '../services/openai_service.dart';
import '../services/revenuecat_service.dart';
import '../services/secure_storage_service.dart';
import '../services/unified_analytics_service.dart';
import '../services/user_service.dart';
import '../services/fortune_teller_service.dart';
import '../services/connectivity_service.dart';
import '../services/scate_service.dart';
import '../entities/entity_manager.dart';
import '../viewmodels/fortune_view_model.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerFactory<FortuneViewModel>(() => FortuneViewModel(
        getIt<FortuneContentRepository>(),
        getIt<UserService>(),
        getIt<HapticService>(),
        getIt<RevenueCatService>(),
        getIt<EntitlementProvider>(),
        getIt<FortuneTeller>(),
      ));

  // Repositories
  getIt.registerLazySingleton<DailyHoroscopeRepository>(
    () => DailyHoroscopeRepository(),
  );
  getIt.registerLazySingleton<FortuneContentRepository>(
    () => FirestoreFortuneContentRepository(),
  );
  getIt.registerLazySingleton<UserRepository>(
    () => FirestoreUserRepository(),
  );
  getIt.registerLazySingleton<CompatibilityDataRepository>(
      () => CompatibilityDataRepository());

  // Managers
  getIt.registerLazySingleton<PetManager>(() => PetManager());
  getIt.registerLazySingleton<OwnerManager>(() => OwnerManager());

  // Services
  getIt.registerLazySingleton<SecureStorageService>(
      () => SecureStorageService());
  getIt.registerLazySingleton<AdjustService>(() => AdjustService());
  getIt.registerLazySingleton<ScateService>(
      () => ScateService(appId: dotenv.env['SCATE_APP_ID']!));
  getIt.registerLazySingleton<FacebookAppEventsService>(
      () => FacebookAppEventsService());
  getIt.registerLazySingleton<AIPromptGenerationService>(
      () => AIPromptGenerationService());
  getIt.registerLazySingleton<AnalyticsService>(() => AnalyticsService());
  getIt.registerLazySingleton<UnifiedAnalyticsService>(
      () => UnifiedAnalyticsService(
            getIt<AnalyticsService>(),
            getIt<FacebookAppEventsService>(),
            getIt<AdjustService>(),
            getIt<ScateService>(),
          ));
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(
        (userId, userData) => getIt<UserService>().addUser(userId, userData)),
  );
  getIt.registerLazySingleton<UserService>(
      () => UserService(getIt<UserRepository>()));
  getIt.registerLazySingleton<RevenueCatService>(() => RevenueCatService(
        getIt<AuthService>(),
      ));
  getIt.registerLazySingleton<DailyHoroscopeService>(
      () => DailyHoroscopeService());
  getIt.registerLazySingleton<FortuneTeller>(() => FortuneTeller(
        getIt<UserService>(),
        '', // Initial empty persona name
        getIt<OpenAIService>(),
      ));
  getIt.registerLazySingleton<CompatibilityScoreService>(
      () => CompatibilityScoreService());
  getIt.registerLazySingleton(() => CompatibilityContentService(
      getIt<OpenAIService>(), getIt<AIPromptGenerationService>()));
  getIt.registerLazySingleton<OpenAIService>(
    () => OpenAIService(
      dotenv.env['OPENAI_API_KEY']!,
      '',
      '',
      '', // Empty strings as placeholder, will be set when creating an instance
    ),
  );
  getIt.registerLazySingleton<HapticService>(() => HapticService());
  getIt.registerLazySingleton<CrashlyticsService>(() => CrashlyticsService());
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());

  // Providers
  getIt.registerLazySingleton<EntitlementProvider>(
    () => EntitlementProvider(getIt<RevenueCatService>()),
  );
}
