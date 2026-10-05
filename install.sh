#!/bin/sh
# Install a released BrainMaps Go binary without sudo.
set -eu
repo=${BRAINMAPS_REPOSITORY:-brainmapsplatform/brainmaps}
version=${BRAINMAPS_VERSION:-latest}
install_dir=${BRAINMAPS_INSTALL_DIR:-"$HOME/.local/bin"}
case "$(uname -s)" in
 Darwin) platform=darwin ;;
 Linux) platform=linux ;;
 *) printf 'Download a binary for your OS from https://github.com/%s/releases/latest\n' "$repo" >&2; exit 1 ;;
esac
case "$(uname -m)" in
 arm64|aarch64) arch=arm64 ;;
 x86_64|amd64) arch=amd64 ;;
 *) echo 'Unsupported architecture (supported: arm64, amd64).' >&2; exit 1 ;;
esac
if [ "$version" = latest ]; then
 base="https://github.com/$repo/releases/latest/download"
else
 case "$version" in *[!a-zA-Z0-9._-]*|'') echo 'Invalid BRAINMAPS_VERSION.' >&2; exit 1 ;; esac
 base="https://github.com/$repo/releases/download/$version"
fi
base=${BRAINMAPS_DOWNLOAD_URL:-$base}
archive="brainmaps_${platform}_${arch}.tar.gz"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
command -v curl >/dev/null 2>&1 || { echo 'curl is required.' >&2; exit 1; }
command -v tar >/dev/null 2>&1 || { echo 'tar is required.' >&2; exit 1; }
printf 'Downloading BrainMaps %s for %s/%s...\n' "$version" "$platform" "$arch"
curl -fsSL --retry 3 --proto-redir '=https' "$base/$archive" -o "$tmp/$archive"
curl -fsSL --retry 3 --proto-redir '=https' "$base/checksums.txt" -o "$tmp/checksums.txt"
expected=$(awk -v name="$archive" '$2 == name { print $1 }' "$tmp/checksums.txt")
case "$expected" in ''|*[!a-fA-F0-9]*) echo 'Missing or invalid release checksum.' >&2; exit 1 ;; esac
[ "${#expected}" -eq 64 ] || { echo 'Invalid SHA256 checksum length.' >&2; exit 1; }
if command -v sha256sum >/dev/null 2>&1; then
 actual=$(sha256sum "$tmp/$archive" | awk '{print $1}')
elif command -v shasum >/dev/null 2>&1; then
 actual=$(shasum -a 256 "$tmp/$archive" | awk '{print $1}')
else
 echo 'sha256sum or shasum is required to verify the download.' >&2; exit 1
fi
[ "$actual" = "$expected" ] || { echo 'Checksum mismatch. Nothing was installed.' >&2; exit 1; }
tar -xzf "$tmp/$archive" -C "$tmp" brainmaps
[ -f "$tmp/brainmaps" ] && [ ! -L "$tmp/brainmaps" ] || { echo 'Invalid release archive.' >&2; exit 1; }
chmod 755 "$tmp/brainmaps"
"$tmp/brainmaps" --version
mkdir -p "$install_dir"
# Copy beside the target, then rename to preserve an existing binary on failure.
staged="$install_dir/.brainmaps-install-$$"
trap 'rm -rf "$tmp"; rm -f "$staged"' EXIT HUP INT TERM
cp "$tmp/brainmaps" "$staged"
chmod 755 "$staged"
mv -f "$staged" "$install_dir/brainmaps"
printf 'Installed %s/brainmaps\n' "$install_dir"
case ":$PATH:" in
 *":$install_dir:"*) ;;
 *) printf 'Add this directory to your PATH: %s\n' "$install_dir" ;;
esac
