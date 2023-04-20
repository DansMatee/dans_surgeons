local firstperson = false
local inMenu = false
local onCooldown = false

local PlasticPrompt

function SetupPlasticPrompt() -- Creates the prompt for entering the plastic surgeon
    Citizen.CreateThread(function()
        local str = 'Plastic Surgeon'
        PlasticPrompt = PromptRegisterBegin()
        PromptSetControlAction(PlasticPrompt, 0xE8342FF2)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(PlasticPrompt, str)
        PromptSetEnabled(PlasticPrompt, false)
        PromptSetVisible(PlasticPrompt, false)
        PromptSetHoldMode(PlasticPrompt, true)
        PromptRegisterEnd(PlasticPrompt)
    end)
end

function openMenu() 
    SendNUIMessage({ -- Sends a message to the UI with the amount of peds in peds_list to display on the menu
        type='getskins',
        maxSkins = #peds_list
    })
    SendNUIMessage({ -- Sends a message to the UI to open
        type='open'
    })
    SetNuiFocus(true, true)
end

function confirmSkin()
    firstperson = not firstperson
    DoScreenFadeOut(2000)
    Citizen.Wait(5000)
    DoScreenFadeIn(2000)
    firstperson = not firstperson

    if (Config.UseCooldown) then -- Allows the cooldown to be toggled
        onCooldown = true
    end
end

RegisterNUICallback('closeUI', function(data, cb)
    local closetype = data.type

    if (closetype == "exit") then -- If the close type is exit, the menu will close without doing anything else
        SetNuiFocus(false, false)
    elseif (closetype == "confirm") then -- If the close type is confirm, the script will then play animations
        SetNuiFocus(false, false)
        confirmSkin()
    end

    cb({})
end)

RegisterNUICallback('previewSkin', function(data, cb) -- This function gets the currently selected option and displays the player model for that option
    local id = tonumber(data.selected)

    local model = GetHashKey(peds_list[id][2]) -- Indexes through the peds_list table, finds the correct line with id, and takes the second variable to use
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(100)
    end

    Citizen.InvokeNative(0xED40380076A31506, PlayerId(), model, false) -- Switches the players model for the one currently selected
    Citizen.InvokeNative(0x283978A15512B2FE, PlayerPedId(), true) -- Gives it a random variation
    SetModelAsNoLongerNeeded(model)

    cb({})
end)




Citizen.CreateThread(function()
    SetupPlasticPrompt()
    while true do
        Citizen.Wait(0)
        local player = PlayerPedId()
        local coords = GetEntityCoords(player)
        -- Gets the distance between the players coords and the config'd location coords
        local dist = #(vector3(coords.x, coords.y, coords.z) - vector3(Config.location.x, Config.location.y, Config.location.z))

        -- Checks if the player is within the set distance
        if (dist < 1.5) then
            if (not inMenu) then
                PromptSetEnabled(PlasticPrompt, true)
                PromptSetVisible(PlasticPrompt, true)
            end
            if PromptHasHoldModeCompleted(PlasticPrompt) then
                if (not onCooldown) then
                    inMenu = true

                    -- Walks to the location defined
                    Citizen.InvokeNative(0x5BC448CB78FA3E88, PlayerPedId(), Config.location.x, Config.location.y, Config.location.z, 0.5, nil, 0, 1, 0)
                    Citizen.Wait(2500)
                    -- Sets the players heading to look at the mirror
                    SetEntityHeading(PlayerPedId(), 213.0)
                    Citizen.Wait(1000)
                    -- Opens the plastic surgeon
                    openMenu()

                    PromptSetEnabled(PlasticPrompt, false)
                    PromptSetVisible(PlasticPrompt, false)
                else
                    print("on cooldown!")
                end
            end
        else
            inMenu = false
            PromptSetEnabled(PlasticPrompt, false)
            PromptSetVisible(PlasticPrompt, false)
        end

        while firstperson do
            Citizen.Wait(10)
            -- Forces first person mode
            Citizen.InvokeNative(0x90DA5BA5C2635416)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if onCooldown then
            -- If cooldown is enabled, wait for the set amount of time by taking the config time, multiplying by 60 to get it to seconds,
            -- Then 1000 to convert into miliseconds to be used
            Citizen.Wait(Config.CooldownTime * 60 * 1000)
            onCooldown = false
        end
    end
end)



