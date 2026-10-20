#!/usr/bin/env bash
#
# release-notes.sh -- release notes for an Entando platform release.
#
# Compares the images pinned in namespace-resources.yaml and the tools pinned in
# manifest with the ones of the previous release tag and, for every component
# whose version moved, collects the GitHub release notes of each version it went
# through (previous, current].
# Prints Markdown ready to paste into the GitHub release of this repository.
#
#   script/release-notes.sh                  # working tree vs the last release tag
#   script/release-notes.sh v7.5.3           # tag (or commit) vs the release before it
#   script/release-notes.sh v7.5.3 v7.5.1    # explicit range
#   script/release-notes.sh --all ...        # keep version-bump entries too
#
# A release tag that does not exist yet stands for HEAD, so the notes of the
# next release can be drafted on its branch and still link to its future tag.
# Without a release argument the dist/ in the working tree is used, so notes can
# be drafted right after ./build.sh, before committing; the title then comes
# from ENTANDO_RELEASE in ./manifest.
#
# GitHub is queried anonymously (60 requests/hour) unless GITHUB_TOKEN/GH_TOKEN
# is set or `gh` is logged in.
set -euo pipefail

usage() {
  # The header comment block, minus the shebang, is the help text.
  awk 'NR>1 && /^#/ { sub(/^# ?/, ""); print; next } NR>1 { exit }' "$0"
  exit "${1:-0}"
}

KEEP_ALL=""
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage 0 ;;
    --all) KEEP_ALL=1; shift ;;
    -*) echo "unknown option: $1" >&2; usage 1 ;;
    *) break ;;
  esac
done

command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }

cd "$(dirname "${BASH_SOURCE[0]}")/.."

RESOURCES="dist/ge-1-1-6/namespace-scoped-deployment/namespace-resources.yaml"
PROJECT_URL="https://github.com/entando/entando-releases"

# ------------------------------------------------------------ image → repo
# GitHub repository that publishes the release notes of each image. Images
# that map to nothing are still listed, just without notes.
#   entando-de-app-*  7.x is built from app-engine (entando-de-app is 6.x only)
repo_for() {
  case "$1" in
    app-builder)               echo "entando/app-builder" ;;
    entando-component-manager) echo "entando-k8s/entando-component-manager" ;;
    entando-de-app-*)          echo "entando/app-engine" ;;
    entando-keycloak)          echo "entando/entando-keycloak" ;;
    entando-k8s-*)             echo "entando-k8s/$1" ;;
    entando-cli|entando-bundler|entando-bundle-cli|generator-jhipster-entando)
                               echo "entando/$1" ;;
    *)                         echo "" ;;
  esac
}

# Images left out of the notes: entando-redhat-sso is built from
# entando-keycloak and always moves with it.
SKIP_IMAGES=" entando-redhat-sso "

# Entries that only announce a version bump, dropped unless --all is given.
NOISE_RE='chore\(release\)|[Bb]ump(ing|ed)? (the )?(entando-[a-z-]+ )?version|[Bb]ump to (version )?v?[0-9]'

# ------------------------------------------------------------- release range
NEW_TAG="${1:-}"
if [ -z "$NEW_TAG" ]; then
  NEW_REF=""                                     # working tree
  NEW_TAG=$(sed -nE 's/^ENTANDO_RELEASE="?([^"]+)"?.*/\1/p' manifest)
  END="HEAD"
elif git rev-parse -q --verify "${NEW_TAG}^{commit}" >/dev/null; then
  NEW_REF="$NEW_TAG"
  END="$NEW_TAG"
else
  NEW_REF="HEAD"                                 # a tag not created yet
  END="HEAD"
fi

last_release() {
  git describe --tags --abbrev=0 --match 'v[0-9]*.[0-9]*.[0-9]*' --exclude '*-*' "$1" 2>/dev/null || true
}

