#!/usr/bin/env bash
# Runs the full verification pipeline and writes the log to .verify/report.txt
# (so it can be read back from a Cowork session).
set -u
cd "$(dirname "$0")/.."
mkdir -p .verify
LOG=.verify/report.txt
: > "$LOG"
run() {
  echo "### $*" | tee -a "$LOG"
  "$@" 2>&1 | tee -a "$LOG"
  echo "### exit=${PIPESTATUS[0]}" | tee -a "$LOG"
}
run flutter --version
run flutter pub get
run dart run build_runner build --delete-conflicting-outputs
run flutter gen-l10n
run flutter analyze
run flutter test
echo "DONE" | tee -a "$LOG"
