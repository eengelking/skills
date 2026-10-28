# Measuring this machine while an app runs

These helpers read the **whole machine**, not one tab or one process. Close other
windows and tabs first, or the numbers include them. Report what you sampled, over how
long, and what else was running.

## GPU load

Each OS and GPU vendor exposes utilization differently. Pick the line for this machine,
and take one reading a second.

| Machine | One reading (a percentage) |
|---|---|
| macOS, Apple GPU, no sudo | `ioreg -r -d 1 -w0 -c IOAccelerator \| grep -o '"Device Utilization %"=[0-9]*' \| head -1 \| cut -d= -f2` |
| Linux or Windows, NVIDIA | `nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits` (add `-l 1` to repeat every second) |
| Linux, AMD (amdgpu driver) | `cat /sys/class/drm/card0/device/gpu_busy_percent` (the card number may differ; list `/sys/class/drm/`) |
| Linux, Intel | `intel_gpu_top -J -s 1000` prints JSON once a second; read the `Render/3D` engine's `busy`. It needs elevated privileges (root, or the `CAP_PERFMON` capability) |
| Windows, any vendor | `(Get-Counter '\GPU Engine(*engtype_3D)\Utilization Percentage').CounterSamples \| Measure-Object CookedValue -Sum` in PowerShell, capped at 100 (the counter has one instance per process) |

Wrap the reading in a loop with a one-second sleep and write `elapsed,percent` rows.
Then average them per window, for example one window per 30 seconds. The same awk
works on macOS and Linux (on Windows run it under WSL or Git Bash, or do the grouping
in PowerShell with `Group-Object`):

```bash
awk -F, -v w=30 -v k=5 '{ i=int($1/w); t=$1-i*w; if (t<k) next
  s[i]+=$2; c[i]++; if (!(i in lo)||$2<lo[i]) lo[i]=$2; if ($2>hi[i]) hi[i]=$2; if (i>last) last=i }
  END { for (i=0;i<=last;i++) if (c[i]) printf "window %d: avg %.1f%%  min %d%%  max %d%%  (%d samples)\n", i, s[i]/c[i], lo[i], hi[i], c[i] }' rows.csv
```

Useful options for a script of your own:

- `--window S`: one average per S seconds, so you can compare a before and an after in
  one run.
- `--skip S`: ignore the first S seconds of each window so a change can settle.
- `--csv FILE`: keep the raw rows.

Print average, minimum, maximum and the sample count per window. A single average hides
spikes. A machine with two GPUs (a laptop with an integrated and a discrete one) needs
the reading for the one the app is actually using.

## Logging a running agent's token count over time

If the tool you are watching exposes per-agent token counts over an endpoint, poll it
on an interval and print one line per agent per sample: time, agent id, status, step
count, context tokens, and the running totals (input, output, cache read, cache write).
Poll read-only, with `curl` (or `Invoke-RestMethod` in PowerShell), and stop after a
count or on interrupt. A log over time shows whether a count only grows, resets, or
jumps.

## Comparing stored counts with the agent's own transcript

To check whether a tool's stored context size for an agent is right, compare it with
the agent's own transcript. A Claude Code agent's transcript is a JSONL file, for a
sub-agent at:

```
~/.claude/projects/*/*/subagents/agent-<id>.jsonl          (macOS, Linux)
%USERPROFILE%\.claude\projects\*\*\subagents\agent-<id>.jsonl   (Windows)
```

Each line that has `message.usage` is one request. The context the agent ended with is
the **last** request's `input_tokens + cache_read_input_tokens +
cache_creation_input_tokens`. Don't add every request's `output_tokens`, because earlier
output is already counted in later input, so adding it counts it twice. Dedupe by
`message.id` (one request can appear on several lines), take the last, and print the
stored figure, the transcript figure and the gap as a percentage. Only print agents
whose gap exceeds a threshold if you want a short report.
