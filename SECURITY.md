# Security Policy

## Supported versions

| Version | Supported |
|---------|-----------|
| 0.1.x   | Yes       |

## Reporting a vulnerability

Please **do not** open a public issue for security problems.

Prefer one of:
- GitHub Security Advisories on this repository (Private vulnerability reporting), or
- Contact the maintainer privately via the email listed on the GitHub profile.

Include:
- description of the issue
- impact assessment
- reproduction steps or proof-of-concept
- affected version / commit

You can expect an initial response within a few days when possible.

## Security posture (product)

- HTTPS only for network requests
- Host allowlist for downloads
- No telemetry by default
- No account system and no first-party server
- Secrets must never be committed to the repository
