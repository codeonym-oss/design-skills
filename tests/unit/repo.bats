#!/usr/bin/env bats
# Repository consistency: manifests, skills and docs stay in sync.

REPO="$(cd "$(dirname "${BATS_TEST_FILENAME}")/../.." && pwd -P)"

@test "VERSION matches plugin.json (image tags are derived from it)" {
  v=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["version"])' "$REPO/.claude-plugin/plugin.json")
  [ "$v" = "$(cat "$REPO/VERSION")" ]
}

@test "every skill directory is registered in plugin.json, and vice versa" {
  registered=$(python3 -c 'import json,sys; print("\n".join(sorted(s.split("/")[-1] for s in json.load(open(sys.argv[1]))["skills"])))' "$REPO/.claude-plugin/plugin.json")
  present=$(cd "$REPO/skills" && ls -d */ | tr -d / | sort)
  [ "$registered" = "$present" ]
}

@test "each SKILL.md has frontmatter whose name matches its directory" {
  for d in "$REPO"/skills/*/; do
    name=$(sed -n '2s/^name: //p' "$d/SKILL.md")
    [ "$name" = "$(basename "$d")" ] || { echo "bad name in $d: $name"; return 1; }
    grep -q '^description: .\{80,\}' "$d/SKILL.md" || { echo "short/missing description in $d"; return 1; }
  done
}

@test "every script a SKILL.md mentions exists" {
  for md in "$REPO"/skills/*/SKILL.md; do
    skill=$(basename "$(dirname "$md")")
    for ref in $(grep -oE '`[a-z0-9-]+(/[a-z0-9-]+)?\.(sh|py)' "$md" | tr -d '`' | sort -u); do
      ref=${ref#scripts/}
      case $ref in
        lib/*|bin/*) f="$REPO/$ref" ;;                                   # repo-level helpers
        */*) f="$REPO/skills/${ref%%/*}/scripts/${ref#*/}" ;;            # other-skill/script.sh
        *) f="$REPO/skills/$skill/scripts/$ref" ;;
      esac
      [ -f "$f" ] || { echo "$md mentions missing $ref"; return 1; }
    done
  done
}

@test "every script is described in its SKILL.md" {
  for s in "$REPO"/skills/*/scripts/*; do
    skill=$(basename "$(dirname "$(dirname "$s")")")
    grep -q "$(basename "$s")" "$REPO/skills/$skill/SKILL.md" || { echo "undocumented: $skill/$(basename "$s")"; return 1; }
  done
}

@test "every guide a SKILL.md links exists" {
  for md in "$REPO"/skills/*/SKILL.md; do
    for ref in $(grep -oE 'references/[a-z0-9-]+\.md' "$md" | sort -u); do
      [ -f "$(dirname "$md")/$ref" ] || { echo "$md links missing $ref"; return 1; }
    done
  done
}

@test "skill scripts source lib/env.sh (so they run in the design environment)" {
  for s in "$REPO"/skills/*/scripts/*.sh; do
    grep -qE 'lib/(env|check)\.sh' "$s" || { echo "$s does not source lib/env.sh"; return 1; }
  done
}

@test "no workstation-specific leftovers in skills" {
  ! grep -rnE 'sudo pacman -S --needed|yay -S|codeonym-arch|Vega|/usr/bin/vendor_perl|codeonym-portfolio|6C63FF' "$REPO/skills"
}
