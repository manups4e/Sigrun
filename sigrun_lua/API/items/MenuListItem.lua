---@class MenuListItem : MenuDynamicListItem
---@field public Items table Array of items (strings, numbers or tables) to scroll through
---@field public _Index number Current selection index within the Items table
---@field public OnListChanged fun(tab: BaseTab, item: MenuListItem, newIndex: number) Callback for index change
---@field public OnListSelected fun(tab: BaseTab, item: MenuListItem, index: number) Callback for item activation
MenuListItem = {}
MenuListItem.__index = MenuListItem
setmetatable(MenuListItem, { __index = MenuDynamicListItem })
MenuListItem.__call = function() return "MenuListItem" end

---Creates a new MenuListItem instance.
---@param Text string The item label
---@param Items table The list of values to scroll through
---@param Index number Initial starting index
---@param Description string|table Description text or table
---@param color SColor|nil Custom background color
---@param highlightColor SColor|nil Custom highlight color
---@return MenuListItem
function MenuListItem.New(Text, Items, Index, Description, color, highlightColor)
    if type(Items) ~= "table" then Items = {} end
    local startIndex = tonumber(Index) or 1
    if startIndex < 1 then startIndex = 1 end

    -- Base dynamic item creation
    local base = MenuDynamicListItem.New(Text or "", Description or "", "", nil, color, highlightColor)
    base.Items = Items
    base._Index = startIndex
    
    -- Default event placeholders
    base.OnListChanged = function(tab, item, newindex) end
    base.OnListSelected = function(tab, item, index) end
    
    local meta = setmetatable(base, MenuListItem)
    
    -- Set initial display value
    if #meta.Items > 0 then
        meta:CurrentListItem(tostring(meta.Items[meta._Index]))
    else
        meta:CurrentListItem("")
    end
    
    return meta
end

---Gets or sets the current index of the list.
---@param Index number|nil New index to set
---@return number|nil Current index if no parameter is provided
function MenuListItem:Index(Index)
    if Index == nil then return self._Index end
    
    local newIndex = tonumber(Index)
    if newIndex then
        -- Wrap around logic
        if newIndex > #self.Items then
            self._Index = 1
        elseif newIndex < 1 then
            self._Index = #self.Items
        else
            self._Index = newIndex
        end

        -- Update visual label
        if #self.Items > 0 then
            self:CurrentListItem(tostring(self.Items[self._Index]))
        else
            self:CurrentListItem("")
        end
    end
end

---Finds the index of a specific item within the list.
---Supports direct comparison or matching by .Name/.Value if the list contains tables.
---@param Item any
---@return number|nil
function MenuListItem:ItemToIndex(Item)
    for i = 1, #self.Items do
        local current = self.Items[i]
        if Item == current then
            return i
        elseif type(current) == "table" then
            if Item == current.Name or Item == current.Value then
                return i
            end
        end
    end
    return nil
end

---Returns the item object at a specific index.
---@param Index number
---@return any|nil
function MenuListItem:IndexToItem(Index)
    local idx = tonumber(Index)
    if idx then
        if idx == 0 then idx = 1 end
        return self.Items[idx]
    end
    return nil
end

---Replaces the current list with a new one and resets the index.
---@param list table New array of items
---@param index number|nil Starting index in the new list
function MenuListItem:ChangeList(list, index)
    if type(list) ~= "table" then return end
    
    self.Items = list
    local targetIndex = index or 1
    
    if targetIndex < 1 or targetIndex > #self.Items then
        targetIndex = 1
    end
    
    self:Index(targetIndex)

    -- Refresh scaleform if attached to a column
    if self.ParentColumn ~= nil then
        local it = IndexOf(self.ParentColumn.Items, self)
        self.ParentColumn:SendItemToScaleform(it, true)
    end
end