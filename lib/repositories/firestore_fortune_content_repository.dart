import '../services/firestore_service.dart';
import 'fortune_content_repository.dart';

class FirestoreFortuneContentRepository implements FortuneContentRepository {
  final int numberOfQuestionsPerCategory = 3;

  @override
  Future<int> getStartingCount() async {
    return await FirestoreService.getStartingCount();
  }

  @override
  Future<List<String>> fetchRandomQuestions() async {
    return await FirestoreService.fetchRandomQuestions(
        numberOfQuestionsPerCategory);
  }

  @override
  Future<Map<String, String>> getRandomPersona() async {
    return await FirestoreService.getRandomPersona();
  }

  @override
  Future<void> clearCache() async {
    await FirestoreService.clearCache();
  }
}
