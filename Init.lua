local ADDON_NAME, ns = ...

-- Variables.
local eventFrame

-- Initializes slash commands.
local function InitSlash()
    SLASH_SPRIO1 = "/SPRIO"
    SLASH_SPRIO2 = "/SellPriority"
    function SlashCmdList.SPRIO(text)
        
    end
end

-- Registers for events.
local function Initialize()
    eventFrame = CreateFrame("Frame")
    ns:RegisterAllEvents(eventFrame)
end

-- Loads all saved variables.
local function LoadVariables()
    SPRIOOptions = SPRIOOptions or {}
end

-- Called when most game data is available.
function ns:OnPlayerEnteringWorld()
    eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

-- Called on ADDON_LOADED.
function ns:OnAddonLoaded(addonName)
    if addonName == ADDON_NAME then
        eventFrame:UnregisterEvent("ADDON_LOADED")
        LoadVariables()
        InitSlash()
        print("|cFFFFFF00SellPriority|r loaded!")
    end
end

Initialize()
