-- Track placement and compare with displayed position (DEBUG - disabled)
-- local function trackPlacement(placeable)
--     local debugData = ConstructionCoords.DisplayCoords.debugData
--     local lastPlacement = debugData.lastPlacement
--
--     if lastPlacement == nil then
--         -- print("[PLACEMENT TRACKING] No pre-placement data found!")
--         return
--     end
--
--     -- Get actual placement position
--     local actualX, actualY, actualZ = getTranslation(placeable.rootNode)
--     local _, actualRotY, _ = getRotation(placeable.rootNode)
--     local actualRot = math.deg(actualRotY)
--     local uniqueId = "unknown"
--     if placeable.getUniqueId ~= nil then
--         uniqueId = placeable:getUniqueId()
--     end
--
--     -- Calculate deltas
--     local deltaX = actualX - lastPlacement.x
--     local deltaZ = actualZ - lastPlacement.z
--     local deltaRot = actualRot - lastPlacement.rot
--
--     -- Normalize rotation delta to -180 to 180
--     while deltaRot > 180 do deltaRot = deltaRot - 360 end
--     while deltaRot < -180 do deltaRot = deltaRot + 360 end
--
--     -- Store comparison
--     local comparison = {
--         id = uniqueId,
--         mode = lastPlacement.mode,
--         displayed = { x = lastPlacement.x, z = lastPlacement.z, rot = lastPlacement.rot },
--         actual = { x = actualX, z = actualZ, rot = actualRot },
--         delta = { x = deltaX, z = deltaZ, rot = deltaRot },
--         snap = { pos = lastPlacement.snapSize, rot = lastPlacement.snapRot }
--     }
--     table.insert(debugData.placements, comparison)
--
--     -- Log detailed comparison (DEBUG - disabled)
--     -- print("=================================================================")
--     -- print(string.format("[PLACEMENT COMPARISON] Object ID: %s", uniqueId))
--     -- print(string.format("  Mode: %s | Snap: %sM / %s°", lastPlacement.mode, tostring(lastPlacement.snapSize), tostring(lastPlacement.snapRot)))
--     -- print(string.format("  DISPLAYED (pre-click): X=%.6f, Z=%.6f, Rot=%.4f°", lastPlacement.x, lastPlacement.z, lastPlacement.rot))
--     -- print(string.format("  ACTUAL (post-place):   X=%.6f, Z=%.6f, Rot=%.4f°", actualX, actualZ, actualRot))
--     -- print(string.format("  DELTA:                 X=%.6f, Z=%.6f, Rot=%.4f°", deltaX, deltaZ, deltaRot))
--
--     -- Flag significant discrepancies
--     local posError = math.sqrt(deltaX^2 + deltaZ^2)
--     if posError > 0.001 or math.abs(deltaRot) > 0.1 then
--         -- print(string.format("  ⚠ WARNING: Position error=%.4fm, Rotation error=%.2f°", posError, math.abs(deltaRot)))
--     else
--         -- print(string.format("  ✓ Match within tolerance"))
--     end
--     -- print("=================================================================")
-- end

local function init()
    -- Register as a mod event listener so we get keyEvent callbacks
    addModEventListener(ConstructionCoords)

    local typeManager = g_constructionBrushTypeManager
    if typeManager ~= nil then
        local classObject = typeManager:getClassObjectByTypeName("placeable")

        if classObject ~= nil then
            local oldUpdatePlaceablePosition = classObject.updatePlaceablePosition

            classObject.updatePlaceablePosition = function(brush, ...)
                -- Refresh keybinding once when the construction screen opens
                if not ConstructionCoords.wasOpen then
                    ConstructionCoords.wasOpen = true
                    ConstructionCoords.InputManager.refreshBinding()
                end

                -- Override snapping config
                ConstructionCoords.Snapping.applyToBrush(brush)

                -- Call original
                oldUpdatePlaceablePosition(brush, ...)

                -- Render coordinates text
                ConstructionCoords.DisplayCoords.draw(brush)
            end

            -- print("--> Construction Coords: Brush hook installed.")
        else
            -- print("--> Mod Error: Construction Coordinates failed to find 'placeable' brush class.")
        end
    else
        -- print("--> Mod Error: Construction Coordinates failed to find 'g_constructionBrushTypeManager'.")
    end
    
    -- Hook BuyPlaceableData to override position with snapped coordinates
    if BuyPlaceableData ~= nil then
        local oldSetPosition = BuyPlaceableData.setPosition
        if oldSetPosition ~= nil then
            BuyPlaceableData.setPosition = function(self, x, y, z, ...)
                -- Check if we have a snapped position stored
                local lastPlacement = ConstructionCoords.DisplayCoords.debugData.lastPlacement
                if lastPlacement ~= nil then
                    -- Check if this position is close to our last displayed position
                    -- (within tolerance to account for minor differences)
                    local dist = math.sqrt((x - lastPlacement.x)^2 + (z - lastPlacement.z)^2)
                    if dist < 2.0 then  -- Within 2 meters, likely the same placement
                        -- print(string.format("[BUY OVERRIDE] Original: (%.3f, %.3f) -> Snapped: (%.3f, %.3f)", 
                        --     x, z, lastPlacement.x, lastPlacement.z))
                        x = lastPlacement.x
                        z = lastPlacement.z
                    end
                end
                return oldSetPosition(self, x, y, z, ...)
            end
            -- print("--> Construction Coords: BuyPlaceableData hook installed.")
        end
    end
end

-- Add update function for delayed placement tracking (DEBUG - disabled)
-- function ConstructionCoords:update(dt)
--     if self._pendingPlacementCheck ~= nil then
--         if not self._pendingPlacementCheck() then
--             self._pendingPlacementCheck = nil
--         end
--     end
-- end

init()
