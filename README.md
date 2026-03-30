# FS25 Construction Coordinates

A Farming Simulator 25 mod that displays precise world coordinates, rotation, and building footprint outlines while in construction mode. Includes customizable snap increments for both position and rotation.

## Features

- **Coordinate Display** — Shows X/Y world position and rotation angle in the construction HUD
- **Snap Cycle Keybinds** — Cycle through translation and rotation snap increments with keyboard shortcuts
- **Building Footprint** — Draws a green outline on the ground showing the building's exact footprint
- **Native HUD Integration** — Text renders inside the game's built-in construction help display

## Keybindings

| Action | Default Binding | Description |
|---|---|---|
| Cycle Position Snap | `LALT + 1` | Cycles through: 0.1, 0.25, 0.5, 1.0, 2.5, 5.0 meters |
| Cycle Rotation Snap | `LALT + 2` | Cycles through: 1°, 5°, 10°, 15°, 30°, 45° |

Bindings are rebindable in-game via Settings > Controls.

## Project Structure

```
src/
├── ConstructionCoords.lua      -- Global namespace
├── main.lua                    -- Entry point, brush hook, mod event listener
├── core/
│   └── InputManager.lua        -- Keybinding parsing and raw keyEvent handling
├── features/
│   ├── DisplayCoords.lua       -- HUD text injection (coordinates + snap info)
│   ├── Footprint.lua           -- 3D building outline rendering
│   └── Snapping.lua            -- Snap increment logic and brush override
└── utils/
    └── InputUtils.lua          -- Binding string parser (modifier mask + sym code)
```

## How It Works

The mod hooks into the game's `ConstructionBrushPlaceable` class via `g_constructionBrushTypeManager`. Every frame during placement:

1. **InputManager** refreshes keybindings from the game's input system
2. **Snapping** overrides the brush's snap settings with the current increment
3. The original `updatePlaceablePosition` runs (game's native placement logic)
4. **DisplayCoords** injects coordinate text into `g_currentMission.hud.inputHelp.extraHelpTexts`
5. **Footprint** draws building edge lines using `DebugUtil.drawDebugLine`

Input is handled via raw `keyEvent` (not `registerActionEvent`) because the construction screen's isolated input context blocks standard action events.

## Building

```bat
build.bat      -- Creates FS25_ConstructionCoords.zip
deploy.bat     -- Copies zip to FS25 mods folder (supports Local and OneDrive paths)
allInOne.bat   -- Build + deploy in one step
```

## Technical Notes

- The construction screen uses an isolated input context (`CONSTRUCTION_MENU`) that prevents standard `registerActionEvent` calls from firing
- Text is injected into `extraHelpTexts` which is cleared every frame by `InputHelpDisplay:draw()`, so injection must happen continuously
- Keybindings are read from `g_inputBinding:getActionByName()` which reflects user-rebindable keys
- The `DEV_REFERENCE.rff` file contains detailed runtime API discoveries and debugging techniques