PREV_TAG="${2:-}"
if [ -z "$PREV_TAG" ]; then
  PREV_TAG=$(last_release "$END")
  # Already tagged: the range starts at the release before.
  [ "$PREV_TAG" = "$NEW_TAG" ] && PREV_TAG=$(last_release "${NEW_TAG}^")
fi
[ -n "$PREV_TAG" ] || { echo "no previous release tag found; pass it explicitly" >&2; exit 1; }
git rev-parse -q --verify "${PREV_TAG}^{commit}" >/dev/null \
  || { echo "not a commit, tag or branch: ${PREV_TAG}" >&2; exit 1; }

# --------------------------------------------------------------- image lists
resources_at() {
  if [ -n "$1" ]; then git show "$1:$RESOURCES"; else cat "$RESOURCES"; fi
}

# key<TAB>org/image<TAB>version, from the entando-docker-image-info ConfigMap
# and from the operator's own container images. A container image reuses the
# ConfigMap key named like it, so entando-k8s-service is listed once.
images_at() {
  resources_at "$1" | awk '
    function field(s, name,   re) {
      re = "\"" name "\":\"[^\"]*\""
      if (!match(s, re)) return ""
      s = substr(s, RSTART, RLENGTH)
      sub("^\"" name "\":\"", "", s); sub(/"$/, "", s)
      return s
    }
    function put(key, image, version) {
      if (!(key in seen)) order[++n] = key
      seen[key] = image "\t" version
    }
    function container(ref,   image, version) {
      gsub(/["[:space:]]/, "", ref)
      sub(/^[^\/]*\.[^\/]*\//, "", ref)         # drop a registry host
      version = ref; sub(/.*:/, "", version)
      image = ref;   sub(/:[^:]*$/, "", image)
      key = image;   sub(/.*\//, "", key)
      put(key, image, version)
    }
    /^kind:/                           { configmap = ($2 == "ConfigMap") }
    configmap && /^  [A-Za-z0-9.-]+:/  { key = $1; sub(/:$/, "", key); next }
    configmap && key && /"version"/ {
      image = field($0, "repository"); if (image == "") image = key
      put(key, field($0, "organization") "/" image, field($0, "version"))
      key = ""; next
    }
    pending                            { container($0); pending = 0; next }
    /^[[:space:]]+image:[[:space:]]*>-[[:space:]]*$/ { pending = 1; next }
    /^[[:space:]]+image:/              { sub(/^[[:space:]]+image:/, ""); container($0) }
    END { for (i = 1; i <= n; i++) print order[i] "\t" seen[order[i]] }
  ' | while IFS=$'\t' read -r key image version; do
    [[ "$SKIP_IMAGES" == *" ${image##*/} "* ]] || printf '%s\t%s\t%s\n' "$key" "$image" "$version"
  done
}

manifest_at() {
  if [ -n "$1" ]; then git show "$1:manifest"; else cat manifest; fi
}

# The same records for the Entando tools pinned in the manifest.
tools_at() {
  manifest_at "$1" | awk -F= '
    BEGIN {
      tool["ENTANDO_CLI_VERSION"]                = "entando-cli"
      tool["VER_ENTANDO_BUNDLER_DEF"]            = "entando-bundler"
      tool["VER_ENTANDO_BUNDLE_CLI_DEF"]         = "entando-bundle-cli"
      tool["VER_GENERATOR_JHIPSTER_ENTANDO_DEF"] = "generator-jhipster-entando"
    }
    $1 in tool {
      version = $2; gsub(/["[:space:]]/, "", version); sub(/^v/, "", version)
      print tool[$1] "\tentando/" tool[$1] "\t" version
    }
  '
}

components_at() {
  images_at "$1"
  tools_at "$1"
}

declare -A OLD_IMAGE OLD_VERSION
while IFS=$'\t' read -r key image version; do
  OLD_IMAGE[$key]="$image"; OLD_VERSION[$key]="$version"
done < <(components_at "$PREV_TAG")

CHANGED=()     # key<TAB>image<TAB>old<TAB>new
ADDED=()       # key<TAB>image<TAB>new
declare -A NEW_KEYS
while IFS=$'\t' read -r key image version; do
  NEW_KEYS[$key]=1
  if [ -z "${OLD_VERSION[$key]+x}" ]; then
    ADDED+=("${key}"$'\t'"${image}"$'\t'"${version}")
  elif [ "${OLD_VERSION[$key]}" != "$version" ] || [ "${OLD_IMAGE[$key]}" != "$image" ]; then
    CHANGED+=("${key}"$'\t'"${image}"$'\t'"${OLD_VERSION[$key]}"$'\t'"${version}")
  fi
done < <(components_at "$NEW_REF")

REMOVED=()     # key<TAB>image<TAB>old
for key in "${!OLD_VERSION[@]}"; do
  [ -n "${NEW_KEYS[$key]+x}" ] || REMOVED+=("${key}"$'\t'"${OLD_IMAGE[$key]}"$'\t'"${OLD_VERSION[$key]}")
done

# -------------------------------------------------------------------- GitHub
TOKEN="${GITHUB_TOKEN:-${GH_TOKEN:-}}"
if [ -z "$TOKEN" ] && command -v gh >/dev/null && gh auth status >/dev/null 2>&1; then
  TOKEN=$(gh auth token 2>/dev/null || true)
fi

CACHE=$(mktemp -d)
trap 'rm -rf "$CACHE"' EXIT

# Downloads the releases of a repository once. Runs in the main shell, so a
# failure stops the script rather than leaving holes in the notes; only a
# repository that does not exist is tolerated, as one without releases.
fetch_releases() {
  local file="$CACHE/${1//\//_}.json" status reset
  [ -f "$file" ] && return
  status=$(curl -sSL -o "$file" -D "$file.headers" -w '%{http_code}' \
                -H "Accept: application/vnd.github+json" \
                ${TOKEN:+-H "Authorization: Bearer $TOKEN"} \
                "https://api.github.com/repos/$1/releases?per_page=100") || status=000
  case "$status" in
    200) ;;
    404) echo "warning: repository $1 not found" >&2; echo "[]" >"$file" ;;
    *)
      echo "cannot read the releases of $1: HTTP ${status} $(jq -r '.message // empty' "$file" 2>/dev/null)" >&2
      reset=$(sed -nE 's/^x-ratelimit-reset:[[:space:]]*([0-9]+).*/\1/Ip' "$file.headers" 2>/dev/null)
      if grep -qiE '^x-ratelimit-remaining:[[:space:]]*0' "$file.headers" 2>/dev/null; then
        echo "GitHub API rate limit exhausted until $(date -d "@${reset}" '+%H:%M'); set GITHUB_TOKEN or run 'gh auth login'" >&2
      fi
      exit 1 ;;
  esac
}

# Published (non-draft, non-prerelease) releases of a repository, as JSON.
releases_of() {
  cat "$CACHE/${1//\//_}.json"
}

# a > b, in version order (7.5.0 < 7.5.0-fix.1 < 7.5.1).
ver_gt() {
  [ "$1" != "$2" ] && [ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | tail -1)" = "$1" ]
}

# The release tags of a repository in (old, new], oldest first.
tags_between() {
  local repo=$1 old=${2#v} new=${3#v} tag v
  releases_of "$repo" \
    | jq -r '.[] | select((.draft or .prerelease) | not) | .tag_name' \
    | grep -E '^v?[0-9]+\.[0-9]+\.[0-9]+(-(hot)?fix\.[0-9]+)?$' \
    | while read -r tag; do
        v=${tag#v}
        if ver_gt "$v" "$old" && ! ver_gt "$v" "$new"; then printf '%s\t%s\n' "$v" "$tag"; fi
      done \
    | sort -V | cut -f2
}

# The change entries of one release as title<TAB>author<TAB>url, from the
# "* title by @author in url" bullets of its notes, leaving out the "New
# Contributors" section and, unless --all, the version bumps.
changes_of() {
  releases_of "$1" \
    | jq -r --arg t "$2" '.[] | select(.tag_name == $t) | .body // ""' | tr -d '\r' \
    | awk '
        /^#+[[:space:]]*New Contributors/ { skip = 1; next }
        /^#/                              { skip = 0; next }
        !skip && /^[*-][[:space:]]/       { print }
      ' \
    | { if [ -n "$KEEP_ALL" ]; then cat; else grep -Ev "$NOISE_RE" || true; fi; } \
    | sed -nE 's/^[*-][[:space:]]+(.*[^[:space:]])[[:space:]]+by @([^[:space:]]+) in (https:[^[:space:]]+)[[:space:]]*$/\1\t\2\t\3/p'
}

# --------------------------------------------------------------------- notes
CHANGES="$CACHE/changes.tsv"
: >"$CHANGES"
TABLE=()

for row in ${CHANGED[@]+"${CHANGED[@]}"}; do
  IFS=$'\t' read -r key image old new <<<"$row"
  name=${image##*/}
  repo=$(repo_for "$name")
  component="$name" to="**${new}**" notes="—"

  if [ -n "$repo" ]; then
    component="[${name}](https://github.com/${repo})"
    if ver_gt "$old" "$new"; then
      to="**${new}** (downgrade)"
    else
      fetch_releases "$repo"
      tags=$(tags_between "$repo" "$old" "$new")
      if [ -n "$tags" ]; then
        to="[**${new}**](https://github.com/${repo}/compare/v${old}...v${new})"
        notes=""
        while read -r tag; do
          notes+="${notes:+ · }[${tag}](https://github.com/${repo}/releases/tag/${tag})"
          changes_of "$repo" "$tag" >>"$CHANGES"
        done <<<"$tags"
      fi
    fi
  fi
  TABLE+=("| ${component} | ${old} | ${to} | ${notes} |")
done
for row in ${ADDED[@]+"${ADDED[@]}"}; do
  IFS=$'\t' read -r key image new <<<"$row"
  TABLE+=("| ${image##*/} | _new_ | **${new}** | — |")
done
for row in ${REMOVED[@]+"${REMOVED[@]}"}; do
  IFS=$'\t' read -r key image old <<<"$row"
  TABLE+=("| ${image##*/} | ${old} | _removed_ | — |")
done

echo "## What's Changed"
echo
if [ ${#TABLE[@]} -eq 0 ]; then
  echo "No platform image changed since ${PREV_TAG}."
else
  echo "| Component | ${PREV_TAG} | ${NEW_TAG} | Release notes |"
  echo "|---|---|---|---|"
  printf '%s\n' "${TABLE[@]}"
fi

# One line per change: the same PR title landing in several repositories, as
# a sync or a dependency update does, is listed once with all its PRs.
if [ -s "$CHANGES" ]; then
  echo
  echo "### Changes"
  echo
  awk -F'\t' '
    function label(url,   p) {
      split(url, p, "/")                      # https: "" github.com org repo pull N
      return p[6] == "pull" ? p[5] "#" p[7] : p[5]
    }
    {
      title = $1; gsub(/[[:space:]]+/, " ", title)
      k = tolower(title)
      if (!(k in titles)) { order[++n] = k; titles[k] = title }
      if (index(" " authors[k] " ", " @" $2 " ") == 0) authors[k] = authors[k] (authors[k] ? " " : "") "@" $2
      links[k] = links[k] (links[k] ? ", " : "") "[" label($3) "](" $3 ")"
    }
    END {
      for (i = 1; i <= n; i++) {
        k = order[i]
        a = authors[k]; gsub(/ /, ", ", a)
        printf "* %s by %s in %s\n", titles[k], a, links[k]
      }
    }
  ' "$CHANGES"
fi

echo
echo "**Full Changelog**: ${PROJECT_URL}/compare/${PREV_TAG}...${NEW_TAG}"
