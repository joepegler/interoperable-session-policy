#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
pins_file="$repo_root/research/SOURCE_PINS.tsv"
verify_only=false

if [[ "${1:-}" == "--verify" ]]; then
  verify_only=true
elif [[ $# -ne 0 ]]; then
  echo "usage: $0 [--verify]" >&2
  exit 2
fi

normalise_github_url() {
  local value="$1"
  if [[ "$value" == git@github.com:* ]]; then
    value="https://github.com/${value#git@github.com:}"
  fi
  printf '%s\n' "$value"
}

public_git() {
  GIT_CONFIG_GLOBAL=/dev/null git "$@"
}

if [[ ! -f "$pins_file" ]]; then
  echo "missing source manifest: $pins_file" >&2
  exit 1
fi

verify_checkout() {
  local source_id="$1"
  local expected_url="$2"
  local expected_commit="$3"
  local relative_path="$4"
  local destination="$repo_root/$relative_path"
  local actual_commit
  local actual_url

  if [[ ! -d "$destination/.git" && ! -f "$destination/.git" ]]; then
    echo "$source_id: missing checkout at $relative_path" >&2
    return 1
  fi

  if [[ -n "$(git -C "$destination" status --short)" ]]; then
    echo "$source_id: checkout is dirty at $relative_path" >&2
    return 1
  fi

  actual_commit="$(git -C "$destination" rev-parse HEAD)"
  actual_url="$(git -C "$destination" remote get-url origin)"
  if [[ "$actual_commit" != "$expected_commit" ]]; then
    echo "$source_id: expected $expected_commit, found $actual_commit" >&2
    return 1
  fi
  if [[ "$(normalise_github_url "$actual_url")" != "$(normalise_github_url "$expected_url")" ]]; then
    echo "$source_id: expected origin $expected_url, found $actual_url" >&2
    return 1
  fi

  echo "$source_id: verified $expected_commit"
}

mkdir -p "$repo_root/references"

while IFS=$'\t' read -r source_id source_url source_commit source_path; do
  [[ -z "$source_id" || "$source_id" == \#* ]] && continue

  destination="$repo_root/$source_path"
  if [[ "$verify_only" == true ]]; then
    verify_checkout "$source_id" "$source_url" "$source_commit" "$source_path"
    continue
  fi

  if [[ -d "$destination/.git" || -f "$destination/.git" ]]; then
    if [[ -n "$(git -C "$destination" status --short)" ]]; then
      echo "$source_id: refusing to change dirty checkout at $source_path" >&2
      exit 1
    fi
    if [[ "$(normalise_github_url "$(git -C "$destination" remote get-url origin)")" != "$(normalise_github_url "$source_url")" ]]; then
      echo "$source_id: origin mismatch at $source_path" >&2
      exit 1
    fi
  elif [[ -e "$destination" ]]; then
    echo "$source_id: destination exists but is not a Git checkout: $source_path" >&2
    exit 1
  else
    public_git clone --filter=blob:none --no-checkout "$source_url" "$destination"
  fi

  public_git -C "$destination" fetch --filter=blob:none "$source_url" "$source_commit"
  git -C "$destination" checkout --detach "$source_commit"
  verify_checkout "$source_id" "$source_url" "$source_commit" "$source_path"
done < "$pins_file"
