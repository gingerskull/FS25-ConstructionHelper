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

            local coordText
            local snapLines = {}

            if brush.snappingActive then
                local snappedX, snappedZ, snappedRotDeg = ConstructionCoords.Snapping.applyManualSnap(rootNode, x, y, z, rotX, rotDeg, rotZ, tSnap, rSnap)

                coordText = string.format("X: %.2f | Y: %.2f | Rot: %.1f°", snappedX, snappedZ, snappedRotDeg)

                if tMode.binding then
                    table.insert(snapLines, {
                        label = string.format("SNAP POSITION: %sm", tostring(tSnap)),
                        keys = tMode.binding.displayParts,
                    })
                end

                if rMode.binding then
                    table.insert(snapLines, {
                        label = string.format("SNAP ROTATION: %s°", tostring(rSnap)),
                        keys = rMode.binding.displayParts,
                    })
                end
            else
                coordText = string.format("X: %.2f | Y: %.2f | Rot: %.1f°", x, z, rotDeg)
            end

            if g_currentMission ~= nil and g_currentMission.hud ~= nil and g_currentMission.hud.inputHelp ~= nil then
                local extension = ConstructionCoords.HelpTooltip.create(coordText, snapLines)
                table.insert(g_currentMission.hud.inputHelp.helpExtensions, extension)
            end
        end
    end
end
