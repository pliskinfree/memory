#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 \"Title\" \"tag1,tag2\" \"Summary\" [content_file]"
  exit 1
fi

TITLE="$1"
TAGS_CSV="$2"
SUMMARY="$3"
CONTENT_FILE="${4:-}"
DATE="$(date +%F)"
SLUG="$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')"
[[ -z "$SLUG" ]] && SLUG="post-$(date +%s)"
OUT="posts/${DATE}-${SLUG}.md"

IFS=',' read -r -a TAGS <<< "$TAGS_CSV"
TAG_LINES=""
for t in "${TAGS[@]}"; do
  t_trim="$(echo "$t" | xargs)"
  [[ -n "$t_trim" ]] && TAG_LINES+="- ${t_trim}\n"
done

{
  echo '---'
  echo "title: \"${TITLE}\""
  echo "date: \"${DATE}\""
  echo "summary: \"${SUMMARY}\""
  echo "draft: false"
  echo 'tags:'
  printf "%b" "$TAG_LINES"
  echo '---'
  echo
  if [[ -n "$CONTENT_FILE" && -f "$CONTENT_FILE" ]]; then
    cat "$CONTENT_FILE"
  else
    echo "${SUMMARY}"
    echo
    echo "（由 OpenClaw 自动发布）"
  fi
} > "$OUT"

git add "$OUT"
git commit -m "publish: ${TITLE}"
git push origin main

echo "Published: $OUT"
