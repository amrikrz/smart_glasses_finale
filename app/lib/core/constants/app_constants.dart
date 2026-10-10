class AppConstants {
  // Change ONLY this line. Same address for video and detections.
  // Laptop test:  '192.168.1.103:8000'
  // Real phone:   'YOUR_PC_IP:8000'   (find it with ipconfig)
  // Raspberry Pi: 'PI_IP:8000'
static const piHost = '192.168.1.103:8000'; 
static const piWsUrl = 'ws://$piHost/ws';
  static const piHttpUrl = 'http://$piHost';

  static const alertCooldown = Duration(seconds: 3);
  static const watchdogTimeout = Duration(seconds: 3);
  static const reconnectDelay = Duration(seconds: 2);
  static const maxSpokenObjects = 3;
}