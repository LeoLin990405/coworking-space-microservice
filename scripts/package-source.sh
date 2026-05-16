#!/usr/bin/env bash
set -euo pipefail

ARCHIVE="${1:-coworking-source.zip}"

zip -r "$ARCHIVE" . \
  -x '.git/*' \
  -x '*.DS_Store' \
  -x "$ARCHIVE" \
  -x 'submission/screenshots/*'

echo "$ARCHIVE"
