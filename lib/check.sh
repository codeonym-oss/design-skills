#!/usr/bin/env bash
# Shared helpers for the skills' check.sh scripts. Distro-agnostic: tools are checked on PATH,
# missing ones are mapped to install commands through lib/packages.tsv.
#   . "$(dirname "$(readlink -f "$0")")/../../../lib/check.sh"
#   section "Editors"; tool inkscape "Inkscape" --version; optional lunacy "Lunacy" "desktop app"; summary
. "$(dirname "${BASH_SOURCE[0]}")/env.sh"

if [[ -t 1 && -z ${NO_COLOR:-} ]]; then
  C_OK=$'\e[32m'; C_BAD=$'\e[31m'; C_WARN=$'\e[33m'; C_DIM=$'\e[2m'; C_B=$'\e[1m'; C_0=$'\e[0m'
else
  C_OK=; C_BAD=; C_WARN=; C_DIM=; C_B=; C_0=
fi

CHECK_FAILS=0
CHECK_MISSING=()
DS_PACKAGES=${DS_PACKAGES:-$DS_ROOT/lib/packages.tsv}

section() { printf '\n%s== %s ==%s\n' "$C_B" "$1" "$C_0"; }
info() { printf '  %s•%s %s\n' "$C_DIM" "$C_0" "$*"; }
warn() { printf '  %s!%s %s\n' "$C_WARN" "$C_0" "$*"; }

# tool <command> [label] [--version]  -> required: reports where it resolves, or counts as missing
tool() {
  local cmd=$1 label=${2:-$1} p v=
  if p=$(command -v "$cmd"); then
    [[ ${3:-} == --version ]] && v="  $("$cmd" --version 2>&1 | grep -m1 . )"
    printf '  %s✔%s %-34s %s%s%s%s\n' "$C_OK" "$C_0" "$label" "$C_DIM" "$p" "$v" "$C_0"
  else
    printf '  %s✘%s %-34s %snot found%s\n' "$C_BAD" "$C_0" "$label" "$C_WARN" "$C_0"
    CHECK_FAILS=$((CHECK_FAILS + 1))
    CHECK_MISSING+=("$cmd")
  fi
}

# optional <command> [label] [note]  -> nice to have (desktop apps, GPU helpers): warns, never fails
optional() {
  local cmd=$1 label=${2:-$1} note=${3:-} p
  if p=$(command -v "$cmd"); then
    printf '  %s✔%s %-34s %s%s%s\n' "$C_OK" "$C_0" "$label" "$C_DIM" "$p" "$C_0"
  else
    printf '  %s!%s %-34s %s%s%s\n' "$C_WARN" "$C_0" "$label" "$C_DIM" "${note:-not installed}" "$C_0"
  fi
}

# full_tool <command> [label] [--version]  -> a tool that only the full image ships (Blender, GIMP…):
# required natively and in the full image; in the core image just a pointer to the full one.
full_tool() {
  if [[ -n ${DS_IN_CONTAINER:-} && ${DS_VARIANT:-} == core ]] && ! command -v "$1" >/dev/null 2>&1; then
    optional "$1" "${2:-$1}" "in the full image (ds pull full)"
  else
    tool "$@"
  fi
}

ds_pkg_manager() {
  if [[ -n ${DS_PKG_MANAGER:-} ]]; then echo "$DS_PKG_MANAGER"; return; fi
  local m
  for m in apt-get pacman dnf brew; do
    if command -v "$m" >/dev/null 2>&1; then echo "${m%-get}"; return; fi
  done
  echo unknown
}

# install_hint <manager> <commands...> -> ready-to-paste install commands
install_hint() {
  local pm=$1 col; shift
  case $pm in apt) col=2 ;; pacman) col=3 ;; dnf) col=4 ;; brew) col=5 ;; *) col=0 ;; esac
  local main=" " extra=" " unknown="" c pkg
  for c in "$@"; do
    pkg=-; ((col)) && pkg=$(awk -F'\t' -v c="$c" -v n="$col" '$1 == c { print $n; exit }' "$DS_PACKAGES" 2>/dev/null)
    case ${pkg:--} in
      -) unknown="$unknown $c" ;;
      cask:*|*@aur) pkg=${pkg#cask:}; pkg=${pkg%@aur}; [[ $extra == *" $pkg "* ]] || extra="$extra$pkg " ;;
      *) [[ $main == *" $pkg "* ]] || main="$main$pkg " ;;
    esac
  done
  main=${main# }; main=${main% }; extra=${extra# }; extra=${extra% }
  case $pm in
    apt)    [[ -n $main ]] && echo "  sudo apt-get install -y $main" ;;
    pacman) [[ -n $main ]] && echo "  sudo pacman -S --needed $main"
            [[ -n $extra ]] && echo "  yay -S --needed $extra" ;;
    dnf)    [[ -n $main ]] && echo "  sudo dnf install -y $main" ;;
    brew)   [[ -n $main ]] && echo "  brew install $main"
            [[ -n $extra ]] && echo "  brew install --cask $extra" ;;
  esac
  [[ -n $unknown ]] && echo "  (no $pm package known for:$unknown)"
  return 0
}

summary() {
  echo
  if ((CHECK_FAILS == 0)); then
    printf '%sAll checks passed.%s\n' "$C_OK" "$C_0"
    return 0
  fi
  printf '%s%d item(s) missing.%s\n' "$C_WARN" "$CHECK_FAILS" "$C_0"
  if [[ -n ${DS_IN_CONTAINER:-} ]]; then
    echo "  These should ship with the image (${DS_VARIANT:-?} ${DS_VERSION:-?}) — for Blender/GIMP/Krita/Scribus/darktable/melt use the full image (DS_VARIANT=full), otherwise please report it."
  else
    echo "Install on this machine with:"
    install_hint "$(ds_pkg_manager)" "${CHECK_MISSING[@]}"
    echo "…or skip installing and use the container: ds pull core (or full), then run skills with DS_RUNTIME unset."
  fi
  return 1
}
