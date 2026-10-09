#!/usr/bin/env bash
set -euo pipefail

: "${TPA_RELEASE_PACKAGE_FILE:?package path is required}"
: "${TPA_RELEASE_VERSION:?release version is required}"
: "${TPA_RELEASE_ARCH:?target architecture is required}"

test "$(dpkg-deb -f "$TPA_RELEASE_PACKAGE_FILE" Package)" = tpa-release-smoke
test "$(dpkg-deb -f "$TPA_RELEASE_PACKAGE_FILE" Version)" = "$TPA_RELEASE_VERSION"
test "$(dpkg-deb -f "$TPA_RELEASE_PACKAGE_FILE" Architecture)" = "$TPA_RELEASE_ARCH"

test "$(dpkg --print-architecture)" = "$TPA_RELEASE_ARCH"

cleanup() {
  sudo apt-get purge -y tpa-release-smoke >/dev/null 2>&1 || true
}
trap cleanup EXIT

package_path=$(realpath "$TPA_RELEASE_PACKAGE_FILE")
sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$package_path"
test "$(tpa-release-smoke)" = "tpa reusable release smoke package"
dpkg-query -W -f='${Package} ${Version} ${Architecture}\n' tpa-release-smoke
