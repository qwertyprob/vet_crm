#!/bin/sh
set -eu

# Runs only on push to main (i.e. after an MR is merged).
if [ "${CI_PIPELINE_SOURCE:-}" != "push" ]; then
  echo "Skip: not a push pipeline"
  exit 0
fi

if [ "${CI_COMMIT_BRANCH:-}" != "main" ]; then
  echo "Skip: branch is not main"
  exit 0
fi

if [ -z "${TELEGRAM_BOT_TOKEN:-}" ] || [ -z "${TELEGRAM_CHAT_ID:-}" ]; then
  echo "Skip: TELEGRAM_BOT_TOKEN or TELEGRAM_CHAT_ID is not set"
  exit 0
fi

echo "New release merged to main"

version=""
if [ -f "config/version.rb" ]; then
  version="$(grep -m1 'VETCRM_VERSION' config/version.rb | sed -E 's/.*"([^"]+)".*/\1/' || true)"
fi
if [ -z "${version}" ]; then
  version="unknown"
fi

notes=""
if [ -f "CHANGELOG.md" ]; then
  notes="$(awk -v v="${version}" 'index($0, "## [" v "]") == 1 {found=1; next} /^## /{found=0} found' CHANGELOG.md | sed '/./,$!d' | head -20 || true)"
fi

if [ -z "${notes}" ]; then
  # Fallback to commit from the merged MR branch instead of merge commit message.
  if git rev-parse -q --verify HEAD^2 >/dev/null 2>&1; then
    notes="$(git log -1 --pretty=format:'%s%n%n%b' HEAD^2 || true)"
  else
    notes="$(git log -1 --pretty=format:'%s%n%n%b' HEAD || true)"
  fi
fi

notes="$(printf '%s\n' "${notes}" | head -20)"

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
