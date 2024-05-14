local Private = select(2, ...)
local TeleportCloak = CreateFrame("Button", "TeleportCloak", UIParent, "SecureActionButtonTemplate")
TeleportCloak:RegisterEvent("ADDON_LOADED")
TeleportCloak:SetMouseClickEnabled(true)
TeleportCloak:SetAttribute("pressAndHoldAction", true)
TeleportCloak:SetAttribute("typerelease", "item")

local TeleportItems = Private.Items

local EquipItemByName, GetInventoryItemID, GetItemCooldown, GetItemCount, GetItemInfo,
    GetItemInfoInstant, GetTime, InCombatLockdown, pairs, print, tinsert, wipe =
    C_Item.EquipItemByName, GetInventoryItemID, C_Item.GetItemCooldown, C_Item.GetItemCount, C_Item.GetItemInfo,
    C_Item.GetItemInfoInstant, GetTime, InCombatLockdown, pairs, print, tinsert, wipe

function TeleportCloak:Print(...)
    print("|cff33ff99TeleportCloak:|r ", ...)
end

local InventoryTypes = {
    cloaks = INVTYPE_CLOAK,
    feet = INVTYPE_FEET,
    necks = INVTYPE_NECK,
    rings = INVTYPE_FINGER,
    tabards = INVTYPE_TABARD,
    trinkets = INVTYPE_TRINKET,
}

function TeleportCloak:Command(msg)
    local cmd, arg = (msg or ""):lower():match("^(%S*)%s*(.-)$")
    if cmd == "add" then
        if arg == "" then
            self:Print("Usage: |cff80ffc0/tc add <item or type>|r")
        else
            if InventoryTypes[arg] then
                for _, item in pairs(TeleportItems[InventoryTypes[arg]]) do
                    tinsert(self.items, item)
                end
            else
                local itemId = GetItemInfoInstant(arg)
                if (not itemId) then
                    self:Print("Item not found:", arg)
                else
                    tinsert(self.items, itemId)
                end
            end
        end
        return
    elseif cmd == "warnings" then
        self.db.warnings = not self.db.warnings
    else
        print("|cff33ff99TeleportCloak", self.Version, "|r")
        self:Print("Add |cff80ffc0/click TeleportCloak|r",
            "to a macro, and TeleportCloak will use your equipped teleport item,",
            "or attempt to equip one if none are equipped.")
        self:Print("To limit to specific items, add",
            "|cff80ffc0/tc add <item or type>|r",
            "for each item or type to the beginning of the macro.")
        self:Print("|cff80ffc0<item>|r can be an item ID or item name")
        local types = "|cff80ffc0<type>|r can be"
        for inventoryType, _ in pairs(InventoryTypes) do
            types = types.." |cff80ffc0"..inventoryType.."|r,"
        end
        self:Print(types, "and will add all items of that type.")

    end
    self:Print("Warnings are",
        self.db.warnings and "|cff19ff19Enabled|r." or "|cffff2020Disabled|r.",
        "To turn them",
        self.db.warnings and "off," or "on,",
        "type |cff80ffc0/tc warnings|r")
end

function TeleportCloak:IsTeleportItem(item)
    for _, items in pairs(TeleportItems) do
        for _, teleportItem in pairs(items) do
            if item == teleportItem then
                return true
            end
        end
    end
    return false
end

local InventorySlots = {
    INVSLOT_NECK,
    INVSLOT_FEET,
    INVSLOT_FINGER1,
    INVSLOT_FINGER2,
    INVSLOT_TRINKET1,
    INVSLOT_TRINKET2,
    INVSLOT_BACK,
    INVSLOT_TABARD,
}

TeleportCloak:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addon = ...
        if addon == "TeleportCloak" then
            self:UnregisterEvent("ADDON_LOADED")
            self.items = {}

            -- Set version
            self.Version = C_AddOns.GetAddOnMetadata("TeleportCloak", "Version") or ""
            if self.Version:sub(1, 1) == "@" then
                self.Version = "Development Version"
            end

            -- Initialize saved variables
            TeleportCloakDB = TeleportCloakDB or { warnings = true }
            self.db = TeleportCloakDB
            self.db.saved = self.db.saved or {}

            -- Register events
            self:RegisterEvent("PLAYER_ENTERING_WORLD")
            self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
            self:RegisterEvent("ZONE_CHANGED_INDOORS")
            self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
            self:RegisterEvent("ZONE_CHANGED")

            -- Register slash commands
            _G["SLASH_TeleportCloak1"] = "/teleportcloak"
            _G["SLASH_TeleportCloak2"] = "/tc"
            SlashCmdList.TeleportCloak = function(msg) TeleportCloak:Command(msg) end
        end
        return
    end

    if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_EQUIPMENT_CHANGED" then
        -- Save equipped items
        for _, slot in pairs(InventorySlots) do
            local item = GetInventoryItemID("player", slot)
            -- Save the item if it's not a teleport item
            if item and (not self:IsTeleportItem(item)) then
                self.db.saved[slot] = item
            end
        end
        return
    end

    -- Wait to restore until out of combat
    if InCombatLockdown() then
        -- A restore was requested while in combat
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end
    if event == "PLAYER_REGEN_ENABLED" then
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    end

    -- Restore equipped items
    for _, slot in pairs(InventorySlots) do
        local item = GetInventoryItemID("player", slot)
        if item and self:IsTeleportItem(item) then
            if (not self.db.saved[slot]) then
                if self.db.warnings then
                    TeleportCloak:Print(select(2, GetItemInfo(item)), "is equipped.")
                end
            else
                EquipItemByName(self.db.saved[slot])
            end
        end
    end
end)

TeleportCloak:SetScript("PreClick", function(self)
    if InCombatLockdown() then return end
    if (not self.items[1]) then
        -- no items are set, default to cloaks
        for _, item in pairs(TeleportItems[INVTYPE_CLOAK]) do
            tinsert(self.items, item)
        end
    end
    for _, item in pairs(self.items) do
        local count = GetItemCount(item)
        if count > 0 then
            local startTime, duration = GetItemCooldown(item)
            if (startTime == 0 or duration - (GetTime() - startTime) <= 30) then
                self:SetAttribute("item", "item:"..item)
                return
            end
        end
    end
    self:Print("All items are on cooldown.")
end)

TeleportCloak:SetScript("PostClick", function(self)
    wipe(self.items)
    if (not InCombatLockdown()) then
        self:SetAttribute("item", nil)
    end
end)
