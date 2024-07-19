abstract class FortuneContentRepository {
  Future<int> getStartingCount();
  Future<List<String>> fetchRandomQuestions();
  Future<Map<String, String>> getRandomPersona();
  Future<void> clearCache();
}
