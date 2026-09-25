#!/usr/bin/env bash
# ds-image: full
# Run Blender in the design environment (container, or natively with the system Python first on PATH).
# Usage: blender.sh [any blender args]   e.g. blender.sh -b --factory-startup -P mockup.py -- --image a.png
. "$(dirname "$(readlink -f "$0")")/../../../lib/env.sh"
exec blender "$@"
