---@class ItemListTab : BaseTab
---@field public LeftColumn ItemListColumn          # Primary column for menu items
---@field public RightColumn DescriptionListColumn  # Side panel for item descriptions
---@field public visibleHelpItems number            # Max items visible in secondary columns
---@field public CurrentColumnIndex number          # Index of column receiving mouse/keyboard input
---@field public _identifier string                 # Internal scaleform page identifier
ItemListTab = {}
ItemListTab.__index = ItemListTab
setmetatable(ItemListTab, { __index = BaseTab })
ItemListTab.__call = function() return "ItemListTab" end

---Creates a new ItemListTab instance with a main column and description panel.
---@param title string
---@param txd string
---@param txn string
---@param color SColor
---@return ItemListTab
function ItemListTab.New(title, txd, txn, color)
    local data = BaseTab.New(title, txd, txn, color)
    data._identifier = "Page_Items"
    data.LeftColumn = ItemListColumn.New()
    data.RightColumn = DescriptionListColumn.New()

    local meta = setmetatable(data, ItemListTab)
    meta.LeftColumn.Parent = meta
    meta.RightColumn.Parent = meta
    return meta
end

---Updates the maximum visible items in the primary column.
---@param maxItems number
function ItemListTab:SetVisibleItems(maxItems)
    self.LeftColumn.VisibleItems = maxItems
    if self.LeftColumn:visible() then
        self:Populate()
        self.LeftColumn:ShowColumn()
    end
end

---Adds a menu item to the primary column.
---@param item MenuItem|MenuListItem|MenuCheckboxItem|MenuSliderItem|MenuProgressItem
function ItemListTab:AddItem(item)
    item.ParentTab = self
    self.LeftColumn:AddItem(item)
end

---Navigates selection upward in the current active column.
function ItemListTab:GoUp()
    if not self.Focused then return end
    self.LeftColumn:GoUp()
end

---Navigates selection downward in the current active column.
function ItemListTab:GoDown()
    if not self.Focused then return end
    self.LeftColumn:GoDown()
end

---Navigates left within list-type items (sliders, lists).
function ItemListTab:GoLeft()
    if not self.Focused then return end
    self.LeftColumn:GoLeft()
end

---Navigates right within list-type items (sliders, lists).
function ItemListTab:GoRight()
    if not self.Focused then return end
    self.LeftColumn:GoRight()
end

---Triggers the activation logic for the currently selected item.
function ItemListTab:Select()
    if not self.Focused then return end
    self.LeftColumn:Select()
end

---Handles the back navigation, managing sub-column stacks or parent menu closure.
function ItemListTab:GoBack()
    -- If sub-columns are active, pop the last one from the stack
    if #self.LeftColumnStack > 0 then
        self:PopColumn()
    else
        -- Otherwise, signal the parent menu to close or go back
        if self.Parent then
            self.Parent:GoBack()
        end
    end
end

---Processes Scaleform mouse interaction events.
---@param eventType number
---@param context number
---@param index number
function ItemListTab:MouseEvent(eventType, context, index)
    if not self.Focused then return end

    if eventType == 5 then -- Left Click
        if index == self.LeftColumn:Index() then
            self:Select()
            return
        end

        local currentItem = self.LeftColumn:CurrentItem()
        if currentItem then currentItem:Selected(false) end

        self.LeftColumn:CurrentSelection(index)

        local newItem = self.LeftColumn:CurrentItem()
        if newItem then newItem:Selected(true) end

        if self.LeftColumn.OnIndexChanged then
            self.LeftColumn.OnIndexChanged(self.LeftColumn:Index())
        end
        self.LeftColumn:UpdateDescription()
    elseif eventType == 8 or eventType == 9 then -- 9 = Hovered, 8 = Unhovered
        self.LeftColumn:HandleHovering(eventType, index)
    end
end

---Handles mouse wheel scrolling input.
---@param dir number
function ItemListTab:MouseScroll(dir)
    if self.CurrentColumnIndex == 0 then
        self.LeftColumn:MouseScroll(dir)
    end
end

---Main input loop for handling tab-specific controls.
function ItemListTab:HandleInput()
    if CheckInput(FRONTEND_INPUT.FRONTEND_INPUT_UP, true, CHECK_INPUT_OVERRIDE_FLAG.CHECK_INPUT_OVERRIDE_FLAG_IGNORE_ANALOGUE_STICKS, false) then
        self:GoUp()
    elseif CheckInput(FRONTEND_INPUT.FRONTEND_INPUT_DOWN, true, CHECK_INPUT_OVERRIDE_FLAG.CHECK_INPUT_OVERRIDE_FLAG_IGNORE_ANALOGUE_STICKS, false) then
        self:GoDown()
    elseif CheckInput(FRONTEND_INPUT.FRONTEND_INPUT_LEFT, true, CHECK_INPUT_OVERRIDE_FLAG.CHECK_INPUT_OVERRIDE_FLAG_IGNORE_ANALOGUE_STICKS, false) then
        self:GoLeft()
    elseif CheckInput(FRONTEND_INPUT.FRONTEND_INPUT_RIGHT, true, CHECK_INPUT_OVERRIDE_FLAG.CHECK_INPUT_OVERRIDE_FLAG_IGNORE_ANALOGUE_STICKS, false) then
        self:GoRight()
    elseif CheckInput(FRONTEND_INPUT.FRONTEND_INPUT_ACCEPT, true, 0, false) then
        self:Select()
    elseif CheckInput(FRONTEND_INPUT.FRONTEND_INPUT_CURSOR_SCROLL_UP, true, 0, false) then
        self:MouseScroll(-1)
    elseif CheckInput(FRONTEND_INPUT.FRONTEND_INPUT_CURSOR_SCROLL_DOWN, true, 0, false) then
        self:MouseScroll(1)
    end
end

---Gives focus to the tab and synchronizes UI state with the scaleform.
function ItemListTab:Focus()
    BaseTab.Focus(self)
    SH.scaleform:CallFunction("SET_COLUMN_FOCUS", self.LeftColumn.position, self.Focused, false, false)

    self.LeftColumn:Index(self.LeftColumn.index)
    self.LeftColumn:UpdateDescription()

    SH.scaleform:CallFunction("SET_COLUMN_HIGHLIGHT", self.LeftColumn.position, self.LeftColumn.index - 1)

    local item = self.LeftColumn:CurrentItem()
    if item then
        item:Selected(true)
    end
    self:Refresh(true)
end

---Removes focus from the tab and deselects current items.
function ItemListTab:UnFocus()
    local item = self.LeftColumn:CurrentItem()
    if item then item:Selected(false) end
    BaseTab.UnFocus(self)
end

---Initializes the Scaleform view with current tab data.
function ItemListTab:Populate()
    SH.scaleform:CallFunction("SET_TITLE", self.LeftColumn.position, self.Title)
    self.LeftColumn:Populate()

    local item = self.LeftColumn:CurrentItem()
    if item then
        item:Selected(true)
    end
end

---Activates the visibility of columns within the tab.
function ItemListTab:ShowColumns()
    self.LeftColumn:ShowColumn()
end
