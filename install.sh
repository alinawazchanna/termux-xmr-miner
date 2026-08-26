#!/data/data/com.termux/files/usr/bin/bash
# install.sh — builds XMRig from source inside Termux.
#
# Building from source (rather than grabbing a random prebuilt Android binary)
# means you can actually read/audit the code you're about to run as root-less
# but still privileged background process on your phone.

set -euo pipefail

XMRIG_VERSION="${XMRIG_VERSION:-v6.22.2}"   # pin a known release; override with env var
BUILD_DIR="$HOME/xmrig-build"

echo "== Updating Termux packages =="
pkg update -y
pkg upgrade -y

echo "== Installing build dependencies =="
pkg install -y git cmake make clang libuv-static openssl-static libjpeg-turbo hwloc tmux

echo "== Fetching XMRig source (${XMRIG_VERSION}) =="
rm -rf "$BUILD_DIR"
git clone --branch "$XMRIG_VERSION" --depth 1 https://github.com/xmrig/xmrig.git "$BUILD_DIR"

echo "== Building =="
mkdir -p "$BUILD_DIR/build"
cd "$BUILD_DIR/build"
cmake .. -DBUILD_STATIC=ON -DCMAKE_BUILD_TYPE=Release
make -j"$(nproc)"

if [ -f "$BUILD_DIR/build/xmrig" ]; then
  cp "$BUILD_DIR/build/xmrig" "$(dirname "$0")/xmrig"
  chmod +x "$(dirname "$0")/xmrig"
  echo
  echo "Build succeeded: $(dirname "$0")/xmrig"
  echo "Next: cp config.example.json config.json, edit it, then run start.sh"
else
  echo "Build failed — check the CMake/make output above." >&2
  exit 1
fi
