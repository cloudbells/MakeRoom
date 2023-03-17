local _, ns = ...

local CUI = LibStub("CloudUI-1.0")
local GetContainerNumSlots = GetContainerNumSlots
local GetContainerItemInfo = GetContainerItemInfo
local GetItemInfo = GetItemInfo
local buttons = {}
local items = {}
local clickedButton = 0

-- Scans the given bag for the cheapest item. If bag is given, only scans that bag.
function ns:ScanBags(bag)
    items = {
        [1] = {
            value = 999999999
        },
        [2] = {
            value = 999999999
        },
        [3] = {
            value = 999999999
        }
    }
    for i = 1, 3 do
        for bag = bag and bag or BACKPACK_CONTAINER, bag and bag or NUM_BAG_SLOTS do
            for slot = 1, GetContainerNumSlots(bag) do
                local texture, count, _, quality, _, _, itemLink, _, _, itemID = GetContainerItemInfo(bag, slot)
                if itemID and SPRIOOptions and not SPRIOOptions.blacklist[itemID] then
                    local itemName, _, _, _, _, _, _, _, _, _, value = GetItemInfo(itemID)
                    if value and value > 0 then
                        value = value * count
                        if value < items[1].value then
                            items[1] = {
                                value = value,
                                itemName = itemName,
                                itemID = itemID,
                                texture = texture,
                                count = count,
                                quality = quality,
                                itemLink = itemLink,
                                bag = bag,
                                slot = slot
                            }
                        elseif value < items[2].value and not (items[1].bag == bag and items[1].slot == slot) then
                            items[2] = {
                                value = value,
                                itemName = itemName,
                                itemID = itemID,
                                texture = texture,
                                count = count,
                                quality = quality,
                                itemLink = itemLink,
                                bag = bag,
                                slot = slot
                            }
                        elseif value < items[3].value and not (items[1].bag == bag and items[1].slot == slot) and not (items[2].bag == bag and items[2].slot == slot) then
                            items[3] = {
                                value = value,
                                itemName = itemName,
                                itemID = itemID,
                                texture = texture,
                                count = count,
                                quality = quality,
                                itemLink = itemLink,
                                bag = bag,
                                slot = slot
                            }
                        end
                    end
                end
            end
        end
    end
    for i = 1, 3 do
        if items[i].texture then
            local color = ITEM_QUALITY_COLORS[items[i].quality]
            buttons[i]:Show()
            buttons[i]:Enable()
            buttons[i].priceFontString:SetText(GetCoinTextureString(items[i].value))
            buttons[i]:SetIcon(items[i].texture)
            buttons[i].countFontString:SetText(items[i].count > 1 and items[i].count)
            buttons[i]:SetBorderColor(color.r, color.g, color.b)
            buttons[i]:SetLink(items[i].itemLink)
            buttons[i]:SetItemLocation(items[i].bag, items[i].slot)
        else
            if i == 1 then
                buttons[i]:Disable()
            else
                buttons[i]:Hide()
            end
            buttons[i].priceFontString:SetText(nil)
            buttons[i]:SetIcon(nil)
            buttons[i].countFontString:SetText(nil)
            buttons[i]:SetLink(nil)
        end
    end
end

-- Called when the button is clicked.
local function DeleteButton_OnClick(self, button)
    if button == "RightButton" then
        if not SPRIOOptions.blacklist[items[self.id].itemID] then
            ns:AddToBlacklist(items[self.id].itemID)
        else
            ns:RemoveFromBlacklist(items[self.id].itemID)
        end
    elseif self:GetLink() then
        clickedButton = self.id
        StaticPopupDialogs["SPRIO_CONFIRM_DELETE"].text = "Are you sure you want to delete " .. items[self.id].itemLink .. (items[self.id].count > 1 and "x" .. items[self.id].count or "")
                .. " (" .. GetCoinTextureString(items[self.id].value) .. ")?"
        StaticPopup_Show("SPRIO_CONFIRM_DELETE")
    end
end

-- Sets the location of the item.
local function DeleteButton_SetItemLocation(self, bag, slot)
    self.bag = bag
    self.slot = slot
end

-- Gets the location of the item.
local function DeleteButton_GetItemLocation(self)
    return self.bag, self. slot
end

-- Called on BAG_UPDATE.
function ns:OnBagUpdate(bag)
    if bag >= 0 then
        ns:ScanBags(bag)
    end
end

-- Creates the delete button.
function ns:InitDeleteButton()
    -- Create the parent frame.
    ns.deleteButtonParent = CreateFrame("Frame", "SellPriorityFrame", UIParent)
    CUI:ApplyTemplate(ns.deleteButtonParent, CUI.templates.BackgroundFrameTemplate)
    CUI:ApplyTemplate(ns.deleteButtonParent, CUI.templates.BorderedFrameTemplate)
    ns.deleteButtonParent:SetSize(50, 50)
    ns.deleteButtonParent:SetPoint("CENTER")
    ns.deleteButtonParent:SetMovable(true)
    ns.deleteButtonParent:HookScript("OnMouseDown", function(self)
        self:StartMoving()
    end)
    ns.deleteButtonParent:HookScript("OnMouseUp", function(self)
        self:StopMovingOrSizing()
    end)
    -- Create buttons.
    for i = 1, 3 do
        buttons[i] = CUI:CreateLinkButton(ns.deleteButtonParent, "SellPriorityButton" .. i, {DeleteButton_OnClick})
        buttons[i]:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        buttons[i]:SetPoint("CENTER")
        buttons[i].priceFontString = buttons[i]:CreateFontString(nil, "OVERLAY", CUI:GetFontNormal():GetName())
        buttons[i].priceFontString:SetPoint("BOTTOM", 0, -25)
        buttons[i].countFontString = buttons[i]:CreateFontString(nil, "OVERLAY", CUI:GetFontNormal():GetName())
        buttons[i].countFontString:SetPoint("BOTTOMRIGHT")
        buttons[i].SetItemLocation = DeleteButton_SetItemLocation
        buttons[i].GetItemLocation = DeleteButton_GetItemLocation
        buttons[i].id = i
    end
    buttons[2]:SetPoint("RIGHT", ns.deleteButtonParent, "LEFT", -10, 0)
    buttons[2].priceFontString:SetPoint("BOTTOM", 0, -17)
    buttons[3]:SetPoint("RIGHT", buttons[2], "LEFT", -10, 0)
    buttons[3].priceFontString:SetPoint("BOTTOM", 0, -17)
    -- Init static popup.
    StaticPopupDialogs["SPRIO_CONFIRM_DELETE"] = {
        text = "Placeholder text",
        button1 = "Yes",
        button2 = "No",
        timeout = 0,
        OnAccept = function()
            PickupContainerItem(buttons[clickedButton]:GetItemLocation())
            DeleteCursorItem()
        end
    }
    ns:ScanBags()
end
