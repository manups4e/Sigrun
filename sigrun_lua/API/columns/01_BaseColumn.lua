BaseColumn = {}
BaseColumn.__index = BaseColumn

---@class BaseColumn
---@field public position number Column position index (0: Left, 1: Center, 2: Right)
---@field public index number Current selected item index
---@field public columnVisible boolean Internal visibility state of the column
---@field public Items BaseItem[] List of items contained in the column
---@field public VisibleItems number Maximum items displayed at once
---@field public Focused boolean Whether the column is currently receiving input
---@field public Label string Column display label
---@field public BGColor SColor Background color of the column
---@field public Parent BaseTab|nil Reference to the parent tab
BaseColumn = {}
BaseColumn.__index = BaseColumn

---Creates a new BaseColumn instance.
---@param pos number|nil Column position index
---@return BaseColumn
function BaseColumn.New(pos)
    local data = {
        position = pos or -1,
        index = 1,
        columnVisible = true,
        Items = {},
        VisibleItems = 16,
        Focused = false,
        Label = "",
        BGColor = SColor.FromArgb(255, 61, 91, 109),
        Parent = nil
    }
    return setmetatable(data, BaseColumn)
end

---Checks if the column is currently visible on screen.
---@return boolean
function BaseColumn:visible()
    return self.Parent ~= nil and self.Parent.Visible and self.Parent.Parent ~= nil and self.Parent.Parent:Visible()
end

---Gets the currently selected item object.
---@return BaseItem|nil
function BaseColumn:CurrentItem()
    return self.Items[self.index]
end

---Gets or sets the current selection index, handling disabled items.
---@param index number|nil
---@return number
function BaseColumn:Index(index)
    if index == nil then return self.index end
    if #self.Items == 0 then return 1 end

    -- Deselect old item
    if self.Items[self.index] then self.Items[self.index]:Selected(false) end

    local idx = math.min(math.max(1, index), #self.Items)

    -- Skip disabled items
    if self.Items[idx] and not self.Items[idx].enabled then
        local startIdx = idx
        repeat
            idx = idx + 1
            if idx > #self.Items then idx = 1 end
            if idx == startIdx then break end
        until self.Items[idx].enabled
    end

    self.index = idx
    if self.Items[self.index] then self.Items[self.index]:Selected(true) end

    if self:visible() then
        SH.scaleform:CallFunction("SET_COLUMN_HIGHLIGHT", self.position, self.index - 1)
    end
    return self.index
end

---Toggles or returns column visibility.
---@param bool boolean|nil
---@return boolean|nil
function BaseColumn:ColumnVisible(bool)
    if bool == nil then return self.columnVisible end
    self.columnVisible = bool
    if self:visible() then
        SH.scaleform:CallFunction("SHOW_COLUMN", self.position, self.columnVisible)
    end
end

---Adds an item to the column's collection.
---@param item BaseItem
function BaseColumn:AddItem(item)
    table.insert(self.Items, item)
end

---Resets the column by clearing all items and resetting the index.
function BaseColumn:ClearColumn()
    self.Items = {}
    self.index = 1
    if self:visible() then
        SH.scaleform:CallFunction("SET_DATA_SLOT_EMPTY", self.position)
    end
end

---Legacy alias for ClearColumn.
function BaseColumn:Clear()
    self:ClearColumn()
end

---Removes a slot at the given index and updates selection.
---@param idx number
function BaseColumn:RemoveSlot(idx)
    if idx > #self.Items then return end

    if self.Items[idx] then self.Items[idx]:Selected(false) end
    table.remove(self.Items, idx)

    if self:visible() then
        SH.scaleform:CallFunction("REMOVE_DATA_SLOT", self.position, 0, idx - 1)
    end

    if #self.Items > 0 then
        self:Index(math.min(self.index, #self.Items))
    else
        self.index = 1
    end
end

-- Virtual methods for interaction
function BaseColumn:Populate() end

function BaseColumn:GoUp() end

function BaseColumn:GoDown() end

function BaseColumn:GoLeft() end

function BaseColumn:GoRight() end

function BaseColumn:Select() end

function BaseColumn:GoBack() end

---Sends the display command to the scaleform.
function BaseColumn:ShowColumn()
    if self:visible() then
        SH.scaleform:CallFunction("DISPLAY_DATA_SLOT", self.position, 0)
    end
end

---Updates the background color of the column.
---@param color SColor
function BaseColumn:SetBGColor(color)
    self.BGColor = color
    if self:visible() then
        SH.scaleform:CallFunction("SET_COLUMN_BG_COLOR", self.position, self.BGColor:ToArgb())
    end
end

---Initializes the scroll bar parameters.
function BaseColumn:InitColumnScroll(visible, visibleItems, maxItems, index, override, xColOffset)
    if self:visible() then
        SH.scaleform:CallFunction("INIT_SCROLL_BAR", self.position, visible, visibleItems, maxItems, (index or 1) - 1,
            override or false, xColOffset or 0.0)
    end
end

---Updates the scroll bar position and appearance.
---Supports multiple overload signatures for scaleform compatibility.
function BaseColumn:SetColumnScroll(...)
    if not self:visible() then return end
    local args = { ... }
    local count = select("#", ...)

    -- Signature: currentPos, maxPos, maxVisible, caption, forceInvisible, captionR
    if count >= 3 and type(args[1]) == "number" then
        SH.scaleform:CallFunction("SET_SCROLL_BAR", self.position, args[1], args[2], args[3] or -1, args[4], args[5],
            args[6] or "")

        -- Signature: caption, rightCaption
    elseif count >= 1 and type(args[1]) == "string" then
        BeginScaleformMovieMethod(SH.scaleform.handle, "SET_SCROLL_BAR")
        PushScaleformMovieFunctionParameterInt(self.position)
        PushScaleformMovieFunctionParameterInt(0) -- pos
        PushScaleformMovieFunctionParameterInt(0) -- max
        PushScaleformMovieFunctionParameterInt(0) -- visible

        BeginTextCommandScaleformString(args[1])
        for i = 2, count do
            local arg = args[i]
            if type(arg) == "number" then
                if math.type(arg) == "integer" then AddTextComponentInteger(arg) else AddTextComponentFloat(arg, 2) end
            elseif type(arg) == "string" then
                AddTextComponentSubstringPlayerName(arg)
            end
        end
        EndTextCommandScaleformString_2()

        if args[2] and type(args[2]) == "string" then
            PushScaleformMovieFunctionParameterBool(false)
            PushScaleformMovieMethodParameterString(args[2])
        end
        EndScaleformMovieMethod()
    end
end
