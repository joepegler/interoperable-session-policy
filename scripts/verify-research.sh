#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

required_files=(
  README.md
  PLAN.md
  research/SOURCES.md
  research/FINDINGS.md
  research/STANDARDS-SHAPE.md
  research/COMPARISON.md
  research/FRAMEWORK-COMPARISON.md
  research/POLICY-CAPABILITY-UNION.md
  research/PROFILE_V0_1.md
  research/OPEN_QUESTIONS.md
  research/SOURCE_PINS.tsv
)

for required_file in "${required_files[@]}"; do
  if [[ ! -s "$required_file" ]]; then
    echo "missing or empty required file: $required_file" >&2
    exit 1
  fi
done

for executable_script in scripts/fetch-references.sh scripts/verify-markdown-links.sh scripts/verify-research.sh; do
  if [[ ! -x "$executable_script" ]]; then
    echo "script is not executable: $executable_script" >&2
    exit 1
  fi
done

bash -n scripts/*.sh

if git ls-files 'references/**' | grep -q .; then
  echo "reference checkouts must not be tracked" >&2
  exit 1
fi

if ! git check-ignore -q references; then
  echo "references/ must be ignored" >&2
  exit 1
fi

if rg -n $'\u2014' README.md PLAN.md research scripts; then
  echo "em dash found in first-party project material" >&2
  exit 1
fi

if rg -n '[[:blank:]]+$' README.md PLAN.md research scripts; then
  echo "trailing whitespace found in first-party project material" >&2
  exit 1
fi

while IFS=$'\t' read -r source_id source_url source_commit source_path; do
  [[ -z "$source_id" || "$source_id" == \#* ]] && continue
  if [[ ! "$source_url" =~ ^https://github\.com/.+\.git$ ]]; then
    echo "$source_id: invalid source URL: $source_url" >&2
    exit 1
  fi
  if [[ ! "$source_commit" =~ ^[0-9a-f]{40}$ ]]; then
    echo "$source_id: commit must be a full SHA: $source_commit" >&2
    exit 1
  fi
  if [[ ! "$source_path" =~ ^references/[A-Za-z0-9._/-]+$ ]]; then
    echo "$source_id: invalid reference path: $source_path" >&2
    exit 1
  fi
done < research/SOURCE_PINS.tsv

duplicate_ids="$(awk -F '\t' '!/^#/ && NF { print $1 }' research/SOURCE_PINS.tsv | sort | uniq -d)"
if [[ -n "$duplicate_ids" ]]; then
  echo "duplicate source IDs: $duplicate_ids" >&2
  exit 1
fi

duplicate_paths="$(awk -F '\t' '!/^#/ && NF { print $4 }' research/SOURCE_PINS.tsv | sort | uniq -d)"
if [[ -n "$duplicate_paths" ]]; then
  echo "duplicate reference paths: $duplicate_paths" >&2
  exit 1
fi

for union_heading in \
  "Candidate mandatory baseline" \
  "Candidate standard extensions" \
  "Implementation-specific capabilities" \
  "Unresolved capabilities and decisions"; do
  if ! rg -Fqx "## $union_heading" research/POLICY-CAPABILITY-UNION.md; then
    echo "missing policy-union classification: $union_heading" >&2
    exit 1
  fi
done

union_ids="$(sed -n 's/^| `\([^`]*\)` |.*/\1/p' research/POLICY-CAPABILITY-UNION.md)"
if [[ -z "$union_ids" ]]; then
  echo "policy union has no stable capability IDs" >&2
  exit 1
fi
if printf '%s\n' "$union_ids" | rg -v '^[A-Z][A-Z0-9-]*$'; then
  echo "invalid policy-union capability ID" >&2
  exit 1
fi
duplicate_union_ids="$(printf '%s\n' "$union_ids" | sort | uniq -d)"
if [[ -n "$duplicate_union_ids" ]]; then
  echo "capability appears in more than one policy-union classification: $duplicate_union_ids" >&2
  exit 1
fi

./scripts/fetch-references.sh --verify
./scripts/verify-markdown-links.sh
git diff --check
echo "research package verification passed"
