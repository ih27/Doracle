import '../services/user_service.dart';

abstract class FortuneTeller {
  final UserService userService;

  FortuneTeller(this.userService);

  Stream<String> getFortune(String question);
}