# pc_detector.py - YOLO server. Camera: the PHONE (app uploads frames) or the PC webcam
import asyncio, json, os, threading, time
import cv2, numpy as np, uvicorn
from fastapi import FastAPI, Request, WebSocket
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import Response
from ultralytics import YOLO
from crossing import CrossingAnalyzer

CAMERA = "app"   # "app" = phone camera sent by VisioNav.  0 = PC webcam
ROTATE = None    # if the picture is sideways: cv2.ROTATE_90_CLOCKWISE,
                 # cv2.ROTATE_90_COUNTERCLOCKWISE or cv2.ROTATE_180
FOCAL = 700
CAM_HEIGHT_M = 1.3

coco = YOLO("yolov8n.pt")
road = YOLO("road.pt") if os.path.exists("road.pt") else None
print("Road model:", "loaded" if road else "NOT found")

cap = None
if CAMERA != "app":
    cap = (cv2.VideoCapture(CAMERA, cv2.CAP_DSHOW) if isinstance(CAMERA, int)
           else cv2.VideoCapture(CAMERA))
    cap.set(cv2.CAP_PROP_BUFFERSIZE, 1)

REAL_H = {"person": 1.7, "chair": 0.9, "car": 1.5, "bus": 3.0, "truck": 3.0,
          "motorcycle": 1.2, "bicycle": 1.0, "dog": 0.5, "bottle": 0.25,
          "laptop": 0.25, "tv": 0.5, "cell phone": 0.15, "traffic light": 0.8}
INFO_ONLY = {"crosswalk", "ped_red", "ped_green"}
NO_DATA = {"state": "unknown", "reason": "no_data", "signal": "none", "crosswalk": None}

analyzer = CrossingAnalyzer(
    has_crosswalk_class=bool(road) and "crosswalk" in road.names.values())

lock = threading.Lock()
latest_jpeg = b""
latest_objects = []
latest_cross = dict(NO_DATA)
last_frame_t = 0.0

in_lock = threading.Lock()
incoming = None
in_seq = 0
last_seq = 0


def direction(xc, w):
    r = xc / w
    return "left" if r < 0.33 else "front" if r < 0.66 else "right"


def danger(d):
    return "high" if d < 1 else "medium" if d < 2.5 else "low"


def ground_distance(y2, h):
    dy = y2 - h / 2
    return 10.0 if dy <= 5 else round(min(CAM_HEIGHT_M * FOCAL / dy, 10), 1)


def next_frame():
    global last_seq
    if CAMERA == "app":
        while True:
            with in_lock:
                if incoming is not None and in_seq != last_seq:
                    last_seq = in_seq
                    return incoming.copy()
            time.sleep(0.02)
    ok, f = cap.read()
    if not ok:
        return None
    if ROTATE is not None:
        f = cv2.rotate(f, ROTATE)
    return f


def worker():
    global latest_jpeg, latest_objects, latest_cross, last_frame_t
    while True:
        frame = next_frame()
        if frame is None:
            time.sleep(0.05)
            continue
        h, w = frame.shape[:2]
        objs, raw = [], []

        res = coco.track(frame, imgsz=320, conf=0.45, persist=True,
                         tracker="bytetrack.yaml", verbose=False)[0]
        annotated = res.plot()
        for b in res.boxes:
            x1, y1, x2, y2 = b.xyxy[0].tolist()
            label = coco.names[int(b.cls)]
            tid = int(b.id) if b.id is not None else -1
            dist = round(min(REAL_H.get(label, 0.5) * FOCAL / max(y2 - y1, 1), 10), 1)
            raw.append({"label": label, "id": tid, "box": (x1, y1, x2, y2)})
            objs.append({"id": max(tid, 0), "label": label,
                         "conf": round(float(b.conf), 2),
                         "direction": direction((x1 + x2) / 2, w),
                         "distance_m": dist, "danger": danger(dist)})

        if road is not None:
            r2 = road(frame, imgsz=416, conf=0.40, verbose=False)[0]
            annotated = r2.plot(img=annotated)
            for i, b in enumerate(r2.boxes):
                x1, y1, x2, y2 = b.xyxy[0].tolist()
                label = road.names[int(b.cls)]
                dist = ground_distance(y2, h)
                raw.append({"label": label, "id": -1, "box": (x1, y1, x2, y2)})
                objs.append({"id": 1000 + i, "label": label,
                             "conf": round(float(b.conf), 2),
                             "direction": direction((x1 + x2) / 2, w),
                             "distance_m": dist,
                             "danger": "low" if label in INFO_ONLY else danger(dist)})

        cross = analyzer.analyze(raw, frame)
        ok, jpg = cv2.imencode(".jpg", annotated, [cv2.IMWRITE_JPEG_QUALITY, 70])
        with lock:
            latest_objects, latest_cross = objs, cross
            last_frame_t = time.time()
            if ok:
                latest_jpeg = jpg.tobytes()


threading.Thread(target=worker, daemon=True).start()

app = FastAPI()
app.add_middleware(CORSMiddleware, allow_origins=["*"],
                   allow_methods=["*"], allow_headers=["*"])


@app.post("/upload")
async def upload(request: Request):
    global incoming, in_seq
    data = await request.body()
    img = cv2.imdecode(np.frombuffer(data, np.uint8), cv2.IMREAD_COLOR)
    if img is None:
        return Response(status_code=400)
    if ROTATE is not None:
        img = cv2.rotate(img, ROTATE)
    with in_lock:
        incoming = img
        in_seq += 1
    return {"ok": True}


@app.get("/frame.jpg")
def frame():
    with lock:
        data = latest_jpeg
    if not data:
        return Response(status_code=404)
    return Response(content=data, media_type="image/jpeg")


def snapshot():
    with lock:
        objs, cross, t = list(latest_objects), dict(latest_cross), last_frame_t
    if time.time() - t > 2.0:          # no fresh picture: never report old data
        return [], dict(NO_DATA)
    return objs, cross


@app.get("/detections")
def detections():
    objs, cross = snapshot()
    return {"objects": objs, "crossing": cross}


@app.websocket("/ws")
async def ws(websocket: WebSocket):
    await websocket.accept()
    while True:
        objs, cross = snapshot()
        await websocket.send_text(json.dumps(
            {"type": "detections", "ts": time.time(),
             "objects": objs, "crossing": cross}))
        await asyncio.sleep(0.2)


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)