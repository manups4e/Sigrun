ItemListColumn = {}
ItemListColumn.__index = ItemListColumn
setmetatable(ItemListColumn, { __index = BaseColumn })
ItemListColumn.__call = function() return "ItemListColumn" end

---@class ItemListColumn : BaseColumn
---@field private _label string Column label
---@field private _color SColor Column theme color
---@field private _isBuilding boolean Prevents interaction during population
---@field private _currentSelection number Internal index tracking
---@field private _unfilteredItems table Backup collection for filtering/sorting
---@field private _rightLabel string Column secondary label
---@field public Parent BaseTab Reference to the parent tab
---@field public ParentTab number Parent tab index identifier
---@field public Items table<number, MenuItem|MenuListItem|MenuCheckboxItem|MenuSliderItem|MenuProgressItem> List of items in the column
---@field public OnIndexChanged fun(index: number) Callback triggered when selection changes
---@field public OnItemSelect fun(index: number) Callback triggered when an item is activated
---@field public AddItems fun(self: ItemListColumn, item: BaseItem) Batch add method (placeholder)


---Creates a new ItemListColumn instance.
---@param label string Column title
---@param _maxItems number|nil Maximum visible items (default: 12)
---@return ItemListColumn
function ItemListColumn.New(label, _maxItems)
    local base = BaseColumn.New(0)
    base.Label = label
    base.VisibleItems = _maxItems or 12
    base._unfilteredItems = {}
    base._unfilteredSelection = 1
    base._topEdge = 1
    base._currentlyHighlighted = 0
    base.mWidth = 300
    base.ScrollNewStyle = true
    base.OnIndexChanged = function(index) end
    base.OnItemSelect = function(index) end
    base.OnListChange = function(column, item, index) end
    return setmetatable(base, ItemListColumn)
end

---Updates the maximum visible items count.
---@param maxItems number
function ItemListColumn:SetVisibleItems(maxItems)
    self.VisibleItems = maxItems
    if self:visible() then
        self:Populate()
        self:ShowColumn()
    end
end

