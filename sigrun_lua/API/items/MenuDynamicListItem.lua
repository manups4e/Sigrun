---@class MenuDynamicListItem : MenuItem
---@field public _currentItem string The text currently displayed as the list value
---@field public Callback fun(tab: BaseTab, item: MenuDynamicListItem, direction: string) Callback for list navigation
---@field public OnListSelected fun(tab: BaseTab, item: MenuDynamicListItem, index: number) Callback for item activation
MenuDynamicListItem = {}
MenuDynamicListItem.__index = MenuDynamicListItem
setmetatable(MenuDynamicListItem, { __index = MenuItem })
MenuDynamicListItem.__call = function() return "MenuDynamicListItem" end

---Creates a new MenuDynamicListItem instance.
---@param Text string The item label
---@param Description string|table Description text or table
---@param StartingItem string Initial value to display in the list
---@param callback function Navigation callback
---@param color SColor|nil Custom background color
---@param highlightColor SColor|nil Custom highlight color
---@return MenuDynamicListItem
function MenuDynamicListItem.New(Text, Description, StartingItem, callback, color, highlightColor)
    local base = MenuItem.New(Text or "", Description or "", color, highlightColor)
    base._currentItem = StartingItem
    base.Callback = callback
    base.ItemId = 1 -- Dynamic lists use the same Slot ID as standard lists in Scaleform
    
    -- Default activation callback
    base.OnListSelected = function(tab, item, index) end
    
    return setmetatable(base, MenuDynamicListItem)
end

---Gets or sets the current text value of the list item.
---@param item string|nil New text to display
---@return string|nil Current text if no parameter is provided
function MenuDynamicListItem:CurrentListItem(item)
    if item == nil then
        return tostring(self._currentItem)
    else
        self._currentItem = item
        if self.ParentColumn ~= nil then
            local it = IndexOf(self.ParentColumn.Items, self)
            self.ParentColumn:SendItemToScaleform(it, true)
        end
    end
end

---Formats the list string with appropriate Rockstar colors based on selection and enabled state.
---@return string Formatted string for Scaleform
function MenuDynamicListItem:createListString()
    local value = self._currentItem
    if type(value) ~= "string" then
        value = tostring(value)
    end

    -- Ensure base color is set
    if not value:find("^~") then
        value = "~s~" .. value
    end

    -- Handle text color based on selection (Invert to black if selected)
    if self:Selected() then
        value = value:gsub("~w~", "~l~")
        value = value:gsub("~s~", "~l~")
    else
        value = value:gsub("~l~", "~s~")
    end

    -- Force grey color if the item is disabled
    if not self:Enabled() then
        value = ReplaceRstarColorsWith(value, "~c~")
    end

    return value
end

---------------------------
-- Unsupported Methods
---------------------------
-- Dynamic List items handle their right-side content internally within the list widget.

function MenuDynamicListItem:RightLabelFont(itemFont)
    error("MenuDynamicListItem does not support a right label font override")
end

function MenuDynamicListItem:RightBadge()
    error("MenuDynamicListItem does not support right badges")
end

function MenuDynamicListItem:RightLabel()
    error("MenuDynamicListItem does not support a right label")
end