#!/bin/bash

# Start the background watcher to fix permissions of FlutterMacOS.framework
(
  # Run a tight loop for 30 seconds without sleep to win the race condition
  end=$((SECONDS+30))
  while [ $SECONDS -lt $end ]; do
    chmod -R u+w "$PROJECT_DIR/../build/macos" 2>/dev/null
  done
) &
WATCHER_PID=$!

# Clean up watcher on exit
cleanup() {
  kill $WATCHER_PID 2>/dev/null
  wait $WATCHER_PID 2>/dev/null
}
trap cleanup EXIT

# Run the original assembly script
"$FLUTTER_ROOT"/packages/flutter_tools/bin/macos_assemble.sh "$@"
EXIT_CODE=$?

exit $EXIT_CODE
