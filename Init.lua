local ADDON_NAME, ns = ...


-- TODO:
    -- add a scroll? add a frame to the right of the highlighted frame and have the highlighted frame be the second most cheap item among the current 4

-- Variables.
local eventFrame
local minimapButton = LibStub("LibDBIcon-1.0")

-- Adds the given item to the blacklist.
function ns:AddToBlacklist(itemID)
    MROptions.blacklist[itemID] = true
    local _, itemLink = GetItemInfo(itemID)
    print("|cFFFFFF00MakeRoom|r: Added " .. itemLink .. " to the blacklist.")
    ns:ScanBags()
end

-- Removes the given item from the blacklist.
function ns:RemoveFromBlacklist(itemID)
    MROptions.blacklist[itemID] = nil
    local _, itemLink = GetItemInfo(itemID)
    print("|cFFFFFF00MakeRoom|r: Removed " .. itemLink .. " from the blacklist.")
    ns:ScanBags()
end

-- Shows or hides the frame.
local function ToggleFrame()
    if MROptions.isHidden then
        ns.deleteButtonParent:Show()
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
    else
        ns.deleteButtonParent:Hide()
        PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
    end
    MROptions.isHidden = not MROptions.isHidden
end

-- Shows or hides the minimap button.
local function ToggleMinimapButton()
    MROptions.minimapTable.show = not MROptions.minimapTable.show
    if not MROptions.minimapTable.show then
        minimapButton:Hide("MakeRoom")
        print("|cFFFFFF00MakeRoom|r: Minimap button hidden. Type /MR minimap to show it again.")
    else
        minimapButton:Show("MakeRoom")
    end
end

-- Initializes the minimap button.
local function InitMinimapButton()
    -- Register for eventual data brokers.
    local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("MakeRoom", {
        type = "data source",
        text = "MakeRoom",
        icon = "Interface/Addons/MakeRoom/Media/FrostPresence",
        OnClick = function(self, button)
            if button == "LeftButton" then
                ToggleFrame()
            elseif button == "RightButton" then
                ToggleMinimapButton()
            end
        end,
        OnEnter = function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:AddLine("|cFFFFFFFFMakeRoom|r")
            GameTooltip:AddLine("Click to toggle the main frame. Right click to hide this minimap button.") -- temp
            GameTooltip:Show()
        end,
        OnLeave = function(self)
            GameTooltip:Hide()
        end
    })
    -- Create minimap icon.
    minimapButton:Register("MakeRoom", LDB, MROptions.minimapTable)
end

-- Initializes slash commands.
local function InitSlash()
    SLASH_MAKEROOM1 = "/MR"
    SLASH_MAKEROOM2 = "/MakeRoom"
    function SlashCmdList.MAKEROOM(text)
        if text == "help" then
            print("|cFFFFFF00MakeRoom|r help: \n/mr minimap - shows or hides the minimap\n/mr blacklist add [itemlink] - adds the given itemlink to the blacklist\n" ..
                    "/mr blacklist remove [itemlink] - removes the given item from the blacklist\n/mr blacklist all - lists all the blacklist items\n" ..
                    "/mr blacklist purge - removes all items from the blacklist")
        elseif text == "minimap" then
            ToggleMinimapButton()
        elseif text:find("blacklist add") then
            ns:AddToBlacklist(ns:ParseIDFromLink(text:match("blacklist add (.+)")))
        elseif text:find("blacklist remove") then
            ns:RemoveFromBlacklist(ns:ParseIDFromLink(text:match("blacklist remove (.+)")))
        elseif text == "blacklist all" then
            local str = ""
            for itemID in pairs(MROptions.blacklist) do
                local _, itemLink = GetItemInfo(itemID)
                str = str .. "\n* " .. itemLink
            end
            print("|cFFFFFF00MakeRoom|r: all blacklist items:" .. str)
        elseif text == "blacklist purge" then
            MROptions.blacklist = {}
            ns:ScanBags()
            print("|cFFFFFF00MakeRoom|r: removed all items from the blacklist")
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
    MROptions = MROptions or {}
    MROptions.isHidden = MROptions.isHidden or false
    MROptions.minimapTable = MROptions.minimapTable or {}
    MROptions.minimapTable.show = MROptions.minimapTable.show or true
    MROptions.blacklist = MROptions.blacklist or {}
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
        print("|cFFFFFF00MakeRoom|r loaded!")
    end
end

Initialize()
