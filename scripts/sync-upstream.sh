#!/usr/bin/env bash
set -euo pipefail

# Diff local ported skills/agents against upstream raw.githubusercontent.com/cursor/plugins.
#   bash scripts/sync-upstream.sh                 # against main (default)
#   bash scripts/sync-upstream.sh --ref v0.14.7    # against any ref/branch/tag
#   bash scripts/sync-upstream.sh --pin 0.14.7     # shorthand for --ref tags/0.14.7 (see below)
# Requires curl.
#
# NOTE: upstream ships skills under the monorepo path pstack/skills. Raw tag refs
# for cursor/plugins look like <tag>/pstack/... only if the tag exists and the layout
# matches. When a pin is given we fetch from the tag; a 404 fails loudly (curl -f).

REF="main"
PIN=""

usage() { echo "usage: $0 [--ref <ref>] [--pin <tag>]"; exit 2; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ref) [[ $# -ge 2 ]] || usage; REF="$2"; shift 2 ;;
    --pin) [[ $# -ge 2 ]] || usage; PIN="$2"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "unknown arg: $1" >&2; usage ;;
  esac
done

# If a pin tag is given it overrides the ref (the tag is the thing we want to diff).
# A bare version like `0.14.7` is shorthand for `tags/0.14.7`; branches,
# full refs, and anything containing a `/` are used verbatim.
if [[ -n "$PIN" ]]; then
  if [[ "$PIN" == *"/"* || "$PIN" == "main" || "$PIN" == "master" ]]; then
    REF="$PIN"
  else
    REF="tags/$PIN"
  fi
  echo "Pinned to tag/ref: $REF (from --pin $PIN)"
else
  echo "Using ref: $REF"
fi

BASE="https://raw.githubusercontent.com/cursor/plugins/$REF/pstack"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

SKILLS=(architect arena automate-me blast-radius bro create-verification-skill figure-it-out how interrogate maintain-verification-skill make-bot-ui no-comments poteto-mode principle-boundary-discipline principle-build-the-lever principle-encode-lessons-in-structure principle-exhaust-the-design-space principle-experience-first principle-fix-root-causes principle-foundational-thinking principle-guard-the-context-window principle-laziness-protocol principle-make-operations-idempotent principle-migrate-callers-then-delete-legacy-apis principle-minimize-reader-load principle-model-the-domain principle-never-block-on-the-human principle-outcome-oriented-execution principle-prove-it-works principle-redesign-from-first-principles principle-separate-before-serializing-shared-state principle-sequence-verifiable-units principle-subtract-before-you-add principle-type-system-discipline recall reflect setup-pstack show-me-your-work swarm tdd teach technical-writing typescript-best-practices unslop why)

echo "Fetching skills from $BASE ..."
for s in "${SKILLS[@]}"; do
  if curl -sfL "$BASE/skills/$s/SKILL.md" -o "$TMP/$s.md"; then
    :
  else
    echo "MISS upstream skill: $s (ref=$REF)"
  fi
done

echo "--- SHA diff (upstream vs local) ---"
for s in "${SKILLS[@]}"; do
  up="$TMP/$s.md"
  loc=".opencode/skills/$s/SKILL.md"
  if [[ ! -f "$loc" ]]; then
    echo "MISSING local skill: $s"
    continue
  fi
  if [[ ! -f "$up" ]]; then
    echo "NO-UPSTREAM skill: $s"
    continue
  fi
  sha_up=$(shasum "$up" | cut -d' ' -f1)
  sha_loc=$(shasum "$loc" | cut -d' ' -f1)
  if [[ "$sha_up" != "$sha_loc" ]]; then
    echo "DIFF $s (up=$sha_up loc=$sha_loc)"
  else
    echo "SAME $s"
  fi
done

echo "--- Agents ---"
for a in poteto-agent comment-sicko; do
  if curl -sfL "$BASE/agents/$a.md" -o "$TMP/$a.md"; then
    loc=".opencode/agents/$a.md"
    if [[ -f "$loc" ]]; then
      echo "agent $a up=$(shasum "$TMP/$a.md" | cut -d' ' -f1) loc=$(shasum "$loc" | cut -d' ' -f1)"
    else
      echo "MISSING local agent: $a"
    fi
  else
    echo "MISS upstream agent: $a (ref=$REF)"
  fi
done

echo
echo "Tip: after bulk-copying updated files, re-apply the PORTING.md allowlist"
echo "(name injection, provider/model-id mapping, ~/.cursor -> opencode paths)."
