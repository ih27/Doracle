abstract class FortuneTeller {
  Stream<String> getFortune(String question);
  void onFortuneReceived(Function(String) callback, Function(String) onError);
}
