#!/bin/sh
set -eu

# Runs only for release tags (v*). The version is the tag name without the "v".
if [ -z "${CI_COMMIT_TAG:-}" ]; then
  echo "Skip: not a tag pipeline"
  exit 0
fi

if [ -z "${TELEGRAM_BOT_TOKEN:-}" ] || [ -z "${TELEGRAM_CHAT_ID:-}" ]; then
  echo "Skip: TELEGRAM_BOT_TOKEN or TELEGRAM_CHAT_ID is not set"
  exit 0
fi

echo "New release ${CI_COMMIT_TAG}"

version="${CI_COMMIT_TAG#v}"

notes=""
if [ -f "CHANGELOG.md" ]; then
  notes="$(awk -v v="${version}" 'index($0, "## [" v "]") == 1 {found=1; next} /^## /{found=0} found' CHANGELOG.md | sed '/./,$!d' || true)"
fi

# Notes come only from CHANGELOG.md; commit messages are never used.
if [ -z "${notes}" ]; then
  echo "Error: CHANGELOG.md has no section for ${version}" >&2
  exit 1
fi

# Drop commit trailers (e.g. Co-Authored-By) and leading blank lines.
# Telegram gets plain text (no parse_mode), so turn Markdown into plain-text equivalents.
notes="$(printf '%s\n' "${notes}" \
  | grep -v '^Co-Authored-By:' \
  | sed -E -e 's/^#+ +(.*)$/\1:/' -e 's/^- /• /' -e 's/`//g' \
  | sed '/./,$!d' || true)"

if [ "$(printf '%s\n' "${notes}" | wc -l)" -gt 20 ]; then
  notes="$(printf '%s\n' "${notes}" | head -20)
…"
fi

repo_url="${REPO_URL:-https://github.com/qwertyprob/vet_crm}"
commit_sha="${CI_COMMIT_SHA:-}"
commit_url=""
if [ -n "${repo_url}" ] && [ -n "${commit_sha}" ]; then
  commit_url="${repo_url}/commit/${commit_sha}"
fi

message="$(cat <<EOF
🚀 New Release

Project: ${CI_PROJECT_PATH:-unknown}
Version: ${version}
$(if [ -n "${commit_url}" ]; then printf 'Commit: %s\n' "${commit_url}"; fi)
Release Notes:
${notes}
EOF
)"

telegram_url="https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage"

# Split into chunks ≤4000 chars, breaking only on line boundaries.
send_message() {
  text="$1"
  if [ -n "${TELEGRAM_THREAD_ID:-}" ]; then
    curl -sS -X POST "${telegram_url}" \
      --data-urlencode "chat_id=${TELEGRAM_CHAT_ID}" \
      --data-urlencode "message_thread_id=${TELEGRAM_THREAD_ID}" \
      --data-urlencode "text=${text}" >/dev/null
  else
    curl -sS -X POST "${telegram_url}" \
      --data-urlencode "chat_id=${TELEGRAM_CHAT_ID}" \
      --data-urlencode "text=${text}" >/dev/null
  fi
}

chunk=""
while IFS= read -r line; do
  if [ -n "${chunk}" ]; then
    candidate="${chunk}
${line}"
  else
    candidate="${line}"
  fi

  if [ ${#candidate} -gt 4000 ]; then
    send_message "${chunk}"
    chunk="${line}"
  else
    chunk="${candidate}"
  fi
done <<EOF
${message}
EOF

[ -n "${chunk}" ] && send_message "${chunk}"

echo "Telegram notification sent"
