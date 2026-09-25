# Shared setup for unit tests: a fake container runtime that records its argv.
REPO="$(cd "$(dirname "${BATS_TEST_FILENAME}")/../.." && pwd -P)"

fake_runtime_setup() {
  FAKEBIN="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$FAKEBIN"
  export RUNTIME_LOG="$BATS_TEST_TMPDIR/runtime.log"
  for rt in docker podman; do
    cat >"$FAKEBIN/$rt" <<'EOF'
#!/usr/bin/env bash
# "image inspect <ref>" succeeds only for refs listed in $FAKE_IMAGES.
if [[ $1 == image && $2 == inspect ]]; then
  [[ " ${FAKE_IMAGES:-} " == *" $3 "* ]]; exit
fi
printf '%s\n' "$(basename "$0")" "$@" >"$RUNTIME_LOG"
echo "FAKE-RUNTIME-RAN"
EOF
    chmod +x "$FAKEBIN/$rt"
  done
  # Our fakes plus the system tools, minus any real docker/podman.
  local sysbin="$BATS_FILE_TMPDIR/sysbin"
  if [[ ! -d $sysbin ]]; then
    mkdir -p "$sysbin"
    # first one wins: /usr/local/bin (e.g. bash 3.2 in the bash:3.2 image), then /usr/bin, then /bin
    ln -s /usr/local/bin/* /usr/bin/* /bin/* "$sysbin"/ 2>/dev/null || true
    rm -f "$sysbin"/docker* "$sysbin"/podman*
  fi
  export PATH="$FAKEBIN:$sysbin"
  unset DS_IN_CONTAINER DS_RUNTIME DS_VARIANT DS_IMAGE DS_IMAGE_REPO DS_IMAGE_TAG DS_MOUNTS DS_FONTS DS_RUN_ARGS DS_ENV DS_GPU
  VERSION=$(<"$REPO/VERSION")
  WORK="$BATS_TEST_TMPDIR/work"
  mkdir -p "$WORK"
  cd "$WORK"; WORK=$(pwd -P)
}

# make_script <path> [marker-line]  -> a skill-like script that sources lib/env.sh
make_script() {
  local path=$1 marker=${2:-}
  mkdir -p "$(dirname "$path")"
  {
    echo '#!/usr/bin/env bash'
    [[ -n $marker ]] && echo "$marker"
    echo "set -euo pipefail"
    echo ". \"$REPO/lib/env.sh\""
    echo 'echo "NATIVE-RAN $*"'
  } >"$path"
  chmod +x "$path"
}

# runtime_argv -> the recorded runtime argv, one per line
runtime_argv() { cat "$RUNTIME_LOG"; }

# has_arg_pair <a> <b>  -> the argv contains <a> immediately followed by <b>
has_arg_pair() {
  local prev=
  while IFS= read -r line; do
    [[ $prev == "$1" && $line == "$2" ]] && return 0
    prev=$line
  done <"$RUNTIME_LOG"
  return 1
}
