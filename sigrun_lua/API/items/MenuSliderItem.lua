---@class MenuSliderItem : MenuItem
---@field public _Index number Current value of the slider
---@field public _Max number Maximum value allowed for the slider
---@field public _Multiplier number The step increment/decrement value
---@field public _heritage boolean Special visual flag for heritage-style sliders
---@field public _sliderColor SColor Color of the slider toggle/bar
---@field public OnSliderChanged fun(tab: BaseTab, item: MenuSliderItem, newIndex: number) Callback for value change
---@field public OnSliderSelected fun(tab: BaseTab, item: MenuSliderItem, index: number) Callback for item activation
MenuSliderItem = {}
MenuSliderItem.__index = MenuSliderItem
setmetatable(MenuSliderItem, { __index = MenuItem })
MenuSliderItem.__call = function() return "MenuSliderItem" end

---Creates a new MenuSliderItem instance.
---@param Text string The item label
---@param Max number|nil Maximum slider value (default: 100)
---@param Multiplier number|nil Step increment (default: 5)
---@param Index number|nil Initial starting value (default: 0)
---@param Heritage boolean|nil Special visual flag (default: false)
---@param Description string|table Description text or table
---@param sliderColor SColor|nil Color of the slider widget
---@param color SColor|nil Custom background color
---@param highlightColor SColor|nil Custom highlight color
---@return MenuSliderItem
function MenuSliderItem.New(Text, Max, Multiplier, Index, Heritage, Description, sliderColor, color, highlightColor)
    local base = MenuItem.New(Text or "", Description or "", color, highlightColor)
    
    base._Index = tonumber(Index) or 0
    base._Max = tonumber(Max) or 100
    base._Multiplier = Multiplier or 5
    base._heritage = Heritage or false
    base._sliderColor = sliderColor or SColor.HUD_Freemode
    base.ItemId = 3 -- Standard ID for Slider items in Scaleform
    
    -- Default event placeholders
    base.OnSliderChanged = function(tab, item, newindex) end
    base.OnSliderSelected = function(tab, item, newindex) end
    
    return setmetatable(base, MenuSliderItem)
end

---Gets or sets the color of the slider widget.
---@param color SColor|nil
---@return SColor|nil Current color if no parameter is provided
function MenuSliderItem:SliderColor(color)
    if color then
        self._sliderColor = color
        if self.ParentColumn ~= nil then
            local it = IndexOf(self.ParentColumn.Items, self)
            self.ParentColumn:SendItemToScaleform(it, true)
        end
    else
        return self._sliderColor
    end
end

---Gets or sets the current slider index with clamping.
---@param Index number|nil New value to set
---@return number|nil Current value if no parameter is provided
function MenuSliderItem:Index(Index)
    if Index ~= nil then
        local newIdx = tonumber(Index)
        if newIdx then
            -- Clamp value between 0 and Max
            if newIdx > self._Max then
                self._Index = self._Max
            elseif newIdx < 0 then
                self._Index = 0
            else
                self._Index = newIdx
            end

            -- Trigger callback (Passing ParentTab as context)
            self.OnSliderChanged(self.ParentTab, self, self._Index)

            if self.ParentColumn ~= nil then
                local it = IndexOf(self.ParentColumn.Items, self)
                self.ParentColumn:SendItemToScaleform(it, true)
            end
        end
    else
        return self._Index
    end
end

---------------------------
-- Unsupported Methods
---------------------------
-- Sliders occupy the right side of the menu slot for the widget interaction.

function MenuSliderItem:RightLabelFont(itemFont)
    error("MenuSliderItem does not support a right label font override")
end

function MenuSliderItem:RightBadge()
    error("MenuSliderItem does not support right badges")
end

function MenuSliderItem:RightLabel()
    error("MenuSliderItem does not support a right label")
end