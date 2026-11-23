#!/usr/bin/env bash
set -euo pipefail

AGY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
chmod +x "$AGY_DIR/statusline.sh" "$AGY_DIR/title.sh"

mkdir -p "$HOME/.gemini/antigravity-cli"

python3 - "$AGY_DIR" << 'EOF'
import json
import os
import sys

agy_dir = sys.argv[1]
settings_path = os.path.expanduser("~/.gemini/antigravity-cli/settings.json")

data = {}
if os.path.exists(settings_path):
    try:
        with open(settings_path, "r", encoding="utf-8") as f:
            data = json.load(f)
    except Exception:
        data = {}

data["notifications"] = True
data["statusLine"] = {
    "type": "command",
    "command": os.path.join(agy_dir, "statusline.sh"),
}
data["title"] = {
    "type": "command",
    "command": os.path.join(agy_dir, "title.sh"),
}

with open(settings_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")

os.chmod(settings_path, 0o600)
print(f"[INFO] Configured agy settings in {settings_path} (statusLine, title, notifications)")
EOF
