---@class MenuSeparatorItem : MenuItem
---@field public Jumpable boolean If true, the menu cursor will skip this item during navigation
MenuSeparatorItem = {}
MenuSeparatorItem.__index = MenuSeparatorItem
setmetatable(MenuSeparatorItem, { __index = MenuItem })
MenuSeparatorItem.__call = function() return "MenuSeparatorItem" end

---Creates a new MenuSeparatorItem instance, used to organize items into sections.
---@param Text string The separator label
---@param jumpable boolean Whether the cursor should skip this item when scrolling
---@param mainColor SColor|nil Custom background color
---@param highlightColor SColor|nil Custom highlight color
---@return MenuSeparatorItem
function MenuSeparatorItem.New(Text, jumpable, mainColor, highlightColor)
    -- Separators usually don't have descriptions, passed as empty string
    local base = MenuItem.New(Text or "", "", mainColor, highlightColor)
    
    base.Jumpable = jumpable or false
    base.ItemId = 6 -- ItemId 6 is designated for separators in the Scaleform
    
    return setmetatable(base, MenuSeparatorItem)
end

---------------------------
-- Unsupported Methods
---------------------------
-- Separators are purely visual and do not support interactive widgets or badges.

function MenuSeparatorItem:RightLabelFont(itemFont)
    error("MenuSeparatorItem does not support a right label font override")
end

function MenuSeparatorItem:LeftBadge()
    error("MenuSeparatorItem does not support badges")
end

function MenuSeparatorItem:RightBadge()
    error("MenuSeparatorItem does not support badges")
end

function MenuSeparatorItem:RightLabel()
    error("MenuSeparatorItem does not support a right label")
end