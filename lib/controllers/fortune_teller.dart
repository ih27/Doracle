import '../services/user_service.dart';

abstract class FortuneTeller {
  final UserService userService;
  String personaName;

  FortuneTeller(this.userService, this.personaName);

  void setPersona(String newPersonaName, String newInstructions);
  Stream<String> getFortune(String question);
}
