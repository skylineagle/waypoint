#!/usr/bin/env bash
# Debug builds only. Walks the simulator through one day's stops in order.
# The script only moves the location. The app's StopTracker marks stops done.
set -euo pipefail

APP="dev.horizon.trekcompanion"
GROUP="group.dev.horizon.trekcompanion"
ROOT="$(cd "$(dirname "$0")" && pwd)"
SPEED="${SPEED:-40}"
# Crossing a stop's 200 m circle on the way to another must stay under the app's dwell.
STAY=$((400 / SPEED + 2))
DWELL="${DWELL:-$((STAY + 8))}"
if (( DWELL < STAY + 4 )); then
  echo "DWELL raised to $((STAY + 4))s: at ${SPEED} m/s the app needs ${STAY}s at a stop to tell it from passing by."
  DWELL=$((STAY + 4))
fi

usage() {
  cat <<USAGE
Walk one day's stops on an iPhone simulator (Debug builds only).

  scripts/sim-timeline.sh 2026-10-09
  scripts/sim-timeline.sh 2026-10-09 "iPhone Air"
  scripts/sim-timeline.sh list

Clears the Done stops, jumps to the date, then travels to each stop in order
at SPEED m/s (default 40) and stays DWELL seconds (default 20). For the run the
app's 2-minute dwell is shortened to a few seconds, so each stop turns done
while you're there. Stops without coordinates are skipped. Ctrl-C stops.
USAGE
}

py() {
  python3 - "$@" <<'PY'
import json, math, os, plistlib, subprocess, sys, tempfile

def phones():
    data = json.loads(subprocess.check_output(["xcrun", "simctl", "list", "devices", "available", "-j"]))
    return [device for devices in data["devices"].values() for device in devices
            if "iPhone" in device.get("name", "") and device.get("isAvailable", True)]

def emit(device):
    print(f"{device['udid']}\t{device['state']}\t{device['name']}")

def resolve(query):
    found = phones()
    if not query:
        booted = [device for device in found if device["state"] == "Booted"]
        if len(booted) == 1:
            return emit(booted[0])
        print("Name an iPhone simulator.", file=sys.stderr)
        for device in booted or found:
            print(f"  {device['name']}  {device['udid']}  {device['state']}", file=sys.stderr)
        sys.exit(1)
    matches = [device for device in found if query in (device["udid"], device["name"])]
    if not matches:
        matches = [device for device in found if query.lower() in device["name"].lower()]
    booted = [device for device in matches if device["state"] == "Booted"]
    if len(matches) == 1 or len(booted) == 1:
        return emit(matches[0] if len(matches) == 1 else booted[0])
    if matches:
        print(f"Several simulators match {query}. Pass the UDID.", file=sys.stderr)
        for device in matches:
            print(f"  {device['name']}  {device['udid']}  {device['state']}", file=sys.stderr)
    else:
        print(f"No iPhone simulator matches {query}.", file=sys.stderr)
    sys.exit(1)

def read_plist(path):
    try:
        with open(path, "rb") as handle:
            return plistlib.load(handle)
    except (OSError, plistlib.InvalidFileException):
        return {}

def extract(path, date, dest):
    try:
        raw = read_plist(path)["today-snapshot"]
        snap = json.loads(raw.decode() if isinstance(raw, bytes) else raw)
    except (KeyError, json.JSONDecodeError, TypeError, UnicodeError):
        return 2
    if snap.get("date") != date:
        return 2
    stops = snap.get("stops") or []
    places = [stop for stop in stops if stop.get("latitude") is not None and stop.get("longitude") is not None]
    if not places:
        return 3
    os.makedirs(dest, exist_ok=True)
    title = (snap.get("dayTitle") or "Today").replace("\t", " ").replace("\n", " ")
    with open(os.path.join(dest, "meta"), "w") as handle:
        handle.write(f"{len(stops)}\t{snap['tripID']}\t{title}\n")
    with open(os.path.join(dest, "ids"), "w") as handle:
        handle.write(",".join(str(stop["id"]) for stop in stops) + "\n")
    with open(os.path.join(dest, "places"), "w") as handle:
        for stop in places:
            name = (stop.get("name") or "Stop").replace("\t", " ").replace("\n", " ")
            handle.write(f"{stop['id']}\t{stop['latitude']}\t{stop['longitude']}\t{name}\n")
    return 0

def distance(a, b):
    (lat1, lon1), (lat2, lon2) = a, b
    x = math.radians(lon2 - lon1) * math.cos(math.radians((lat1 + lat2) / 2))
    y = math.radians(lat2 - lat1)
    return math.hypot(x, y) * 6_371_000

def away(lat, lon, meters):
    return lat - meters / 111_320, lon

def done_keys(path):
    return [key for key in read_plist(path) if key.startswith("done-stops-")]

def done_today(path, trip, ids):
    done = {str(item) for item in read_plist(path).get(f"done-stops-{trip}", [])}
    return [stop_id for stop_id in ids if stop_id in done]

def check():
    assert abs(distance((35.0, 139.0), (35.001, 139.0)) - 111.2) < 1
    assert distance(away(35.7, 139.7, 600), (35.7, 139.7)) > 590
    dest = tempfile.mkdtemp()
    path = os.path.join(dest, "group.plist")
    snap = {"tripID": 1, "date": "2026-10-09", "dayTitle": "Kappabashi",
            "stops": [{"id": 59, "name": "A", "latitude": 35.71, "longitude": 139.78},
                      {"id": 77, "name": "No pin"},
                      {"id": 60, "name": "B", "latitude": 35.69, "longitude": 139.77}]}
    with open(path, "wb") as handle:
        plistlib.dump({"today-snapshot": json.dumps(snap).encode(), "done-stops-1": [32, 60]}, handle)
    out = os.path.join(dest, "out")
    assert extract(path, "2026-10-08", out) == 2
    assert extract(path, "2026-10-09", out) == 0
    assert open(os.path.join(out, "ids")).read().strip() == "59,77,60"
    assert len(open(os.path.join(out, "places")).read().splitlines()) == 2
    assert done_today(path, "1", ["59", "77", "60"]) == ["60"]
    assert done_keys(path) == ["done-stops-1"]
    print("ok")

cmd, args = sys.argv[1], sys.argv[2:]
if cmd == "check":
    check()
elif cmd == "list":
    for device in phones():
        print(f"{device['state']:<10} {device['name']}  {device['udid']}")
elif cmd == "resolve":
    resolve(args[0] if args else "")
elif cmd == "extract":
    sys.exit(extract(*args))
elif cmd == "seconds":
    print(math.ceil(distance(tuple(map(float, args[0].split(","))), tuple(map(float, args[1].split(",")))) / float(args[2])) + 2)
elif cmd == "away":
    lat, lon = away(float(args[0]), float(args[1]), float(args[2]))
    print(f"{lat:.6f},{lon:.6f}")
elif cmd == "done-keys":
    print("\n".join(done_keys(args[0])))
elif cmd == "done-count":
    print(len(done_today(args[0], args[1], args[2].split(","))))
else:
    sys.exit(f"unknown {cmd}")
PY
}

