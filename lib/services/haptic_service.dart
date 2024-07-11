import 'package:haptic_feedback/haptic_feedback.dart';
import 'user_service.dart';

class HapticService {
  final UserService _userService;

  HapticService(this._userService);

  Future<void> initialize() async {
    final canVibrate = await Haptics.canVibrate();
    await _userService.updateUserField('canVibrate', canVibrate);
  }

  void lightImpact() {
    if (_userService.value?.canVibrate ?? false) {
      Haptics.vibrate(HapticsType.light);
    }
  }

  void mediumImpact() {
    if (_userService.value?.canVibrate ?? false) {
      Haptics.vibrate(HapticsType.medium);
    }
  }

  void heavyImpact() {
    if (_userService.value?.canVibrate ?? false) {
      Haptics.vibrate(HapticsType.heavy);
    }
  }

  void rigid() {
    if (_userService.value?.canVibrate ?? false) {
      Haptics.vibrate(HapticsType.rigid);
    }
  }

  void soft() {
    if (_userService.value?.canVibrate ?? false) {
      Haptics.vibrate(HapticsType.soft);
    }
  }

  void selection() {
    if (_userService.value?.canVibrate ?? false) {
      Haptics.vibrate(HapticsType.selection);
    }
  }

  void success() {
    if (_userService.value?.canVibrate ?? false) {
      Haptics.vibrate(HapticsType.success);
    }
  }

  void warning() {
    if (_userService.value?.canVibrate ?? false) {
      Haptics.vibrate(HapticsType.warning);
    }
  }

  void error() {
    if (_userService.value?.canVibrate ?? false) {
      Haptics.vibrate(HapticsType.error);
    }
  }
}
