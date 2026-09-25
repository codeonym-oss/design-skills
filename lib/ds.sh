#!/usr/bin/env bash
# design-skills dispatcher: decides where a skill script runs.
#
#   inside the image (DS_IN_CONTAINER=1) or DS_RUNTIME=native  -> run right here
#   otherwise                                                  -> re-run the same script, with the
#                                                                 same paths, inside the pinned image
#
# Runs on the host, so it must stay bash 3.2-compatible (macOS): no ${x,,}, no declare -A,
# no mapfile, and empty arrays expanded as ${a[@]+"${a[@]}"}.

DS_ROOT=${DS_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)}
DS_DEFAULT_REPO=ghcr.io/codeonym-oss/design-skills
# Tools that only exist in the full image.
DS_FULL_TOOLS=" blender gimp gimp-console gimp-console-3.2 krita scribus darktable darktable-cli melt gmic xvfb-run vainfo "
# Environment variables the skill scripts read; forwarded into the container when set.
DS_PASS_ENV="QUALITY FORMAT WIDTH NO_COLOR COLUMNS DS_FONTS"

ds_version() { cat "$DS_ROOT/VERSION"; }

ds_die() { echo "ds: $*" >&2; exit 1; }

# ds_runtime -> docker | podman | native
ds_runtime() {
  if [[ -n ${DS_IN_CONTAINER:-} ]]; then echo native; return 0; fi
  case ${DS_RUNTIME:-auto} in
    native) echo native ;;
    docker|podman)
      command -v "$DS_RUNTIME" >/dev/null 2>&1 \
        || { echo "ds: DS_RUNTIME=$DS_RUNTIME but '$DS_RUNTIME' was not found on PATH" >&2; return 1; }
      echo "$DS_RUNTIME" ;;
    auto)
      local r
      for r in docker podman; do
        if command -v "$r" >/dev/null 2>&1; then echo "$r"; return 0; fi
      done
      echo native ;;
    *) echo "ds: unknown DS_RUNTIME=$DS_RUNTIME (auto|docker|podman|native)" >&2; return 1 ;;
  esac
}

# ds_image <core|full> -> image reference
ds_image() {
  if [[ -n ${DS_IMAGE:-} ]]; then echo "$DS_IMAGE"; return 0; fi
  echo "${DS_IMAGE_REPO:-$DS_DEFAULT_REPO}:${DS_IMAGE_TAG:-$(ds_version)}-$1"
}

# ds_pick_variant <runtime> <needs-full: 0|1> -> core | full
# full is a superset of core, so once it is on this machine it serves everything.
ds_pick_variant() {
  if [[ -n ${DS_VARIANT:-} ]]; then echo "$DS_VARIANT"; return 0; fi
  if [[ $2 == 1 ]] || "$1" image inspect "$(ds_image full)" >/dev/null 2>&1; then echo full; else echo core; fi
}

# ds_marker <file> <key> -> value of a "# ds-<key>: <value>" line near the top of a script
ds_marker() { sed -n "1,15s/^# ds-$2: *\([a-z]*\).*/\1/p" "$1" 2>/dev/null | head -1; }

ds_tool_needs_full() { [[ $DS_FULL_TOOLS == *" $1 "* ]] && echo 1 || echo 0; }

# ds_abspath <path> -> absolute, symlink-free path of an existing file or directory
ds_abspath() {
  if [[ -d $1 ]]; then (cd "$1" && pwd -P)
  else echo "$(cd "$(dirname "$1")" && pwd -P)/$(basename "$1")"; fi
}

