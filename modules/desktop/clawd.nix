{ pkgs, lib, ... }:

let
  clawd-hook = pkgs.writeShellApplication {
    name = "clawd-hook";
    runtimeInputs = with pkgs; [
      jq
      coreutils
      util-linux
    ];
    text = ''
      dir="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/clawd"
      sessions="$dir/sessions"
      mkdir -p "$sessions"

      alive() {
        [ "$1" -gt 0 ] && [[ "$(cat "/proc/$1/comm" 2>/dev/null)" == *claude* ]]
      }

      aggregate() {
        local files=() file pid
        for file in "$sessions"/*.json; do
          [ -e "$file" ] || continue
          pid=$(jq -r '.claudePid // 0' "$file" 2>/dev/null || echo 0)
          if alive "$pid"; then
            files+=("$file")
          else
            rm -f "$file"
          fi
        done
        if [ ''${#files[@]} -eq 0 ]; then
          jq -n --argjson now "$(date +%s%3N)" \
            '{state: "sleeping", tool: "", kittyPid: 0, sessions: 0, updated: $now}'
        else
          jq -s '
            def rank: {attention: 4, ready: 3, working: 2, thinking: 1}[.state] // 0;
            (sort_by([rank, .updated]) | last) as $top
            | {state: $top.state, tool: $top.tool, kittyPid: $top.kittyPid,
               sessions: length, since: $top.updated,
               updated: (map(.updated) | max)}' "''${files[@]}"
        fi > "$dir/state.json.tmp"
        mv -f "$dir/state.json.tmp" "$dir/state.json"
      }

      locked_aggregate() {
        exec 9>"$dir/lock"
        flock -w 2 9 || exit 0
        aggregate
      }

      if [ "''${1:-}" = "--refresh" ]; then
        locked_aggregate
        exit 0
      fi

      input=$(cat)
      IFS=$'\x1f' read -r event session tool ntype cwd < <(jq -r '[
        .hook_event_name, .session_id, .tool_name, .notification_type, .cwd]
        | map(. // "" | tostring) | join("\u001f")' <<<"$input") || exit 0
      [ -n "$session" ] || exit 0
      file="$sessions/$session.json"

      category() {
        case "$1" in
          Read | Grep | Glob | LS) echo read ;;
          Edit | Write | MultiEdit | NotebookEdit) echo write ;;
          Bash | BashOutput | KillShell | Monitor) echo bash ;;
          WebFetch | WebSearch | mcp__claude-in-chrome__*) echo web ;;
          Agent | Task) echo agent ;;
          *) echo think ;;
        esac
      }

      previous_tool=""
      [ -e "$file" ] && previous_tool=$(jq -r '.tool // ""' "$file" 2>/dev/null || true)

      case "$event" in
        SessionStart) state=idle tool="" ;;
        Stop | StopFailure) state=ready tool="" ;;
        UserPromptSubmit | PostToolUse | PostToolUseFailure | PermissionDenied) state=thinking tool="" ;;
        PreToolUse) state=working tool=$(category "$tool") ;;
        PermissionRequest) state=attention tool=$(category "$tool") ;;
        Notification)
          case "$ntype" in
            permission_prompt | elicitation_dialog | elicitation_url_dialog | agent_needs_input)
              state=attention tool=$previous_tool
              ;;
            *) exit 0 ;;
          esac
          ;;
        SessionEnd)
          rm -f "$file"
          locked_aggregate
          exit 0
          ;;
        *) exit 0 ;;
      esac

      claude_pid=0
      kitty_pid=0
      pid=$PPID
      while [ "$pid" -gt 1 ]; do
        comm=$(cat "/proc/$pid/comm" 2>/dev/null) || break
        case "$comm" in
          *claude*) [ "$claude_pid" -eq 0 ] && claude_pid=$pid ;;
          *kitty*)
            kitty_pid=$pid
            break
            ;;
        esac
        stat=$(cat "/proc/$pid/stat" 2>/dev/null) || break
        read -r _ pid _ <<<"''${stat##*) }"
      done

      jq -n --arg state "$state" --arg tool "$tool" --arg cwd "$cwd" \
        --argjson claudePid "$claude_pid" --argjson kittyPid "$kitty_pid" \
        --argjson updated "$(date +%s%3N)" \
        '{state: $state, tool: $tool, cwd: $cwd, claudePid: $claudePid,
          kittyPid: $kittyPid, updated: $updated}' >"$file.tmp"
      mv -f "$file.tmp" "$file"
      locked_aggregate
    '';
  };

  hook = {
    hooks = [
      {
        type = "command";
        command = "/run/current-system/sw/bin/clawd-hook";
        timeout = 5;
      }
    ];
  };
in
{
  environment.systemPackages = [ clawd-hook ];

  environment.etc."claude-code/managed-settings.json".text = builtins.toJSON {
    hooks = lib.genAttrs [
      "SessionStart"
      "SessionEnd"
      "UserPromptSubmit"
      "PreToolUse"
      "PostToolUse"
      "PostToolUseFailure"
      "PermissionRequest"
      "PermissionDenied"
      "Notification"
      "Stop"
      "StopFailure"
    ] (_: [ hook ]);
  };
}
