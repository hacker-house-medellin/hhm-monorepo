#!/usr/bin/env bash
set -Eeuo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

[[ -f .zpkg.toml ]] || { echo 'missing .zpkg.toml' >&2; exit 1; }
[[ -f .gitmodules ]] || { echo 'missing .gitmodules' >&2; exit 1; }
[[ -f .zed-submodules.tsv ]] || { echo 'missing .zed-submodules.tsv' >&2; exit 1; }

dependencies="$({ awk '
  /^[[:space:]]*\[dependencies\][[:space:]]*$/ { in_deps=1; next }
  /^[[:space:]]*\[/ { in_deps=0 }
  in_deps {
    line=$0
    sub(/^[[:space:]]*"/, "", line)
    if (line != $0) { sub(/".*/, "", line); print tolower(line) }
  }
' .zpkg.toml; } | sort -u)"

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

allowed_classifications='^(workspace|inventory|embedded-source|experiment-reference|legacy)$'
module_count="$(git config -f .gitmodules --get-regexp '^submodule\..*\.url$' | wc -l | tr -d ' ')"
classification_count="$(awk -F '\t' 'NF == 2 && $1 !~ /^#/ { count += 1 } END { print count + 0 }' .zed-submodules.tsv)"

[[ "$module_count" = 14 ]] || {
  printf 'expected 14 deployment submodules, found %s\n' "$module_count" >&2
  exit 1
}
[[ "$classification_count" = "$module_count" ]] || {
  printf 'expected one classification for each submodule: %s modules, %s classifications\n' "$module_count" "$classification_count" >&2
  exit 1
}

while read -r key url; do
  [[ -n "${key:-}" && -n "${url:-}" ]] || continue
  path_key="${key#submodule.}"
  path_key="${path_key%.url}"
  module_path="$(git config -f .gitmodules --get "submodule.${path_key}.path")"
  identity="$(normalize_github_repo "$url" 2>/dev/null || true)"
  [[ -n "$identity" ]] || {
    printf 'unsupported submodule URL: %s\n' "$url" >&2
    exit 1
  }
  classification="$(awk -F '\t' -v module_path="$module_path" '$1 == module_path { print $2; exit }' .zed-submodules.tsv)"
  [[ "$classification" =~ $allowed_classifications ]] || {
    printf 'submodule %s lacks a valid classification\n' "$module_path" >&2
    exit 1
  }
  if grep -Fxq "$identity" <<<"$dependencies"; then
    printf '%s is represented both as a Zed dependency and a Git submodule (%s)\n' "$identity" "$key" >&2
    exit 1
  fi
done < <(git config -f .gitmodules --get-regexp '^submodule\..*\.url$')

while IFS=$'\t' read -r module_path classification; do
  [[ -n "${module_path:-}" ]] || continue
  [[ "$classification" =~ $allowed_classifications ]] || {
    printf 'invalid classification for %s: %s\n' "$module_path" "$classification" >&2
    exit 1
  }
  git config -f .gitmodules --get-regexp '^submodule\..*\.path$' | awk '{ print $2 }' | grep -Fxq "$module_path" || {
    printf 'classification references no submodule: %s\n' "$module_path" >&2
    exit 1
  }
done < .zed-submodules.tsv

printf 'Zed/submodule ownership contract validated\n'
