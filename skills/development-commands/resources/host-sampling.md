# Measuring this machine while an app runs

These helpers read the **whole machine**, not one tab or one process. Close other
windows and tabs first, or the numbers include them. Report what you sampled, over how
long, and what else was running.

## GPU load on macOS, no sudo

The Apple GPU reports its device utilization through the I/O registry. Sample it once a
second:

```bash
ioreg -r -d 1 -w0 -c IOAccelerator | grep -o '"Device Utilization %"=[0-9]*' | head -1 | cut -d= -f2
```

Wrap that in a loop with `sleep 1`, record `elapsed,percent` rows, and average them per
window (for example one window per 30 seconds). Useful options for a script:

- `--window S`: one average per S seconds, so you can compare a before and an after in
  one run.
- `--skip S`: ignore the first S seconds of each window so a change can settle.
- `--csv FILE`: keep the raw rows.

Print average, minimum, maximum and the sample count per window. A single average hides
spikes.

## Logging a running agent's token count over time

If the tool you are watching exposes per-agent token counts over an endpoint, poll it
on an interval and print one line per agent per sample: time, agent id, status, step
count, context tokens, and the running totals (input, output, cache read, cache write).
Poll read-only, with `curl`, and stop after a count or on interrupt. A log over time
shows whether a count only grows, resets, or jumps.

## Comparing stored counts with the agent's own transcript

To check whether a tool's stored context size for an agent is right, compare it with
the agent's own transcript. A Claude Code agent's transcript is a JSONL file, for a
sub-agent at:

```
~/.claude/projects/*/*/subagents/agent-<id>.jsonl
```

Each line that has `message.usage` is one request. The context the agent ended with is
the **last** request's `input_tokens + cache_read_input_tokens +
cache_creation_input_tokens`. Don't add every request's `output_tokens`, because earlier
output is already counted in later input, so adding it counts it twice. Dedupe by
`message.id` (one request can appear on several lines), take the last, and print the
stored figure, the transcript figure and the gap as a percentage. Only print agents
whose gap exceeds a threshold if you want a short report.
