local function safeLoad(url: string): any?
    print("Attempting to load from URL: " .. url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not success then
        warn("Failed to load: " .. url .. " - Error: " .. tostring(result))
        return nil
    end
    return result
end

-- Load Rayfield UI library and modules from AUBELI/Cassie
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local CommonUtil = safeLoad('https://raw.githubusercontent.com/AUBELI/Cassie/main/Main/Modules/CommonUtil.luau')
local AUTMainModule = safeLoad('https://raw.githubusercontent.com/AUBELI/Cassie/main/Main/Modules/AUTMainModule.luau')

-- Check if modules loaded successfully
if not CommonUtil or not AUTMainModule then
    warn("One or more required modules failed to load. Aborting.")
    return
end

-- Create the main window
local Window = Rayfield:CreateWindow({
    Name = "Supreme Hub | AUT | By Supreme",
    Icon = 0,
    LoadingTitle = "Supreme Hub",
    LoadingSubtitle = "By Supreme",
    ShowText = "Supreme Hub",
    Theme = "Default",
    ToggleUIKeybind = "LeftControl",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SupremeHub_AUT",
        FileName = "AUTConfig"
    }
})

-- Create tabs
local TabMain = Window:CreateTab("Main", "home")
local TabAutoLevel = Window:CreateTab("Auto-Level", "activity")
local TabMisc = Window:CreateTab("Misc", "map")
local TabSettings = Window:CreateTab("Settings", "settings")

-- Auto-Level System
TabAutoLevel:CreateSection("Auto-Level System")
local ToggleAutoFarm = TabAutoLevel:CreateToggle({
    Name = "Enable Auto-Level",
    CurrentValue = false,
    Flag = "AutoLevelToggle",
    Callback = function(Value: boolean)
        if Value then
            AUTMainModule.IsMonitoring = true
            AUTMainModule.RunLevelWatcher()
        else
            AUTMainModule.Reset()
        end
    end
})

TabAutoLevel:CreateSlider({
    Name = "Farm Delay (Seconds)",
    Range = {0.05, 1},
    Increment = 0.01,
    CurrentValue = 0.1,
    Flag = "FarmDelaySlider",
    Callback = function(Value: number)
        AUTMainModule.FarmInterval = Value
    end
})

local rarities = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"}
local selectedRarities = {}
for _, rarity in ipairs(rarities) do
    local default = rarity == "Common"
    selectedRarities[rarity] = default
    TabAutoLevel:CreateToggle({
        Name = rarity .. " Shards",
        CurrentValue = default,
        Flag = rarity .. "ShardToggle",
        Callback = function(Value: boolean)
            selectedRarities[rarity] = Value
            local activeRarities = {}
            for r, s in pairs(selectedRarities) do
                if s then table.insert(activeRarities, r) end
            end
            AUTMainModule.SetShardRarity(activeRarities)
        end
    })
end

-- Teleports
TabMisc:CreateSection("Teleports")
local locationNames = {}
for name in pairs(AUTMainModule.TeleportLocations or {}) do
    table.insert(locationNames, name)
end
table.sort(locationNames)

local selectedLocation
TabMisc:CreateDropdown({
    Name = "Choose a Location",
    Options = locationNames,
    CurrentOption = {locationNames[1] or ""},
    MultipleOptions = false,
    Flag = "TeleportDropdown",
    Callback = function(Option: {string})
        selectedLocation = Option[1]
    end
})

TabMisc:CreateButton({
    Name = "Teleport",
    Callback = function()
        if not selectedLocation then
            return
        end
        local position = AUTMainModule.TeleportLocations[selectedLocation]
        if position then
            local success, err = pcall(function()
                CommonUtil.Teleport(position)
            end)
            if not success then
                warn("Teleport error: " .. tostring(err))
            end
        end
    end
})

-- Stand
TabMisc:CreateSection("Stand")
TabMisc:CreateToggle({
    Name = "Auto Ascension",
    CurrentValue = false,
    Flag = "AutoAscensionToggle",
    Callback = function(Value: boolean)
        AUTMainModule.SetAutoAscend(Value)
        if Value then
            AUTMainModule.IsMonitoring = true
            AUTMainModule.RunLevelWatcher()
        else
            AUTMainModule.Reset()
        end
    end
})

-- Visuals
TabMisc:CreateSection("Visuals")
TabMisc:CreateToggle({
    Name = "VFX Remover",
    CurrentValue = false,
    Flag = "VFXRemoverToggle",
    Callback = function(Value: boolean)
        AUTMainModule.SetVFXAutoRemove(Value)
    end
})

TabMisc:CreateToggle({
    Name = "Remove Desert Fog",
    CurrentValue = false,
    Flag = "FogRemoverToggle",
    Callback = function(Value: boolean)
        AUTMainModule.SetFogAutoRemove(Value)
    end
})

-- Load saved configuration
Rayfield:LoadConfiguration()
