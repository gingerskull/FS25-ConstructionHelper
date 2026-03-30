ConstructionCoords.HelpTooltip = {}

ConstructionCoords.HelpTooltip._lineHeight = nil

--- Create a help extension object for injection into g_currentMission.hud.inputHelp.helpExtensions.
-- Renders coordinate text on the left, graphical key caps on the right (native FS25 style).
-- @param coordText string  Plain text for line 1 (coordinates/rotation)
-- @param snapLines table   Array of {label="Snap: 1.0m", keys={"LALT","1"}} or nil
-- @return help extension table
function ConstructionCoords.HelpTooltip.create(coordText, snapLines)
    local extension = {
        priority = GS_PRIO_NORMAL,
        _coordText = coordText,
        _snapLines = snapLines or {},
    }

    function extension:getHeight()
        local lineCount = 1 + #self._snapLines
        local lh = ConstructionCoords.HelpTooltip._lineHeight
        if lh == nil then
            lh = g_currentMission.hud.inputHelp.iconSizeY
            ConstructionCoords.HelpTooltip._lineHeight = lh
        end
        local lineOffsetY = g_currentMission.hud.inputHelp.lineOffsetY or 0.0046
        local lineStep = lh + lineOffsetY
        -- Add one extra lineStep as top padding to separate from native lines
        return (lineCount + 1) * lineStep
    end

    function extension:draw(inputHelpDisplay, posX, posY)
        local lineHeight = ConstructionCoords.HelpTooltip._lineHeight
        if lineHeight == nil then
            lineHeight = inputHelpDisplay.iconSizeY
            ConstructionCoords.HelpTooltip._lineHeight = lineHeight
        end
        local keyOverlay = inputHelpDisplay.keyButtonOverlay
        local textSize = inputHelpDisplay.textSize
        local textOffsetX = inputHelpDisplay.textOffsetX
        local textOffsetY = inputHelpDisplay.textOffsetY
        local bgOverlay = inputHelpDisplay.lineBg
        local lineOffsetY = inputHelpDisplay.lineOffsetY or 0.0046
        local lineStep = lineHeight + lineOffsetY

        -- Skip one lineStep as top padding (reserved in getHeight)
        posY = posY - lineStep

        -- Line 1: coordinate text (plain, no key caps)
        bgOverlay:renderCustom(posX, posY)
        setTextBold(false)
        setTextAlignment(RenderText.ALIGN_LEFT)
        setTextColor(1, 1, 1, 1)
        renderText(posX + textOffsetX, posY + textOffsetY, textSize, self._coordText)
        posY = posY - lineStep

        -- Lines 2+: snap tooltips with graphical key caps
        for _, line in ipairs(self._snapLines) do
            bgOverlay:renderCustom(posX, posY)

            -- Label text on the left
            setTextBold(false)
            setTextAlignment(RenderText.ALIGN_LEFT)
            setTextColor(1, 1, 1, 1)
            renderText(posX + textOffsetX, posY + textOffsetY, textSize, line.label)

            -- Key caps on the right (render right-to-left)
            local keys = line.keys
            local rightEdge = posX + bgOverlay.width
            local currentX = rightEdge
            for i = #keys, 1, -1 do
                local keyWidth = keyOverlay:getButtonWidth(keys[i], lineHeight)
                currentX = currentX - keyWidth - g_pixelSizeX
                keyOverlay:renderButton(keys[i], currentX, posY, lineHeight, true)
            end

            posY = posY - lineStep
        end

        return posY
    end

    return extension
end
