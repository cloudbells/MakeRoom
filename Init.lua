local ADDON_NAME, ns = ...


-- TODO:
    -- add a scroll? add a frame to the right of the highlighted frame and have the highlighted frame be the second most cheap item among the current 4


-- Variables.
local eventFrame
local minimapButton = LibStub("LibDBIcon-1.0")

-- Adds the given item to the blacklist.
function ns:AddToBlacklist(itemID)
    SPRIOOptions.blacklist[itemID] = true
    local _, itemLink = GetItemInfo(itemID)
    print("|cFFFFFF00SellPriority|r: Added " .. itemLink .. " to the blacklist.")
    ns:ScanBags()
end

-- Removes the given item from the blacklist.
function ns:RemoveFromBlacklist(itemID)
    SPRIOOptions.blacklist[itemID] = nil
    local _, itemLink = GetItemInfo(itemID)
    print("|cFFFFFF00SellPriority|r: Removed " .. itemLink .. " from the blacklist.")
    ns:ScanBags()
end

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
        print("|cFFFFFF00SellPriority|r: Minimap button hidden. Type /SPRIO minimap to show it again.")
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
        icon = "Interface/Addons/SellPriority/Media/FrostPresence",
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
        if text == "help" then
            print("|cFFFFFF00SellPriority|r help: \n/sprio minimap - shows or hides the minimap\n/sprio blacklist add [itemlink] - adds the given itemlink to the blacklist\n" ..
                    "/sprio blacklist remove [itemlink] - removes the given item from the blacklist\n/sprio blacklist all - lists all the blacklist items\n" ..
                    "/sprio blacklist purge - removes all items from the blacklist")
        elseif text == "minimap" then
            ToggleMinimapButton()
        elseif text:find("blacklist add") then
            ns:AddToBlacklist(ns:ParseIDFromLink(text:match("blacklist add (.+)")))
        elseif text:find("blacklist remove") then
            ns:RemoveFromBlacklist(ns:ParseIDFromLink(text:match("blacklist remove (.+)")))
        elseif text == "blacklist all" then
            local str = ""
            for itemID in pairs(SPRIOOptions.blacklist) do
                local _, itemLink = GetItemInfo(itemID)
                str = str .. "\n* " .. itemLink
            end
            print("|cFFFFFF00SellPriority|r: all blacklist items:" .. str)
        elseif text == "blacklist purge" then
            SPRIOOptions.blacklist = {}
            ns:ScanBags()
            print("|cFFFFFF00SellPriority|r: removed all items from the blacklist")
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
    SPRIOOptions.blacklist = SPRIOOptions.blacklist or {}
end

-- Called when most game data is available.
function ns:OnPlayerEnteringWorld()
    eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    ns:ScanBags()
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
