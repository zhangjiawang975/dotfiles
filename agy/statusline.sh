#!/usr/bin/env python3
import json
import os
import subprocess
import sys

# ANSI colors
RESET = "\033[0m"
BOLD = "\033[1m"
DIM = "\033[2m"
CYAN = "\033[36m"
BLUE = "\033[38;5;75m"
MAGENTA = "\033[95m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
RED = "\033[31m"
GRAY = "\033[90m"


def fmt_tokens(n):
    if not n or n <= 0:
        return "0"
    if n >= 1_000_000:
        return f"{n / 1_000_000:.1f}M"
    if n >= 1_000:
        return f"{n / 1_000:.0f}k"
    return str(int(n))


def fmt_duration(sec):
    if sec is None or sec <= 0:
        return ""
    sec = int(sec)
    days, rem = divmod(sec, 86400)
    hours, rem = divmod(rem, 3600)
    mins = rem // 60
    if days > 0:
        return f"{days}d{hours}h"
    if hours > 0:
        return f"{hours}h{mins:02d}m"
    return f"{mins}m"


def pct_color(pct, invert=False):
    # invert=False: higher is worse (context used)
    # invert=True: higher is better (quota remaining)
    if invert:
        if pct >= 50:
            return GREEN
        if pct >= 20:
            return YELLOW
        return RED
    else:
        if pct < 60:
            return GREEN
        if pct < 80:
            return YELLOW
        return RED


def make_bar(pct, width=8):
    pct = max(0.0, min(100.0, pct))
    filled = int(round(pct / 100.0 * width))
    return "█" * filled + "░" * (width - filled)


def get_git_info(cwd):
    if not cwd or not os.path.isdir(cwd):
        return None, False
    try:
        branch = subprocess.check_output(
            ["git", "-C", cwd, "rev-parse", "--abbrev-ref", "HEAD"],
            stderr=subprocess.DEVNULL,
            timeout=0.4,
            text=True,
        ).strip()
        if not branch:
            return None, False
        status = subprocess.check_output(
            ["git", "-C", cwd, "status", "--porcelain"],
            stderr=subprocess.DEVNULL,
            timeout=0.4,
            text=True,
        ).strip()
        return branch, bool(status)
    except Exception:
        return None, False


def parse_quota_bucket(bucket_id, info):
    """Return (family_order, family_label, window_tag) for a quota bucket."""
    low = bucket_id.lower()
    reset_sec = info.get("reset_in_seconds")

    # Determine window tag ("5h", "周", or "")
    if any(k in low for k in ("week", "7d")):
        win = "周"
    elif any(k in low for k in ("5h", "5-hour", "five", "short", "hourly", "session")):
        win = "5h"
    elif reset_sec is not None:
        if reset_sec >= 24 * 3600:
            win = "周"
        elif reset_sec <= 6 * 3600:
            win = "5h"
        else:
            win = ""
    else:
        win = ""

    # Determine model family
    if "argon" in low:
        return (1, "Argon", win)
    if any(k in low for k in ("3p", "claude", "gpt", "anthropic", "openai", "third", "partner")):
        return (2, "Claude", win)
    if any(k in low for k in ("gemini", "neon", "flash", "pro")):
        return (0, "Gemini", win)
    if low in ("weekly", "week", "7d", "5h", "five-hour", "short"):
        return (3, "", win)
    return (4, bucket_id, win)


