import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../core/constants/app_constants.dart';
import '../../alerts/domain/crossing.dart';
import '../../alerts/domain/detection.dart';
import '../domain/pi_repository.dart';

class PiRepositoryImpl implements PiRepository {
  final _detCtrl = StreamController<List<Detection>>.broadcast();
  final _crossCtrl = StreamController<CrossingInfo>.broadcast();
  final _statusCtrl = StreamController<PiStatus>.broadcast();
  WebSocketChannel? _channel;
  Timer? _watchdog;
  bool _wantConnected = false;

  @override
  Stream<List<Detection>> get detections => _detCtrl.stream;
  @override
  Stream<CrossingInfo> get crossing => _crossCtrl.stream;
  @override
  Stream<PiStatus> get status => _statusCtrl.stream;

  @override
  Future<void> connect() async {
    _wantConnected = true;
    _statusCtrl.add(PiStatus.connecting);
    try {
      _channel = WebSocketChannel.connect(Uri.parse(AppConstants.piWsUrl));
      await _channel!.ready;
      _statusCtrl.add(PiStatus.connected);
      _resetWatchdog();
      _channel!.stream.listen(
        _onMessage,
        onDone: _onLost,
        onError: (_) => _onLost(),
      );
    } catch (_) {
      _onLost();
    }
  }

  void _onMessage(dynamic raw) {
    _resetWatchdog();
    final json = jsonDecode(raw as String) as Map<String, dynamic>;
    if (json['type'] == 'health') return;
    final list = (json['objects'] as List? ?? [])
        .map((e) => Detection.fromJson(e as Map<String, dynamic>))
        .toList();
    _detCtrl.add(list);
    final c = json['crossing'];
    if (c is Map<String, dynamic>) _crossCtrl.add(CrossingInfo.fromJson(c));
  }

  void _resetWatchdog() {
    _watchdog?.cancel();
    _watchdog = Timer(AppConstants.watchdogTimeout, _onLost);
  }

  void _onLost() {
    _watchdog?.cancel();
    _channel?.sink.close();
    _crossCtrl.add(CrossingInfo.unknown); // never keep a stale "clear"
    _statusCtrl.add(PiStatus.disconnected);
    if (_wantConnected) {
      Future.delayed(AppConstants.reconnectDelay, connect);
    }
  }

  @override
  void disconnect() {
    _wantConnected = false;
    _watchdog?.cancel();
    _channel?.sink.close();
    _statusCtrl.add(PiStatus.disconnected);
  }
}