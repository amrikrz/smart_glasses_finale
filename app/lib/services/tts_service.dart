import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final _tts = FlutterTts();

  // Speed per platform: web 1.0 = normal, Android 0.5 = normal.
  static const double webRate = 1.25;
  static const double mobileRate = 0.55;

  Future<void> init(String langCode, {double? rate}) async {
    await _tts.setLanguage(langCode); // ar-SA, fr-FR, en-US
    await _tts.setSpeechRate(rate ?? (kIsWeb ? webRate : mobileRate));
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);
  }

  /// Is a voice for this language installed on the phone?
  Future<bool> isAvailable(String langCode) async {
    try {
      final r = await _tts.isLanguageAvailable(langCode);
      return r == true || r == 1;
    } catch (_) {
      return true; // cannot check: assume yes
    }
  }

  Future<void> speak(String text) => _tts.speak(text);

  Future<void> speakNow(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }
}