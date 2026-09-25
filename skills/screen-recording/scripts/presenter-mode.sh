#!/usr/bin/env bash
# ds-runtime: host
# Toggle "presenter mode" for recordings: bigger cursor + Ctrl ripple to locate the pointer.
# Remembers your previous values and restores them with "off".
# Usage: presenter-mode.sh on [cursor-size=40] | off | status
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/../../../lib/env.sh"
state=${XDG_STATE_HOME:-$HOME/.local/state}/ds-presenter-mode
schema=org.gnome.desktop.interface
if ! command -v gsettings >/dev/null 2>&1 || ! gsettings get $schema cursor-size >/dev/null 2>&1; then
  echo "presenter mode needs a GNOME desktop (gsettings $schema)." >&2
  echo "Elsewhere: macOS → Accessibility → Display → Pointer size + 'Shake to locate';" >&2
  echo "Windows → Settings → Accessibility → Mouse pointer and touch; KDE → Cursors + 'Locate pointer'." >&2
  exit 1
fi

case ${1:-status} in
  on)
    size=${2:-40}
    if [[ ! -f $state ]]; then
      mkdir -p "$(dirname "$state")"
      printf '%s\n%s\n' "$(gsettings get $schema cursor-size)" "$(gsettings get $schema locate-pointer)" >"$state"
    fi
    gsettings set $schema cursor-size "$size"
    gsettings set $schema locate-pointer true
    echo "✔ presenter mode on: cursor $size px, press Ctrl to show a ripple around the pointer"
    ;;
  off)
    if [[ -f $state ]]; then
      { read -r size; read -r locate; } <"$state"
      gsettings set $schema cursor-size "$size"
      gsettings set $schema locate-pointer "$locate"
      rm -f "$state"
      echo "✔ restored: cursor $size px, locate-pointer $locate"
    else
      echo "presenter mode was not on (nothing to restore)"
    fi
    ;;
  status)
    echo "cursor-size=$(gsettings get $schema cursor-size) locate-pointer=$(gsettings get $schema locate-pointer) presenter-mode=$([[ -f $state ]] && echo on || echo off)"
    ;;
  *) echo "usage: $0 on [size] | off | status" >&2; exit 2 ;;
esac
