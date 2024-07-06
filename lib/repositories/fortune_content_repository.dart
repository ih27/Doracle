abstract class FortuneContentRepository {
  Future<int> getStartingCount();
  Future<List<String>> fetchRandomQuestions(int numberOfQuestionsPerCategory);
  Future<Map<String, String>> getRandomPersona();
}
