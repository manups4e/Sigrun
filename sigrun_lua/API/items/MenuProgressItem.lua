---@class MenuProgressItem : MenuItem
---@field public _Max number Maximum value of the progress bar
---@field public _Index number Current value/index of the progress bar
---@field public _Multiplier number Step multiplier for navigation
---@field public _sliderColor SColor Color of the filled progress bar
---@field public BackgroundSliderColor SColor Background color of the slider track
---@field public OnProgressChanged fun(newIndex: number) Callback triggered when the value changes
---@field public OnProgressSelected fun(tab: BaseTab, item: MenuProgressItem, index: number) Callback triggered on activation
MenuProgressItem = {}
MenuProgressItem.__index = MenuProgressItem
setmetatable(MenuProgressItem, { __index = MenuItem })
MenuProgressItem.__call = function() return "MenuProgressItem" end

---Creates a new MenuProgressItem instance (Progress Bar).
---@param Text string The item label
---@param Max number|nil Maximum progress value (default: 100)
---@param Index number|nil Initial progress value (default: 0)
---@param Description string|table Description text or table
---@param sliderColor SColor|nil Progress bar fill color
---@param color SColor|nil Custom background color
---@param highlightColor SColor|nil Custom highlight color
---@param backgroundSliderColor SColor|nil Slider track background color
---@return MenuProgressItem
function MenuProgressItem.New(Text, Max, Index, Description, sliderColor, color, highlightColor, backgroundSliderColor)
    local base = MenuItem.New(Text or "", Description or "", color, highlightColor)
    base._Max = Max or 100
    base._Multiplier = 5
    base._Index = Index or 0
    base._sliderColor = sliderColor or SColor.HUD_Freemode
    base.BackgroundSliderColor = backgroundSliderColor or SColor.HUD_Pause_bg
    base.ItemId = 4 -- ItemId 4 is standard for Progress/Slider bars in Scaleform

    -- Default event placeholders
    base.OnProgressChanged = function(newindex) end
    base.OnProgressSelected = function(tab, item, newindex) end

    return setmetatable(base, MenuProgressItem)
end

---Gets or sets the progress bar fill color.
---@param color SColor|nil
---@return SColor|nil Current color if no parameter is provided
function MenuProgressItem:SliderColor(color)
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

---Gets or sets the current progress index.
---@param index number|nil New value to set
---@return number|nil Current value if no parameter is provided
function MenuProgressItem:Index(index)
    if index ~= nil then
        local newIdx = tonumber(index)
        if newIdx then
            -- Clamp value between 0 and Max
            if newIdx > self._Max then
                self._Index = self._Max
            elseif newIdx < 0 then
                self._Index = 0
            else
                self._Index = newIdx
            end

            self.OnProgressChanged(self._Index)

            if self.ParentColumn ~= nil then
                local it = IndexOf(self.ParentColumn.Items, self)
                self.ParentColumn:SendItemToScaleform(it, true)
            end
        end
    else
        return self._Index
    end
end

---Alias for the Index method.
---@param index number
function MenuProgressItem:Value(index)
    return self:Index(index)
end

---------------------------
-- Unsupported Methods
---------------------------
-- Progress items use the right side of the slot to display the bar widget.

function MenuProgressItem:RightLabelFont(itemFont)
    error("MenuProgressItem does not support a right label font override")
end

function MenuProgressItem:RightBadge()
    error("MenuProgressItem does not support right badges")
end

function MenuProgressItem:RightLabel()
    error("MenuProgressItem does not support a right label")
end
