# FS25 Construction Helper

A Farming Simulator 25 mod that enhances building placement with precise coordinate display and advanced snapping controls. Features both global (world-aligned) and local (rotation-aligned) snapping modes for perfect alignment at any angle.

## Features

- **Coordinate Display** — Shows X/Z world position and rotation angle in the construction HUD with 3-decimal precision
- **Snap Cycle Keybinds** — Cycle through translation and rotation snap increments with keyboard shortcuts
- **Local Snap Mode** — Grid rotates with building angle for perfect parallel alignment at any rotation (30°, 45°, 60°, etc.)
- **Native HUD Integration** — Text renders inside the game's built-in construction help display with graphical key overlays

## Keybindings

| Action | Default Binding | Description |
|---|---|---|
| Cycle Position Snap | `LALT + 1` | Cycles through: 0.1, 0.25, 0.5, 1.0, 2.5, 5.0 meters |
| Cycle Rotation Snap | `LALT + 2` | Cycles through: 1°, 5°, 10°, 15°, 30°, 45° |
| Toggle Local Snap | `LALT + 3` | Switches between global (world grid) and local (building-relative) snapping |

Bindings are rebindable in-game via Settings > Controls.

## Snap Modes

### Global Mode (Default)
Building snaps to world X/Z coordinate grid. Best for 90° aligned placements and standard orthogonal layouts.

### Local Mode
The entire snapping grid rotates rigidly with the building. Objects placed at the same local grid coordinates will form perfectly parallel lines in world space, regardless of rotation angle.

**Example**: Place buildings at local grid positions (3,0), (6,0), (9,0) with 30° rotation:
- World positions: (2.598, 1.5), (5.196, 3.0), (7.794, 4.5)
- Result: Three buildings forming a straight line at exactly 30°

Perfect for creating aligned rows of buildings, fences, or any structures at non-orthogonal angles.

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