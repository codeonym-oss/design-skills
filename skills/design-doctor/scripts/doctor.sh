#!/usr/bin/env bash
# ds-runtime: host
# Health check of the whole design toolchain: runtime, images, every skill's check, one summary.
# Usage: doctor.sh [--verbose]
. "$(dirname "$(readlink -f "$0")")/../../../lib/env.sh"
skills_dir="$DS_ROOT/skills"
verbose=0; [[ ${1:-} == --verbose ]] && verbose=1
if [[ -t 1 && -z ${NO_COLOR:-} ]]; then G=$'\e[32m' R=$'\e[31m' Y=$'\e[33m' B=$'\e[1m' D=$'\e[2m' N=$'\e[0m'; else G='' R='' Y='' B='' D='' N=''; fi

rt=$(ds_runtime) || exit 1
printf '%sdesign-skills %s — health check%s\n' "$B" "$(ds_version)" "$N"
printf 'host %s · %s %s · runtime %s\n' "$(uname -n)" "$(uname -s)" "$(uname -m)" "$rt"

have=" "
if [[ $rt != native ]]; then
  for v in core full; do
    img=$(ds_image "$v")
    if "$rt" image inspect "$img" >/dev/null 2>&1; then
      have="$have$v "
      printf '  %s✔%s %-5s %s %s(%s)%s\n' "$G" "$N" "$v" "$img" "$D" \
        "$("$rt" image inspect -f '{{.Size}}' "$img" | numfmt --to=iec --suffix=B 2>/dev/null || echo ?)" "$N"
    else
      printf '  %s·%s %-5s %s %snot pulled — ds pull %s%s\n' "$Y" "$N" "$v" "$img" "$D" "$v" "$N"
    fi
  done
  [[ $have == *" full "* ]] && have=" core full "
elif [[ -n ${DS_IN_CONTAINER:-} ]]; then
  have=" ${DS_VARIANT:-full} "; [[ $have == " full " ]] && have=" core full "
  printf '  inside the %s image\n' "${DS_VARIANT:-?}"
else
  have=" core full "   # native host: check everything
fi

echo
printf '%-18s %-10s %s\n' "SKILL" "STATUS" "DETAILS"
failed=0
for check in "$skills_dir"/*/scripts/check.sh; do
  skill=$(basename "$(dirname "$(dirname "$check")")")
  needs=core; [[ $(ds_marker "$check" image) == full ]] && needs=full
  if [[ $(ds_marker "$check" runtime) != host && $have != *" $needs "* ]]; then
    printf '%-18s %s%-10s%s %s\n' "$skill" "$Y" "skipped" "$N" "needs the $needs image (ds pull $needs)"
    continue
  fi
  out=$(DS_VARIANT=${DS_VARIANT:-$( [[ $have == *" full "* ]] && echo full || echo core)} bash "$check" 2>&1); rc=$?
  missing=$(grep -E '✘' <<<"$out" | sed -E 's/^ *✘ //; s/ {2,}.*//' | paste -sd, - | sed 's/,/, /g')
  if ((rc == 0)); then printf '%-18s %s%-10s%s\n' "$skill" "$G" "ok" "$N"
  else failed=1; printf '%-18s %s%-10s%s %s\n' "$skill" "$R" "missing" "$N" "$missing"; fi
  ((verbose)) && { sed 's/^/    /' <<<"$out"; echo; }
done

if [[ $rt == native ]]; then
  echo
  printf '%sPATH shadowing%s\n' "$B" "$N"
  found=0
  for t in ffmpeg ffprobe perl python3 magick gs; do
    if p=$(shadowed "$t"); then
      found=1
      case $t in
        ffmpeg|ffprobe) why="may lack VAAPI hardware encoding" ;;
        perl) why="can break exiftool" ;;
        python3) why="can break Blender's numpy/glTF when launched from a terminal" ;;
        *) why="differs from the distro build" ;;
      esac
      printf '  %s!%s %-8s → %s (%s)\n' "$Y" "$N" "$t" "$p" "$why"
    fi
  done
  if ((found)); then
    echo "  Skill scripts already put /usr/bin first. To fix your shell too, move Homebrew to the end of PATH"
    echo "  (zsh, after the 'brew shellenv' line):  path=(\${path:#/home/linuxbrew/.linuxbrew/*} /home/linuxbrew/.linuxbrew/bin)"
  else
    echo "  none"
  fi
fi

echo
printf '%sStorage%s\n' "$B" "$N"
read -r avail pcent < <(df -h . | awk 'NR==2 {print $4, $5}')
printf '  this folder: %s free (%s used)\n' "$avail" "$pcent"
((${pcent%\%} >= 90)) && printf '  %s!%s disk nearly full — renders, recordings and the full image (≈4 GB) need room\n' "$Y" "$N"

echo
if ((failed)); then echo "Run with --verbose for install commands."; exit 1; fi
echo "Everything available is healthy."
