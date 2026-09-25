#!/usr/bin/env bash
# ds-runtime: host
# Check the recording setup on THIS desktop (recording can't happen inside a container).
. "$(dirname "$(readlink -f "$0")")/../../../lib/check.sh"

section "Recorder"
optional obs "OBS Studio" "install from https://obsproject.com (Windows/macOS/Linux)"
for d in /usr/lib/obs-plugins /usr/lib/x86_64-linux-gnu/obs-plugins /usr/lib64/obs-plugins "$HOME/.config/obs-studio/plugins" \
         "$HOME/.var/app/com.obsproject.Studio/config/obs-studio/plugins" "$HOME/Library/Application Support/obs-studio/plugins"; do
  [[ -d $d ]] || continue
  n=$(ls -1 "$d" 2>/dev/null | wc -l | tr -d ' ')
  info "plugins dir: $d ($n entries)"
done

section "Session"
info "OS: $(uname -s) · session: ${XDG_SESSION_TYPE:-n/a} · desktop: ${XDG_CURRENT_DESKTOP:-n/a}"
[[ ${XDG_SESSION_TYPE:-} == wayland ]] && info "Wayland: capture via PipeWire (Screen Capture (PipeWire) source); global hotkeys need a portal-aware plugin"

section "Presentation helpers"
optional showmethekey-gtk "showmethekey (keystroke overlay, Linux)" "Linux: showmethekey · macOS: KeyCastr · Windows: Carnac"
if command -v gsettings >/dev/null && gsettings get org.gnome.desktop.interface cursor-size >/dev/null 2>&1; then
  info "GNOME cursor-size $(gsettings get org.gnome.desktop.interface cursor-size) · locate-pointer $(gsettings get org.gnome.desktop.interface locate-pointer) (presenter-mode.sh)"
fi

section "Post-production (runs in the container)"
info "finish-recording.sh remuxes, trims and loudness-normalizes via ffmpeg — no local install needed"

summary
