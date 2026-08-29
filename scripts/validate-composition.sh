#!/usr/bin/env bash
set -Eeuo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

product_org="hacker-house-medellin"
long_prefix="hacker-house-medellin"
allowed_classifications='^(workspace|inventory|embedded-source|experiment-reference|legacy)$'
status_code=0

while IFS= read -r manifest; do
  [[ -n "$manifest" ]] || continue
  if grep -nE "\"${product_org}/${long_prefix}-(clients|interfaces|libs?|cli|sync|infra|monorepo|mcp-server\\.rs)\"" "$manifest"; then
    echo "error: $manifest references a superseded long-name package identity" >&2
    status_code=1
  fi
done < <(find . -type f -name '.zpkg.toml' -not -path './.git/*' -print | sort)

dependencies="$(awk '
  /^[[:space:]]*\[dependencies\][[:space:]]*$/ { in_deps=1; next }
  /^[[:space:]]*\[/ { in_deps=0 }
  in_deps {
    line=$0
    sub(/^[[:space:]]*"/, "", line)
    if (line != $0) { sub(/".*/, "", line); print tolower(line) }
  }
' .zpkg.toml | sort -u)"

if git ls-files | grep -Eq '(^|/)(\.vendor/\.zed|zed_modules)(/|$)'; then
  echo 'error: materialized Zed dependencies must not be committed' >&2
  status_code=1
fi

gitlinks="$(git ls-files --stage | awk '$1 == "160000" { print $4 }')"
if [[ -n "$gitlinks" ]]; then
  if [[ ! -f .zed-submodules.tsv ]]; then
    echo 'error: gitlinks exist but .zed-submodules.tsv is missing' >&2
    status_code=1
  else
    while IFS= read -r gitlink; do
      [[ -n "$gitlink" ]] || continue
      classification="$(awk -F '\t' -v gitlink="$gitlink" '$1 == gitlink { print $2; exit }' .zed-submodules.tsv)"
      if [[ ! "$classification" =~ $allowed_classifications ]]; then
        echo "error: gitlink '$gitlink' lacks a valid classification" >&2
        status_code=1
      fi
    done <<<"$gitlinks"
  fi
fi

normalize_github_repo() {
  local value="${1%/}"
  value="${value%.git}"
  case "$value" in
    https://github.com/*) value="${value#https://github.com/}" ;;
    http://github.com/*) value="${value#http://github.com/}" ;;
    git://github.com/*) value="${value#git://github.com/}" ;;
    git@github.com:*) value="${value#git@github.com:}" ;;
    ssh://git@github.com/*) value="${value#ssh://git@github.com/}" ;;
    github.com/*) value="${value#github.com/}" ;;
    *) return 1 ;;
  esac
  [[ "$value" == */* && "$value" != */*/* ]] || return 1
  printf '%s\n' "$value" | tr '[:upper:]' '[:lower:]'
}

if [[ -f .gitmodules ]]; then
  module_count="$(git config -f .gitmodules --get-regexp '^submodule\..*\.url$' | wc -l | tr -d ' ')"
  [[ "$module_count" = 14 ]] || {
    printf 'error: expected 14 deployment gitlinks, found %s\n' "$module_count" >&2
    status_code=1
  }

  while read -r key url; do
    [[ -n "${key:-}" && -n "${url:-}" ]] || continue
    identity="$(normalize_github_repo "$url" 2>/dev/null || true)"
    if [[ "$identity" != "$product_org/"* ]]; then
      printf 'error: untrusted or cross-org submodule URL: %s\n' "$url" >&2
      status_code=1
      continue
    fi
    if grep -Fxq "$identity" <<<"$dependencies"; then
      printf "error: '%s' is both a Zed dependency and a Git submodule (%s)\n" "$identity" "$key" >&2
      status_code=1
    fi
  done < <(git config -f .gitmodules --get-regexp '^submodule\..*\.url$' || true)
fi

if (( status_code != 0 )); then
  exit "$status_code"
fi

echo 'composition policy: ok'
