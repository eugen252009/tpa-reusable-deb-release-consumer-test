#!/usr/bin/env bash
set -euo pipefail

: "${TPA_RELEASE_PACKAGE_FILE:?package path is required}"
: "${TPA_RELEASE_VERSION:?release version is required}"
: "${TPA_RELEASE_ARCH:?target architecture is required}"

test "$(dpkg-deb -f "$TPA_RELEASE_PACKAGE_FILE" Package)" = tpa-release-smoke
test "$(dpkg-deb -f "$TPA_RELEASE_PACKAGE_FILE" Version)" = "$TPA_RELEASE_VERSION"
test "$(dpkg-deb -f "$TPA_RELEASE_PACKAGE_FILE" Architecture)" = "$TPA_RELEASE_ARCH"

docker run --rm --platform "linux/$TPA_RELEASE_ARCH" \
  --env DEBIAN_FRONTEND=noninteractive \
  --volume "$TPA_RELEASE_PACKAGE_FILE:/tmp/tpa-release-smoke.deb:ro" \
  debian:trixie-slim sh -ec '
    apt-get update
    apt-get install -y --no-install-recommends /tmp/tpa-release-smoke.deb
    test "$(tpa-release-smoke)" = "tpa reusable release smoke package"
    dpkg-query -W -f="${Package} ${Version} ${Architecture}\n" tpa-release-smoke
  '
