# crossing.py - advisory only. It never decides that crossing is safe.
import time
from collections import defaultdict, deque
import cv2

VEHICLES = {"car", "bus", "truck", "motorcycle", "bicycle"}
APPROACH_GROWTH = 0.25   # box height grows > 25 % per second = approaching
CLOSE_RATIO = 0.30       # box taller than 30 % of the frame = close
QUIET_SECONDS = 4.0      # no vehicle for this long before "clear"


class CrossingAnalyzer:
    def __init__(self, has_crosswalk_class=False):
        self.hist = defaultdict(lambda: deque(maxlen=10))  # id -> (time, box_h)
        self.last_vehicle = time.time()   # first 4 s after start = caution
        self.has_crosswalk_class = has_crosswalk_class

    @staticmethod
    def _light_color(frame, box):
        x1, y1, x2, y2 = [max(int(v), 0) for v in box]
        crop = frame[y1:y2, x1:x2]
        if crop.size == 0:
            return "unknown"
        hsv = cv2.cvtColor(crop, cv2.COLOR_BGR2HSV)
        red = cv2.inRange(hsv, (0, 120, 120), (10, 255, 255)) | \
              cv2.inRange(hsv, (170, 120, 120), (180, 255, 255))
        green = cv2.inRange(hsv, (40, 80, 100), (90, 255, 255))
        r, g = int(red.sum() / 255), int(green.sum() / 255)
        if max(r, g) < 15:
            return "unknown"
        return "red" if r > g else "green"

    def analyze(self, raw, frame):
        now = time.time()
        h = frame.shape[0]
        approaching = close = visible = False
        signal = "none"
        crosswalk = False if self.has_crosswalk_class else None

        for o in raw:
            lab = o["label"]
            x1, y1, x2, y2 = o["box"]
            if lab in VEHICLES:
                visible = True
                bh = y2 - y1
                if bh / h > CLOSE_RATIO:
                    close = True
                tid = o["id"]
                if tid >= 0:
                    hist = self.hist[tid]
                    hist.append((now, bh))
                    t0, h0 = hist[0]
                    if now - t0 >= 0.5 and h0 > 0:
                        if (bh - h0) / h0 / (now - t0) > APPROACH_GROWTH:
                            approaching = True
            elif lab == "ped_red":
                signal = "red"
            elif lab == "ped_green" and signal != "red":
                signal = "green"
            elif lab == "traffic light" and signal == "none":
                c = self._light_color(frame, o["box"])  # a car light is only a hint
                if c != "unknown":
                    signal = c
            elif lab == "crosswalk":
                crosswalk = True

        for tid in list(self.hist):                      # forget old tracks
            if now - self.hist[tid][-1][0] > 1.5:
                del self.hist[tid]

        if visible:
            self.last_vehicle = now

        if approaching or close:
            state, reason = "wait", "vehicle"
        elif signal == "red":
            state, reason = "wait", "signal_red"
        elif visible or now - self.last_vehicle < QUIET_SECONDS:
            state, reason = "caution", "vehicle_visible"
        else:
            state, reason = "clear", "none"

        return {"state": state, "reason": reason,
                "signal": signal, "crosswalk": crosswalk}