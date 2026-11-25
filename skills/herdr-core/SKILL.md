---
name: herdr-core
description: Delegate work in Herdr with hc. Use when the user asks to orchestrate, delegate, spawn subagents, coordinate OpenCode and Antigravity, or run a task in a child terminal.
herdr-core-version: "0.1.21"
---

# Herdr core: delegate with hc

`hc` is on PATH. You are a Herdr agent: `$HC_TERMINAL_ID` is your terminal address, and terminals you start are your children.

## When to delegate

Delegate when: two or more independent workstreams, a long read-only investigation, verification that can run in parallel, or a second model's review.
Do it yourself when: one file or one flow, a quick edit, or work that needs your full conversation context.
Never delegate: scope or priority decisions, secrets, or destructive operations without the user's approval.
Children are leaves: give each one a closed brief and forbid subagents.

## Delegate a task

```sh
hc run --bg --name <slug> --cwd <repo> -- "<agent>" "<task>. Report with: hc send $HC_TERMINAL_ID '<result>'"
```

- Always use `--bg` for agents. Without it their screen streams into your output and blocks you.
- Keep children interactive and leaf: no one-shot print modes, no subagents from children.
- Put the first task in `run`; a send to a booting agent can be lost.
- `--parent` is automatic when you run from your terminal. Add `--parent $HC_TERMINAL_ID` if unsure.
- Give each child: objective, files in scope, out of scope, acceptance criteria, verification, and the exact report command.

## Presets

- Antigravity, Hydrogen low: `agy-h "<task>"`
- OpenCode: `oc-h "<task>"`

Both aliases already set `--bg`, a unique name, the model/effort, and keep the child attached to your terminal.

Choose the agent that fits the task; neither is the default.

For another Antigravity effort, use the model and flag together: `gemini-4-hydrogen-<effort>` with `--effort <effort>` (`low`, `medium`, `high`, `xhigh`).

## Choosing effort

Choose the cheapest effort that can do the job yourself; do not ask the user unless the task or cost is ambiguous:

- `low`: trivial tasks, summaries, broad parallel searches.
- `medium`: default for scoped implementation.
- `high`: hard debugging, design, or reviewing large changes.
- `xhigh`: adversarial review, or something that already failed at `high`.

`agy-h` is the low preset. For any other effort, use the full command: `hc run --bg --name <slug> --cwd <repo> -- agy --model gemini-4-hydrogen-<effort> --effort <effort> "<task>"`. Do not use `max` with Hydrogen.

## Collect and steer

```sh
hc wait --children any      # next news from a child
hc wait --children all      # until none is working
hc read <t> --lines 100     # see what it did
hc send <t> "next step"     # another turn
hc interrupt <t>            # stop its current turn
hc kill <t>; hc rm <t>      # clean up
```

Never sleep or poll. If a child is `blocked`, read its screen and ask the user; never use `hc send --force` to bypass a permission decision. Do not stop or restart the shared core.
