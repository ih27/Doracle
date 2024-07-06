import '../services/firestore_service.dart';
import 'fortune_content_repository.dart';

class FirestoreFortuneContentRepository implements FortuneContentRepository {
  @override
  Future<int> getStartingCount() async {
    return await FirestoreService.getStartingCount();
  }

  @override
  Future<List<String>> fetchRandomQuestions(
      int numberOfQuestionsPerCategory) async {
    return await FirestoreService.fetchRandomQuestions(
        numberOfQuestionsPerCategory);
  }

  @override
  Future<Map<String, String>> getRandomPersona() async {
    return await FirestoreService.getRandomPersona();
  }
}
