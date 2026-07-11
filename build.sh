#!/bin/bash
set -e

# Export the exact Zephyr base path to fix the auto-discovery bug
export ZEPHYR_BASE="/workspaces/zmk-config-homerow/modules/zephyr/zephyr"

echo "======================================"
echo "      Building Left Keyboard...       "
echo "======================================"
west build -s zmk/app -d build/left -b nice_nano@2.0.0 -- -DSHIELD=corne_left -DZMK_CONFIG="/workspaces/zmk-config-homerow/config" -DZephyr_DIR="/workspaces/zmk-config-homerow/modules/zephyr/zephyr/share/zephyr-package/cmake"

echo "======================================"
echo "      Building Right Keyboard...      "
echo "======================================"
# We use build/right here so it doesn't delete the left half's cached files!
west build -s zmk/app -d build/right -b nice_nano@2.0.0 -- -DSHIELD=corne_right -DZMK_CONFIG="/workspaces/zmk-config-homerow/config" -DZephyr_DIR="/workspaces/zmk-config-homerow/modules/zephyr/zephyr/share/zephyr-package/cmake"

echo "======================================"
echo "      Organizing output files...      "
echo "======================================"
mkdir -p firmware
cp build/left/zephyr/zmk.uf2 firmware/left.uf2
cp build/right/zephyr/zmk.uf2 firmware/right.uf2

echo "✅ Success! left.uf2 and right.uf2 are ready in the firmware folder."
