import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HapticService {
  static const String _canVibrateKey = 'can_vibrate';
  bool? _canVibrate;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _canVibrate = await Haptics.canVibrate();
    await prefs.setBool(_canVibrateKey, _canVibrate ?? false);
  }

  Future<bool> getCanVibrate() async {
    if (_canVibrate != null) return _canVibrate!;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_canVibrateKey) ?? false;
  }

  Future<void> lightImpact() async {
    if (await getCanVibrate()) {
      Haptics.vibrate(HapticsType.light);
    }
  }

  Future<void> mediumImpact() async {
    if (await getCanVibrate()) {
      Haptics.vibrate(HapticsType.medium);
    }
  }

  Future<void> heavyImpact() async {
    if (await getCanVibrate()) {
      Haptics.vibrate(HapticsType.heavy);
    }
  }

  Future<void> rigid() async {
    if (await getCanVibrate()) {
      Haptics.vibrate(HapticsType.rigid);
    }
  }

  Future<void> soft() async {
    if (await getCanVibrate()) {
      Haptics.vibrate(HapticsType.soft);
    }
  }

  Future<void> selection() async {
    if (await getCanVibrate()) {
      Haptics.vibrate(HapticsType.selection);
    }
  }

  Future<void> success() async {
    if (await getCanVibrate()) {
      Haptics.vibrate(HapticsType.success);
    }
  }

  Future<void> warning() async {
    if (await getCanVibrate()) {
      Haptics.vibrate(HapticsType.warning);
    }
  }

  Future<void> error() async {
    if (await getCanVibrate()) {
      Haptics.vibrate(HapticsType.error);
    }
  }
}
