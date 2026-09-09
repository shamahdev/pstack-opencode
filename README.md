# pstack-opencode

> **Ported to opencode** from [`cursor/plugins/tree/main/pstack`](https://github.com/cursor/plugins/tree/main/pstack) v0.14.7 MIT — author Lauren Tan. The pstack philosophy stays the same: *if you want to go fast, go deep first.* This turns opencode into a rigorous engineering team you can parallelize with confidence.

Original upstream README lives at [`/tmp/pstack-upstream/README.md`](https://github.com/cursor/plugins/tree/main/pstack#readme). See `PORTING.md` for the exact delta between Cursor and opencode.

## Install

**Option A — vendor (simplest):**

```bash
# from this repo root, copy skills + agents into your project
cp -r .opencode/skills .opencode/agents /path/to/your/project/.opencode/
# or global
cp -r .opencode/skills ~/.config/opencode/skills/
cp -r .opencode/agents ~/.config/opencode/agents/
```

**Option B — as an opencode plugin (npm):**

```json
// opencode.json
{ "plugin": ["pstack-opencode"] }
```

```bash
bun install pstack-opencode  # or npm
```

Both ship the same files; pick one.

## Get started

1. Run `setup-pstack` and choose which models you want:

```
skill("setup-pstack")
```

It detects `opencode models` and writes `pstack.models` to `opencode.json` (project root) or `~/.config/opencode/opencode.json` (global) — your choice. Re-run anytime.

2. Use `poteto-mode` whenever you need rigor:

```
skill("poteto-mode")
# or slash alias if enabled: /poteto-mode
```

New here? `docs/guide/README.md` walks through a first real task.

The mode is sticky — once entered it stays on across turns and routes to playbooks automatically. Say "opt out of poteto-mode" to leave.

## Usage

```
skill("poteto-mode") — drive any non-trivial task: the skill picks one of 23 playbooks, opens a todo list, and routes to the other skills.
skill("how")         — how does X work?
skill("why")         — why was X built that way? (7 parallel evidence streams)
skill("architect")   — settle callers/types/shape before crossing a function boundary
skill("arena")       — N parallel attempts, cross-judge, graft the best
skill("swarm")       — N workers across slices/races, one aggregated report
skill("interrogate") — 4-model adversarial review
skill("tdd")         — cheap local test → failing test first
```

Full skill list: 45 skills under `.opencode/skills/` (including 21 `principle-*` leaf skills), 2 agents under `.opencode/agents/` (`poteto-agent`, `comment-sicko`), 23 playbooks under `.opencode/skills/poteto-mode/playbooks/`.

## Skills table

| Skill | When |
|-------|------|
| `poteto-mode` | default entry point for any non-trivial task |
| `setup-pstack` | pick models per role (writes `opencode.json`) |
| `how` / `why` / `recall` / `teach` / `blast-radius` | investigation & rationale |
| `architect` / `arena` / `swarm` / `interrogate` / `figure-it-out` / `tdd` | design & execution |
| `unslop` / `technical-writing` / `no-comments` / `typescript-best-practices` / `bro` | quality & prose |
| `reflect` / `show-me-your-work` / `automate-me` / `make-bot-ui` / `create-verification-skill` / `maintain-verification-skill` | process & meta |
| `principle-*` (21) | leaf principles indexed by `poteto-mode` |

See upstream [`pstack` README](https://github.com/cursor/plugins/tree/main/pstack) for the 23 playbooks and 21 principles in detail.

## Agents

- `poteto-agent` (`mode: subagent`) — routing target for `poteto-mode`. Reads `poteto-mode` in full before any work. Invoke via `Task` with `agent: "poteto-agent"`.
- `comment-sicko` (`mode: subagent`) — read-only comment reviewer, usually via `skill("no-comments")`.

## Not shipped here

Same as upstream: `automations/benny` (dormant Slack automation; would need Slack infra) and `cursor-team-kit` complements (`deslop`, `control-cli`, `control-ui`) are not bundled. `PORTING.md` tracks them as follow-ups.

## Verify the port

```bash
bash scripts/verify-port.sh
bash scripts/sync-upstream.sh  # optional: diff against upstream
```

## Make it yours

Run `skill("automate-me")` — mines your transcripts and drafts a `<handle>-mode` skill routing through pstack — same as upstream.

## License

MIT — see `LICENSE` (upstream, retained verbatim).
