# Drop coding-agent session markers inherited from a dead session.
#
# A multiplexer server hands every pane it opens a *snapshot* of the environment
# of the shell that started it. Start herdr or tmux from inside a Claude Code
# Bash-tool shell and that snapshot keeps the session's markers forever: days
# later a brand new pane still announces CLAUDE_CODE_CHILD_SESSION=1 and a
# CLAUDE_PID that exited long ago. A `claude` launched there believes it is a
# nested session and turns transcript saving off, warning once and scrolling by.
#
# Restarting the multiplexer clears it but kills live sessions, so check the
# claim instead: a *child* session is a descendant process. Walk up from this
# shell; if the agent that stamped these variables is not on the way to init,
# they belong to someone else and get dropped. A genuinely nested shell finds
# its parent and keeps them, so agent-spawned shells still look like agents.
() {
  emulate -L zsh

  local agent_pid=${CLAUDE_PID:-${CLAUDE_CODE_MESSAGING_SOCKET:t:r}}
  [[ $agent_pid == <-> ]] || return   # no pid to check the claim against

  local -A parent
  local pid ppid
  while read -r pid ppid; do parent[$pid]=$ppid; done < <(ps -Ao pid=,ppid= 2>/dev/null)
  (( $#parent )) || return            # ps gave us nothing; assume the claim is honest

  pid=$$
  while [[ $pid == <-> && $pid != 1 ]]; do
    [[ $pid == $agent_pid ]] && return   # real descendant, leave the markers alone
    pid=${parent[$pid]}
  done

  unset AI_AGENT CLAUDECODE CLAUDE_EFFORT CLAUDE_PID CLAUDE_PLUGIN_DATA \
    CLAUDE_CODE_CHILD_SESSION CLAUDE_CODE_ENTRYPOINT CLAUDE_CODE_EXECPATH \
    CLAUDE_CODE_MESSAGING_SOCKET CLAUDE_CODE_SESSION_ID \
    CODEX_COMPANION_SESSION_ID CODEX_COMPANION_TRANSCRIPT_PATH
}
