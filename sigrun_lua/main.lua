SH = {}
SH.scaleform = nil
SH.instance = nil

-- using onResourceStop because this way even if stopped by server (or restarted)
-- the scaleform will be unloaded for safety
AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        if SH.scaleform ~= nil and SH.scaleform:IsLoaded() then
            SH.scaleform:Dispose()
        end
    end
end)

Citizen.CreateThread(function()
    --[[
        You can move and / or replace this whole file within your own logic..
        make sure to keep the SH.scaleform and SH.instance table as the whole API depends on these.
        ⚠️ This is basically the whole "if it's set as visible.. draw it"
    ]]
    while true do
        Wait(0)
        if SH.instance and SH.instance:Visible() then
            SH.scaleform:Render2D()
        end
    end
end)

Citizen.CreateThread(function()
    local allowMouse = true
    while true do
        Wait(0)
        if SH.instance and SH.instance:Visible() then
            if SH.instance._mouseEnabled and IsUsingKeyboard(2) then
                if not allowMouse then
                    allowMouse = true
                    SH.scaleform:CallFunction("INIT_MOUSE_EVENTS", allowMouse)
                end
                SH.instance:ProcessMouse()
            else
                if allowMouse then
                    allowMouse = false
                    SH.scaleform:CallFunction("INIT_MOUSE_EVENTS", allowMouse)
                end
            end
            SH.instance:ProcessControl()
        end
    end
end)
