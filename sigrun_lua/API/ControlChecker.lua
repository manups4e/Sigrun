-- Input state and timing constants
local FRONTEND_ANALOGUE_THRESHOLD = 80 -- Threshold for stick movement (out of 128)
local BUTTON_PRESSED_DOWN_INTERVAL = 250 -- Initial delay before refiring
local BUTTON_PRESSED_REFIRE_ATTRITION = 45 -- How much to speed up per refire
local BUTTON_PRESSED_REFIRE_MINIMUM = 100 -- Fastest refire speed allowed

-- Local state tracking
local s_iLastRefireTimeUp = BUTTON_PRESSED_DOWN_INTERVAL
local s_iLastRefireTimeDn = BUTTON_PRESSED_DOWN_INTERVAL
local s_pressedDownTimer = GetGameTimer()
local s_lastGameFrame = 0
local iPreviousXAxis = 0.0
local iPreviousYAxis = 0.0
local iPreviousXAxisR = 0.0
local iPreviousYAxisR = 0.0

---Processes and validates frontend input with support for stick acceleration and debouncing.
---@param input number The FRONTEND_INPUT enum value to check.
---@param bPlaySound boolean Whether to play the standard UI sound if triggered.
---@param OverrideFlags number Flags from CHECK_INPUT_OVERRIDE_FLAG to ignore certain inputs.
---@param bCheckForButtonJustPressed boolean If true, checks JustPressed; otherwise, checks JustReleased.
---@return boolean bInputTriggered Returns true if the input is valid for the current frame.
function CheckInput(input, bPlaySound, OverrideFlags, bCheckForButtonJustPressed)
    local bOnlyCheckForDown = false
    local interval = 0
    local frameCount = GetFrameCount()
    local gameTimer = GetGameTimer()

    -- Determine refire interval based on direction
    if input == FRONTEND_INPUT.FRONTEND_INPUT_UP then
        interval = s_iLastRefireTimeUp
    elseif input == FRONTEND_INPUT.FRONTEND_INPUT_DOWN then
        interval = s_iLastRefireTimeDn
    else
        interval = BUTTON_PRESSED_DOWN_INTERVAL
    end

    -- Allow refire if enough time has passed since the last valid input
    if s_lastGameFrame ~= frameCount and gameTimer > (s_pressedDownTimer + interval) then
        bOnlyCheckForDown = true
    end

    local bInputTriggered = false
    local iXAxis, iYAxis = 0.0, 0.0
    local iXAxisR, iYAxisR = 0.0, 0.0

    local ignoreDpad = (OverrideFlags & CHECK_INPUT_OVERRIDE_FLAG.CHECK_INPUT_OVERRIDE_FLAG_IGNORE_D_PAD) ~= 0
    local ignoreSticks = (OverrideFlags & CHECK_INPUT_OVERRIDE_FLAG.CHECK_INPUT_OVERRIDE_FLAG_IGNORE_ANALOGUE_STICKS) ~= 0

    -- Fetch Stick Data
    if not ignoreSticks then
        iXAxis = GetDisabledControlNormal(2, 195) * 128.0
        iYAxis = GetDisabledControlNormal(2, 196) * 128.0
        iXAxisR = GetDisabledControlNormal(2, 197) * 128.0
        iYAxisR = GetDisabledControlNormal(2, 198) * 128.0
    end

    ---------------------------
    -- Directional Navigation
    ---------------------------

    -- UP
    if input == FRONTEND_INPUT.FRONTEND_INPUT_UP then
        if iXAxis > -FRONTEND_ANALOGUE_THRESHOLD and iXAxis < FRONTEND_ANALOGUE_THRESHOLD then
            if bOnlyCheckForDown then
                if iYAxis < -FRONTEND_ANALOGUE_THRESHOLD or (IsDisabledControlPressed(2, 188) and not ignoreDpad) then
                    bInputTriggered = true
                end
            else
                if (iPreviousYAxis > -FRONTEND_ANALOGUE_THRESHOLD and iYAxis < -FRONTEND_ANALOGUE_THRESHOLD) or 
                   (IsDisabledControlJustPressed(2, 188) and not ignoreDpad) then
                    bInputTriggered = true
                end
            end
        end

        -- Update refire acceleration for UP
        if s_lastGameFrame ~= frameCount then
            if iYAxis < -FRONTEND_ANALOGUE_THRESHOLD or (IsDisabledControlPressed(2, 188) and not ignoreDpad) then
                if bInputTriggered then
                    s_iLastRefireTimeUp = math.max(s_iLastRefireTimeUp - BUTTON_PRESSED_REFIRE_ATTRITION, BUTTON_PRESSED_REFIRE_MINIMUM)
                end
            else
                s_iLastRefireTimeUp = BUTTON_PRESSED_DOWN_INTERVAL
            end
        end

    -- DOWN
    elseif input == FRONTEND_INPUT.FRONTEND_INPUT_DOWN then
        if iXAxis > -FRONTEND_ANALOGUE_THRESHOLD and iXAxis < FRONTEND_ANALOGUE_THRESHOLD then
            if bOnlyCheckForDown then
                if iYAxis > FRONTEND_ANALOGUE_THRESHOLD or (IsDisabledControlPressed(2, 187) and not ignoreDpad) then
                    bInputTriggered = true
                end
            else
                if (iPreviousYAxis < FRONTEND_ANALOGUE_THRESHOLD and iYAxis > FRONTEND_ANALOGUE_THRESHOLD) or 
                   (IsDisabledControlJustPressed(2, 187) and not ignoreDpad) then
                    bInputTriggered = true
                end
            end
        end

        -- Update refire acceleration for DOWN
        if s_lastGameFrame ~= frameCount then
            if iYAxis > FRONTEND_ANALOGUE_THRESHOLD or (IsDisabledControlPressed(2, 187) and not ignoreDpad) then
                if bInputTriggered then
                    s_iLastRefireTimeDn = math.max(s_iLastRefireTimeDn - BUTTON_PRESSED_REFIRE_ATTRITION, BUTTON_PRESSED_REFIRE_MINIMUM)
                end
            else
                s_iLastRefireTimeDn = BUTTON_PRESSED_DOWN_INTERVAL
            end
        end

    -- LEFT
    elseif input == FRONTEND_INPUT.FRONTEND_INPUT_LEFT then
        if iYAxis > -FRONTEND_ANALOGUE_THRESHOLD and iYAxis < FRONTEND_ANALOGUE_THRESHOLD then
            if bOnlyCheckForDown then
                if iXAxis < -FRONTEND_ANALOGUE_THRESHOLD or (IsDisabledControlPressed(2, 189) and not ignoreDpad) then
                    bInputTriggered = true
                end
            else
                if (iPreviousXAxis > -FRONTEND_ANALOGUE_THRESHOLD and iXAxis < -FRONTEND_ANALOGUE_THRESHOLD) or 
                   (IsDisabledControlJustPressed(2, 189) and not ignoreDpad) then
                    bInputTriggered = true
                end
            end
        end

    -- RIGHT
    elseif input == FRONTEND_INPUT.FRONTEND_INPUT_RIGHT then
        if iYAxis > -FRONTEND_ANALOGUE_THRESHOLD and iYAxis < FRONTEND_ANALOGUE_THRESHOLD then
            if bOnlyCheckForDown then
                if iXAxis > FRONTEND_ANALOGUE_THRESHOLD or (IsDisabledControlPressed(2, 190) and not ignoreDpad) then
                    bInputTriggered = true
                end
            else
                if (iPreviousXAxis < FRONTEND_ANALOGUE_THRESHOLD and iXAxis > FRONTEND_ANALOGUE_THRESHOLD) or 
                   (IsDisabledControlJustPressed(2, 190) and not ignoreDpad) then
                    bInputTriggered = true
                end
            end
        end

    ---------------------------
    -- Actions & Buttons
    ---------------------------

    -- ACCEPT / SELECT
    elseif input == FRONTEND_INPUT.FRONTEND_INPUT_ACCEPT or input == FRONTEND_INPUT.FRONTEND_INPUT_CURSOR_ACCEPT then
        local control = (input == FRONTEND_INPUT.FRONTEND_INPUT_CURSOR_ACCEPT) and 237 or 201
        if bCheckForButtonJustPressed then
            bInputTriggered = IsDisabledControlJustPressed(2, control)
        else
            bInputTriggered = IsDisabledControlJustReleased(2, control)
        end

    -- BACK / CANCEL
    elseif input == FRONTEND_INPUT.FRONTEND_INPUT_BACK or input == FRONTEND_INPUT.FRONTEND_INPUT_CURSOR_BACK then
        local control = (input == FRONTEND_INPUT.FRONTEND_INPUT_CURSOR_BACK) and 238 or 202
        if bCheckForButtonJustPressed then
            bInputTriggered = IsDisabledControlJustPressed(2, control)
        else
            bInputTriggered = IsDisabledControlJustReleased(2, control)
        end

    -- SHOULDER BUTTONS
    elseif input == FRONTEND_INPUT.FRONTEND_INPUT_LB then
        bInputTriggered = IsDisabledControlJustPressed(2, 205)
    elseif input == FRONTEND_INPUT.FRONTEND_INPUT_RB then
        bInputTriggered = IsDisabledControlJustPressed(2, 206)

    -- MOUSE SCROLL
    elseif input == FRONTEND_INPUT.FRONTEND_INPUT_CURSOR_SCROLL_UP then
        bInputTriggered = IsDisabledControlPressed(2, 241)
    elseif input == FRONTEND_INPUT.FRONTEND_INPUT_CURSOR_SCROLL_DOWN then
        bInputTriggered = IsDisabledControlPressed(2, 242)

    -- GENERIC BUTTONS
    elseif input == FRONTEND_INPUT.FRONTEND_INPUT_X then
        bInputTriggered = IsDisabledControlJustReleased(2, 203)
    elseif input == FRONTEND_INPUT.FRONTEND_INPUT_Y then
        bInputTriggered = IsDisabledControlJustReleased(2, 204)
    end

    ---------------------------
    -- Post-Trigger Logic
    ---------------------------

    if bInputTriggered then
        if s_lastGameFrame ~= frameCount then
            s_pressedDownTimer = gameTimer
            s_lastGameFrame = frameCount
            iPreviousXAxis = iXAxis
            iPreviousYAxis = iYAxis
            iPreviousXAxisR = iXAxisR
            iPreviousYAxisR = iYAxisR
        end

        if bPlaySound then
            local sound = "SELECT"
            if input == FRONTEND_INPUT.FRONTEND_INPUT_UP or input == FRONTEND_INPUT.FRONTEND_INPUT_CURSOR_SCROLL_UP or
               input == FRONTEND_INPUT.FRONTEND_INPUT_DOWN or input == FRONTEND_INPUT.FRONTEND_INPUT_CURSOR_SCROLL_DOWN then
                sound = "NAV_UP_DOWN"
            elseif input == FRONTEND_INPUT.FRONTEND_INPUT_LEFT or input == FRONTEND_INPUT.FRONTEND_INPUT_RIGHT then
                sound = "NAV_LEFT_RIGHT"
            elseif input == FRONTEND_INPUT.FRONTEND_INPUT_BACK or input == FRONTEND_INPUT.FRONTEND_INPUT_CURSOR_BACK then
                sound = "BACK"
            end
            PlaySoundFrontend(-1, sound, "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
        end
    end

    return bInputTriggered
end