case "${1:-}" in
  check) py check; exit 0 ;;
  list) py list; exit 0 ;;
esac

date="${1:-}"
if [[ ! "$date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  usage
  exit 1
fi

line="$(py resolve "${2:-}")" || exit 1
IFS=$'\t' read -r udid state name <<< "$line"
echo "Using $name"

if [[ "$state" != "Booted" ]]; then
  xcrun simctl boot "$udid"
  xcrun simctl bootstatus "$udid" -b
fi
open -a Simulator --args -CurrentDeviceUDID "$udid" >/dev/null 2>&1 || true

container="$(xcrun simctl get_app_container "$udid" "$APP" "$GROUP")"
plist="$container/Library/Preferences/$GROUP.plist"
work="$(mktemp -d)"
cleanup() {
  xcrun simctl spawn "$udid" defaults delete "$APP" StopDwellSeconds >/dev/null 2>&1 || true
  rm -rf "$work"
}
trap cleanup EXIT
trap 'printf "\nStopped.\n"; exit 0' INT TERM

xcrun simctl location "$udid" clear
xcrun simctl privacy "$udid" grant location-always "$APP"
xcrun simctl spawn "$udid" defaults write "$APP" today-map-shown -bool true
xcrun simctl spawn "$udid" defaults write "$APP" StopDwellSeconds -float "$STAY"
xcrun simctl terminate "$udid" "$APP" >/dev/null 2>&1 || true
xcrun simctl spawn "$udid" defaults delete "$APP" stop-visit >/dev/null 2>&1 || true
for key in $(py done-keys "$plist"); do
  xcrun simctl spawn "$udid" defaults delete "${plist%.plist}" "$key"
done
stamp="$(stat -f %m "$plist" 2>/dev/null || echo 0)"
SIMULATOR="$udid" "$ROOT/sim-day.sh" "$date"

ready=0
for _ in $(seq 1 45); do
  if [[ "$(stat -f %m "$plist" 2>/dev/null || echo 0)" != "$stamp" ]]; then
    code=0
    py extract "$plist" "$date" "$work" || code=$?
    if [[ "$code" == "0" ]]; then ready=1; break; fi
    if [[ "$code" == "3" ]]; then echo "That day has no stops with a location."; exit 1; fi
  fi
  sleep 1
done
if [[ "$ready" != "1" ]]; then
  echo "The app never published $date. Sign in on the simulator, and use a day that is on the trip."
  exit 1
fi

IFS=$'\t' read -r total trip title < "$work/meta"
ids="$(cat "$work/ids")"
echo "$title · $total stops. Ctrl-C to stop."

shown() {
  xcrun simctl spawn "$udid" defaults export "${plist%.plist}" "$work/prefs.plist"
  py done-count "$work/prefs.plist" "$trip" "$ids"
}

travel() {
  xcrun simctl location "$udid" start --speed="$SPEED" "$1" "$2"
  sleep "$(py seconds "$1" "$2" "$SPEED")"
  xcrun simctl location "$udid" set "$2"
}

IFS=$'\t' read -r _ first_lat first_lon _ < "$work/places"
here="$(py away "$first_lat" "$first_lon" 600)"
xcrun simctl location "$udid" set "$here"
sleep 3

while IFS=$'\t' read -r _ lat lon stop <&3; do
  echo "→ $stop"
  travel "$here" "$lat,$lon"
  here="$lat,$lon"
  sleep "$DWELL"
  echo "  app shows $(shown) of $total done"
done 3< "$work/places"

echo "→ leaving the last stop"
IFS=$'\t' read -r _ last_lat last_lon _ <<< "$(tail -n 1 "$work/places")"
travel "$here" "$(py away "$last_lat" "$last_lon" 600)"
sleep 3
echo "Day walked · app shows $(shown) of $total done"
