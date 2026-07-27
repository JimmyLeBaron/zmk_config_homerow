# ZMK Config - Corne 5-Column Project Context

This file contains the context and rules established for this specific ZMK configuration, specifically tuned for a 5-column Corne keyboard, Nick Coutsos Keymap Editor, ZMK Studio, and macOS compatibility.

## 1. Keymap Editor & ZMK Studio Compatibility
*   **The Conflict:** Keymap Editor natively looks for `zmk,matrix_transform` in the `chosen` node to render the correct 5-column layout. However, ZMK Studio strictly requires `zmk,physical-layout` and will **fail to build** if `zmk,matrix_transform` is also present in the `chosen` node.
*   **The Fix:** We use the native devicetree `/delete-property/` trick.
    ```dts
    chosen {
        zmk,physical-layout = &foostan_corne_5col_layout;
        zmk,matrix_transform = &five_column_transform;
        /delete-property/ zmk,matrix_transform;
    };
    ```
    *Why it works:* Keymap Editor's AST parser reads the assignment and stops, correctly rendering the 5-column UI. The Zephyr devicetree compiler executes the `/delete-property/` instruction before validation, successfully hiding it from ZMK Studio.

## 2. macOS Shortcuts & Media Keys
*   macOS ignores standard ZMK consumer/keyboard keycodes for copy, paste, and undo.
*   **DO NOT** use `K_COPY`, `K_PASTE`, `K_CUT`, `K_UNDO`, `K_REDO`.
*   **DO** use macOS native GUI bindings: `LG(C)`, `LG(V)`, `LG(X)`, `LG(Z)`, `LS(LG(Z))`.
*   **Media Keys:** For media keys to work on macOS, use the Consumer (`C_`) keycodes instead of Keyboard (`K_`) keycodes.
    *   *Correct:* `C_MUTE`, `C_VOL_UP`, `C_VOL_DN`, `C_PREV`, `C_PP`, `C_NEXT`.
    *   *Incorrect:* `K_MUTE`, `K_BACK`, `K_PLAY_PAUSE`, `K_NEXT`.

## 3. Home Row Mods & Mod-Morph Timings
*   **Home Row Mods:** We use `hml` and `hmr` (Hold-Tap) with `hold-trigger-on-release;` to prevent false triggers during fast typing.
*   **Shift Keys:** We use separated `hml_shift` and `hmr_shift` behaviors specifically for the Shift modifiers on the home row. **These do NOT use `hold-trigger-on-release;`.** 
    *   *Reason:* If `hold-trigger-on-release` is active, the Shift modifier is delayed until the next key is released. This breaks `mod-morph` behaviors (like our custom `&colon_semi`) which must evaluate the modifier state at the exact moment they are pressed.
*   **Display Names:** Custom behaviors (`hml`, `hmr`, `lm`) have `display-name` properties defined so that KeyPeek and ZMK Studio render human-readable labels instead of raw hex codes.

## 4. Build Environment
*   **Local Build Script:** Firmware is built locally using `./build.sh` inside the provided Docker devcontainer.
*   **GitHub Actions:** The default GitHub Actions workflow (`.github/workflows/build.yml`) has been renamed to `.yml.disabled` so that pushing to GitHub doesn't trigger redundant cloud builds.
