---

name: setup-pstack
description: Configure which models pstack uses per role. Detects your available models and writes an always-applied rule that overrides the skill defaults. Use for /setup-pstack, "configure pstack models", or changing pstack's model choices.
---
# Setup pstack

Write `opencode.json` (`opencode.json` project root or `~/.config/opencode/opencode.json` global), a JSON model map that overrides the skill defaults that sets pstack's model per role. The skills read it and fall back to their inline defaults when a line is absent, so this is an override layer, not a requirement.

## Steps

### 1. Detect available models

Run `opencode models` (or check `~/.config/opencode/opencode.json` providers) to enumerate available `provider/model-id` values for the `Task` tool `model` field. If that command is unavailable, ask the user to paste their provider/model IDs. Never write a real model ID you have not confirmed. The aliases `inherit-parent` and `auto` are always valid (omit `Task` `model` → use parent session model).

### 2. Load current state

The default role-to-model mapping is the JSON shape shown in step 5 below. If `opencode.json` (project root) or `~/.config/opencode/opencode.json` (global) already exists, read it and treat its `agent` / `pstack.models` values as the current choices. Otherwise start from those defaults. Ask the user: **Project** (`opencode.json`) or **Global** (`~/.config/opencode/opencode.json`)?

### 3. Map and confirm

Show every role with its current model, marking any real slug not in the detected set as needing a choice. Ask whether to accept as-is or change specific roles, offering the detected models plus `inherit-parent` and `auto` (both mean: this role runs on the parent chat model, which is how Auto users stay on Auto) as the options. Prefer AskQuestion over free text. For panel roles (how critics, arena runners, architect runners, interrogate reviewers) the value is a list, and one subagent runs per entry, alias entries included, so the list length sets the count. `arena cross-judge pool` is also a list, but Arena selects one value from it whose model family differs from the parent's when possible. `swarm workers` is the default model for every worker unless a race or comparison assigns another model per arm.

### 4. Validate

Every real slug written must be in the detected set; `inherit-parent` and `auto` always pass. If a chosen real slug is not available, stop and ask again. A rule pointing at a model the user cannot use breaks every delegation that reads it.

### 5. Write the rule

Write the chosen target file (`opencode.json` for project root, or `~/.config/opencode/opencode.json` for global) — merge into existing JSON so re-runs stay idempotent. Skills read `pstack.models` (preferred) or `agent.<role>.model` fallbacks. Shape (JSON excerpt):

```json
{
  "pstack": {
    "models": {
      "feature, refactoring": "xai/grok-4-fast",
      "bug-fix": "anthropic/claude-opus-4-20250514",
      "perf-issue": "anthropic/claude-opus-4-20250514",
      "hillclimb": "anthropic/claude-opus-4-20250514",
      "judgment and prose": "anthropic/claude-opus-4-20250514",
      "hardest tasks": "anthropic/claude-opus-4-20250514",
      "how explorer": "xai/grok-4-fast",
      "how explainer": "anthropic/claude-opus-4-20250514",
      "how critics": ["anthropic/claude-opus-4-20250514", "openai/gpt-5.1-codex", "xai/grok-4-fast", "anthropic/claude-opus-4-20250514"],
      "why investigators": "xai/grok-4-fast",
      "why synthesizer": "anthropic/claude-opus-4-20250514",
      "reflect tooling": "openai/gpt-5.1-codex",
      "reflect judgment, divergent, synthesizer": "anthropic/claude-opus-4-20250514",
      "arena runners": ["anthropic/claude-opus-4-20250514", "openai/gpt-5.1-codex", "xai/grok-4-fast", "anthropic/claude-opus-4-20250514"],
      "arena cross-judge pool": ["anthropic/claude-opus-4-20250514", "openai/gpt-5.1-codex", "xai/grok-4-fast", "anthropic/claude-opus-4-20250514"],
      "swarm workers": "xai/grok-4-fast",
      "architect runners": ["anthropic/claude-opus-4-20250514", "openai/gpt-5.1-codex", "xai/grok-4-fast", "anthropic/claude-opus-4-20250514"],
      "interrogate reviewers": ["anthropic/claude-opus-4-20250514", "openai/gpt-5.1-codex", "xai/grok-4-fast", "anthropic/claude-opus-4-20250514"]
    }
  }
}
```

### 6. Confirm

Tell the user the JSON was written/merged, show the target path, and note it applies to new sessions. Re-running this skill updates it. Fallback: omit a role key to use the skill's inline default.

### 7. Offer a verification skill (optional)

Check whether the project has a way to drive the real app for proof (a `verify-*` skill, or an existing harness). If not, offer once: "want a project-local verification skill, so agents can drive the app the way a user does and prove changes work? I can generate one with /create-verification-skill." On yes, invoke `/create-verification-skill` (resolves wherever pstack is installed — workspace, user, or plugin). On no, move on without pushing.
