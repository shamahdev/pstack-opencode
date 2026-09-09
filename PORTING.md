# pstack-opencode porting notes

**Source:** [`cursor/plugins/tree/main/pstack`](https://github.com/cursor/plugins/tree/main/pstack) `v0.14.7` MIT, author Lauren Tan.  
**This repo:** `pstack-opencode` — same content adapted for [opencode](https://opencode.ai).

## What changed (allowlist)

Mechanical edits only — everything else is verbatim. Re-apply on upstream sync.

| Area | Cursor (upstream) | opencode (this port) |
|------|-------------------|----------------------|
| Skill frontmatter | may omit `name`, may exceed 1024 chars, uses `disable-model-invocation` etc. | injected `name: <dirname>` (regex `^[a-z0-9]+(-[a-z0-9]+)*$`), trimmed `description` ≤1024. Unknown keys kept (opencode ignores them). |
| Agents | `is_background:true`, `subagent_type: "poteto-agent"`, `subagent_type: general` + `readonly`, `run_in_background`, `environment: "cloud"/"local"`, `cloud_base_branch` | `.opencode/agents/*.md` with `mode: subagent`, `description` required, invoked via `Task` `agent:"poteto-agent"` / `agent:"comment-sicko"`; skills use `agent: general` (full access) vs `agent: explore` (read-only) instead of `subagent_type`/`readonly`; no `environment`/`run_in_background`/`cloud_base_branch` (local worktrees/branches); agent `color` must be a hex or theme token (`warning`/`error`/etc.), not CSS names (`yellow`/`red`). |
| Model IDs | `claude-fable-5-1-thinking-max`, `grok-4.6-fast-xhigh`, `gpt-5.6-sol-max`, `claude-opus-5-thinking-xhigh` | `anthropic/claude-opus-4-20250514`, `xai/grok-4-fast`, `openai/gpt-5.1-codex`, `anthropic/claude-opus-4-20250514`. Fallback = parent session model (`inherit-parent`/`auto` → omit Task `model`). |
| Config path | `~/.cursor/rules/pstack-models.mdc` (`alwaysApply:true`, one line per role) | JSON at `opencode.json` (project root) or `~/.config/opencode/opencode.json` (global) under `pstack.models` (see `setup-pstack` skill). `setup-pstack` asks Project vs Global and merges. |
| Verification skill output | `.cursor/skills/verify-<app>/SKILL.md` | `.opencode/skills/verify-<app>/SKILL.md` (compat alias `.claude/skills/verify-<app>` also scanned) |
| Plugin install | `/add-plugin pstack` | copy `.opencode/skills/`+`.opencode/agents/` or `opencode.json` `plugin: ["pstack-opencode"]` |
| Paths | `~/.cursor/projects/<slug>/agent-transcripts/`, `~/.cursor/` | `~/.config/opencode/projects/`, `~/.config/opencode/` |
| Not ported | — | `automations/benny` (Slack triage), `cursor-team-kit` complement (`deslop`, `control-cli`, `control-ui`) — documented as follow-up. Where playbooks name them, they are optional: use `/unslop` for `/deslop`, and the repo's `verify-*` skill or manual live run for `control-*`. Upstream notes "not shipped here". |
| Banner | — | `poteto-mode` SKILL.md has a port banner linking upstream. |
| Project config | — | root `opencode.json` ships `permission.skill.*: allow` + `instructions: [poteto-mode]` so skills load without prompts. `pstack.models` is absent until `setup-pstack` writes it; skills use inline defaults meanwhile. |
| Toolchain | — | `.opencode/package.json` + lockfile vendor `@opencode-ai/plugin` for local checks; `node_modules/` is gitignored and not part of the port. |

## Model mapping table

This table is the static port default. Confirm every slug via `opencode models` before use; `setup-pstack` does not edit this file — it writes confirmed `pstack.models` to project `opencode.json` or global `~/.config/opencode/opencode.json`, which overrides these defaults at runtime per role.

- `claude-fable-5-1-thinking-max` → `anthropic/claude-opus-4-20250514`
- `grok-4.6-fast-xhigh` / `grok-4.6-fast` → `xai/grok-4-fast`
- `gpt-5.6-sol-max` → `openai/gpt-5.1-codex`
- `claude-opus-5-thinking-xhigh` → `anthropic/claude-opus-4-20250514`

## Verifying the port

Run `bash scripts/verify-port.sh` — asserts 45 skills, 2 agents, 23 playbooks and frontmatter validity; prints `opencode skill list` opportunistically when `opencode` is installed (no assertion). See `scripts/sync-upstream.sh` for diffing against upstream at a pinned tag.

## Syncing upstream

```bash
bash scripts/sync-upstream.sh                # diffs against main
bash scripts/sync-upstream.sh --ref main     # explicit ref
bash scripts/sync-upstream.sh --pin <tag>    # diffs against that tag/ref (only when upstream has it)
```

`--pin` overrides `--ref` and is the way to diff a pinned tag. A missing tag/ref fails loudly (the script uses `curl -f`). Note: bare version tags such as `0.14.7` currently 404 upstream; `main` is the verified working ref.

Re-apply the allowlist above after bulk-copying updated files from `https://raw.githubusercontent.com/cursor/plugins/main/pstack`.
