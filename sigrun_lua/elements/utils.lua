--[[
Taken from ScaleformUI utils, courtesy of manups4e (manups4e@gmail.com | https:https://github.com/manups4e)
to manups4e for its Brynhildr inventory, Have fun my friend.. you deserve these utils!
Author: manups4e
Source: https://github.com/manups4e/ScaleformUI
]]

-- Make the number type detected as integer to avoid multiple lint detections.
---@diagnostic disable-next-line: duplicate-doc-alias
---@alias integer number

---starts
---@param Str string
---@param Start string
---@return boolean
function string.starts(Str, Start)
    return string.sub(Str, 1, string.len(Start)) == Start
end

---StartsWith
---@param self string
---@param str string
---@return boolean
string.StartsWith = function(self, str)
    return self:find('^' .. str) ~= nil
end

---IsNullOrEmpty
---@param self string
---@return boolean
string.IsNullOrEmpty = function(self)
    return self == nil or self == '' or not not tostring(self):find("^%s*$")
end

---SplitLabel
---@param self string
---@return table
string.SplitLabel = function(self)
    local stringsNeeded = math.ceil((self:len() - 1) / 99)
    local outputString = {}

    -- Fill table with substrings
    for i = 0, stringsNeeded - 1 do
        local start = i * 99
        local length = math.min(99, self:len() - start)
        table.insert(outputString, self:sub(start + 1, start + length))
    end

    return outputString
end

---Insert
---@param self string
---@param pos number
---@param str2 string
string.Insert = function(self, pos, str2)
    return self:sub(1, pos) .. str2 .. self:sub(pos + 1)
end

-- Return the first index with the given value (or -1 if not found).
function table.indexOf(self, value)
    for i, v in ipairs(self) do
        if v == value then
            return i
        end
    end
    return -1
end

function IndexOf(table, value)
    for i, v in ipairs(table) do
        if v == value then
            return i
        end
    end
    return -1
end

-- Return a key with the given value (or nil if not found).  If there are
-- multiple keys with that value, the particular key returned is arbitrary.
function KeyOf(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then
            return k
        end
    end
    return nil
end

function math.round(num, numDecimalPlaces)
    if numDecimalPlaces then
        local power = 10 ^ numDecimalPlaces
        return math.floor((num * power) + 0.5) / (power)
    else
        return math.floor(num + 0.5)
    end
end

function ToBool(input)
    if input == "true" or tonumber(input) == 1 or input == true then
        return true
    else
        return false
    end
end

function string.split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t, i = {}, 1
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        t[i] = str
        i = i + 1
    end

    return t
end

function Split(pString, pPattern)
    local Table = {} -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pPattern
    local last_end = 1
    local s, e, cap = pString:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            Table[#Table + 1] = cap
        end
        last_end = e + 1
        s, e, cap = pString:find(fpat, last_end)
    end
    if last_end <= #pString then
        cap = pString:sub(last_end)
        Table[#Table + 1] = cap
    end
    return Table
end

function ResolutionMaintainRatio()
    local screenw, screenh = GetActiveScreenResolution()
    local ratio = screenw / screenh
    local width = 1080 * ratio
    return width, 1080
end

function SafezoneBounds()
    local t = GetSafeZoneSize()
    local g = math.round(t, 2)
    g = (g * 100) - 90
    g = 10 - g

    local screenw = 720 * GetAspectRatio(false)
    local screenh = 720
    local ratio = screenw / screenh
    local wmp = ratio * 5.4

    return math.round(g * wmp), math.round(g * 5.4)
end

function FormatXWYH(Value, Value2)
    local w, h = ResolutionMaintainRatio()
    return Value / w, Value2 / h
end

---Returns the magnitude of the vector.
---@param vector vector3 -- The vector to get the magnitude of.
---@return number
function GetVectorMagnitude(vector)
    return Sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
end

---Returns true if the vector is inside the sphere, false otherwise.
---@param vector vector3 -- The vector to check.
---@param position vector3 -- The position of the sphere.
---@param scale vector3 -- The scale of the sphere.
---@return boolean
function IsVectorInsideSphere(vector, position, scale)
    local distance = (vector - position)
    local radius = GetVectorMagnitude(scale) / 2
    return GetVectorMagnitude(distance) <= radius
end

function AllTrue(t)
    for _, v in pairs(t) do
        if not v then return false end
    end

    return true
end

function AllFalse(t)
    for _, v in pairs(t) do
        if v then return true end
    end

    return false
end

function IsMouseInBounds(X, Y, Width, Height)
    local MX, MY = math.round(GetControlNormal(0, 239) * 1920), math.round(GetControlNormal(0, 240) * 1080)
    MX, MY = FormatXWYH(MX, MY)
    X, Y = FormatXWYH(X, Y)
    Width, Height = FormatXWYH(Width, Height)
    return (MX >= X and MX <= X + Width) and (MY > Y and MY < Y + Height)
end

function TableHasKey(table, key)
    local lowercaseKey = string.lower(key)

    for k, _ in pairs(table) do
        if string.lower(k) == lowercaseKey then
            return true
        end
    end

    return false
end

function LengthSquared(vector)
    return math.sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
end

function Wrap(value, min, max)
    local range = max - min
    local normalizedValue = math.fmod(value - min, range)

    if normalizedValue < 0 then
        normalizedValue = normalizedValue + range
    end

    local epsilon = 1e-12 -- A small number close to zero
    if math.abs(normalizedValue - range) < epsilon then
        normalizedValue = range
    end

    return min + normalizedValue
end

---Converts player's current screen resolution coordinates into scaleform coordinates (1280 x 720)
---@param realX number
---@param realY number
---@return vector2
function ConvertResolutionCoordsToScaleformCoords(realX, realY)
    local x, y = GetActiveScreenResolution()
    return vector2(realX / x * 1280, realY / y * 720)
end

---Converts scaleform coordinates (1280 x 720) into player's current screen resolution coordinates
---@param scaleformX number
---@param scaleformY number
---@return vector2
function ConvertScaleformCoordsToResolutionCoords(scaleformX, scaleformY)
    local x, y = GetActiveScreenResolution()
    return vector2(scaleformX / 1280 * x, scaleformY / 720 * y)
end

---Converts screen coords (0.0 - 1.0) into scaleform coords (1280 x 720)
---@param scX number
---@param scY number
---@return vector2
function ConvertScreenCoordsToScaleformCoords(scX, scY)
    return vector2(scX * 1280, scY * 720)
end

---Converts scaleform coords (1280 x 720) into screen coords (0.0 - 1.0)
---@param scaleformX number
---@param scaleformY number
---@return vector2
function ConvertScaleformCoordsToScreenCoords(scaleformX, scaleformY)
    -- Normalize coordinates to 0.0 - 1.0 range
    local w, h = 1280, 720
    return vector2((scaleformX / w), (scaleformY / h))
end

function ConvertResolutionCoordsToScreenCoords(x, y)
    local w, h = GetActualScreenResolution()
    local normalizedX = math.max(0.0, math.min(1.0, x / w))
    local normalizedY = math.max(0.0, math.min(1.0, y / h))
    return vector2(normalizedX, normalizedY)
end

function ConvertScreenCoordsToResolutionCoords(nx, ny)
    local w, h = GetActualScreenResolution()
    local x = math.floor(nx * w + 0.5)
    local y = math.floor(ny * h + 0.5)
    return vector2(x, y)
end

---Converts player's current screen resolution size into scaleform size (1280 x 720)
---@param realWidth number
---@param realHeight number
---@return vector2
function ConvertResolutionSizeToScaleformSize(realWidth, realHeight)
    local x, y = GetActiveScreenResolution()
    return vector2(realWidth / x * 1280, realHeight / y * 720)
end

---Converts scaleform size (1280 x 720) into player's current screen resolution size
---@param scaleformWidth number
---@param scaleformHeight number
---@return vector2
function ConvertScaleformSizeToResolutionSize(scaleformWidth, scaleformHeight)
    local x, y = GetActiveScreenResolution()
    return vector2(scaleformWidth / 1280 * x, scaleformHeight / 720 * y)
end

---Converts screen size (0.0 - 1.0) into scaleform size (1280 x 720)
---@param scWidth number
---@param scHeight number
---@return vector2
function ConvertScreenSizeToScaleformSize(scWidth, scHeight)
    return vector2(scWidth * 1280, scHeight * 720)
end

---Converts scaleform size (1280 x 720) into screen size (0.0 - 1.0)
---@param scaleformWidth number
---@param scaleformHeight number
---@return vector2
function ConvertScaleformSizeToScreenSize(scaleformWidth, scaleformHeight)
    -- Normalize size to 0.0 - 1.0 range
    local w, h = GetActualScreenResolution()
    return vector2((scaleformWidth / w), (scaleformHeight / h))
end

function ConvertResolutionSizeToScreenSize(width, height)
    local w, h = GetActualScreenResolution()
    local normalizedWidth = math.max(0.0, math.min(1.0, width / w))
    local normalizedHeight = math.max(0.0, math.min(1.0, height / h))
    return vector2(normalizedWidth, normalizedHeight)
end

---Adjust 1080p values to any aspect ratio
---@param x number
---@param y number
---@param w number
---@param h number
---@return number
---@return number
---@return number
---@return number
function AdjustNormalized16_9ValuesForCurrentAspectRatio(x, y, w, h)
    local fPhysicalAspect = GetAspectRatio(false)
    if IsSuperWideScreen() then
        fPhysicalAspect = 16.0 / 9.0
    end

    local fScalar = (16.0 / 9.0) / fPhysicalAspect
    local fAdjustPos = 1.0 - fScalar

    w = w * fScalar

    local newX = x * fScalar
    x = newX + fAdjustPos * 0.5
    x, w = AdjustForSuperWidescreen(x, w)
    return x, y, w, h
end

function GetWideScreen()
    local WIDESCREEN_ASPECT = 1.5
    local fLogicalAspectRatio = GetAspectRatio(false)
    local w, h = GetActualScreenResolution()
    local fPhysicalAspectRatio = w / h
    if fPhysicalAspectRatio <= WIDESCREEN_ASPECT then
        return false
    end
    return fLogicalAspectRatio > WIDESCREEN_ASPECT
end

---Adjusts normalized values to SuperWidescreen resolutions
---@param x number
---@param w number
---@return number
---@return number
function AdjustForSuperWidescreen(x, w)
    if not IsSuperWideScreen() then
        return x, w
    end

    local difference = ((16.0 / 9.0) / GetAspectRatio(false))

    x = 0.5 - ((0.5 - x) * difference)
    w = w * difference

    return x, w
end

function IsSuperWideScreen()
    local aspRat = GetAspectRatio(false)
    return aspRat > (16.0 / 9.0)
end

function Join(symbol, list)
    local result = ""
    for i, value in ipairs(list) do
        if i ~= 1 then
            result = result .. symbol
        end
        result = result .. tostring(value)
    end
    return result
end

function Convert180to360(angle)
    return 360.0 - ((angle + 360.0) % 360.0)
end

function table:contains(value)
    for _, v in pairs(self) do
        if v == value then
            return true
        end
    end
    return false
end

function GetMinSafeZone(aspectRatio, bScript)
    local safezoneSizeX = GetSafeZoneSize()
    local safezoneSizeY = GetSafeZoneSize()

    if (aspectRatio < 1.0) then
        safezoneSizeX = 1.0 - ((1.0 - safezoneSizeX) + (1.0 - aspectRatio))
    end


    local width, height = GetActualScreenResolution()

    local safeW = width * safezoneSizeX
    local safeH = height * safezoneSizeY
    local offsetW = (width - safeW) * 0.5
    local offsetH = (height - safeH) * 0.5

    -- Round down to lowest area
    local x0 = math.ceil(offsetW)
    local y0 = math.ceil(offsetH)
    local x1 = math.floor(width - offsetW)
    local y1 = math.floor(height - offsetH)

    x0 /= width
    y0 /= height
    x1 /= width
    y1 /= height

    if (bScript and IsSuperWideScreen()) then
        local fDifference = (16.0 / 9.0) / GetAspectRatio(true)
        local fMaxBounds = width * fDifference
        local fResDif = width - fMaxBounds
        local fOffsetAbsolute = fResDif * 0.5
        local fOffsetRelative = fOffsetAbsolute / width

        x0 += fOffsetRelative
        x1 -= fOffsetRelative
    end
    return x0, y0, x1, y1
end

function GetDifferenceFrom_16_9_ToCurrentAspectRatio()
    local fOffsetValue = 0.0;

    if not IsSuperWideScreen() then
        local width, height = GetActualScreenResolution()

        local fAspectRatio = width / height;
        local fMarginRatio = (1.0 - GetSafeZoneSize()) * 0.5;
        local fDifferenceInMarginSize = fMarginRatio * ((16.0 / 9.0)) - fAspectRatio;
        fOffsetValue = (1.0 - (fAspectRatio / (16.0 / 9.0))) - fDifferenceInMarginSize * 0.5;
    end

    return fOffsetValue;
end

function GetMinSafeZoneForScaleformMovies(aspectRatio)
    local x0, y0, x1, y1 = GetMinSafeZone(aspectRatio);

    local fSafeZoneAdjust = GetDifferenceFrom_16_9_ToCurrentAspectRatio();

    x0 += fSafeZoneAdjust;
    x1 -= fSafeZoneAdjust;
    return x0, y0, x1, y1
end

function UpdateSafeZone(scaleform)
    local x0, y0, x1, y1 = GetMinSafeZoneForScaleformMovies(GetAspectRatio(false));
    --ms_fLowestTopRightY = fSafeZoneY[0];
    local lang = GetCurrentLanguage()
    scaleform:CallFunction("SET_DISPLAY_CONFIG", 1280, 720, y0, y1, x0, x1, GetWideScreen(), false,
        lang == 8 or lang == 9 or lang == 10)
end

function DrawText(x, y, text, scale, color)
    scale = scale or 0.5
    color = color or { r = 255, g = 255, b = 255, a = 255 }

    -- Esempio per FiveM
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(scale, scale)
    SetTextColour(color.r, color.g, color.b, color.a)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

function RampValue(x, funcInA, funcInB, funcOutA, funcOutB)
    local funcInRange = funcInB - funcInA;
    local t = math.clamp((x - funcInA) / funcInRange, 0.0, 1.0)
    return math.lerp(t, funcOutA, funcOutB);
end

function math.clamp(val, min, max)
    return math.max(min, math.min(max, val))
end

function math.lerp(t, a, b)
    return a + (b - a) * t
end

function math.mag(x, y, z)
    return math.sqrt(x * x + y * y + z * z)
end

local function remap(x, inMin, inMax, outMin, outMax)
    return (x - inMin) / (inMax - inMin) * (outMax - outMin) + outMin
end

---Converts a world position into a normalized screen position for HUD elements.
---Handles visibility, scaling by distance, and off-screen projection.
---If the world position is visible in the camera frustum, returns its screen coordinates.
---If it's not visible but `showIfOutOfSight` is true, projects it to the nearest screen edge.
---When `displayRange == -1`, the element is always considered visible.
---@param position vector3                  World position of the element.
---@param offset vector3|nil                Optional offset applied to position. Defaults to (0, 0, 0).
---@param scaleStartDistance number|nil     Distance where scaling starts. Default: 0.0
---@param scaleEndDistance number|nil       Distance where scaling ends. Default: displayRange or 500.0
---@param scaleMax number|nil               Maximum scale factor in percentage (0.0–1.0). Default: 1.0
---@param scaleMin number|nil               Minimum scale factor in percentage (0.0–1.0). Default: 0.0
---@param showIfOutOfSight boolean|nil      If true, show element at screen edges when out of sight. Default: true
---@param keepScalingOutOfSight boolean|nil If true, preserve scaling when out of sight. Default: true
---
---@return boolean|number visible           Whether the element should be displayed (on-screen or edge-projected).
---@return vector2 screenPos                Normalized screen coordinates (0.0–1.0). Returns (-1.0, -1.0) if hidden.
---@return number scale                     Normalized scale factor in percentage (0.0–1.0).
---@return number direction                 Screen side where the out of sight elements is shown: 1 = Top, 2 = Right, 3 = Bottom, 4 = Left
---
---@example
---```lua
----- Example 1: Visible only within 200m, scales from 1.0 to 0.5 between 10m and 150m
---local visible, pos, scale = GetScreenCoordinatesForComponent(vec3(100, 200, 30), nil, 200, 10, 150, 1.0, 0.5)
---
----- Example 2: Always visible, fixed scale
---local visible, pos, scale = GetScreenCoordinatesForComponent(targetPos, nil, -1, nil, nil, 0.8, 0.8)
---```
function GetScreenCoordinatesForComponent(position, offset, scaleStartDistance, scaleEndDistance, scaleMax,
                                          scaleMin, showIfOutOfSight, keepScalingOutOfSight)
    offset = offset or vector3(0.0, 0.0, 0.0)
    scaleStartDistance = scaleStartDistance or 0.0
    scaleEndDistance = scaleEndDistance or (scaleEndDistance ~= -1 and scaleEndDistance or 500.0)
    scaleMax = math.clamp(scaleMax, 0.0, 1.0) or 1.0
    scaleMin = math.clamp(scaleMin, 0.0, 1.0) or 0.0
    showIfOutOfSight = showIfOutOfSight or true
    keepScalingOutOfSight = keepScalingOutOfSight or true

    local camPos
    if Config.Components.WorldMarkers.relativePositionType == 1 then
        camPos = GetFinalRenderedCamCoord()
    else
        camPos = GetGameplayCamCoord()
    end
    local diff = position - camPos
    local dist = math.sqrt(diff.x * diff.x + diff.y * diff.y + diff.z * diff.z)

    -- Corregge la distanza in base al FOV
    local fovFactor = GetFinalRenderedCamFov() / 45.0
    dist = dist * fovFactor
    -- Controllo visibilità
    if scaleEndDistance == -1 or dist <= scaleEndDistance then
        local worldCoords = position + offset
        local success, screenX, screenY = GetScreenCoordFromWorldCoord(worldCoords.x, worldCoords.y, worldCoords.z)

        local scale
        if scaleEndDistance == -1 then
            scale = scaleMax
        else
            scale = RampValue(dist, scaleStartDistance, scaleEndDistance, scaleMax, scaleMin)
        end

        -- Se visibile normalmente
        if success then
            return true, vector2(screenX, screenY), scale, -1
        elseif showIfOutOfSight then -- Se non visibile ma vogliamo comunque mostrarlo ai bordi
            success, screenX, screenY = GetHudScreenPositionFromWorldPosition(worldCoords.x, worldCoords.y, worldCoords
            .z)
            if success then
                screenX = remap(screenX, 0.1, 0.9, 0.0, 1.0)
                screenY = remap(screenY, 0.1, 0.9, 0.0, 1.0)
                local nuScale = 1.0
                if keepScalingOutOfSight then
                    nuScale = scale
                end
                return true, vector2(screenX, screenY), nuScale, success
            end
        end
    end

    return false, vector2(-1.0, -1.0), 0.0, -1
end

local ignoredFormats = {
    "~n",
    "~h",
    "~bold",
    "~italic",
    "~ws",
    "~wanted_star",
    "~nrt",
    "~EX_R*",
    "~BLIP_",
    "~a",
    "~1",
    "~a_",
    "~1_",
    "~x",
    "~z",
    "~INPUT_",
    "~INPUTGROUP_",
    "~ACCEPT",
    "~CANCEL",
    "~PAD_",
}

local visualFormats = {
    "~ws",
    "~wanted_star",
    "~EX_R*",
    "~BLIP_",
    "~INPUT_",
    "~INPUTGROUP_",
    "~ACCEPT",
    "~CANCEL",
    "~PAD_",
}

local function getAllIndexes(label, substr)
    local first = 0
    local result = {}
    while true do
        first = label:find(substr, first + 1)
        if not first then break end
        table.insert(result, first)
    end
    return result
end

function ReplaceRstarColorsWith(label, color)
    if not label:find("~") then return label end
    local findIndexes = getAllIndexes(label, "~")

    local tmp = label
    for i = #findIndexes - 1, 1, -2 do
        local index = findIndexes[i]
        local length = findIndexes[i + 1] - index + 1
        local toContinue = false
        for k, v in pairs(ignoredFormats) do
            if string.starts(tmp:sub(index, length), v) then
                toContinue = true
                break
            end
        end
        if not toContinue then
            local char = tmp:sub(index, length)
            tmp = tmp:gsub(char, color)
        end
    end
    return tmp
end

function IsStringIconFormatted(label)
    if not label:find("~") then return false end
    local findIndexes = getAllIndexes(label, "~")
    local tmp = label
    local toContinue = false
    for i = #findIndexes - 1, 1, -2 do
        local index = findIndexes[i]
        local length = findIndexes[i + 1] - index + 1
        for k, v in pairs(visualFormats) do
            if string.starts(tmp:sub(index, length), v) then
                toContinue = true
                break
            end
        end
    end
    return toContinue
end

function MsFromLength(length, time)
    return length * time
end

function ParseColorInput(input)
    if not input then return nil end
    -- Se è già un oggetto SColor (interno)
    if input.ToArgb then return input end
    -- Se è una tabella {r, g, b, a} o {R, G, B, A}
    if type(input) == "table" then
        local r = input.r or input.R or 255
        local g = input.g or input.G or 255
        local b = input.b or input.B or 255
        local a = input.a or input.A or 255
        return SColor.FromArgb(a, r, g, b)
    end
    -- Se è un numero intero (ARGB)
    if type(input) == "number" then
        return SColor.FromArgb(input)
    end
    return nil
end

function ParseCrewTagInput(rawString)
    if type(rawString) ~= "string" or #rawString < 4 then
        return nil
    end

    local char1 = string.sub(rawString, 1, 1)
    local isPrivate = (char1 == "(")
    local char2 = string.sub(rawString, 2, 2)
    local containsRockstar = (char2 == "*")
    local hexLength = 6
    local hexColorStr = string.sub(rawString, -hexLength)
    local crewColor = SColor.FromHex and SColor.FromHex(hexColorStr) or SColor.HUD_White
    local middlePart = string.sub(rawString, 3, -(hexLength + 1))
    local levelStr, tagStr = string.match(middlePart, "^(%d+)(.+)$")
    local level = 0
    if levelStr then
        level = tonumber(levelStr)
    else
        tagStr = middlePart
    end
    return CrewTag.New(tagStr, isPrivate, containsRockstar, level, crewColor)
end

function isUrl(v) -- used to check for DUI textures in files.
    return type(v) == "string" and (v:sub(1, 7) == "http://" or v:sub(1, 8) == "https://")
end

function GetStringWidth(label)
    SetTextFont(0) -- set the default font to $Font2 or Chalet-London (classic)
    SetTextScale(0.0, 0.35) -- FIX this makes the text the right size for the screen.
    BeginTextCommandGetWidth(label)
    return EndTextCommandGetWidth(true) * 1280
end
