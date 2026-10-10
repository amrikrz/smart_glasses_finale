# smart_glasses_finale
# VisioNav – Smart Vision Assistant

An assistive prototype for blind and low-vision people. A camera sees the scene, a YOLO model detects obstacles, and a Flutter Android app **speaks** what it finds (in French) and **vibrates** when something is close.

```
Phone camera ──Wi-Fi──► PC runs YOLO ──Wi-Fi──► VisioNav app speaks + vibrates
```

Everything runs over your Wi-Fi. **No USB cable is needed** to use it.

> ## ⚠️ Safety notice
> This is an **experimental prototype**, not a medical or safety device. It does **not** replace a white cane, a guide dog, or your hearing. Distance estimates are approximate, the camera cannot see traffic from the sides or behind, and detection can fail at night or in rain. **Do not rely on it to cross a street.** It has not been tested with blind users or mobility instructors.

---

## Status

| Works now | Not built yet |
|---|---|
| Object detection (YOLOv8, 80 COCO classes) | Stairs, curb and pedestrian-signal detection |
| Direction (left / front / right) and approximate distance | Real SOS (today it is only a countdown) |
| Spoken alerts in French, vibration by danger level | Voice commands by microphone |
| "Devant moi ?" (describe the scene) and "Répéter" | GPS navigation, OCR, translation |
| Optional road model: crosswalk, pothole | Backend, login, caregiver dashboard |
| Street-crossing **advisory** (vehicles, never says "safe") | Foreground service (alerts stop with the screen off) |
| Phone camera streamed to the PC | Raspberry Pi version (planned, untested) |
| Companion-mode screens (camera, navigation, translation, VisioAI) | These screens use sample data, not real features |

---

## How it works

1. The app opens the phone's rear camera and uploads pictures to the PC (`POST /upload`).
2. `pi_server/pc_detector.py` runs YOLO on each picture, tracks objects, estimates direction and distance, and runs the crossing advisory.
3. The server sends results to the app over a WebSocket (`/ws`) and serves the annotated picture (`/frame.jpg`).
4. The app filters repeats, sorts by danger, and speaks the most important alert.

**Danger levels:** under 1 m = high (strong vibration, interrupts speech), 1–2.5 m = medium (spoken), over 2.5 m = low (only when you ask "Devant moi ?").

---

## Repository layout

```
.
├── app/                  Flutter Android app
├── pi_server/            Python detection server
│   ├── pc_detector.py
│   ├── crossing.py
│   └── road.pt           (optional, NOT included, see "Road model")
└── training/             Scripts to prepare datasets for the road model
    ├── inspect_datasets.py
    └── merge_datasets.py
```

---

## Requirements

**PC (runs the model)**
- Windows, macOS or Linux, Python 3.9 or newer
- No GPU needed (a GPU makes it faster)

**Phone**
- Android phone with a camera and the French text-to-speech voice installed

**Network**
- Phone and PC on the **same Wi-Fi** (see the hotspot option below if the router blocks it)

**To build the app**
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable, Dart 3.3 or newer) and Android SDK (installed with Android Studio)

---

## Quick start (no USB)

### 1. Get the code

```bash
git clone https://github.com/YOUR_USER/YOUR_REPO.git
cd YOUR_REPO
```

### 2. Start the detection server on the PC

```bash
cd pi_server
pip install ultralytics opencv-python numpy fastapi uvicorn websockets lap
python pc_detector.py
```

The first run downloads `yolov8n.pt` automatically (internet needed once). You should see:

```
Road model: NOT found      ← normal if you have no road.pt
INFO:     Uvicorn running on http://0.0.0.0:8000
```

Leave this window open.

> If you get `Errno 10048` (port already in use), an old copy is still running. Close it, or find it with `netstat -ano | findstr :8000` and stop it with `taskkill /PID <number> /F` (Windows).

### 3. Allow the connection through the firewall (Windows)

Windows asks the first time Python starts. Click **Allow** for private networks. If it didn't ask, run this in PowerShell **as Administrator**:

```powershell
netsh advfirewall firewall add rule name="VisioNav 8000" dir=in action=allow protocol=TCP localport=8000 profile=private
```

