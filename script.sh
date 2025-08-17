#!/usr/bin/env bash
set -euo pipefail

RUN_DIR="$HOME/gnyana"
mkdir -p "$RUN_DIR"

PROMPT_FILE="$RUN_DIR/prompt.txt"   # put the updated prompt text here
OUT_FILE="$RUN_DIR/daily_$(date +%F).md"

# Build JSON safely with jq (no nested shell quoting)
JSON_PAYLOAD="$(
  jq -n \
     --arg model "gpt-5-pro" \
     --rawfile content "$PROMPT_FILE" \
     '{model:$model, messages:[{role:"user", content:$content}]}'
)"

# Call your LLM endpoint
curl -sS \
  -H "Authorization: Bearer $LLM_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$JSON_PAYLOAD" \
  "https://api.your-llm.com/v1/chat/completions" \
| jq -r '.choices[0].message.content' > "$OUT_FILE"

echo "Wrote $OUT_FILE"
