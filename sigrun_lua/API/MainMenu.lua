MainMenu = setmetatable({}, MainMenu)
MainMenu.__index = MainMenu
MainMenu.__call = function() return "MainMenu" end

---@class MainMenu
---@field private index integer Current active tab index
---@field private _visible boolean Internal visibility state
---@field private _isBuilding boolean Prevents input during scaleform population
---@field private _mouseEnabled boolean Whether mouse interaction is allowed
---@field private _animateDescriptions boolean Toggle for description scroll animations
---@field private _maxExtensionPixels number Maximum menu width in scaleform pixels
---@field public Tabs BaseTab[] Collection of tabs assigned to this menu
---@field public OnTabChange fun(newTab:BaseTab, index:number, oldTab:BaseTab, oldIndex:number) Callback triggered on tab switch
---@field public OnMenuOpen fun(menu:MainMenu) Callback triggered when menu opens
---@field public OnMenuClose fun(menu:MainMenu) Callback triggered when menu closes
---@field public TemporarilyHidden boolean Toggle to hide UI without disposing scaleform
MainMenu = {}
MainMenu.__index = MainMenu

---Creates a new MainMenu menu instance
---@return MainMenu
function MainMenu.New()
    local menu = {
        Tabs = {},
        _isBuilding = false,
        _visible = false,
        _mouseEnabled = true,
        _animateDescriptions = true,
        _maxExtensionPixels = 450,
        index = 1,
        TemporarilyHidden = false,
        OnTabChange = function(tab, newindex, oldTab, oldIndex) end,
        OnMenuOpen = function(menu) end,
        OnMenuClose = function(menu) end
    }
    return setmetatable(menu, MainMenu)
end

--- Enable/Disable the mouse for the entire menu.
--- @param bool boolean Toggle the mouse with this.
function MainMenu:MouseEnabled(bool)
    if bool == nil then return self._mouseEnabled end
    self._mouseEnabled = bool
end

---Sets or gets the menu visibility.
---Handles scaleform loading, tab initialization, and cleanup.
---@param visible boolean|nil
---@return boolean|nil
function MainMenu:Visible(visible)
    if visible ~= nil then
        self._visible = visible
        if visible then
            assert(not SH.instance, "A MainMenu menu instance is already active!")

            if not IsPauseMenuActive() then
                self._isBuilding = true

                -- Initialize Scaleform if not already loaded
                if SH.scaleform == nil or SH.scaleform.handle == 0 then
                    SH.scaleform = Scaleform.RequestWidescreen("sigrun")
                    while not SH.scaleform:IsLoaded() do Wait(0) end
                end

                -- Setup Tabs
                SH.scaleform:CallFunction("SET_TABS_SLOT_EMPTY", 0)
                for i = 1, #self.Tabs do
                    local tab = self.Tabs[i]
                    tab.Visible = (i == self.index)

                    -- SET_TABS_SLOT: index, unused, unused, isVertical, unused, visible, txd, txn, color, isWarning, animateWarning, warningColor
                    SH.scaleform:CallFunction("SET_TABS_SLOT", i - 1, 0, 0, 0, 0, true, tab.txd, tab.txn,
                        tab.Color, tab.isWarning, tab.animateWarning, tab.warningColor)
                end

                -- Initial UI Setup
                SH.scaleform:CallFunction("DISPLAY_TABS", 0)
                SH.scaleform:CallFunction("HIGHLIGHT_TAB", self.index - 1)

                local current = self:CurrentTab()
                if current then
                    SH.scaleform:CallFunction("SET_TABS_TITLE", current.Title, current.showArrow, not current.hideTabs)
                end

                self:BuildMainMenu()
                self.OnMenuOpen(self)
                SH.instance = self
            end
        else
            -- Cleanup
            SH.instance = nil
            self.OnMenuClose(self)
            if SH.scaleform then
                SH.scaleform:Dispose()
                SH.scaleform = nil
            end
        end
    else
        return self._visible
    end
end

---Navigates to a specific tab index or returns the current one.
---@param idx integer|nil
---@return integer|nil
function MainMenu:Index(idx)
    if idx ~= nil then
        if #self.Tabs == 0 then return end

        local oldIndex = self.index
        local oldTab = self.Tabs[oldIndex]

        -- Boundary checks (Wrapping)
        self.index = idx
        if self.index > #self.Tabs then self.index = 1 end
        if self.index < 1 then self.index = #self.Tabs end

        if oldIndex == self.index then return end

        oldTab.Visible = false
        local current = self:CurrentTab()

        current.Visible = true
        SH.scaleform:CallFunction("HIGHLIGHT_TAB", self.index - 1)
        SH.scaleform:CallFunction("SET_TABS_TITLE", current.Title, current.showArrow, not current.hideTabs)
        if self:Visible() then
            self:BuildMainMenu()
        end
        self.OnTabChange(self.Tabs[self.index], self.index, oldTab, oldIndex)
    else
        return self.index
    end
