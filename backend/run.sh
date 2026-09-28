#!/usr/bin/env bash
# Run the Kanz API on this computer (Linux, macOS, or Git Bash on Windows).
#
#   ./run.sh              serve on port 8000
#   ./run.sh --reload     restart automatically when code or prompts change
#   PORT=8100 ./run.sh    use another port
#
# Creates backend/.venv on first run, installs requirements.txt whenever it changes,
# creates backend/.env from .env.example if it is missing, and prints the URLs to use
# from the Android emulator and from a phone on the same Wi-Fi.
set -euo pipefail
cd "$(dirname "$0")"

PORT="${PORT:-8000}"
RELOAD=()
for arg in "$@"; do
  case "$arg" in
    --reload) RELOAD=(--reload --reload-dir app --reload-dir prompts) ;;
    -h | --help) sed -n '2,6p' "$0"; exit 0 ;;
    *) echo "Unknown option: $arg (try --help)" >&2; exit 2 ;;
  esac
done

# --- Virtual environment -------------------------------------------------------------
venv_python() {
  if [ -x .venv/bin/python ]; then echo .venv/bin/python; elif [ -x .venv/Scripts/python.exe ]; then echo .venv/Scripts/python.exe; fi
}
PY="$(venv_python)"
if [ -z "$PY" ]; then
  echo "Creating the virtual environment in backend/.venv ..."
  BASE_PY="$(command -v python3.11 || command -v python3 || command -v python || true)"
  [ -n "$BASE_PY" ] || { echo "Python 3.11 is required." >&2; exit 1; }
  "$BASE_PY" -m venv .venv
  PY="$(venv_python)"
fi

# --- Requirements (reinstalled only when requirements.txt changes) --------------------
sha256() { if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1"; else shasum -a 256 "$1"; fi | cut -d' ' -f1; }
STAMP=.venv/.requirements.sha256
WANTED="$(sha256 requirements.txt)"
if [ ! -f "$STAMP" ] || [ "$(cat "$STAMP")" != "$WANTED" ]; then
  echo "Installing requirements ..."
  "$PY" -m pip install --disable-pip-version-check --quiet -r requirements.txt
  echo "$WANTED" > "$STAMP"
fi

# --- Secrets --------------------------------------------------------------------------
if [ ! -f .env ]; then
  cp .env.example .env
  echo "Created backend/.env from .env.example. Put your GEMINI_API_KEY in it, then restart." >&2
fi

# --- Where to point the app -------------------------------------------------------------
lan_ips() {
  {
    hostname -I 2>/dev/null | tr ' ' '\n'
    command -v ip >/dev/null 2>&1 && ip -4 -o addr show scope global 2>/dev/null | awk '{print $4}' | cut -d/ -f1
    command -v ifconfig >/dev/null 2>&1 && ifconfig 2>/dev/null | awk '/inet /{print $2}' | sed 's/addr://'
    command -v ipconfig >/dev/null 2>&1 && ipconfig 2>/dev/null | tr -d '\r' | awk -F': ' '/IPv4/{print $2}'
  } | grep -E '^[0-9]+(\.[0-9]+){3}$' | grep -vE '^(127\.|169\.254\.)' | sort -u
}

echo
echo "Kanz API on port $PORT"
printf '  %-20s http://127.0.0.1:%s/docs\n' "This computer" "$PORT"
printf '  %-20s http://10.0.2.2:%s\n' "Android emulator" "$PORT"
for ip in $(lan_ips || true); do
  printf '  %-20s http://%s:%s\n' "Phone on same Wi-Fi" "$ip" "$PORT"
done
echo "  If the phone cannot connect, allow incoming connections on port $PORT in the firewall."
echo

# --- Serve ------------------------------------------------------------------------------
exec "$PY" -m uvicorn app.main:app --host 0.0.0.0 --port "$PORT" ${RELOAD[@]+"${RELOAD[@]}"}
