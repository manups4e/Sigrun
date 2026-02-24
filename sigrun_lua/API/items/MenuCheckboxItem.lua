---@class MenuCheckboxItem : MenuItem
---@field public _Checked boolean Internal state of the checkbox
---@field public CheckBoxStyle number Style index for the checkbox (e.g., cross, tick)
---@field public OnCheckboxChanged fun(tab: BaseTab, item: MenuCheckboxItem, checked: boolean) Callback triggered when the state changes
MenuCheckboxItem = {}
MenuCheckboxItem.__index = MenuCheckboxItem
setmetatable(MenuCheckboxItem, { __index = MenuItem })
MenuCheckboxItem.__call = function() return "MenuCheckboxItem" end

---Creates a new MenuCheckboxItem instance.
---@param Text string The item label
---@param Check boolean Initial checked state
---@param checkStyle number|nil Optional style index
---@param Description string|table Description text or table
---@param color SColor|nil Custom background color
---@param highlightColor SColor|nil Custom highlight color
---@return MenuCheckboxItem
function MenuCheckboxItem.New(Text, Check, checkStyle, Description, color, highlightColor)
    local base = MenuItem.New(Text or "", Description or "", color, highlightColor)
    base._Checked = ToBool(Check)
    base.CheckBoxStyle = checkStyle or 0
    base.ItemId = 2 -- Fixed ID for Checkbox items in Scaleform
    
    -- Default callback placeholder
    base.OnCheckboxChanged = function(tab, item, checked) end
    
    return setmetatable(base, MenuCheckboxItem)
end

---Gets or sets the checked state of the item.
---@param bool boolean|nil New state to set
---@return boolean|nil Current state if no parameter is provided
function MenuCheckboxItem:Checked(bool)
    if bool ~= nil then
        self._Checked = ToBool(bool)
        if self.ParentColumn ~= nil then
            local it = IndexOf(self.ParentColumn.Items, self)
            self.ParentColumn:SendItemToScaleform(it, true)
        end
    else
        return self._Checked
    end
end

---------------------------
-- Unsupported Methods
---------------------------
-- These methods are overridden to prevent usage on Checkbox items 
-- as they are not supported by the Scaleform layout.

function MenuCheckboxItem:RightLabelFont(itemFont)
    error("MenuCheckboxItem does not support a right label")
end

function MenuCheckboxItem:RightBadge()
    error("MenuCheckboxItem does not support right badges")
end

function MenuCheckboxItem:RightLabel()
    error("MenuCheckboxItem does not support a right label")
end

function MenuCheckboxItem:SetSubColumn(itemListColumn, newTitle, showArrow, hideTabs)
    error("MenuCheckboxItem does not support subcolumns by nature")
end