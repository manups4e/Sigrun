local mainMenu
RegisterCommand("sigrun", function (a,b,c)
    BuildMenu()
end)

local randDescriptions = {
    "This is a required field for a valid mission.",
    "In sit amet justo a dui fringilla suscipit.",
    "Quisque porta neque et urna pharetra, sed vehicula metus dapibus.",
    "Pellentesque placerat magna quis nunc scelerisque, vitae ullamcorper nunc lobortis.",
    "Curabitur hendrerit odio non urna varius pellentesque",
    "Aliquam et ex ac velit imperdiet laoreet quis eu magna",
    "Vestibulum semper turpis in bibendum feugiat",
    "Nulla eu orci nec est pulvinar bibendum",
    "Phasellus quis nisi a lectus pharetra interdum.",
    "In et justo at orci imperdiet vestibulum vitae ac lorem.",
    "Etiam semper tellus in sem porta pretium."
}

function BuildMenu()
    -- Initializing the Main Menu
    if mainMenu then
        mainMenu:Visible(false)
        mainMenu = nil
        return
    end
    mainMenu = MainMenu.New()
    
    -- true by default, set it to false to remove all mouse related features.
    mainMenu:MouseEnabled(true) 
    
    -- set this to true to allow scroll only when mouse hovering on the menu.
    mainMenu:ScrollOnlyOnMenuHover(true)
    
    for i = 1, 5 do -- you can add as many tabs as you want.. and they will automatically scroll on Q, E / Lb, Rb press.
        local tabTitle = "Tab #" .. i
        local tabColor = SColor.FromRandomValues()

        -- Create the Tab
        -- Tabs are created with (title, txd, txn, color of texture which is default white)
        local tab = ItemListTab.New(tabTitle, "mppublicmissioncreatoricons", "mission_creator_details_icon", tabColor)

        -- Setup initial Tab settings (Warning tip on the 3rd tab as example)
        if i == 3 then
            -- warning tip params are (enable, animate, color which is default red )
            tab:SetWarningTip(true, true, SColor.HUD_Red)
        end

        mainMenu:AddTab(tab)
    end

    -------------------------------------------------------
    -- TAB 1: SHOWCASE ITEMS
    -------------------------------------------------------
    local firstTab = mainMenu.Tabs[1]
    
    -- ⚠️ set this to true for the new R* scrolling style.
    firstTab.LeftColumn.ScrollNewStyle = false

    firstTab:UpdateTitle("SHOWCASE", false, false)

    -- Standard MenuItem with SubColumn
    local subMenuColumn = ItemListColumn.New("HIERARCHY", 10)
    for i = 1, 15 do
        subMenuColumn:AddItem(MenuItem.New("Sub Item " .. i, "This is inside a sub-column"))
    end

    local itemSub = MenuItem.New("Open SubColumn", "Click to explore the hierarchy")
    itemSub:RightLabel("Explore >")
    -- SetSubColumn will automatically add an Activated event to the item with the submenu switch.. you can manually do this doing
    --[[
        itemHash.Activated = function(column, item)
            TabParent:PushColumn(NewColumn, showArrow, hideTabs) -- params are (ItemListColumn, bool, bool)
        end

    ]]
    itemSub:SetSubColumn(subMenuColumn, true, true)
    firstTab:AddItem(itemSub)

    -- Item with Rich Descriptions and Badges
    local itemRich = MenuItem.New("Advanced Item", randDescriptions[1])
    itemRich:RightLabel("Value: $500")
    -- Differently than ScaleformUI, Sigrun wants you to input your badge textures, this is to allow further customizations
    -- changing textures at any time and color on need.
    itemRich:LeftBadge("commonmenu", "shop_lock")
    itemRich:RightBadge("commonmenu", "mp_alerttriangle", SColor.HUD_White)
    -- Items have 3 descriptions, you can change them using this function.
    -- the default desctription you add at item creation is at index 1.
    itemRich:Description(2, "Second description slot with icon", SColor.HUD_Orange, "commonmenu", "mp_alerttriangle")
    itemRich:Description(3, "Third slot for more info", SColor.HUD_Pure_white)
    -- IsImportant will add a little colored highlight on the left side of the item.
    -- params are (enabled, color, animateHighlight)
    itemRich:IsImportant(true, SColor.HUD_Gold, true)
    firstTab:AddItem(itemRich)

    -- Checkbox Item
    local itemCheck = MenuCheckboxItem.New("Toggle Feature", true, 1, "Enable or disable this experimental feature")
    itemCheck.OnCheckboxChanged = function(tab, item, checked)
        print("Checkbox is now: " .. tostring(checked))
    end
    firstTab:AddItem(itemCheck)

    -- List Item (Static)
    local itemList = MenuListItem.New("Select Character", { "Franklin", "Michael", "Trevor" }, 1,
        "Choose your starting character")
    itemList.OnListChanged = function(tab, item, index)
        print("Selected character index: " .. index)
    end
    firstTab:AddItem(itemList)

    -- Colored MenuItem
    local itemColor = MenuItem.New("~HUD_COLOUR_FREEMODE~Custom ~w~Colors", "Color text using standard Rockstar tokens",
        SColor.FromHudColor(21), SColor.FromHudColor(24))
    firstTab:AddItem(itemColor)

    -- Separators
    firstTab:AddItem(MenuSeparatorItem.New("WIDGET SECTION", false)) -- Selectable

    -- Slider Item
    local itemSlider = MenuSliderItem.New("Difficulty", 100, 10, 50, false, "Adjust the game difficulty level")
    firstTab:AddItem(itemSlider)

    -- Progress Item (Disabled Example)
    local itemProgress = MenuProgressItem.New("Experience Level", 100, 75, "Your current rank progress")
    itemProgress:Enabled(false)
    firstTab:AddItem(itemProgress)

    firstTab:AddItem(MenuSeparatorItem.New("Separator (Jumped)", true)) -- Jumped 

    -- Batch of generic items
    for i = 1, 5 do
        local generic = MenuItem.New("Extra Item " .. i, randDescriptions[math.random(1, #randDescriptions)])
        firstTab:AddItem(generic)
    end

    -------------------------------------------------------
    -- TAB 2: EMPTY TAB EXAMPLE
    -------------------------------------------------------
    local secondTab = mainMenu.Tabs[2]
    secondTab:AddItem(MenuItem.New("Settings", "Change your preferences here"))
    secondTab:AddItem(MenuCheckboxItem.New("Notifications", false, 0, "Toggle HUD notifications"))

    -- Set the menu visible
    mainMenu:Visible(true)
end
