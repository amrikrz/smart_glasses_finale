import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/l10n/strings.dart';
import '../../../services/haptic_service.dart';
import '../../../services/tts_service.dart';
import '../../connection/data/pi_repository_impl.dart';
import '../../connection/domain/pi_repository.dart';
import '../domain/alert_policy.dart';
import '../domain/crossing.dart';
import '../domain/detection.dart';
import '../domain/message_formatter.dart';

// ---- providers ----
final piRepositoryProvider = Provider<PiRepository>((ref) {
  final repo = PiRepositoryImpl();
  ref.onDispose(repo.disconnect);
  return repo;
});
final ttsProvider = Provider((ref) => TtsService());
final hapticProvider = Provider((ref) => HapticService());
final languageProvider = StateProvider<String>((ref) => 'ar'); // ar | fr | en

final connectionStatusProvider = StreamProvider<PiStatus>(
  (ref) => ref.watch(piRepositoryProvider).status,
);

// ---- state ----
class AlertState {
  final List<Detection> latest;
  final String lastMessage;
  final int frames;
  final CrossingInfo crossing;
  final bool crossingActive;
  final bool voiceMissing;

  const AlertState({
    this.latest = const [],
    this.lastMessage = '',
    this.frames = 0,
    this.crossing = CrossingInfo.unknown,
    this.crossingActive = false,
    this.voiceMissing = false,
  });

  AlertState copyWith({
    List<Detection>? latest,
    String? lastMessage,
    int? frames,
    CrossingInfo? crossing,
    bool? crossingActive,
    bool? voiceMissing,
  }) =>
      AlertState(
        latest: latest ?? this.latest,
        lastMessage: lastMessage ?? this.lastMessage,
        frames: frames ?? this.frames,
        crossing: crossing ?? this.crossing,
        crossingActive: crossingActive ?? this.crossingActive,
        voiceMissing: voiceMissing ?? this.voiceMissing,
      );
}

class AlertNotifier extends Notifier<AlertState> {
  static const _memory = Duration(seconds: 2);
  static const _crossingDuration = Duration(seconds: 30);

  final _policy = AlertPolicy();
  StreamSubscription? _sub;
  StreamSubscription? _crossSub;
  bool _started = false;
  DateTime _lastSeen = DateTime.fromMillisecondsSinceEpoch(0);

  Timer? _crossTimer;
  DateTime _crossAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _crossSpoken = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime? _clearSince;
  String _crossKey = '';

  @override
  AlertState build() {
    ref.onDispose(() {
      _sub?.cancel();
      _crossSub?.cancel();
      _crossTimer?.cancel();
    });
    return const AlertState();
  }

  String get _lang => ref.read(languageProvider);

  String _ttsCode(String l) =>
      {'en': 'en-US', 'fr': 'fr-FR', 'ar': 'ar-SA'}[l] ?? 'ar-SA';

  Future<void> start() async {
    if (_started) return;
    _started = true;
    final repo = ref.read(piRepositoryProvider);
    _sub = repo.detections.listen(_onDetections);
    _crossSub = repo.crossing.listen(_onCrossing);
    await _prepareVoice();
    await repo.connect();
  }

  Future<bool> _prepareVoice() async {
    try {
      final tts = ref.read(ttsProvider);
      final code = _ttsCode(_lang);
      await tts.init(code);
      final ok = await tts.isAvailable(code);
      state = state.copyWith(voiceMissing: !ok);
      return ok;
    } catch (_) {
      return true;
    }
  }

  /// Switch language: voice, messages and screen texts.
  Future<void> setLanguage(String lang) async {
    ref.read(languageProvider.notifier).state = lang;
    _crossKey = '';
    state = state.copyWith(lastMessage: '');
    final ok = await _prepareVoice();
    if (ok) await _say(S.t(lang, 'langChanged'));
  }

  Future<void> _onDetections(List<Detection> all) async {
    final now = DateTime.now();
    if (all.isNotEmpty) _lastSeen = now;
    final latest = all.isNotEmpty
        ? all
        : (now.difference(_lastSeen) < _memory ? state.latest : <Detection>[]);
    state = state.copyWith(latest: latest, frames: state.frames + 1);

    final speak = _policy.filter(all);
    if (speak.isEmpty) return;
    final top = speak.first;

    if (state.crossingActive && top.danger != Danger.high) return;

    final msg = MessageFormatter(_lang).format(top);
    state = state.copyWith(lastMessage: msg);
    try {
      await ref.read(hapticProvider).vibrate(top.danger);
      final tts = ref.read(ttsProvider);
      top.danger == Danger.high ? await tts.speakNow(msg) : await tts.speak(msg);
    } catch (_) {}
  }

  // ---------------- crossing aid ----------------

  void _onCrossing(CrossingInfo c) {
    _crossAt = DateTime.now();
    state = state.copyWith(crossing: c);
    if (!state.crossingActive) return;

    final now = DateTime.now();
    if (c.state == CrossState.clear) {
      _clearSince ??= now;
      if (now.difference(_clearSince!) < const Duration(seconds: 2)) return;
    } else {
      _clearSince = null;
    }

    final key = c.key;
    final repeatWait = c.state == CrossState.wait &&
        now.difference(_crossSpoken) > const Duration(seconds: 3);
    if (key == _crossKey && !repeatWait) return;

    _crossKey = key;
    _crossSpoken = now;
    _say(c.message(_lang));
  }

  Future<void> startCrossing() async {
    _crossTimer?.cancel();
    _crossKey = '';
    _clearSince = null;
    state = state.copyWith(crossingActive: true);
    _crossTimer = Timer(_crossingDuration, stopCrossing);

    final fresh = DateTime.now().difference(_crossAt) < const Duration(seconds: 2);
    final c = fresh ? state.crossing : CrossingInfo.unknown;
    await _say('${S.t(_lang, 'crossIntro')} ${c.message(_lang)}');
  }

  Future<void> stopCrossing() async {
    _crossTimer?.cancel();
    if (!state.crossingActive) return;
    state = state.copyWith(crossingActive: false);
    await _say(S.t(_lang, 'crossEnd'));
  }

  Future<void> _say(String text) async {
    try {
      await ref.read(ttsProvider).speakNow(text);
    } catch (_) {}
  }

  // ---------------- other actions ----------------

  Future<void> describeScene() async {
    final text = MessageFormatter(_lang).describeScene(state.latest);
    state = state.copyWith(lastMessage: text);
    await _say(text);
  }

  Future<void> repeatLast() async {
    if (state.lastMessage.isEmpty) return;
    await _say(state.lastMessage);
  }

  /// Spoken text for the screen (SOS, connection).
  Future<void> say(String key) => _say(S.t(_lang, key));
}

final alertNotifierProvider =
    NotifierProvider<AlertNotifier, AlertState>(AlertNotifier.new);