Also set your Wi-Fi network type to **Private** (Settings → Network → Wi-Fi → your network).

### 4. Find the PC's address

```bash
ipconfig        # Windows: use "IPv4 Address" under Wi-Fi
ifconfig        # macOS / Linux
```

Example: `192.168.1.103`. This address can change when the router restarts.

### 5. Test from the phone's browser

Connect the phone to the same Wi-Fi, turn off mobile data and any VPN, then open Chrome and go to:

```
http://192.168.1.103:8000/detections
```

You should see text such as `{"objects":[],"crossing":{...}}`. If it does not load, see [Troubleshooting](#troubleshooting).

### 6. Put the address in the app

Edit `app/lib/core/constants/app_constants.dart`:

```dart
static const piHost = '192.168.1.103:8000';   // your PC address
```

This value is compiled into the app, so rebuild after changing it.

### 7. Build the app and install it without a cable

```bash
cd app
flutter pub get
flutter build apk --release
```

The file is created at:

```
app/build/app/outputs/flutter-apk/app-release.apk
```

Send it to the phone (Google Drive, Telegram, email), open it, allow "install from this source", and install. Accept the **camera** permission on first launch.

**Alternative: Wireless debugging (Android 11 or newer)**, which lets you run directly from the PC:

1. Phone: Settings → Developer options → **Wireless debugging** → On → **Pair device with pairing code**.
2. PC: `adb pair <ip>:<pairing-port>` and enter the 6-digit code.
3. Back on the phone's Wireless debugging screen, note the other IP and port, then: `adb connect <ip>:<port>`
4. `flutter devices`, then `flutter run -d <ip>:<port>`

### 8. Use it

Keep the PC server running, open **VisioNav**, and hold the phone upright with the rear camera facing forward (chest height works well).

| Control | What it does |
|---|---|
| Green **Devant moi ?** | Reads out the objects currently detected |
| Blue **Répéter** | Repeats the last alert |
| Orange **Traverser ?** | Street-crossing advisory for 30 seconds (information only) |
| Red **SOS** (hold) | 5-second countdown, tap to cancel. **Does not send anything yet** |
| Top-right icon | Companion mode (screens for a sighted helper) |

The top bar shows **Connecté** and a **Reçus** counter. If the counter does not move, the app is not receiving data from the PC.

---

## Camera options

In `pi_server/pc_detector.py`:

```python
CAMERA = "app"   # phone camera sent by the app (default)
# CAMERA = 0     # PC webcam
# CAMERA = "http://PHONE_IP:8080/video"   # IP Webcam app stream
ROTATE = None    # picture sideways? try cv2.ROTATE_90_CLOCKWISE
```

If the picture is sideways or upside down, set `ROTATE`. Left and right alerts depend on an upright picture.

**Distance calibration:** put a person exactly 2 m from the camera and change `FOCAL` until the app says about 2 m. Distances from a single camera are always rough.

---

## Road model (optional)

The base model knows 80 everyday classes (person, car, chair, bus, traffic light, …). An optional second model, `road.pt`, adds **crosswalk** and **pothole**. It is **not included** in this repository. To use it, place your trained file at `pi_server/road.pt`. The server prints `Road model: loaded` when it finds it.

To train your own:

1. Download datasets from [Roboflow Universe](https://universe.roboflow.com) in **YOLOv8** format. **Check the class list and sample images first.** Datasets with similar names can contain something else entirely.
2. Put each one in `training/raw/<name>/` (each folder must contain `data.yaml`, `train/`, `valid/`).
3. Run `python training/inspect_datasets.py` to see the class names, then edit the `ALIASES` in `training/merge_datasets.py` and run it to produce a `merged/` dataset with these classes:
   `crosswalk, ped_red, ped_green, pothole, stairs, curb, manhole, pole, barrier`
4. Train on Google Colab (free GPU):
   ```python
   from ultralytics import YOLO
   YOLO("yolov8n.pt").train(data="/content/merged/data.yaml",
                            epochs=50, imgsz=640, batch=16)
   ```
5. Copy `runs/detect/train/weights/best.pt` to `pi_server/road.pt`.

Tip: a large `merged.zip` takes hours to upload from a home connection. Download the datasets **inside Colab** with the `roboflow` Python package instead.

Test on photos from **your own streets**, not only the dataset. Check each dataset's license before sharing a model or using it commercially.

---

## Configuration

| Setting | File | Default |
|---|---|---|
| Server address | `app/lib/core/constants/app_constants.dart` → `piHost` | `127.0.0.1:8000` |
| Camera source, rotation, focal length | `pi_server/pc_detector.py` | `"app"`, `None`, `700` |
| Speech speed | `app/lib/services/tts_service.dart` | web `1.25`, mobile `0.62` |
| Language | `languageProvider` in `alert_notifier.dart` | `fr` |
| Port | last line of `pc_detector.py` | `8000` |

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Phone browser cannot open `http://PC_IP:8000/detections` | Same Wi-Fi? Mobile data and VPN off? Firewall rule added? Network set to **Private**? |
| Works on the PC but not the phone | The router may isolate devices (common on guest Wi-Fi). Use your phone's **hotspot**: connect the PC to it, run `ipconfig` again, and use the new address |
| App says **Non connecté** | Server not running, or the PC address changed. Check `ipconfig`, update `piHost`, rebuild |
| App says **Pas de flux vidéo** | The server has no picture yet. Check the camera permission and the small camera box in the app |
| Small box says **Caméra refusée** | Settings → Apps → VisioNav → Permissions → Camera |
| Small box says **PC injoignable** | The phone cannot reach the server (see the first rows) |
| No voice | Settings → General management → Language → Text-to-speech, and install the French voice |
| Voice too slow or too fast | Change `webRate` / `mobileRate` in `tts_service.dart` |
| Alerts stop when the screen turns off | Expected: the foreground service is not built yet. Keep the screen on |
| `Errno 10048` on the server | Another server is using port 8000. Stop it first |
| Build error mentioning `Registrar` | An old plugin version. Run `flutter pub upgrade --major-versions` |
| `StateProvider isn't defined` | With Riverpod 3, add `import 'package:flutter_riverpod/legacy.dart';` |

---

## Security notes

- The server has **no login** and accepts uploads from any device that can reach it. Use it only on a network you trust, and **never expose port 8000 to the internet**.
- The app allows plain `http://` and `ws://` traffic (`usesCleartextTraffic`) so it can talk to a local server. Use HTTPS/WSS and authentication before any real deployment.
- Pictures from the phone camera are processed in memory and are not saved by the server.
- Never commit API keys (for example a Roboflow key). Keep them in environment variables.

---

## Roadmap

- [ ] Real SOS: GPS, push notification and SMS to a caregiver
- [ ] Voice commands (microphone) and a settings screen (speech speed, language)
- [ ] Faster camera streaming instead of photo upload, and a foreground service
- [ ] Stairs, curb and pedestrian-signal models trained on local street photos
- [ ] Raspberry Pi 5 version with an ultrasonic distance sensor
- [ ] Backend, accounts, and a caregiver dashboard
- [ ] Testing with blind users and orientation-and-mobility instructors

---

## Suggested `.gitignore` additions

```
build/
.dart_tool/
*.apk
__pycache__/
training/raw/
training/merged/
training/small/
*.zip
.env
```

Large model files (`*.pt`) are better shared as a GitHub Release than committed to the repository.

---

## Contributing

Issues and pull requests are welcome. If you test this with blind or low-vision users, please share what worked and what did not. That feedback matters more than any code.

## Credits

- [Ultralytics YOLOv8](https://github.com/ultralytics/ultralytics) for object detection (licensed AGPL-3.0, so check the terms before distributing a derived work)
- [Roboflow Universe](https://universe.roboflow.com) community datasets for the road model (check each dataset's license)
- [Flutter](https://flutter.dev), [FastAPI](https://fastapi.tiangolo.com), [OpenCV](https://opencv.org)

## License

Choose a license for your own code (for example MIT) and add a `LICENSE` file. Remember that dependencies carry their own licenses.

**Author:** YOUR NAME
