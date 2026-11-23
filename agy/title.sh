#!/usr/bin/env bash
IFS= read -r -d '' DATA || true

STATE="idle"
if [[ "$DATA" =~ \"agent_state\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]]; then
  STATE="${BASH_REMATCH[1]}"
fi

CWD=""
if [[ "$DATA" =~ \"current_dir\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]]; then
  CWD="${BASH_REMATCH[1]}"
elif [[ "$DATA" =~ \"cwd\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]]; then
  CWD="${BASH_REMATCH[1]}"
fi

WS="${CWD##*/}"
[[ -z "$WS" ]] && WS="agy"

if [[ "$DATA" =~ \"tool_confirmation_pending\"[[:space:]]*:[[:space:]]*true ]]; then
  STATUS="🔔 等待确认"
else
  case "$STATE" in
    working|thinking) STATUS="⏳ 思考中..." ;;
    tool_use)         STATUS="🛠️ 执行中..." ;;
    reviewing)        STATUS="🔔 等待确认" ;;
    initializing|authenticating) STATUS="🚀 启动中..." ;;
    error)            STATUS="❌ 出错" ;;
    idle|*)           STATUS="✅ 已完成" ;;
  esac
fi

printf '%s · %s\n' "$STATUS" "$WS"
