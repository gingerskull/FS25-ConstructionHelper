ConstructionCoords.Snapping = {}

function ConstructionCoords.Snapping.applyToBrush(brush)
    local tMode = ConstructionCoords.InputManager.modes.trans
    local rMode = ConstructionCoords.InputManager.modes.rot

    -- Override the engine's snap settings with ours
    if brush.snappingActive then
        brush.snappingSize = tMode.increments[tMode.index]
        brush.snappingAngleDeg = rMode.increments[rMode.index]
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
