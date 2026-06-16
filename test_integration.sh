#!/bin/bash
npx @stoplight/prism-cli mock test/fixtures/openapi/openapi.json &
PRISM_PID=$!

until curl -s http://localhost:4010/health > /dev/null 2>&1; do
  sleep 0.5
done

flutter test test/integration/
kill $PRISM_PID
