---@class MenuItem : BaseItem
---@field public Descriptions table<number, table> List of description objects {label, color, txd, txn}
---@field public LabelFont string Font name for the primary label
---@field public _rightLabelFont string Font name for the secondary label
---@field public _Hovered boolean Whether the item is being hovered by the mouse
---@field public blinkDescription boolean Whether the description text should blink
---@field public _rightLabel string Text displayed on the right side of the item
---@field public keepWhite boolean If true, forces text color to remain white
---@field public _mainColor SColor Background color of the item
---@field public _highlightColor SColor Color used when the item is selected
---@field public _itemData table Custom user data associated with the item
---@field public ParentMenu Sigrun|nil Reference to the parent menu
---@field public ParentColumn ItemListColumn|nil Reference to the parent column
---@field public ItemId number Scaleform item type identifier
---@field public LeftIcon table {TXD, TXN} Icons displayed on the left
---@field public RightIcon table {TXD, TXN} Icons displayed on the right
---@field public _isImportant boolean Whether to show the importance highlight
---@field public _importantColor SColor Color of the importance highlight
---@field public _importantAnimate boolean Whether the importance highlight animates
---@field public Activated fun(tab: BaseTab, item: MenuItem) Callback for item selection
---@field public Highlighted fun(tab: BaseTab, item: MenuItem) Callback for item highlight
---@field public OnTabPressed fun(tab: BaseTab) Callback for tab key interaction
MenuItem = {}
MenuItem.__index = MenuItem
setmetatable(MenuItem, { __index = BaseItem })
MenuItem.__call = function() return "MenuItem" end

---Creates a new MenuItem instance.
---@param text string The item label
---@param description string|table Initial description text or table of descriptions
---@param color SColor|nil Custom background color
---@param highlightColor SColor|nil Custom highlight color
---@return MenuItem
function MenuItem.New(text, description, color, highlightColor)
    local base = BaseItem.New(text)
    
    -- Initialize the three supported description slots
    base.Descriptions = {
        [1] = { label = "", color = SColor.HUD_Pure_white, txd = "", txn = "" },
        [2] = { label = "", color = SColor.HUD_Pure_white, txd = "", txn = "" },
        [3] = { label = "", color = SColor.HUD_Pure_white, txd = "", txn = "" }
    }

    -- Handle description input (single string or formatted table)
    if type(description) == "table" then
        for k, v in pairs(description) do
            if type(v) == "table" then
                base.Descriptions[k] = v
            elseif type(v) == "string" then
                base.Descriptions[k].label = tostring(v)
            end
        end
    else
        base.Descriptions[1].label = description and tostring(description) or ""
    end

    base.LabelFont = "$Font2"
    base._rightLabelFont = "$Font2"
    base._Hovered = false
    base.blinkDescription = false
    base._rightLabel = ""
    base.keepWhite = false
    base._mainColor = color or SColor.HUD_Pause_bg
    base._highlightColor = highlightColor or SColor.HUD_Pure_white
    base._itemData = {}
    base.ParentMenu = nil
    base.ParentColumn = nil
    base.ItemId = 0
    base.LeftIcon = { TXD = "", TXN = "", mainColor = SColor.HUD_White, highlightColor = SColor.HUD_Black }
    base.RightIcon = { TXD = "", TXN = "", mainColor = SColor.HUD_White, highlightColor = SColor.HUD_Black }
    base._isImportant = false
    base._importantColor = SColor.HUD_Pure_white
    base._importantAnimate = false

    -- Default event placeholders
    base.Activated = function(tab, item) end
    base.Highlighted = function(tab, item) end
    base.OnTabPressed = function(tab) end

    return setmetatable(base, MenuItem)
end

---Gets or sets custom data for the item.
---@param data table|nil
---@return table|nil
function MenuItem:ItemData(data)
    if data == nil then return self._itemData end
    self._itemData = data
end

---Forces the text color to stay white regardless of selection.
---@param keep boolean|nil
---@return boolean|nil
function MenuItem:KeepTextColorWhite(keep)
    if keep == nil then return self.keepWhite end
    self.keepWhite = ToBool(keep)
    if self.ParentColumn then
        local it = IndexOf(self.ParentColumn.Items, self)
        self.ParentColumn:SendItemToScaleform(it, true)
    end
end

---Sets the font for the primary (left) label.
---@param font string|nil
---@return string|nil
function MenuItem:LeftLabelFont(font)
    if font == nil then return self.LabelFont end
    self.LabelFont = font
    if self.ParentColumn then
        local it = IndexOf(self.ParentColumn.Items, self)
        self.ParentColumn:SendItemToScaleform(it, true)
    end
end

---Sets the font for the secondary (right) label.
---@param font string|nil
---@return string|nil
function MenuItem:RightLabelFont(font)
    if font == nil then return self._rightLabelFont end
    self._rightLabelFont = font
    if self.ParentColumn then
        local it = IndexOf(self.ParentColumn.Items, self)
        self.ParentColumn:SendItemToScaleform(it, true)
    end
end

---Updates the selection state and refreshes the Scaleform view.
---@param bool boolean|nil
---@return boolean|nil
function MenuItem:Selected(bool)
    if bool ~= nil then
        self.selected = ToBool(bool)
        if self.ParentColumn then
            self.Highlighted(self.ParentColumn.Parent, self)
            local it = IndexOf(self.ParentColumn.Items, self)
            self.ParentColumn:SendItemToScaleform(it, true)
        end
    else
        return self.selected
    end
