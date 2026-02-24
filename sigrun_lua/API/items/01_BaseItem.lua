
---@class BaseItem
---@field protected selected boolean Indicates whether the item is currently highlighted
---@field protected enabled boolean Indicates whether the item can be interacted with
---@field public label string The primary text displayed on the item
---@field public ParentTab BaseTab|nil Reference to the parent tab containing this item
---@field public ParentColumn BaseColumn|nil Reference to the column containing this item

BaseItem = setmetatable({}, BaseItem)
BaseItem.__index = BaseItem
BaseItem.__call = function()
    return "BaseItem", "BaseItem"
end

---Creates a new BaseItem instance.
---@param label string The text to display
---@param labelFont string|nil Optional font override for the label
---@return BaseItem
function BaseItem.New(label, labelFont)
    local data = {
        label = label or "",
        labelFont = labelFont or nil, -- Added for consistency with SendItemToScaleform
        selected = false,
        enabled = true,
        ParentTab = nil,
        ParentColumn = nil,
    }
    return setmetatable(data, BaseItem)
end

---Gets or sets the selection state of the item.
---@param bool boolean|nil New selected state
---@return boolean|nil Current state if no parameter is provided
function BaseItem:Selected(bool)
    if bool == nil then
        return self.selected
    else
        self.selected = bool
    end
end

---Gets or sets the enabled state of the item.
---@param bool boolean|nil New enabled state
---@return boolean|nil Current state if no parameter is provided
function BaseItem:Enabled(bool)
    if bool == nil then
        return self.enabled
    else
        self.enabled = bool
    end
end

---Returns the label of the item.
---@param text string|nil Optional new label to set
---@return string
function BaseItem:Label(text)
    if text ~= nil then
        self.label = text
    end
    return self.label
end