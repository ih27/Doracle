abstract class FortuneContentRepository {
  Future<List<String>> fetchRandomQuestions(int numberOfQuestionsPerCategory);
  Future<Map<String, String>> getRandomPersona();
}
