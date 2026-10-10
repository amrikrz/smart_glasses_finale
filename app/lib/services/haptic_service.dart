import 'package:vibration/vibration.dart';
import '../features/alerts/domain/detection.dart';

class HapticService {
  Future<void> vibrate(Danger d) async {
    if (!(await Vibration.hasVibrator() )) return;
    switch (d) {
      case Danger.high:
        Vibration.vibrate(pattern: [0, 300, 100, 300, 100, 300]);
      case Danger.medium:
        Vibration.vibrate(duration: 150);
      case Danger.low:
        break;
    }
  }
}