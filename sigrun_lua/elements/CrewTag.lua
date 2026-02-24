---@enum CrewHierarchy
CrewHierarchy = {
    Leader = 0,
    Commissioner = 1,
    Liutenant = 3,
    Representative = 4,
    Muscle = 5,
    Generic = 6
}

CrewTag = setmetatable({}, CrewTag)
CrewTag.__index = CrewTag
CrewTag.__call = function()
    return "CrewTag"
end

---@class CrewTag
---@field TAG string


---@param tag? string
---@param crewTypeIsPrivate? boolean
---@param crewTagContainsRockstar? boolean
---@param level? number|CrewHierarchy
---@param crewColor? SColor
---@return table
function CrewTag.New(tag, crewTypeIsPrivate, crewTagContainsRockstar, level, crewColor)
    local hexColor
    hexColor = crewColor and crewColor:ToHexRGB() or SColor.HUD_White:ToHexRGB()

    local result = "";
    if tag ~= nil and tag ~= "" then
        if crewTypeIsPrivate then result = result .. "(" else result = result .. " " end
        if crewTagContainsRockstar then result = result .. "*" else result = result .. " " end
        result = result .. level
        result = result .. string.upper(tag)
        result = result .. hexColor
    end
    local data = {
        tag = tag,
        IsPrivate = crewTypeIsPrivate,
        ContainsRockstar = crewTagContainsRockstar,
        level = level,
        crewColor = crewColor,
        TAG = result
    }
    return setmetatable(data, CrewTag)
end

--- used internally only!!
function CrewTag.FromTag(rawString)
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
    local data = {
        tag = tagStr,
        IsPrivate = isPrivate,
        ContainsRockstar = containsRockstar,
        level = level,
        crewColor = crewColor,
        TAG = rawString
    }

    return setmetatable(data, CrewTag)
end