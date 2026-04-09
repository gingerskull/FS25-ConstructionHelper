ConstructionCoords.Snapping = {}

-- Track the first placement as anchor for consistent local grid
ConstructionCoords.Snapping.localGridAnchor = nil

function ConstructionCoords.Snapping.applyToBrush(brush)
    local tMode = ConstructionCoords.InputManager.modes.trans
    local rMode = ConstructionCoords.InputManager.modes.rot
    local localSnapEnabled = ConstructionCoords.localSnapEnabled

    if brush.snappingActive then
        if localSnapEnabled then
            -- LOCAL MODE: Disable game position snapping, we handle it manually
            brush.snappingSize = 0.0001  -- Effectively disables grid snapping
            brush.snappingAngleDeg = rMode.increments[rMode.index]
        else
            -- GLOBAL MODE: Let game handle snapping natively
            brush.snappingSize = tMode.increments[tMode.index]
            brush.snappingAngleDeg = rMode.increments[rMode.index]
        end
    end
end

function ConstructionCoords.Snapping.applyManualSnap(rootNode, x, y, z, rotX, rotDeg, rotZ, tSnap, rSnap)
    -- Manually snap translation for precise grid alignment
    local snappedX = MathUtil.round(x / tSnap) * tSnap
    local snappedZ = MathUtil.round(z / tSnap) * tSnap

    -- Manually snap rotation
    local snappedRotDeg = MathUtil.round(rotDeg / rSnap) * rSnap

    -- Apply customized snap positions & rotations back to the node
    setTranslation(rootNode, snappedX, y, snappedZ)
    setRotation(rootNode, rotX, math.rad(snappedRotDeg), rotZ)

    return snappedX, snappedZ, snappedRotDeg
end

function ConstructionCoords.Snapping.applyLocalSnap(brush, rootNode, x, y, z, rotX, rotDeg, rotZ, tSnap, rSnap)
    -- Snap rotation first (this defines our local coordinate system)
    local snappedRotDeg = MathUtil.round(rotDeg / rSnap) * rSnap
    local rotRad = math.rad(snappedRotDeg)

    -- Calculate cosine and sine once
    local cosR = math.cos(rotRad)
    local sinR = math.sin(rotRad)

    -- Transform world position to local coordinates relative to world origin
    -- Using standard rotation matrix: local = rotation_inverse * world
    -- Inverted signs to fix 180-degree offset
    local localX = x * cosR - z * sinR
    local localZ = x * sinR + z * cosR

    -- Snap to local grid
    local snappedLocalX = MathUtil.round(localX / tSnap) * tSnap
    local snappedLocalZ = MathUtil.round(localZ / tSnap) * tSnap

    -- Transform back to world coordinates
    -- Using standard rotation matrix: world = rotation * local
    -- Inverted signs to match the corrected world-to-local transform
    local snappedX = snappedLocalX * cosR + snappedLocalZ * sinR
    local snappedZ = -snappedLocalX * sinR + snappedLocalZ * cosR

    -- Store local grid coordinates for display
    ConstructionCoords.Snapping.lastLocalCoords = {
        x = snappedLocalX,
        z = snappedLocalZ,
        snap = tSnap
    }

    -- Apply snapped position and rotation to the node
    setTranslation(rootNode, snappedX, y, snappedZ)
    setRotation(rootNode, rotX, math.rad(snappedRotDeg), rotZ)

    -- Also update brush position so placement uses snapped coordinates
    if brush ~= nil then
        brush.posX = snappedX
        brush.posZ = snappedZ
        brush.posY = y
        if brush.rotY ~= nil then
            brush.rotY = math.rad(snappedRotDeg)
        end
    end

    return snappedX, snappedZ, snappedRotDeg
end
