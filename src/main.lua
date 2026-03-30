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

                -- Draw building footprint on the ground
                ConstructionCoords.Footprint.draw(brush)
            end

            print("--> Mod Loaded: Construction Coords modular architecture initialized.")
        else
            print("--> Mod Error: Construction Coordinates failed to find 'placeable' brush class.")
        end
    else
        print("--> Mod Error: Construction Coordinates failed to find 'g_constructionBrushTypeManager'.")
    end
end

init()
