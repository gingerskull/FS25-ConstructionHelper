ConstructionCoords.InputUtils = {}

-- Modifier key name → keyEvent modifier bitmask
local MODIFIER_KEYS = {
    KEY_lalt = 256, KEY_ralt = 256,
    KEY_lshift = 1, KEY_rshift = 2,
    KEY_lctrl = 64, KEY_rctrl = 128,
}

-- Special key name → SDL sym code
local SPECIAL_KEYS = {
    KEY_space = 32, KEY_return = 13, KEY_escape = 27,
    KEY_backspace = 8, KEY_tab = 9,
    KEY_f1 = 282, KEY_f2 = 283, KEY_f3 = 284, KEY_f4 = 285,
    KEY_f5 = 286, KEY_f6 = 287, KEY_f7 = 288, KEY_f8 = 289,
    KEY_f9 = 290, KEY_f10 = 291, KEY_f11 = 292, KEY_f12 = 293,
}

-- Key name → display name for tooltip
local DISPLAY_NAMES = {
    KEY_lalt = "LALT", KEY_ralt = "RALT",
    KEY_lshift = "LSHIFT", KEY_rshift = "RSHIFT",
    KEY_lctrl = "LCTRL", KEY_rctrl = "RCTRL",
    KEY_space = "SPACE", KEY_return = "ENTER",
    KEY_escape = "ESC", KEY_backspace = "BKSP", KEY_tab = "TAB",
}

--- Parse a binding string like "KEY_lalt KEY_1" into modifier mask, sym code, and display text.
function ConstructionCoords.InputUtils.parseBinding(bindingStr)
    local result = { modifierMask = 0, keySym = 0, displayParts = {} }

    for keyName in bindingStr:gmatch("%S+") do
        if MODIFIER_KEYS[keyName] then
            -- Modifier key (ALT, SHIFT, CTRL)
            result.modifierMask = result.modifierMask + MODIFIER_KEYS[keyName]
            table.insert(result.displayParts, DISPLAY_NAMES[keyName] or keyName)
        elseif SPECIAL_KEYS[keyName] then
            -- Special key (F1-F12, SPACE, etc.)
            result.keySym = SPECIAL_KEYS[keyName]
            table.insert(result.displayParts, DISPLAY_NAMES[keyName] or keyName)
        else
            -- Standard key: KEY_x → ASCII code of x
            local char = keyName:match("KEY_(.+)")
            if char and #char == 1 then
                result.keySym = string.byte(char)
                table.insert(result.displayParts, char:upper())
            else
                table.insert(result.displayParts, (char or keyName):upper())
            end
        end
    end

    result.displayText = table.concat(result.displayParts, " + ")
    return result
end
