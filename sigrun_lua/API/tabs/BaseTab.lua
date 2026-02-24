BaseTab = setmetatable({}, BaseTab)
BaseTab.__index = BaseTab
BaseTab.__call = function() return "BaseTab" end

---@class BaseTab
---@field public _identifier string Internal identifier for scaleform page loading
---@field public Title string Current tab title
---@field public Color SColor Tab theme color
---@field public Type number Tab type identifier
---@field public Visible boolean Whether the tab is currently active and visible
---@field public Focused boolean Whether the tab is receiving input
---@field public Active boolean Internal state for tab activity
---@field public Parent Sigrun Reference to the parent menu instance
---@field public LeftColumn BaseColumn The primary column (usually index 0)
---@field public CenterColumn BaseColumn The middle column (usually index 1)
---@field public RightColumn BaseColumn The side panel column (usually index 2)
---@field public BottomColumn BaseColumn The footer or bottom column
---@field public CurrentColumnIndex integer Index of the column currently in focus
---@field public LeftColumnStack BaseColumn[] Stack used for sub-column navigation history
---@field public isWarning boolean Whether the tab shows a warning badge
---@field public animateWarning boolean Whether the warning badge is animated
---@field public warningColor SColor Color of the warning badge
---@field public txd string Texture dictionary for the tab icon
---@field public txn string Texture name for the tab icon
---@field public showArrow boolean Whether to show a navigation arrow in the title
---@field public hideTabs boolean Whether to hide the tab bar when this tab is focused
---@field public Activated fun(tab: BaseTab) Callback triggered when the tab is selected
BaseTab = {}
BaseTab.__index = BaseTab

---Creates a new BaseTab instance
---@param title string
---@param txd string
---@param txn string
---@param color SColor
---@return BaseTab
function BaseTab.New(title, txd, txn, color)
    local data = {
        Title = title or "",
        txd = txd or "",
        txn = txn or "",
        Color = color or SColor.HUD_White,
        Type = 0,
        Visible = false,
        Focused = false,
        Active = false,
        Parent = nil,
        _identifier = "",
        LeftColumn = nil,
        CenterColumn = nil,
        RightColumn = nil,
        BottomColumn = nil,
        CurrentColumnIndex = 0,
        isWarning = false,
        animateWarning = false,
        warningColor = SColor.HUD_Red,
        showArrow = false,
        hideTabs = false,
        LeftColumnStack = {},
        Activated = function(tab) end
    }
    return setmetatable(data, BaseTab)
end

-- Virtual Methods (To be overridden by child classes)
function BaseTab:Populate() end

function BaseTab:Refresh(highlightOldIndex) end

function BaseTab:ShowColumns() end

function BaseTab:Focus() self.Focused = true end

function BaseTab:UnFocus() self.Focused = false end

function BaseTab:GoUp() end

function BaseTab:GoDown() end

function BaseTab:GoLeft() end

function BaseTab:GoRight() end

function BaseTab:Select() end

function BaseTab:MouseEvent(eventType, context, index) end

function BaseTab:StateChange(state) end

function BaseTab:GoBack() end

---Sets up and assigns the left column
---@param column BaseColumn
---@return BaseColumn
function BaseTab:SetupLeftColumn(column)
    column.position = 0
    column.Parent = self
    self.LeftColumn = column
    return self.LeftColumn
end

---Sets up and assigns the right column
---@param column BaseColumn
---@return BaseColumn
function BaseTab:SetupRightColumn(column)
    column.position = 2
    column.Parent = self
    self.RightColumn = column
    return self.RightColumn
end

---Returns the column currently receiving input
---@return BaseColumn
function BaseTab:CurrentColumn()
    if self.CurrentColumnIndex == 0 then
        return self.LeftColumn
    elseif self.CurrentColumnIndex == 2 then
        return self.RightColumn
    end
    return self.CenterColumn
end

---Returns the column at a specific scaleform position
---@param pos integer 0=Left, 1=Center, 2=Right
---@return BaseColumn|nil
function BaseTab:GetColumnAtPosition(pos)
    if pos == 0 then return self.LeftColumn end
    if pos == 1 then return self.CenterColumn end
    if pos == 2 then return self.RightColumn end
    return nil
end

---Updates the warning badge status for this tab
function BaseTab:SetWarningTip(isWarning, animateWarning, warningColor)
    self.isWarning = isWarning or false
    self.animateWarning = animateWarning or false
    self.warningColor = warningColor or SColor.HUD_Red

    if self.Parent and self.Parent:Visible() then
        -- Find our index in the parent tab list
        local idx = -1
        for i, v in ipairs(self.Parent.Tabs) do
            if v == self then
                idx = i; break
            end
        end

        if idx ~= -1 then
            SH.scaleform:CallFunction("UPDATE_TABS_SLOT", idx - 1, 0, 0, 0, 0, true, self.txd, self.txn, self.Color,
                self.isWarning, self.animateWarning, self.warningColor)
        end
    end
end

---Updates the title bar appearance and visibility
---@param title string
---@param showArrow boolean
---@param hideTabs boolean
function BaseTab:UpdateTitle(title, showArrow, hideTabs)
    self.Title = title or ""
    self.showArrow = showArrow or false
    self.hideTabs = hideTabs or false

    if self.Parent and self.Parent:Visible() and self.Parent:CurrentTab() == self then
        SH.scaleform:CallFunction("SET_TABS_TITLE", self.Title, self.showArrow, not self.hideTabs)
    end
end

---Pushes a new column into the view, saving the previous one to the stack
---@param newColumn BaseColumn
---@param showArrow boolean|nil
---@param hideTabs boolean|nil
function BaseTab:PushColumn(newColumn, showArrow, hideTabs)
    if self.LeftColumn then
        -- Backup current UI state into the column before pushing it
        self.LeftColumn._oldTitle = self.Title
        self.LeftColumn._oldShowArrow = self.showArrow
        self.LeftColumn._oldHideTabs = self.hideTabs

        table.insert(self.LeftColumnStack, self.LeftColumn)
        SH.scaleform:CallFunction("SET_DATA_SLOT_EMPTY", self.LeftColumn.position)
    end

    self.LeftColumn = newColumn
    self.LeftColumn.Parent = self

    self:UpdateTitle(self.LeftColumn.Label or self.Title, showArrow, hideTabs)

    self:Populate()
    self:ShowColumns()
    self:Focus()
end

---Restores the previous column from the stack
---@return boolean success Returns true if a column was popped
function BaseTab:PopColumn()
    if #self.LeftColumnStack == 0 then return false end

    SH.scaleform:CallFunction("SET_DATA_SLOT_EMPTY", self.LeftColumn.position)

    local previousColumn = table.remove(self.LeftColumnStack)

    -- Restore UI state from backup
    if previousColumn._oldTitle then
        self:UpdateTitle(previousColumn._oldTitle, previousColumn._oldShowArrow, previousColumn._oldHideTabs)
    end

    self.LeftColumn = previousColumn
    self:Populate()
    self:ShowColumns()

    self.LeftColumn:UpdateDescription()
    SH.scaleform:CallFunction("SET_COLUMN_HIGHLIGHT", self.LeftColumn.position, self.LeftColumn.index - 1)

    return true
end
