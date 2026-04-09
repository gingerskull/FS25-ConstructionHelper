ConstructionCoords.DisplayCoords = {}

-- Debug tracking storage
ConstructionCoords.DisplayCoords.debugData = {
    frameCount = 0,
    lastPlacement = nil,  -- Stores data right before click
    placements = {}       -- Stores all placement comparisons
}

function ConstructionCoords.DisplayCoords.draw(brush)
    if brush.errorText == nil and brush.placeable ~= nil and getVisibility(brush.placeable.rootNode) then
        local rootNode = brush.placeable.rootNode
        local x, y, z = getTranslation(rootNode)
        local rotX, rotY, rotZ = getRotation(rootNode)

        if x ~= nil and rotY ~= nil then
            local tMode = ConstructionCoords.InputManager.modes.trans
            local rMode = ConstructionCoords.InputManager.modes.rot

            local tSnap = tMode.increments[tMode.index]
            local rSnap = rMode.increments[rMode.index]
            local rotDeg = math.deg(rotY)

            local coordText
            local snapLines = {}
            local localSnapEnabled = ConstructionCoords.localSnapEnabled
            local uniqueId = "unknown"
            if brush.placeable.getUniqueId ~= nil then
                uniqueId = brush.placeable:getUniqueId()
            end

            if brush.snappingActive then
                local snappedX, snappedZ, snappedRotDeg

                if localSnapEnabled then
                    -- LOCAL MODE: Disable game position snapping, we handle it manually
                    -- Log before/after for debugging
                    local preX, preY, preZ = getTranslation(rootNode)
                    local _, preRotY, _ = getRotation(rootNode)
                    local preRot = math.deg(preRotY)
                    
                    snappedX, snappedZ, snappedRotDeg = ConstructionCoords.Snapping.applyLocalSnap(brush, rootNode, x, y, z, rotX, rotDeg, rotZ, tSnap, rSnap)
                    
                    -- Verify position was set correctly
                    local postX, postY, postZ = getTranslation(rootNode)
                    local _, postRotY, _ = getRotation(rootNode)
                    local postRot = math.deg(postRotY)
                    
                    -- Debug logging every 10 frames for local mode (more frequent to catch issues)
                    ConstructionCoords.DisplayCoords.debugData.frameCount = ConstructionCoords.DisplayCoords.debugData.frameCount + 1
                    if ConstructionCoords.DisplayCoords.debugData.frameCount % 10 == 0 then
                        print(string.format("[LOCAL DEBUG] Frame %d", ConstructionCoords.DisplayCoords.debugData.frameCount))
                        print(string.format("  BEFORE snap: Pos(%.4f, %.4f) Rot:%.2f°", preX, preZ, preRot))
                        print(string.format("  AFTER snap:  Pos(%.4f, %.4f) Rot:%.2f°", snappedX, snappedZ, snappedRotDeg))
                        print(string.format("  READ BACK:   Pos(%.4f, %.4f) Rot:%.2f°", postX, postZ, postRot))
                        print(string.format("  DELTA:       Pos(%.6f, %.6f) Rot:%.4f°", 
                            math.abs(postX - snappedX), math.abs(postZ - snappedZ), math.abs(postRot - snappedRotDeg)))
                    end
                else
                    -- GLOBAL MODE: Game already snapped, just read the position
                    snappedX, _, snappedZ = getTranslation(rootNode)
                    snappedRotDeg = math.deg(select(2, getRotation(rootNode)))
                    
                    -- Debug logging every 30 frames for global mode
                    ConstructionCoords.DisplayCoords.debugData.frameCount = ConstructionCoords.DisplayCoords.debugData.frameCount + 1
                    if ConstructionCoords.DisplayCoords.debugData.frameCount % 30 == 0 then
                        print(string.format("[GLOBAL DEBUG] Frame %d - ID:%s Pos:(%.4f, %.4f) Rot:%.2f°", 
                            ConstructionCoords.DisplayCoords.debugData.frameCount, uniqueId, snappedX, snappedZ, snappedRotDeg))
                    end
                end

                -- Store for placement comparison
                ConstructionCoords.DisplayCoords.debugData.lastPlacement = {
                    id = uniqueId,
                    x = snappedX,
                    z = snappedZ,
                    rot = snappedRotDeg,
                    mode = localSnapEnabled and "LOCAL" or "GLOBAL",
                    snapSize = tSnap,
                    snapRot = rSnap
                }

                coordText = string.format("X: %.3f | Y: %.3f | Rot: %.1f°", snappedX, snappedZ, snappedRotDeg)

                if tMode.binding then
                    table.insert(snapLines, {
                        label = string.format("SNAP POSITION: %sM", tostring(tSnap)),
                        keys = tMode.binding.displayParts,
                    })
                end

                if rMode.binding then
                    table.insert(snapLines, {
                        label = string.format("SNAP ROTATION: %s°", tostring(rSnap)),
                        keys = rMode.binding.displayParts,
                    })
                end

                -- Add local snap mode indicator
                local toggleBinding = ConstructionCoords.InputManager.localSnapToggle.binding
                local modeText = localSnapEnabled and "LOCAL" or "GLOBAL"
                if toggleBinding then
                    table.insert(snapLines, {
                        label = string.format("SNAP MODE: %s", modeText),
                        keys = toggleBinding.displayParts,
                    })
                else
                    table.insert(snapLines, {
                        label = string.format("SNAP MODE: %s", modeText),
                        keys = {},
                    })
                end

                -- Show local grid coordinates in LOCAL mode
                if localSnapEnabled and ConstructionCoords.Snapping.lastLocalCoords then
                    local localCoords = ConstructionCoords.Snapping.lastLocalCoords
                    table.insert(snapLines, {
                        label = string.format("LOCAL GRID: %.1f, %.1f", localCoords.x, localCoords.z),
                        keys = {},
                    })
                end
            else
                coordText = string.format("X: %.3f | Y: %.3f | ROT: %.1f°", x, z, rotDeg)
            end

            if g_currentMission ~= nil and g_currentMission.hud ~= nil and g_currentMission.hud.inputHelp ~= nil then
                local extension = ConstructionCoords.HelpTooltip.create(coordText, snapLines)
                table.insert(g_currentMission.hud.inputHelp.helpExtensions, extension)
            end
        end
    end
end
