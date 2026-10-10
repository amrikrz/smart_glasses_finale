import '../../alerts/domain/crossing.dart';
import '../../alerts/domain/detection.dart';

enum PiStatus { disconnected, connecting, connected }

abstract class PiRepository {
  Stream<List<Detection>> get detections;
  Stream<CrossingInfo> get crossing;
  Stream<PiStatus> get status;
  Future<void> connect();
  void disconnect();
}