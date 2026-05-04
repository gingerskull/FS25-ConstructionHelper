# FS25 Construction Helper

A Farming Simulator 25 mod that enhances building placement with precise coordinate display and advanced snapping controls. Features both global (world-aligned) and local (rotation-aligned) snapping modes for perfect alignment at any angle.

## Features

- **Coordinate Display** — Shows X/Z world position and rotation angle in the construction HUD with 3-decimal precision
- **Snap Cycle Keybinds** — Cycle through translation and rotation snap increments with keyboard shortcuts
- **Local Snap Mode** — Grid rotates with building angle for perfect parallel alignment at any rotation (30°, 45°, 60°, etc.)

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

## Building

```
build.bat      -- Creates FS25_ConstructionCoords.zip
deploy.bat     -- Copies zip to FS25 mods folder (supports Local and OneDrive paths)
allInOne.bat   -- Build + deploy in one step
```