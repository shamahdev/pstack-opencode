#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS="$ROOT/.opencode/skills"
AGENTS="$ROOT/.opencode/agents"
PLAYBOOKS="$ROOT/.opencode/skills/poteto-mode/playbooks"
ERR=0
ok() { echo "ok - $*"; }
fail() { echo "FAIL - $*" >&2; ERR=1; }

# counts
count_skills=$(find "$SKILLS" -maxdepth 1 -mindepth 1 -type d | wc -l | tr -d ' ')
count_agents=$(find "$AGENTS" -maxdepth 1 -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
count_playbooks=$(find "$PLAYBOOKS" -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

[[ "$count_skills" -eq 45 ]] && ok "$count_skills skills" || fail "skills count=$count_skills expected 45"
[[ "$count_agents" -eq 2 ]] && ok "$count_agents agents" || fail "agents count=$count_agents expected 2"
[[ "$count_playbooks" -eq 23 ]] && ok "$count_playbooks playbooks" || fail "playbooks count=$count_playbooks expected 23"

# frontmatter validity: name + description
for d in "$SKILLS"/*/; do
  f="$d/SKILL.md"
  [[ -f "$f" ]] || { fail "missing SKILL.md in $d"; continue; }
  name_dir=$(basename "$d")
  # name must match dir and regex
  name_line=$(grep -m1 "^name:" "$f" || true)
  name_val=$(echo "$name_line" | sed 's/^name:[[:space:]]*//')
  if [[ "$name_val" != "$name_dir" ]]; then fail "name mismatch in $f: got '$name_val' want '$name_dir'"; else ok "name $name_dir"; fi
  if ! echo "$name_val" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$'; then fail "name regex fail $name_val in $f"; fi
  if ! grep -q "^description:" "$f"; then fail "missing description in $f"; fi
  # description length ≤1024
  desc=$(grep -m1 "^description:" "$f" | sed 's/^description:[[:space:]]*//')
  len=$(printf "%s" "$desc" | wc -c | tr -d ' ')
  if [[ "$len" -gt 1024 ]]; then fail "description too long ($len) in $f"; fi
done

# agents frontmatter
for f in "$AGENTS"/*.md; do
  [[ -f "$f" ]] || continue
  if ! grep -q "^description:" "$f"; then fail "agent missing description $f"; fi
  if ! grep -q "^mode:" "$f"; then fail "agent missing mode $f"; fi
done

# references existence spot checks
[[ -f "$ROOT/.opencode/skills/how/references/explorer-prompt.md" ]] && ok "how explorer-prompt" || fail "how explorer-prompt missing"
[[ -f "$ROOT/.opencode/skills/why/references/epistemics.md" ]] && ok "why epistemics" || fail "why epistemics missing"
[[ -f "$ROOT/.opencode/skills/architect/references/runner-prompt.md" ]] && ok "architect runner-prompt" || fail "architect runner-prompt missing"
[[ -f "$ROOT/.opencode/skills/interrogate/references/rubric.md" ]] && ok "interrogate rubric" || fail "interrogate rubric missing"
[[ -f "$ROOT/.opencode/skills/show-me-your-work/scripts/log.sh" ]] && ok "show-me-your-work log.sh" || fail "log.sh missing"
[[ -f "$ROOT/assets/logo.png" ]] && ok "assets/logo.png" || fail "assets/logo.png missing"
[[ -f "$ROOT/docs/guide/README.md" ]] && ok "docs/guide" || fail "docs/guide missing"
[[ -f "$ROOT/LICENSE" ]] && ok "LICENSE" || fail "LICENSE missing"
[[ -f "$ROOT/PORTING.md" ]] && ok "PORTING.md" || fail "PORTING.md missing"
[[ -f "$ROOT/opencode.json" ]] && ok "opencode.json" || fail "opencode.json missing"
[[ -f "$ROOT/package.json" ]] && ok "package.json" || fail "package.json missing"

# opencode listing if available
if command -v opencode >/dev/null 2>&1; then
  echo "--- opencode skill list (if plugin/skill path supported) ---"
  opencode skill list 2>&1 | head -n 100 || true
fi

if [[ $ERR -eq 0 ]]; then
  echo "verify-port: all checks passed"
else
  echo "verify-port: FAILED" >&2
fi
exit $ERR
