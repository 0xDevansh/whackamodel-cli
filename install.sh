#!/bin/sh
# Installer for blackbox-ml-game (whackamodel-cli).
# Usage: curl -fsSL https://raw.githubusercontent.com/0xDevansh/whackamodel-cli/main/install.sh | sh
# Env: INSTALL_DIR (default ~/.local/bin)
set -eu

REPO="0xDevansh/whackamodel-cli"
BRANCH="main"
NAME="blackbox-ml-game"
BASE="https://raw.githubusercontent.com/$REPO/$BRANCH/bin"

case "$(uname -s)" in
  Linux)  os=linux ;;
  Darwin) os=macos ;;
  MINGW*|MSYS*|CYGWIN*) os=windows ;;
  *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac
case "$(uname -m)" in
  x86_64|amd64)  arch=x86_64 ;;
  aarch64|arm64) arch=aarch64 ;;
  *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac
# A Rosetta/x86 shell on an Apple Silicon Mac: still prefer the native build.
if [ "$os" = macos ] && [ "$arch" = x86_64 ] && [ "$(sysctl -n hw.optional.arm64 2>/dev/null || echo 0)" = 1 ]; then
  arch=aarch64
fi

ext=""; [ "$os" = windows ] && ext=".exe"
asset="$NAME-$os-$arch$ext"
dir="${INSTALL_DIR:-$HOME/.local/bin}"
dest="$dir/$NAME$ext"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

echo "Downloading $asset ..."
if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$BASE/$asset" -o "$tmp"
elif command -v wget >/dev/null 2>&1; then
  wget -qO "$tmp" "$BASE/$asset"
else
  echo "Need curl or wget." >&2; exit 1
fi

mkdir -p "$dir"
mv "$tmp" "$dest"
chmod +x "$dest"
# Avoid macOS Gatekeeper complaints for a downloaded binary.
[ "$os" = macos ] && xattr -d com.apple.quarantine "$dest" 2>/dev/null || true

echo "Installed: $dest"
case ":$PATH:" in
  *":$dir:"*) echo "Run: $NAME list" ;;
  *) echo "Add it to your PATH:  export PATH=\"$dir:\$PATH\""
     echo "Then run: $NAME list" ;;
esac