end

---Adds a new tab to the menu collection.
---@param tab BaseTab
---@return BaseTab
function MainMenu:AddTab(tab)
    tab.Parent = self
    table.insert(self.Tabs, tab)
    return tab
end

---Returns the currently active tab object.
---@return BaseTab|nil
function MainMenu:CurrentTab()
    return self.Tabs[self.index]
end

---Configures whether descriptions should animate when changing selection.
---@param bool boolean
function MainMenu:AnimateDescriptions(bool)
    if bool == nil then return self._animateDescriptions end
    self._animateDescriptions = bool
end

---Sets the maximum extension width for the menu columns.
---@param width number Pixels (Scaleform 1280x720 coordinate system)
function MainMenu:SetMaxMenuWidth(width)
    if not width then return self._maxExtensionPixels end
    self._maxExtensionPixels = width
end

---Populates the scaleform with the current tab's data.
function MainMenu:BuildMainMenu()
    if not SH.scaleform or not SH.scaleform:IsLoaded() then return end

    self._isBuilding = true
    local tab = self:CurrentTab()

    if tab then
        SH.scaleform:CallFunction("LOAD_CHILD_PAGE", tab._identifier)
        tab:Populate()
        tab:ShowColumns()
        tab:Focus()
    end

    self._isBuilding = false
end

---Closes the menu.
function MainMenu:GoBack()
    self:Visible(false)
end

---Main logic loop for keyboard/controller navigation.
function MainMenu:ProcessControl()
    if not self:Visible() or self.TemporarilyHidden or self._isBuilding then
        return
    end

    if self._mouseEnabled then
        HideHudComponentThisFrame(19)
        HideHudComponentThisFrame(20)
    end


    -- Tab Switching (LB/RB or Keyboard equivalent)
    if CheckInput(FRONTEND_INPUT.FRONTEND_INPUT_LB, false, 0, false) then --[[ or (IsDisabledControlJustPressed(2, 192) and IsControlPressed(2, 21) and IsUsingKeyboard(2))]]
        if #self.Tabs > 1 and not self:CurrentTab().hideTabs then
            self:Index(self.index - 1)
            PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
        end
    elseif CheckInput(FRONTEND_INPUT.FRONTEND_INPUT_RB, false, 0, false) then --[[ or (IsDisabledControlJustPressed(2, 192) and IsUsingKeyboard(2))]]
        if #self.Tabs > 1 and not self:CurrentTab().hideTabs then
            self:Index(self.index + 1)
            PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
        end
        -- Global Back Logic
    elseif CheckInput(FRONTEND_INPUT.FRONTEND_INPUT_BACK, true, 0, false) or
        CheckInput(FRONTEND_INPUT.FRONTEND_INPUT_CURSOR_BACK, true, 0, false) then
        local current = self:CurrentTab()
        if current and current.GoBack then
            current:GoBack()
        else
            self:GoBack()
        end
    else
        -- Delegate input to the active tab (each tab file will have its own input handling)
        local current = self:CurrentTab()
        if current then current:HandleInput() end
    end
end

---Processes mouse interaction and hover events via Scaleform.
function MainMenu:ProcessMouse()
    if not IsUsingKeyboard(2) or not self._mouseEnabled then
        return
    end

    SetMouseCursorActiveThisFrame()
    SetInputExclusive(2, 239)
    SetInputExclusive(2, 240)
    SetInputExclusive(2, 238)
    SetInputExclusive(2, 237)

    if SH.scaleform == nil or not SH.scaleform:IsLoaded() then return end

    local success, eventType, context, itemId = GetScaleformMovieCursorSelection(SH.scaleform.handle)
    if success then
        if context == 1000 then    -- Context 1000 usually refers to the Tab bar
            if eventType == 5 then -- Left Click
                self:Index(itemId + 1)
            end
        else
            -- Forward mouse events to the current tab
            local current = self:CurrentTab()
            if current then
                current:MouseEvent(eventType, context, itemId + 1)
            end
        end
    end
end