def main():
    raw = sys.stdin.read().strip()
    if not raw:
        return
    try:
        data = json.loads(raw)
    except Exception:
        return

    sep = f" {GRAY}│{RESET} "
    line1 = []
    line2 = []

    # Line 1: Agent state + Model │ Mode (Shift+Tab) │ Workspace / Repo + Git Branch │ Context Window
    state = (data.get("agent_state") or "idle").lower()
    dot_color = GREEN if state == "idle" else (RED if state == "error" else YELLOW)
    model_obj = data.get("model") or {}
    model_name = model_obj.get("display_name") or model_obj.get("id") or "No Model"
    line1.append(f"{dot_color}●{RESET} {BOLD}{CYAN}{model_name}{RESET}")

    cycle_mode = (data.get("cycle_mode") or "default").lower()
    if cycle_mode == "auto":
        line1.append(f"{BOLD}{GREEN}▸▸ auto{RESET}")
    elif cycle_mode == "accept-edits":
        line1.append(f"{BOLD}{YELLOW}▸ accept-edits{RESET}")
    elif cycle_mode == "plan":
        line1.append(f"{BOLD}{MAGENTA}▪ plan{RESET}")
    else:
        line1.append(f"{DIM}{cycle_mode}{RESET}")

    ws = data.get("workspace") or {}
    cwd = ws.get("current_dir") or data.get("cwd") or ""
    if cwd:
        repo_name = os.path.basename(cwd.rstrip("/")) or cwd
        branch, dirty = get_git_info(cwd)
        if branch:
            dirty_mark = f"{YELLOW}*{RESET}" if dirty else ""
            line1.append(f"{BLUE}{repo_name}{RESET} {MAGENTA} {branch}{RESET}{dirty_mark}")
        else:
            line1.append(f"{BLUE}{repo_name}{RESET}")

    ctx = data.get("context_window") or {}
    used_pct = ctx.get("used_percentage")
    ctx_size = ctx.get("context_window_size") or 0
    total_in = ctx.get("total_input_tokens") or 0
    total_out = ctx.get("total_output_tokens") or 0
    used_tokens = ctx.get("used_tokens")
    if used_tokens is None:
        cur = ctx.get("current_usage") or {}
        if cur:
            used_tokens = (
                (cur.get("input_tokens") or 0)
                + (cur.get("cache_read_input_tokens") or 0)
                + (cur.get("cache_creation_input_tokens") or 0)
                + (cur.get("output_tokens") or 0)
            )
        else:
            used_tokens = total_in + total_out

    if used_pct is not None:
        c = pct_color(used_pct, invert=False)
        bar = make_bar(used_pct, width=8)
        if ctx_size > 0:
            line1.append(
                f"CTX {c}{bar} {used_pct:.1f}%{RESET} {DIM}({fmt_tokens(used_tokens)}/{fmt_tokens(ctx_size)}){RESET}"
            )
        else:
            line1.append(f"CTX {c}{bar} {used_pct:.1f}%{RESET}")

    # Line 2: Quotas grouped cleanly by model family (Gemini / Argon / Claude/GPT)
    quota = data.get("quota") or {}
    if isinstance(quota, dict) and quota:
        grouped = {}
        for bucket_id, info in quota.items():
            if not isinstance(info, dict) or info.get("disabled"):
                continue
            fam_order, fam_label, win = parse_quota_bucket(bucket_id, info)
            frac = info.get("remaining_fraction")
            amt = info.get("remaining_amount")
            if frac is None and amt is None:
                continue
            reset_str = fmt_duration(info.get("reset_in_seconds"))
            if frac is not None:
                rem_pct = max(0.0, min(100.0, float(frac) * 100.0))
                qc = pct_color(rem_pct, invert=True)
                val = f"{qc}{rem_pct:.0f}%{RESET}"
            else:
                val = f"{GREEN}{amt}{RESET}"

            win_order = 0 if win == "5h" else (1 if win == "周" else 2)
            grouped.setdefault((fam_order, fam_label), []).append((win_order, win, val, reset_str))

        for (_, fam_label), entries in sorted(grouped.items(), key=lambda x: x[0]):
            entries.sort(key=lambda e: e[0])
            rendered_entries = []
            for _, win, val, reset_str in entries:
                reset_part = f"{DIM}({reset_str}){RESET}" if reset_str else ""
                if win:
                    rendered_entries.append(f"{win}:{val}{reset_part}")
                else:
                    rendered_entries.append(f"{val}{reset_part}")

            body = " ".join(rendered_entries)
            if fam_label:
                line2.append(f"{BOLD}{fam_label}{RESET} {body}")
            else:
                line2.append(body)

    out_lines = []
    if line1:
        out_lines.append(sep.join(line1))
    if line2:
        out_lines.append(sep.join(line2))
    print("\n".join(out_lines))


if __name__ == "__main__":
    main()
