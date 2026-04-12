#!/usr/bin/env bash
set -euo pipefail

AVD="${ANDROID_AVD:-Pixel_7_Pro_API_35}"

flutter emulators --launch "$AVD" || true

echo "Waiting for an Android emulator…"
id=""
for _ in $(seq 1 90); do
  id="$(
    flutter devices --machine 2>/dev/null | python3 -c "
import json, sys
try:
    for d in json.load(sys.stdin):
        if d.get('emulator') and str(d.get('targetPlatform', '')).startswith('android'):
            print(d.get('id', ''))
            break
except Exception:
    pass
" || true
  )"
  if [[ -n "$id" ]]; then
    break
  fi
  sleep 2
done

if [[ -z "$id" ]]; then
  echo "No Android emulator found. Fix AVD startup (see flutter emulators output) or set ANDROID_AVD." >&2
  exit 1
fi

exec flutter run -d "$id"
