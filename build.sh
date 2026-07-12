#!/bin/bash
set -e

# Export the exact Zephyr base path to fix the auto-discovery bug
export ZEPHYR_BASE="/workspaces/zmk-config-homerow/modules/zephyr/zephyr"

# Make sure build directory exists for logs
mkdir -p build

echo "================================================="
echo " Building Left & Right Keyboards simultaneously! "
echo " (Outputs are being written to log files)        "
echo "================================================="

echo "🔨 Building Left Keyboard... (Logging to build/left.log)"
west build -s zmk/app -d build/left -b nice_nano@2.0.0 -S studio-rpc-usb-uart -- -DSHIELD="corne_left raw_hid_adapter" -DZMK_CONFIG="/workspaces/zmk-config-homerow/config" -DZephyr_DIR="/workspaces/zmk-config-homerow/modules/zephyr/zephyr/share/zephyr-package/cmake" -DCONFIG_ZMK_STUDIO=y -DCONFIG_ZMK_STUDIO_TRANSPORT_BLE=y > build/left.log 2>&1 &
PID_LEFT=$!

echo "🔨 Building Right Keyboard... (Logging to build/right.log)"
west build -s zmk/app -d build/right -b nice_nano@2.0.0 -- -DSHIELD=corne_right -DZMK_CONFIG="/workspaces/zmk-config-homerow/config" -DZephyr_DIR="/workspaces/zmk-config-homerow/modules/zephyr/zephyr/share/zephyr-package/cmake" > build/right.log 2>&1 &
PID_RIGHT=$!

echo "⏳ Waiting for compilers to finish..."

# We manually check the exit statuses so we can print the logs on failure
FAIL=0

if ! wait $PID_LEFT; then
    echo ""
    echo "❌ LEFT KEYBOARD BUILD FAILED! Here is the error log:"
    echo "----------------------------------------------------"
    cat build/left.log
    echo "----------------------------------------------------"
    FAIL=1
fi

if ! wait $PID_RIGHT; then
    echo ""
    echo "❌ RIGHT KEYBOARD BUILD FAILED! Here is the error log:"
    echo "----------------------------------------------------"
    cat build/right.log
    echo "----------------------------------------------------"
    FAIL=1
fi

if [ $FAIL -eq 1 ]; then
    echo "Aborting firmware copy due to build errors."
    exit 1
fi

echo ""
echo "======================================"
echo "      Organizing output files...      "
echo "======================================"
mkdir -p firmware
cp build/left/zephyr/zmk.uf2 firmware/left.uf2
cp build/right/zephyr/zmk.uf2 firmware/right.uf2

echo "✅ Success! left.uf2 and right.uf2 are ready in the firmware folder."
