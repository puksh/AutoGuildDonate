local function IsAddonAlreadyRegistered(name)
    if type(AddonManager) ~= "table" or type(AddonManager.Addons) ~= "table" then return false end
    for _, a in ipairs(AddonManager.Addons) do
        if type(a) == "table" and a.name == name then return true end
    end
    return false
end

local function OpenAGDConfig()
    if type(AGDConfig) == "function" then AGDConfig(); return end
    local cfg = rawget(_G or {}, "AutoGuildDonateConfigFrame")
    if cfg and type(ToggleUIFrame) == "function" then ToggleUIFrame(cfg) end
end

if type(AddonManager) == "table" and type(AddonManager.RegisterAddonTable) == "function" then
    if not IsAddonAlreadyRegistered("AutoGuildDonate") then
        local addon = {
            name = "AutoGuildDonate",
            version = "v5.0",
            author = "ZTrek - edited by puksh",
            description = "Automatically donate selected resources and gold to the guild.",
            category = "Economy",
            -- Icons
            icon = "Interface/Addons/AutoGuildDonate/buttons/AGDNormal",
            mini_icon = "Interface/Addons/AutoGuildDonate/buttons/AGDNormal",
            mini_icon_pushed = "Interface/Addons/AutoGuildDonate/buttons/AGDPushed",
            -- Slash command
            slashCommands = nil,
            -- Config frame
            configFrame = rawget(_G or {}, "AutoGuildDonateConfigFrame"),
            -- Click handlers
            onClickScript = function(btn, key)
                OpenAGDConfig()
            end,
            mini_onClickScript = function(btn, key)
                OpenAGDConfig()
            end,
            -- Enable/disable handlers
            disableScript = function()
                local loadFrame = rawget(_G or {}, "AutoGuildDonateLoad")
                if loadFrame then
                    if type(loadFrame.UnregisterAllEvents) == "function" then loadFrame:UnregisterAllEvents() end
                    if type(loadFrame.SetScript) == "function" then loadFrame:SetScript("OnUpdate", nil) end
                    if type(loadFrame.Hide) == "function" then loadFrame:Hide() end
                end
                local minimap = rawget(_G or {}, "AGD_Config")
                if minimap and type(minimap.SetVisible) == "function" then minimap:SetVisible(false)
                elseif minimap and type(minimap.Hide) == "function" then minimap:Hide() end
                local cfg = rawget(_G or {}, "AutoGuildDonateConfigFrame")
                if cfg and type(cfg.Hide) == "function" then cfg:Hide() end
                if rawget(_G or {}, "AutoGuildDonateLoaded") ~= nil then AutoGuildDonateLoaded = false end
            end,
            enableScript = function()
                local loadFrame = rawget(_G or {}, "AutoGuildDonateLoad")
                if loadFrame and type(_G.AutoGuildDonate_OnLoad) == "function" then pcall(_G.AutoGuildDonate_OnLoad, loadFrame) end
                local minimap = rawget(_G or {}, "AGD_Config")
                if minimap and type(minimap.SetVisible) == "function" then minimap:SetVisible(true)
                elseif minimap and type(minimap.Show) == "function" then minimap:Show() end
                if rawget(_G or {}, "AutoGuildDonateLoaded") ~= nil then AutoGuildDonateLoaded = true end
            end,
        }
        AddonManager.RegisterAddonTable(addon)
        _G.AddonManager_SkipAutoRegister_AutoGuildDonate = true
    end
else
    if type(DEFAULT_CHAT_FRAME) == "table" and type(DEFAULT_CHAT_FRAME.AddMessage) == "function" then
        DEFAULT_CHAT_FRAME:AddMessage(string.format("%s%s%s %sv%s%s %s%s%s",
            BlueText or "", ADDON or "Auto Guild Donate", EndColor or "",
            GreenText or "", VERSION or "", EndColor or "",
            WhiteText or "", CREATOR or "", EndColor or ""))
    end
end
