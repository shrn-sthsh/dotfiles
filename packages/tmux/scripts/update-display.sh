#!/usr/bin/env bash

# Update DISPLAY inside all tmux panes in all sessions for X11 forwarding.
# Support bash, zsh, vim, and nvim (include `:terminal` buffers).
#
# Note: vim/nvim `:terminal` buffers need to be placed into normal mode.
# The following option allow for this in different manners:
# 	--vim-normal=term   send C-\ C-n esc esc (default)
# 	--vim-normal=esc    send esc esc
# 	--vim-normal=ctrlx  send ctrl-x
#
# e.g. ~/,tmux/scripts/update-display.sh --vim-normal=esc

# mode option
escape_mode="term"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --vim-normal=*) escape_mode="${1#*=}";;
    *) echo "ERROR: unknown option: $1" >&2; exit 1;;
  esac
  shift
done

# display value
if [[ -z "${DISPLAY:-}" ]]; then
  echo "DISPLAY is empty; aborting." >&2
  exit 1
fi
NEW_DISPLAY="$DISPLAY"

# switch to vim normal mode
function switch_normal_mode()
{
  local pane_id="$1"
  case "$escape_mode" in
    term)
      tmux send-keys -t "$pane_id" C-\\ C-n Escape Escape
      ;;
    ctrlx)
      tmux send-keys -t "$pane_id" C-x
      ;;
    esc|*)
      tmux send-keys -t "$pane_id" Escape Escape
      ;;
  esac
}

# check if lljbash/zsh-renew-tmux-env installed
if [[ ! -z $(type zsh 2>/dev/null) ]]; then
    HAS_RENEW=$(zsh -ci 'type renew_tmux_env | grep function')
else
    HAS_RENEW=
fi

# update all panes
tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index} #{pane_current_command}" | \
while read -r line; do
  [[ -z "$line" ]] && continue

  pane_id="${line%% *}"
  pane_cmd="${line#* }"
  pane_id="$(basename "$pane_cmd")"

  case "$base_cmd" in
    bash|zsh)
      tmux send-keys -t "$pane_id" "export DISPLAY=$NEW_DISPLAY" Enter
      ;;
    vi|vim|nvim*)
      switch_normal_mode "$pane_id"
      tmux send-keys -t "$pane_id" ":let \$DISPLAY = \"$NEW_DISPLAY\"" Enter
      tmux send-keys -t "$pane_id" ":silent! xrefresh -black" Enter
  esac
done
