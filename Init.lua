local ADDON_NAME, ns = ...


-- TODO:
    -- add blacklist
    -- add a scroll? add a frame to the right of the highlighted frame and have the highlighted frame be the second most cheap item among the current 4


-- Variables.
local eventFrame
local minimapButton = LibStub("LibDBIcon-1.0")

-- Shows or hides the frame.
local function ToggleFrame()
    if SPRIOOptions.isHidden then
        ns.deleteButtonParent:Show()
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
    else
        ns.deleteButtonParent:Hide()
        PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
    end
    SPRIOOptions.isHidden = not SPRIOOptions.isHidden
end

-- Shows or hides the minimap button.
local function ToggleMinimapButton()
    SPRIOOptions.minimapTable.show = not SPRIOOptions.minimapTable.show
    if not SPRIOOptions.minimapTable.show then
        minimapButton:Hide("SellPriority")
        print("|cFFFFFF00SellPriority:|r Minimap button hidden. Type /SPRIO minimap to show it again.")
    else
        minimapButton:Show("SellPriority")
    end
end

-- Initializes the minimap button.
local function InitMinimapButton()
    -- Register for eventual data brokers.
    local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("SellPriority", {
        type = "data source",
        text = "SellPriority",
        icon = "Interface/Addons/SellPriority/Media/FrostPresence", -- TEMP
        OnClick = function(self, button)
            if button == "LeftButton" then
                ToggleFrame()
            elseif button == "RightButton" then
                ToggleMinimapButton()
            end
        end,
        OnEnter = function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:AddLine("|cFFFFFFFFSellPriority|r")
            GameTooltip:AddLine("Click to toggle the main frame. Right click to hide this minimap button.") -- temp
            GameTooltip:Show()
        end,
        OnLeave = function(self)
            GameTooltip:Hide()
        end
    })
    -- Create minimap icon.
    minimapButton:Register("SellPriority", LDB, SPRIOOptions.minimapTable)
end

-- Initializes slash commands.
local function InitSlash()
    SLASH_SPRIO1 = "/SPRIO"
    SLASH_SPRIO2 = "/SellPriority"
    function SlashCmdList.SPRIO(text)
        if text == "minimap" then
            ToggleMinimapButton()
        else
            ToggleFrame()
        end
    end
end

-- Registers for events.
local function Initialize()
    eventFrame = CreateFrame("Frame")
    ns:RegisterAllEvents(eventFrame)
    ns:InitDeleteButton()
end

-- Loads all saved variables.
local function LoadVariables()
    SPRIOOptions = SPRIOOptions or {}
    SPRIOOptions.isHidden = SPRIOOptions.isHidden or false
    SPRIOOptions.minimapTable = SPRIOOptions.minimapTable or {}
    SPRIOOptions.minimapTable.show = SPRIOOptions.minimapTable.show or true
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
        InitMinimapButton()
        InitSlash()
        print("|cFFFFFF00SellPriority|r loaded!")
    end
end

Initialize()
