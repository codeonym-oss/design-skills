# Security policy

## Supported versions

| Version | Supported |
|---|---|
| latest minor (`0.x`) | ✔ security fixes, rebuilt images |
| older | ✘ — upgrade the plugin and pull the new image |

Images are rebuilt when the pinned Ubuntu base gets security updates (Dependabot); a patch release follows.

## Reporting a vulnerability

Please **don't open a public issue**. Report privately through GitHub:
**Security → Report a vulnerability** on https://github.com/codeonym-oss/design-skills/security/advisories/new

Include what you found, how to reproduce it (the script, arguments and `ds version` output), and the impact.
You'll get an acknowledgement within 7 days and a fix or mitigation plan within 30.

## Scope

- `bin/ds`, `lib/*.sh`: the host-side dispatcher decides what gets mounted into the container — path
  handling and argument passing are in scope.
- Skill scripts and the images: command injection, unsafe file handling, vulnerable bundled packages.
- Out of scope: vulnerabilities in upstream tools themselves (report those upstream; we'll ship the fixed package).
