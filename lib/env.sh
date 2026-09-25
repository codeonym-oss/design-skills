#!/usr/bin/env bash
# Sourced at the top of every skill script:
#   . "$(dirname "$(readlink -f "$0")")/../../../lib/env.sh"
#
# 1. Puts the script in the design environment: unless it is already running inside the
#    design-skills image (or DS_RUNTIME=native), the script re-runs itself in the container
#    with the same paths and arguments. See lib/ds.sh. Inside the image, fonts in ./fonts
#    (and $DS_FONTS) are registered for every tool.
# 2. In native mode on Linux, prefers the distro's tools over Homebrew's: a Homebrew ffmpeg has
#    no VAAPI, a Homebrew perl breaks exiftool, a Homebrew python3 breaks Blender's numpy/glTF.
. "$(dirname "${BASH_SOURCE[0]}")/ds.sh"
ds_reexec "$0" "$@"
[[ -n ${DS_IN_CONTAINER:-} ]] && ds_project_fonts

export DS_ORIG_PATH=${DS_ORIG_PATH:-$PATH}
[[ $(uname -s) == Linux ]] && export PATH="/usr/bin:$PATH"

# shadowed <cmd>: prints the path your normal shell would run if it isn't the /usr/bin one.
shadowed() {
  local p
  p=$(PATH=$DS_ORIG_PATH command -v "$1" 2>/dev/null) || return 1
  [[ $p != /usr/bin/$1 && -x /usr/bin/$1 ]] && echo "$p"
}
