ConstructionCoords.InputManager = {}

-- Define Snapping States and Keybindings
ConstructionCoords.InputManager.modes = {
    trans = { action = "CONSTRUCT_SNAP_CYCLE", increments = {0.1, 0.25, 0.5, 1.0, 2.5, 5.0}, index = 4, binding = nil, keyWasDown = false },
    rot = { action = "CONSTRUCT_ROT_SNAP_CYCLE", increments = {1, 5, 10, 15, 30, 45}, index = 4, binding = nil, keyWasDown = false }
}

-- Local snap toggle state (not a cycle mode)
ConstructionCoords.InputManager.localSnapToggle = {
    action = "CONSTRUCT_LOCAL_SNAP_TOGGLE",
    binding = nil,
    keyWasDown = false
}

--- Read the current keybindings from the game's input binding system.
function ConstructionCoords.InputManager.refreshBinding()
    if g_inputBinding == nil then return end

    for _, mode in pairs(ConstructionCoords.InputManager.modes) do
        local ok, action = pcall(function() return g_inputBinding:getActionByName(mode.action) end)
        if ok and action ~= nil and action.primaryKeyboardInput ~= nil then
            mode.binding = ConstructionCoords.InputUtils.parseBinding(action.primaryKeyboardInput)
        else
            mode.binding = nil
        end
    end

    -- Refresh local snap toggle binding
    local toggle = ConstructionCoords.InputManager.localSnapToggle
    local ok, action = pcall(function() return g_inputBinding:getActionByName(toggle.action) end)
    if ok and action ~= nil and action.primaryKeyboardInput ~= nil then
        toggle.binding = ConstructionCoords.InputUtils.parseBinding(action.primaryKeyboardInput)
    else
        toggle.binding = nil
    end
end

--- Raw keyboard listener — detects key presses matching the current bindings.
function ConstructionCoords:keyEvent(unicode, sym, modifier, isDown)
    -- Only active when construction screen is open with a brush
    if g_constructionScreen == nil or g_constructionScreen.brush == nil then
        ConstructionCoords.wasOpen = false
        return
    end

    for _, mode in pairs(ConstructionCoords.InputManager.modes) do
        local binding = mode.binding
        if binding ~= nil and binding.keySym ~= 0 then
            if not isDown then
                if sym == binding.keySym then mode.keyWasDown = false end
            else
                local modifierMatch = binding.modifierMask == 0 or bitAND(modifier, binding.modifierMask) > 0
                if modifierMatch and sym == binding.keySym and not mode.keyWasDown then
                    mode.index = (mode.index % #mode.increments) + 1
                    mode.keyWasDown = true

                    ConstructionCoords.InputManager.refreshBinding()
                end
            end
        end
    end

    -- Handle local snap toggle (boolean flip, not cycle)
    local toggle = ConstructionCoords.InputManager.localSnapToggle
    local toggleBinding = toggle.binding
    if toggleBinding ~= nil and toggleBinding.keySym ~= 0 then
        if not isDown then
            if sym == toggleBinding.keySym then toggle.keyWasDown = false end
        else
            local modifierMatch = toggleBinding.modifierMask == 0 or bitAND(modifier, toggleBinding.modifierMask) > 0
            if modifierMatch and sym == toggleBinding.keySym and not toggle.keyWasDown then
                ConstructionCoords.localSnapEnabled = not ConstructionCoords.localSnapEnabled
                toggle.keyWasDown = true

                ConstructionCoords.InputManager.refreshBinding()
            end
        end
    end
end
