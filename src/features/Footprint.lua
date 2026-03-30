ConstructionCoords.Footprint = {}

-- Outline color: solid green
local OUTLINE_R, OUTLINE_G, OUTLINE_B = 0.2, 1, 0.2
-- Outline thickness
local OUTLINE_THICKNESS = 2.4

function ConstructionCoords.Footprint.draw(brush)
    if brush.errorText ~= nil or brush.placeable == nil or not getVisibility(brush.placeable.rootNode) then
        return
    end

    local placeable = brush.placeable

    -- Get building dimensions from placement test areas
    local spec = placeable.spec_placement
    if spec == nil or spec.testAreas == nil or #spec.testAreas == 0 then
        return
    end

    local area = spec.testAreas[1]
    if area.size == nil then
        return
    end

    local sizeX = area.size.x  -- width
    local sizeZ = area.size.z  -- length

    if sizeX == nil or sizeZ == nil or sizeX <= 0 or sizeZ <= 0 then
        return
    end

    -- Get world position and rotation
    local x, y, z = getTranslation(placeable.rootNode)
    local _, rotY, _ = getRotation(placeable.rootNode)

    -- Apply rotation (negate rotY to match game's rotation direction)
    local cosR = math.cos(-rotY)
    local sinR = math.sin(-rotY)

    -- Half-extent vectors along local axes, rotated to world space
    local halfX = sizeX * 0.5
    local halfZ = sizeZ * 0.5

    -- Half-extent along local X axis, rotated to world space
    local hwX = halfX * cosR
    local hwZ = halfX * sinR

    -- Half-extent along local Z axis, rotated to world space
    local hhX = -halfZ * sinR
    local hhZ = halfZ * cosR

    -- Corner positions (XZ plane)
    local c1x, c1z = x + hwX + hhX, z + hwZ + hhZ  -- front-right
    local c2x, c2z = x - hwX + hhX, z - hwZ + hhZ  -- front-left
    local c3x, c3z = x - hwX - hhX, z - hwZ - hhZ  -- back-left
    local c4x, c4z = x + hwX - hhX, z + hwZ - hhZ  -- back-right

    -- Get terrain heights at each corner for aligned outline
    local terrainNode = g_currentMission.terrainRootNode
    local c1y = getTerrainHeightAtWorldPos(terrainNode, c1x, 0, c1z) + 0.02
    local c2y = getTerrainHeightAtWorldPos(terrainNode, c2x, 0, c2z) + 0.02
    local c3y = getTerrainHeightAtWorldPos(terrainNode, c3x, 0, c3z) + 0.02
    local c4y = getTerrainHeightAtWorldPos(terrainNode, c4x, 0, c4z) + 0.02

    -- Draw 4 thick edge lines using DebugUtil (radius controls thickness)
    DebugUtil.drawDebugLine(c1x, c1y, c1z, c2x, c2y, c2z, OUTLINE_R, OUTLINE_G, OUTLINE_B, OUTLINE_THICKNESS, false)
    DebugUtil.drawDebugLine(c2x, c2y, c2z, c3x, c3y, c3z, OUTLINE_R, OUTLINE_G, OUTLINE_B, OUTLINE_THICKNESS, false)
    DebugUtil.drawDebugLine(c3x, c3y, c3z, c4x, c4y, c4z, OUTLINE_R, OUTLINE_G, OUTLINE_B, OUTLINE_THICKNESS, false)
    DebugUtil.drawDebugLine(c4x, c4y, c4z, c1x, c1y, c1z, OUTLINE_R, OUTLINE_G, OUTLINE_B, OUTLINE_THICKNESS, false)
end
