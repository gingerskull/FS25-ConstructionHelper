ConstructionCoords.DisplayCoords = {}

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

            local tHint = tMode.binding and (" [" .. tMode.binding.displayText .. "]") or ""
            local rHint = rMode.binding and (" [" .. rMode.binding.displayText .. "]") or ""

            local coordText, rotText

            if brush.snappingActive then
                local snappedX, snappedZ, snappedRotDeg = ConstructionCoords.Snapping.applyManualSnap(rootNode, x, y, z, rotX, rotDeg, rotZ, tSnap, rSnap)

                coordText = string.format("X: %.2f | Y: %.2f | Snap: %sm%s", snappedX, snappedZ, tostring(tSnap), tHint)
                rotText = string.format("Rot: %.1f° | Snap: %s°%s", snappedRotDeg, tostring(rSnap), rHint)
            else
                coordText = string.format("X: %.2f | Y: %.2f", x, z)
                rotText = string.format("Rot: %.1f°", rotDeg)
            end

            if g_currentMission ~= nil and g_currentMission.hud ~= nil and g_currentMission.hud.inputHelp ~= nil and g_currentMission.hud.inputHelp.extraHelpTexts ~= nil then
                table.insert(g_currentMission.hud.inputHelp.extraHelpTexts, coordText)
                table.insert(g_currentMission.hud.inputHelp.extraHelpTexts, rotText)
            end
        end
    end
end