---Adds a new item to the column collection.
---@param item MenuItem|MenuListItem|MenuCheckboxItem|MenuSliderItem|MenuProgressItem
function ItemListColumn:AddItem(item)
    if item:MainColor() == SColor.HUD_Pause_bg then
        local color = SColor.HUD_Pause_bg
        if #self.Items % 2 == 0 then
            color = SColor.HUD_Pausemap_tint
            item:MainColor(color)
        end
    end
    item.ParentColumn = self
    table.insert(self.Items, item)

    if self:visible() then
        self:InitColumnScroll(#self.Items >= self.VisibleItems, self.VisibleItems, #self.Items, self.index)

        if #self.Items <= self.VisibleItems then
            local idx = #self.Items
            self:AddSlot(idx)
            self:UpdateDescription()
            self.Items[idx]:Selected(idx == self.index)
        end
    end
end

---Displays the column in the scaleform and handles initial highlighting.
function ItemListColumn:ShowColumn()
    if not self:visible() or #self.Items == 0 then return end
    BaseColumn.ShowColumn(self)
    SH.scaleform:CallFunction("SET_COLUMN_FOCUS", self.position, self.Focused, false, false)

    if #self.Items > 0 and self:CurrentItem().ItemId == 6 and self:CurrentItem().Jumpable then
        self:CurrentItem():Selected(false)
        self.index = self.index + 1
        if self.index > #self.Items then
            self.index = 1
        end
        self:CurrentItem():Selected(true)
    end

    SH.scaleform:CallFunction("UPDATE_MENU_WIDTH", self.mWidth, self.Parent.Parent._maxExtensionPixels)
    self:InitColumnScroll(#self.Items >= self.VisibleItems, self.VisibleItems, #self.Items, self.index)
    self:SetColumnScroll(#self.Items >= self.VisibleItems, self.index)
end

---Clears and repopulates all data slots in the scaleform.
function ItemListColumn:Populate()
    if not self:visible() then return end
    SH.scaleform:CallFunction("SET_DATA_SLOT_EMPTY", self.position)
    SH.scaleform:CallFunction("SET_COLUMN_MAX_ITEMS", self.position, self.VisibleItems)
    SH.scaleform:CallFunction("INIT_SCROLL_BAR", self.position, false, 0, 0, 0)
    for i = 1, #self.Items, 1 do
        self:SetDataSlot(i)
    end
end

---Updates the current selection index and handles disabled items logic.
---@param index number|nil
---@return number
function ItemListColumn:CurrentSelection(index)
    if index == nil then
        return self.index
    end
    if #self.Items == 0 then return 1 end
    self.Items[self.index]:Selected(false)
    local idx = math.min(math.max(1, index), #self.Items)

    if not self.Items[idx].enabled then
        local startIdx = idx
        repeat
            idx = idx + 1
            if idx > #self.Items then
                idx = 1
            end
            if idx > #self.Items then break end
        until self.Items[idx].enabled or idx == startIdx
    end

    if not self.Items[idx].enabled then
        idx = self.index
    end

    self.index = idx
    self.Items[self.index]:Selected(true)
    if self:visible() then
        self:UpdateDescription()
        SH.scaleform:CallFunction("SET_COLUMN_HIGHLIGHT", self.position, self.index - 1)
    end
    return self.index
end

---Sets a data slot at the given index and updates column width.
---@param index number
function ItemListColumn:SetDataSlot(index)
    if self.index > #self.Items then return end
    if self:visible() then
        self:SendItemToScaleform(index)
    end

    local lwidth = GetStringWidth("SIGRUN_ITMLST_LBL")
    local rwidth = GetStringWidth("SIGRUN_ITMLST_RLBL")
    if math.round(rwidth, 2) == 1.28 then
        rwidth = GetStringWidth("SIGRUN_ITMLST_LSTITM_RLBL")
    end
    local width = lwidth + rwidth
    if width > self.mWidth then
        self.mWidth = width
    end
end

---Updates an existing data slot.
---@param index number
function ItemListColumn:UpdateSlot(index)
    if self.index > #self.Items then return end
    if self:visible() then
        self:SendItemToScaleform(index, true)
    end
end

---Adds a new data slot dynamically.
---@param index number
function ItemListColumn:AddSlot(index)
    if self.index > #self.Items then return end
    if self:visible() then
        self:SendItemToScaleform(index, false, false, true)
    end

    local lwidth = GetStringWidth("SIGRUN_ITMLST_LBL")
    local rwidth = GetStringWidth("SIGRUN_ITMLST_RLBL")
    if math.round(rwidth, 2) == 1.28 then
        rwidth = GetStringWidth("SIGRUN_ITMLST_LSTITM_RLBL")
    end
    local width = lwidth + rwidth
    if width > self.mWidth then
        self.mWidth = width
    end
end

---Inserts an item at a specific index.
---@param item MenuItem
---@param index number
function ItemListColumn:AddItemAt(item, index)
    table.insert(self.Items, index, item)
    if not self:visible() then return end
    self:AddSlot(index)
    item:Selected(index == self.index)
end

---Internal method to dispatch item data to the scaleform movie.
---@param i number Index
---@param update boolean|nil True to update existing slot
---@param newItem boolean|nil True for spliced data
---@param isSlot boolean|nil True for adding a new slot
function ItemListColumn:SendItemToScaleform(i, update, newItem, isSlot)
    if i > #self.Items then return end
    local item = self.Items[i]
    local str = "SET_DATA_SLOT"

    if update then str = "UPDATE_DATA_SLOT" end
    if newItem then str = "SET_DATA_SLOT_SPLICE" end
    if isSlot then str = "ADD_SLOT" end

    AddTextEntry("SIGRUN_ITMLST_LSTITM_RLBL", "")
    AddTextEntry("SIGRUN_ITMLST_RLBL", "")

    BeginScaleformMovieMethod(SH.scaleform.handle, str)
    PushScaleformMovieFunctionParameterInt(self.position)
    PushScaleformMovieFunctionParameterInt(i - 1)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(item.ItemId)

    if item.ItemId == 1 then
        local rlabel = "SIGRUN_ITMLST_LSTITM_RLBL"
        AddTextEntry("SIGRUN_ITMLST_LSTITM_RLBL", item:CurrentListItem())
        BeginTextCommandScaleformString(rlabel)
        EndTextCommandScaleformString_2()
    elseif item.ItemId == 2 then
        PushScaleformMovieFunctionParameterBool(item:Checked())
    elseif item.ItemId == 3 or item.ItemId == 4 or item.ItemId == 5 then
        PushScaleformMovieFunctionParameterInt(item:Index())
    else
        PushScaleformMovieFunctionParameterInt(0)
    end

    PushScaleformMovieFunctionParameterBool(item:Enabled())
    local label = "SIGRUN_ITMLST_LBL"
    AddTextEntry(label, item:Label())
    BeginTextCommandScaleformString(label)
    EndTextCommandScaleformString_2()
    PushScaleformMovieFunctionParameterBool(false)
    if item.ItemId == 1 then
        PushScaleformMovieFunctionParameterInt(item:MainColor():ToArgb())
        PushScaleformMovieFunctionParameterInt(item:HighlightColor():ToArgb())
        PushScaleformMovieMethodParameterString(item.LeftIcon.TXD)
        PushScaleformMovieMethodParameterString(item.LeftIcon.TXN)
        PushScaleformMovieMethodParameterString(item.LabelFont)
        PushScaleformMovieMethodParameterString(item._rightLabelFont)
    elseif item.ItemId == 2 then
        PushScaleformMovieFunctionParameterInt(item.CheckBoxStyle)
        PushScaleformMovieFunctionParameterInt(item:MainColor():ToArgb())
        PushScaleformMovieFunctionParameterInt(item:HighlightColor():ToArgb())
        PushScaleformMovieMethodParameterString(item.LeftIcon.TXD)
        PushScaleformMovieMethodParameterString(item.LeftIcon.TXN)
        PushScaleformMovieMethodParameterString(item.LabelFont)
    elseif item.ItemId == 3 then
        PushScaleformMovieFunctionParameterInt(item._Max)
        PushScaleformMovieFunctionParameterInt(item._Multiplier)
        PushScaleformMovieFunctionParameterInt(item:MainColor():ToArgb())
        PushScaleformMovieFunctionParameterInt(item:HighlightColor():ToArgb())
        PushScaleformMovieFunctionParameterInt(item:SliderColor():ToArgb())
        PushScaleformMovieFunctionParameterBool(item._heritage)
        PushScaleformMovieMethodParameterString(item.LeftIcon.TXD)
        PushScaleformMovieMethodParameterString(item.LeftIcon.TXN)
        PushScaleformMovieMethodParameterString(item.LabelFont)
    elseif item.ItemId == 4 then
        PushScaleformMovieFunctionParameterInt(item._Max)
        PushScaleformMovieFunctionParameterInt(item._Multiplier)
        PushScaleformMovieFunctionParameterInt(item:MainColor():ToArgb())
        PushScaleformMovieFunctionParameterInt(item:HighlightColor():ToArgb())
        PushScaleformMovieFunctionParameterInt(item:SliderColor():ToArgb())
        PushScaleformMovieMethodParameterString(item.LeftIcon.TXD)
        PushScaleformMovieMethodParameterString(item.LeftIcon.TXN)
        PushScaleformMovieMethodParameterString(item.LabelFont)
    elseif item.ItemId == 5 then
        PushScaleformMovieFunctionParameterInt(item._Type)
        PushScaleformMovieFunctionParameterInt(item:SliderColor():ToArgb())
        PushScaleformMovieFunctionParameterInt(item:MainColor():ToArgb())
        PushScaleformMovieFunctionParameterInt(item:HighlightColor():ToArgb())
        PushScaleformMovieMethodParameterString(item.LeftIcon.TXD)
        PushScaleformMovieMethodParameterString(item.LeftIcon.TXN)
        PushScaleformMovieMethodParameterString(item.LabelFont)
    elseif item.ItemId == 6 then
        PushScaleformMovieFunctionParameterBool(item.Jumpable)
        PushScaleformMovieFunctionParameterInt(item:MainColor():ToArgb())
        PushScaleformMovieFunctionParameterInt(item:HighlightColor():ToArgb())
        PushScaleformMovieMethodParameterString(item.LabelFont)
    else
        PushScaleformMovieFunctionParameterInt(item:MainColor():ToArgb())
        PushScaleformMovieFunctionParameterInt(item:HighlightColor():ToArgb())
        AddTextEntry("SIGRUN_ITMLST_RLBL", item._rightLabel)
        BeginTextCommandScaleformString("SIGRUN_ITMLST_RLBL")
        EndTextCommandScaleformString_2()
        PushScaleformMovieMethodParameterString(item.LeftIcon.TXD)
        PushScaleformMovieMethodParameterString(item.LeftIcon.TXN)
        PushScaleformMovieMethodParameterString(item.RightIcon.TXD)
        PushScaleformMovieMethodParameterString(item.RightIcon.TXN)
        PushScaleformMovieMethodParameterString(item.LabelFont)
        PushScaleformMovieMethodParameterString(item._rightLabelFont)
    end

    PushScaleformMovieMethodParameterBool(item:KeepTextColorWhite())
    local extraInputs = { item._isImportant, item._importantColor:ToArgb(), item._importantAnimate, item.LeftIcon
        .mainColor:ToArgb(), item.LeftIcon.highlightColor:ToArgb(), item.RightIcon.mainColor:ToArgb(), item.RightIcon
        .highlightColor:ToArgb() }
    local str = Join(',', extraInputs)
    AddTextEntry("SIGRUN_EXTRA_PARAM", str)
    BeginTextCommandScaleformString("SIGRUN_EXTRA_PARAM")
    EndTextCommandScaleformString() -- no weird conversions needed
    EndScaleformMovieMethod()
end

---Removes an item from the collection by matching labels.
---@param item MenuItem
function ItemListColumn:RemoveItem(item)
    if item == nil then
        print("^1[ERROR] ItemListColumn:RemoveItem() - item is nil")
        return
    end
    for k, v in pairs(self.Items) do
        if v:Label() == item:Label() then
            self:RemoveSlot(k)
        end
    end
end

---Removes an item at the specific index.
---@param index number
function ItemListColumn:RemoveItemAt(index)
    if index > #self.Items or index < 1 then return end
    self:RemoveSlot(index)
end

---Internal method to remove a data slot from scaleform and update view.
---@param idx number
function ItemListColumn:RemoveSlot(idx)
    BaseColumn.RemoveSlot(self, idx)
    self:UpdateDescription()
end

---Updates the description panel for the currently selected item.
function ItemListColumn:UpdateDescription()
    local item = self:CurrentItem()
    if not item then
        AddTextEntry("Sigrun_Description_0", "")
        AddTextEntry("Sigrun_Description_1", "")
        AddTextEntry("Sigrun_Description_2", "")
        self.Parent.RightColumn:UpdateSlot(1, item)
        self.Parent.RightColumn:UpdateSlot(2, item)
        self.Parent.RightColumn:UpdateSlot(3, item)
        return
    end
    AddTextEntry("Sigrun_Description_0", item.Descriptions[1].label or "")
    AddTextEntry("Sigrun_Description_1", item.Descriptions[2].label or "")
    AddTextEntry("Sigrun_Description_2", item.Descriptions[3].label or "")
    self.Parent.RightColumn:UpdateSlot(1, item)
    self.Parent.RightColumn:UpdateSlot(2, item)
    self.Parent.RightColumn:UpdateSlot(3, item)
end

---Previews descriptions for a specific item (usually for mouse hovering).
---@param index number
function ItemListColumn:PreviewDescription(index)
    local item = self.Items[index]
    AddTextEntry("Sigrun_Description_0", item.Descriptions[1].label or "")
    AddTextEntry("Sigrun_Description_1", item.Descriptions[2].label or "")
    AddTextEntry("Sigrun_Description_2", item.Descriptions[3].label or "")
    self.Parent.RightColumn:UpdateSlot(1, item)
    self.Parent.RightColumn:UpdateSlot(2, item)
    self.Parent.RightColumn:UpdateSlot(3, item)
end

---Moves the selection upward.
function ItemListColumn:GoUp()
    if not self:visible() or #self.Items == 0 then return end
    self:CurrentItem():Selected(false)
    local didWrap = false

    repeat
        Citizen.Wait(0)
        self.index = self.index - 1
        if self.index < 1 then
            self.index = #self.Items
            didWrap = true
        end
    until self:CurrentItem().ItemId ~= 6 or (self:CurrentItem().ItemId == 6 and not self:CurrentItem().Jumpable)

    if didWrap then
        self._topEdge = #self.Items - self.VisibleItems + 1
        if self._topEdge < 1 then self._topEdge = 1 end
    elseif self.index < self._topEdge then
        self._topEdge = self.index
    end

    local isScrollVisible = #self.Items >= self.VisibleItems
    self:SetColumnScroll(isScrollVisible, self._topEdge)

    self:CurrentItem():Selected(true)
    self.OnIndexChanged(self:CurrentSelection())

    SH.scaleform:CallFunction("SET_COLUMN_HIGHLIGHT", self.position, self.index - 1)
    if self._currentlyHighlighted ~= 0 then
        self:PreviewDescription(self._currentlyHighlighted);
        local relativeDescIdx = self._currentlyHighlighted - self._topEdge;
        self:SendDescriptionCommand(relativeDescIdx);
    else
        self:UpdateDescription()
        self:SendDescriptionCommand(self.index - self._topEdge)
    end
end

---Moves the selection downward.
function ItemListColumn:GoDown()
    if not self:visible() or #self.Items == 0 then return end
    self:CurrentItem():Selected(false)
    local didWrap = false

    repeat
        Citizen.Wait(0)
        self.index = self.index + 1
        if self.index > #self.Items then
            self.index = 1
            didWrap = true
        end
    until self:CurrentItem().ItemId ~= 6 or (self:CurrentItem().ItemId == 6 and not self:CurrentItem().Jumpable)

    if didWrap then
        self._topEdge = 1
    else
        local visibleEnd = self._topEdge + self.VisibleItems - 1
        if self.index > visibleEnd then
            self._topEdge = self.index - self.VisibleItems + 1
        end
    end

    local isScrollVisible = #self.Items >= self.VisibleItems
    self:SetColumnScroll(isScrollVisible, self._topEdge)

    self:CurrentItem():Selected(true)
    self.OnIndexChanged(self:CurrentSelection())

    SH.scaleform:CallFunction("SET_COLUMN_HIGHLIGHT", self.position, self.index - 1)
    if self._currentlyHighlighted ~= 0 then
        self:PreviewDescription(self._currentlyHighlighted);
        local relativeDescIdx = self._currentlyHighlighted - self._topEdge;
        self:SendDescriptionCommand(relativeDescIdx);
    else
        self:UpdateDescription()
        self:SendDescriptionCommand(self.index - self._topEdge)
    end
end

---Handles mouse wheel scrolling.
---@param dir number Scroll direction
function ItemListColumn:MouseScroll(dir)
    if not self:visible() or #self.Items == 0 then return end

    if not self.ScrollNewStyle then
        if (dir == 1) then
            self:GoDown()
        else
            self:GoUp();
        end
        return;
    end

    local numItems = #self.Items
    local maxVisible = self.VisibleItems

    local newTopEdge = self._topEdge + dir
    local maxTopEdge = numItems - maxVisible + 1
    if maxTopEdge < 1 then maxTopEdge = 1 end

    if newTopEdge < 1 then newTopEdge = 1 end
    if newTopEdge > maxTopEdge then newTopEdge = maxTopEdge end

    if newTopEdge == self._topEdge then
        return
    end

    local actualDelta = newTopEdge - self._topEdge
    self._topEdge = newTopEdge

    local visibleStart = self._topEdge
    local visibleEnd = self._topEdge + maxVisible - 1
    local indexChanged = false
    local targetIndex = self.index

    if self.index < visibleStart then
        targetIndex = visibleStart
        while targetIndex <= visibleEnd and self.Items[targetIndex] and self.Items[targetIndex].ItemId == 6 and self.Items[targetIndex].Jumpable do
            Wait(0)
            targetIndex = targetIndex + 1
        end
        if targetIndex > visibleEnd then targetIndex = visibleStart end
    elseif self.index > visibleEnd then
        targetIndex = visibleEnd
        while targetIndex >= visibleStart and self.Items[targetIndex] and self.Items[targetIndex].ItemId == 6 and self.Items[targetIndex].Jumpable do
            Wait(0)
            targetIndex = targetIndex - 1
        end
        if targetIndex < visibleStart then targetIndex = visibleEnd end
    end

    if targetIndex ~= self.index then
        self:CurrentItem():Selected(false)
        self.index = targetIndex
        self:CurrentItem():Selected(true)
        indexChanged = true
    end

    SH.scaleform:CallFunction("SET_INPUT_EVENT", self.position, dir)

    if indexChanged then
        SH.scaleform:CallFunction("SET_COLUMN_HIGHLIGHT", self.position, self.index - 1)
        self.OnIndexChanged(self.index)
    end
    self:SetColumnScroll(#self.Items >= self.VisibleItems, self._topEdge)

    if self._currentlyHighlighted ~= 0 then
        local predictedHoverIndex = self._currentlyHighlighted + actualDelta
        if predictedHoverIndex >= 1 and predictedHoverIndex <= numItems then
            if self.Items[self._currentlyHighlighted] then
                self.Items[self._currentlyHighlighted]._Hovered = false
            end
            self._currentlyHighlighted = predictedHoverIndex
            self.Items[self._currentlyHighlighted]._Hovered = true
            self:PreviewDescription(self._currentlyHighlighted)
            self:SendDescriptionCommand(self._currentlyHighlighted - self._topEdge)
        else
            self:UpdateDescription()
            self:SendDescriptionCommand(self._currentlyHighlighted - self._topEdge)
        end
    else
        self:UpdateDescription()
        self:SendDescriptionCommand(self.index - self._topEdge)
    end
end

---Handles mouse hover events.
---@param type number Event type (9 hovered, 8 not hovered)
---@param item number Item index
function ItemListColumn:HandleHovering(type, item)
    if #self.Items == 0 then return end
    local _item = self.Items[item]
    local oldItem = self.Items[self._currentlyHighlighted]
    if type == 9 then
        if not _item._Hovered then
            if oldItem then
                oldItem._Hovered = false
            end
            self._currentlyHighlighted = item
            _item._Hovered = true
            if self.Items[item]:_hasDescriptions() then
                self:PreviewDescription(item)
                self:SendDescriptionCommand(item - self._topEdge)
            else
                self:UpdateDescription()
                self:SendDescriptionCommand(self.index - self._topEdge)
            end
        end
    elseif type == 8 then
        if oldItem then
            oldItem._Hovered = false
        end
        self._currentlyHighlighted = 0
        if _item._Hovered then
            _item._Hovered = false
        end
        self:UpdateDescription()
        self:SendDescriptionCommand(self.index - self._topEdge)
    end
end

---Navigates left for list or slider items.
function ItemListColumn:GoLeft()
    if not self:visible() or #self.Items == 0 then return end
    local curItem = self:CurrentItem()
    if not curItem:Enabled() then
        PlaySoundFrontend(-1, "ERROR", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
        return
    end

    if curItem.ItemId == 1 then
        if curItem() == "MenuListItem" then
            curItem:Index(curItem:Index() - 1)
            self.OnListChange(self, curItem, curItem._Index)
            curItem.OnListChanged(self, curItem, curItem._Index)
        else
            local result = tostring(curItem.Callback(curItem, "left"))
            curItem:CurrentListItem(result)
        end
    elseif curItem.ItemId == 3 or curItem.ItemId == 4 or curItem.ItemId == 5 then
        curItem:Index(curItem:Index() - curItem._Multiplier)
    end
    self:UpdateDescription()
end

---Navigates right for list or slider items.
function ItemListColumn:GoRight()
    if not self:visible() or #self.Items == 0 then return end
    local curItem = self:CurrentItem()
    if not curItem:Enabled() then
        PlaySoundFrontend(-1, "ERROR", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
        return
    end
    if curItem.ItemId == 1 then
        if curItem() == "MenuListItem" then
            curItem:Index(curItem:Index() + 1)
            self.OnListChange(self, curItem, curItem._Index)
            curItem.OnListChanged(self, curItem, curItem._Index)
        else
            local result = tostring(curItem.Callback(curItem, "right"))
            curItem:CurrentListItem(result)
        end
    elseif curItem.ItemId == 3 or curItem.ItemId == 4 or curItem.ItemId == 5 then
        curItem:Index(curItem:Index() + curItem._Multiplier)
    end
    self:UpdateDescription()
end

---Activates the currently selected item.
function ItemListColumn:Select()
    if not self:visible() or #self.Items == 0 then return end
    if not self:CurrentItem():Enabled() then
        PlaySoundFrontend(-1, "ERROR", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
        return
    end
    self:UpdateDescription()
    if self:CurrentItem().ItemId == 1 then
        self:CurrentItem().OnListSelected(nil, self:CurrentItem(), self:CurrentItem():Index())
        self.OnItemSelect(self:Index())
    elseif self:CurrentItem().ItemId == 2 then
        self:CurrentItem():Checked(not self:CurrentItem():Checked())
        self:CurrentItem().OnCheckboxChanged(nil, self:CurrentItem(), self:CurrentItem():Checked())
    else
        self.OnItemSelect(self:Index())
        if self:CurrentItem().Activated ~= nil then
            self:CurrentItem().Activated(nil, self:CurrentItem())
        end
    end
end

---Updates labels for a specific item.
function ItemListColumn:UpdateItemLabels(index, leftLabel, rightLabel)
    if not self:visible() or #self.Items == 0 or index > #self.Items then return end
    local item = self.Items[index]
    item:Label(leftLabel)
    item:RightLabel(rightLabel)
end

---Updates the primary label of an item.
function ItemListColumn:UpdateItemLabel(index, label)
    if not self:visible() or #self.Items == 0 or index > #self.Items then return end
    local item = self.Items[index]
    item:Label(label)
end

---Updates the right label of an item.
function ItemListColumn:UpdateItemRightLabel(index, label)
    if not self:visible() or #self.Items == 0 or index > #self.Items then return end
    local item = self.Items[index]
    item:RightLabel(label)
end

---Updates the left badge of an item.
function ItemListColumn:UpdateItemLeftBadge(index, badge)
    if not self:visible() or #self.Items == 0 or index > #self.Items then return end
    local item = self.Items[index]
    item:LeftBadge(badge)
end

---Updates the right badge of an item.
function ItemListColumn:UpdateItemRightBadge(index, badge)
    if not self:visible() or #self.Items == 0 or index > #self.Items then return end
    local item = self.Items[index]
    item:RightBadge(badge)
end

---Enables or disables an item.
function ItemListColumn:EnableItem(index, enable)
    if not self:visible() or #self.Items == 0 or index > #self.Items then return end
    local item = self.Items[index]
    item:Enabled(enable)
end

---Alias for ClearColumn.
function ItemListColumn:Clear()
    self:ClearColumn()
end

---Clears all items from the column and resets UI.
function ItemListColumn:ClearColumn()
    BaseColumn.ClearColumn(self)
    AddTextEntry("Sigrun_Description_0", "")
    AddTextEntry("Sigrun_Description_1", "")
    AddTextEntry("Sigrun_Description_2", "")
    self:UpdateDescription()
    self:SetColumnScroll(false, 0)
end

---Sorts items based on a custom comparison function.
---@param compare fun(a: any, b: any): boolean
function ItemListColumn:SortItems(compare)
    if not self:visible() or #self.Items == 0 then return end
    self:CurrentItem():Selected(false)
    if self._unfilteredItems == nil or #self._unfilteredItems == 0 then
        for i, item in ipairs(self.Items) do
            table.insert(self._unfilteredItems, item)
        end
    end
    self._unfilteredSelection = self:Index()
    self:Clear()
    local list = self._unfilteredItems
    table.sort(list, compare)
    self.Items = list
    if self:visible() then
        self:Populate()
        self:ShowColumn()
    end
end

---Filters items based on a predicate function.
---@param predicate fun(item: any): boolean
function ItemListColumn:FilterItems(predicate)
    self:CurrentItem():Selected(false)
    if self._unfilteredItems == nil or #self._unfilteredItems == 0 then
        for i, item in ipairs(self.Items) do
            table.insert(self._unfilteredItems, item)
        end
    end
    self._unfilteredSelection = self:Index()
    self:Clear()
    local filteredItems = {}
    for i, item in ipairs(self._unfilteredItems) do
        if predicate(item) then
            table.insert(filteredItems, item)
        end
    end
    self.Items = filteredItems
    if self:visible() then
        self:Populate()
        self:ShowColumn()
    end
end

---Resets active filters and restores the original item list.
function ItemListColumn:ResetFilter()
    if self._unfilteredItems ~= nil and #self._unfilteredItems > 0 then
        self:CurrentItem():Selected(false)
        self:Clear()
        self.Items = self._unfilteredItems
        self:Index(self._unfilteredSelection)
        self._unfilteredItems = {}
        self._unfilteredSelection = 1
        if self:visible() then
            self:Populate()
            self:ShowColumn()
        end
    end
end

---Initializes the scaleform scroll bar.
function ItemListColumn:InitColumnScroll(visible, visibleItems, maxItems, index)
    if self:visible() then
        SH.scaleform:CallFunction("INIT_SCROLL_BAR", self.position, visible, visibleItems, maxItems, index - 1)
    end
end

---Updates the scaleform scroll bar position.
function ItemListColumn:SetColumnScroll(visible, index)
    if self:visible() then
        SH.scaleform:CallFunction("SET_SCROLL_BAR", self.position, visible, index - 1)
    end
end

---Sends the description animation command to the scaleform.
function ItemListColumn:SendDescriptionCommand(index)
    SH.scaleform:CallFunction("SET_DESCRIPTION", self.position, index, self.Parent.Parent._animateDescriptions)
end