end

---Sets whether the item is being hovered by the mouse.
---@param bool boolean|nil
---@return boolean|nil
function MenuItem:Hovered(bool)
    if bool ~= nil then self._Hovered = ToBool(bool)
    else return self._Hovered end
end

---Updates the enabled state and refreshes the Scaleform view.
---@param bool boolean|nil
---@return boolean|nil
function MenuItem:Enabled(bool)
    if bool ~= nil then
        self.enabled = ToBool(bool)
        if self.ParentColumn then
            local it = IndexOf(self.ParentColumn.Items, self)
            self.ParentColumn:SendItemToScaleform(it, true)
        end
    else
        return self.enabled
    end
end

---Adds a visual highlight (importance indicator) to the item.
---@param isImportant boolean Enable/disable highlight
---@param highlightColor SColor|nil Defaults to HUD_Pure_white
---@param animate boolean|nil Breathing effect
function MenuItem:IsImportant(isImportant, highlightColor, animate)
    if isImportant == nil then return self._isImportant end
    self._isImportant = isImportant
    self._importantColor = highlightColor or SColor.HUD_Pure_white
    self._importantAnimate = animate or false
    
    if self.ParentColumn then
        local it = IndexOf(self.ParentColumn.Items, self)
        self.ParentColumn:SendItemToScaleform(it, true)
    end
end

---Configures specific description slots.
---@param index number (1-3)
---@param str string Description text
---@param color SColor|nil Text color
---@param txd string|nil Texture dictionary for icon
---@param txn string|nil Texture name for icon
function MenuItem:Description(index, str, color, txd, txn)
    index = index or 1
    if index < 1 or index > 3 then return end

    if str ~= nil then self.Descriptions[index].label = tostring(str) end
    if color ~= nil then self.Descriptions[index].color = color end
    
    self.Descriptions[index].txd = txd and tostring(txd) or ""
    self.Descriptions[index].txn = txn and tostring(txn) or ""

    if self.ParentColumn then
        self.ParentColumn:UpdateDescription()
    end
end

---Sets the primary background color.
---@param color SColor|nil
---@return SColor|nil
function MenuItem:MainColor(color)
    if color then
        self._mainColor = color
        if self.ParentColumn then
            local it = IndexOf(self.ParentColumn.Items, self)
            self.ParentColumn:SendItemToScaleform(it, true)
        end
    else
        return self._mainColor
    end
end

---Sets the background color used when highlighted.
---@param color SColor|nil
---@return SColor|nil
function MenuItem:HighlightColor(color)
    if color then
        self._highlightColor = color
        if self.ParentColumn then
            local it = IndexOf(self.ParentColumn.Items, self)
            self.ParentColumn:SendItemToScaleform(it, true)
        end
    else
        return self._highlightColor
    end
end

---Sets the primary text of the item.
---@param text string|nil
---@return string|nil
function MenuItem:Label(text)
    if text ~= nil then
        self.label = tostring(text)
        if self.ParentColumn then
            local it = IndexOf(self.ParentColumn.Items, self)
            self.ParentColumn:SendItemToScaleform(it, true)
        end
    else
        return self.label
    end
end

---Sets the text displayed on the right side.
---@param text string|nil
---@return string|nil
function MenuItem:RightLabel(text)
    if text ~= nil then
        self._rightLabel = tostring(text)
        if self.ParentColumn then
            local it = IndexOf(self.ParentColumn.Items, self)
            self.ParentColumn:SendItemToScaleform(it, true)
        end
    else
        return self._rightLabel
    end
end

---Sets a badge/icon for the right side.
---@param txd string
---@param txn string
function MenuItem:RightBadge(txd, txn, mainColor, highlightColor)
    self.RightIcon = { TXD = txd, TXN = txn, mainColor = mainColor or SColor.HUD_White, highlightColor = highlightColor or highlightColor or (mainColor or SColor.HUD_Black)}
    if self.ParentColumn then
        local it = IndexOf(self.ParentColumn.Items, self)
        self.ParentColumn:SendItemToScaleform(it, true)
    end
end

---Sets a badge/icon for the left side.
---@param txd string
---@param txn string
function MenuItem:LeftBadge(txd, txn, mainColor, highlightColor)
    self.LeftIcon = { TXD = txd, TXN = txn, mainColor = mainColor or SColor.HUD_White, highlightColor = highlightColor or highlightColor or (mainColor or SColor.HUD_Black)}
    if self.ParentColumn then
        local it = IndexOf(self.ParentColumn.Items, self)
        self.ParentColumn:SendItemToScaleform(it, true)
    end
end

---Checks if any of the description slots contain text.
---@return boolean
function MenuItem:_hasDescriptions()
    for i = 1, #self.Descriptions do
        if self.Descriptions[i].label ~= "" then
            return true
        end
    end
    return false
end

---Configures the item to push a sub-column when activated.
---@param itemListColumn ItemListColumn The sub-column to display
---@param showArrow boolean|nil Optional navigation arrow
---@param hideTabs boolean|nil Optional hide tab bar
function MenuItem:SetSubColumn(itemListColumn, showArrow, hideTabs)
    self.Activated = function(_, item)
        local tab = item.ParentColumn.Parent
        if tab then
            tab:PushColumn(itemListColumn, showArrow, hideTabs)
        end
    end
end