# Directories the container must never have mounted over (it would replace the image's own).
ds_mountable() {
  case $1 in
    /|/bin|/boot|/dev|/etc|/home|/lib|/lib32|/lib64|/libx32|/opt|/proc|/root|/run|/sbin|/srv|/sys|/usr|/var) return 1 ;;
    /bin/*|/boot/*|/dev/*|/etc/*|/lib/*|/lib32/*|/lib64/*|/libx32/*|/proc/*|/run/*|/sbin/*|/sys/*|/usr/*) return 1 ;;
  esac
  return 0
}

# ds_container_exec <runtime> <image> <interactive: 0|1> <command...>
# Replaces the current process with the container run.
ds_container_exec() {
  local rt=$1 image=$2 interactive=$3; shift 3
  local work; work=$(pwd -P)
  [[ $work == / ]] && ds_die "run from a project directory, not /"

  local args=(run --rm --init)
  if [[ $interactive == 1 ]]; then args+=(-it)
  else args+=(-i); [[ -t 0 && -t 1 ]] && args+=(-t); fi

  if [[ $rt == podman ]]; then args+=(--userns=keep-id)
  else args+=(--user "$(id -u):$(id -g)"); fi

  # Same paths inside and out: the working dir (read-write) and this repo (read-only).
  local mounted=("$work")
  args+=(-v "$work:$work" -w "$work")
  if [[ $DS_ROOT != "$work" ]]; then args+=(-v "$DS_ROOT:$DS_ROOT:ro"); mounted+=("$DS_ROOT"); fi

  # Any other directory the command refers to (absolute or ../ paths), plus DS_MOUNTS.
  local a p dir m skip
  local extra=()
  for a in "$@"; do case $a in /*|../*) extra+=("$a") ;; esac; done
  for a in ${DS_MOUNTS:-} ${DS_FONTS:-}; do extra+=("$a"); done
  for a in ${extra[@]+"${extra[@]}"}; do
    if [[ -d $a ]]; then dir=$(ds_abspath "$a")
    elif [[ -e $a || -d $(dirname "$a") ]]; then dir=$(ds_abspath "$(dirname "$a")")
    else continue; fi
    ds_mountable "$dir" || continue
    skip=0
    for m in "${mounted[@]}"; do
      if [[ $dir == "$m" || $dir == "$m"/* ]]; then skip=1; break; fi
    done
    ((skip)) && continue
    args+=(-v "$dir:$dir"); mounted+=("$dir")
  done

  # Hardware video encoding (VAAPI) when the host has a GPU render node.
  if [[ ${DS_GPU:-1} != 0 && -e /dev/dri/renderD128 ]]; then
    args+=(--device /dev/dri)
    p=$(stat -c %g /dev/dri/renderD128 2>/dev/null) && args+=(--group-add "$p")
  fi

  local v
  for v in $DS_PASS_ENV ${DS_ENV:-}; do
    if [[ -n ${!v+x} ]]; then args+=(-e "$v=${!v}"); fi
  done

  # Extra runtime flags, word-split on purpose: DS_RUN_ARGS="--security-opt label=disable --memory 8g"
  # shellcheck disable=SC2206
  [[ -n ${DS_RUN_ARGS:-} ]] && args+=($DS_RUN_ARGS)

  exec "$rt" "${args[@]}" "$image" "$@"
}

# ds_project_fonts: inside the image, make ./fonts and $DS_FONTS visible to every tool
# (fontconfig reads ~/.config/fontconfig/fonts.conf; HOME is per-run in the container).
ds_project_fonts() {
  local d dirs=""
  [[ -d fonts ]] && dirs="$(pwd -P)/fonts"
  for d in ${DS_FONTS:-}; do [[ -d $d ]] && dirs="$dirs
$(ds_abspath "$d")"; done
  [[ -n $dirs ]] || return 0
  mkdir -p "$HOME/.config/fontconfig"
  {
    echo '<?xml version="1.0"?><!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd"><fontconfig>'
    while IFS= read -r d; do
      [[ -n $d ]] && printf '  <dir>%s</dir>\n' "$(sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' <<<"$d")"
    done <<<"$dirs"
    echo '</fontconfig>'
  } >"$HOME/.config/fontconfig/fonts.conf"
}

# ds_reexec <script> [args...]
# Called (via lib/env.sh) at the top of every skill script. Returns when the script should run
# here; otherwise re-runs it inside the container and never returns.
ds_reexec() {
  local script; script=$(ds_abspath "$1"); shift
  [[ $(ds_marker "$script" runtime) == host ]] && return 0
  local rt; rt=$(ds_runtime) || exit 1
  [[ $rt == native ]] && return 0
  local needs=0; [[ $(ds_marker "$script" image) == full ]] && needs=1
  ds_container_exec "$rt" "$(ds_image "$(ds_pick_variant "$rt" "$needs")")" 0 bash "$script" "$@"
}
