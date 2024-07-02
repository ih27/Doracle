import '../services/user_service.dart';

abstract class FortuneTeller {
  final UserService userService;
  final String personaName;
  final String personaInstructions;

  FortuneTeller(this.userService, this.personaName, this.personaInstructions);

  Stream<String> getFortune(String question);
}