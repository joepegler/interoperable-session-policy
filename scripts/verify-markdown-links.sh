#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

documents=(README.md PLAN.md research)
failures=0
local_links=0
evidence_links=0

heading_exists() {
  local target="$1"
  local expected_slug="$2"
  local heading
  local slug

  while IFS= read -r heading; do
    slug="$(
      printf '%s\n' "$heading" |
        sed -E 's/^#{1,6}[[:space:]]+//; s/<[^>]*>//g; s/[^[:alnum:] _-]//g; s/[[:space:]]+/-/g' |
        tr '[:upper:]' '[:lower:]'
    )"
    if [[ "$slug" == "$expected_slug" ]]; then
      return 0
    fi
  done < <(rg '^#{1,6}[[:space:]]+' "$target" || true)

  return 1
}

while IFS=: read -r source link; do
  [[ "$link" == http://* || "$link" == https://* || "$link" == mailto:* ]] && continue

  clean="${link%%#*}"
  fragment=""
  if [[ "$link" == *'#'* ]]; then
    fragment="${link#*#}"
  fi

  if [[ -z "$clean" ]]; then
    target="$source"
  else
    target="$(dirname "$source")/$clean"
  fi

  local_links=$((local_links + 1))
  if [[ ! -f "$target" ]]; then
    echo "missing local link: $source -> $link" >&2
    failures=$((failures + 1))
    continue
  fi
  if [[ -n "$fragment" ]] && ! heading_exists "$target" "$fragment"; then
    echo "missing local heading: $source -> $link" >&2
    failures=$((failures + 1))
  fi
done < <(
  rg --with-filename -o --pcre2 '\]\(\K(?!https?://|mailto:)[^)[:space:]]+' "${documents[@]}" || true
)

while IFS= read -r link; do
  clean="${link%%#*}"
  fragment=""
  if [[ "$link" == *'#'* ]]; then
    fragment="${link#*#}"
  fi

  repo_path="${clean#https://github.com/}"
  owner="${repo_path%%/*}"
  rest="${repo_path#*/}"
  repo="${rest%%/*}"
  tail="${rest#*/}"
  kind="${tail%%/*}"
  [[ "$kind" == "blob" || "$kind" == "tree" ]] || continue

  revision_and_path="${tail#*/}"
  revision="${revision_and_path%%/*}"
  [[ "$revision" =~ ^[0-9a-f]{40}$ ]] || continue

  relative=""
  if [[ "$revision_and_path" == */* ]]; then
    relative="${revision_and_path#*/}"
  fi
  source_url="https://github.com/$owner/$repo.git"
  checkout="$(
    awk -F '\t' -v url="$source_url" -v commit="$revision" \
      '$2 == url && $3 == commit { print $4; exit }' research/SOURCE_PINS.tsv
  )"

  evidence_links=$((evidence_links + 1))
  if [[ -z "$checkout" ]]; then
    echo "unpinned exact-revision link: $link" >&2
    failures=$((failures + 1))
    continue
  fi

  target="$checkout"
  if [[ -n "$relative" ]]; then
    target="$checkout/$relative"
  fi
  if [[ "$kind" == "blob" && ! -f "$target" ]]; then
    echo "missing linked file: $link" >&2
    failures=$((failures + 1))
    continue
  fi
  if [[ "$kind" == "tree" && ! -d "$target" ]]; then
    echo "missing linked tree: $link" >&2
    failures=$((failures + 1))
    continue
  fi

  if [[ "$kind" == "blob" && "$fragment" =~ ^L([0-9]+)(-L([0-9]+))?$ ]]; then
    last_line="${BASH_REMATCH[3]:-${BASH_REMATCH[1]}}"
    available_lines="$(wc -l < "$target" | tr -d ' ')"
    if ((last_line > available_lines)); then
      echo "line anchor outside linked file ($available_lines lines): $link" >&2
      failures=$((failures + 1))
    fi
  elif [[ "$kind" == "blob" && -n "$fragment" ]] && ! heading_exists "$target" "$fragment"; then
    echo "missing linked heading: $link" >&2
    failures=$((failures + 1))
  fi
done < <(
  rg -o --no-filename 'https://github\.com/[^)>[:space:]]+' "${documents[@]}" | sort -u
)

if ((failures > 0)); then
  exit 1
fi

echo "$local_links local Markdown links and anchors verified"
echo "$evidence_links pinned GitHub paths and anchors verified"
