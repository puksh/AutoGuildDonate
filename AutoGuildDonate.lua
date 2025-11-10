
AGDResources = nil

local Auto = TEXT("UI_LOTTERYSHOP_AUTO")
local GuildContribution = TEXT("SYS_ITEMTYPE_26")
local Guild = TEXT("GUILDWAR_LANDMARK_NAME_1")

local _lang = tostring(GetLanguage() or "")
local ENLang = (string.sub(_lang,1,2):upper() == "EN") and true or false
local ADDON = ENLang and "Auto Guild Donate" or Auto.." "..GuildContribution

local VERSION = 5.2
local Author = TEXT("GUILD_MSG_POST_AUTHOR")
local CREATOR = Author..": ZTrek - edited by puksh"

local WhiteText = "|cffFFFFFF"
local GreenText = "|cff00ff00"
local BlueText = "|cff0072bc"
local PurpleText = "|cffc805f8"
local EndColor = "|r"

local AutoGuildDonateLoaded = true
local AGDDelay = 1

local LeftClickOpenSettings = TEXT("CHANNEL_CHANGE_LEFT_MOUSE_OPEN")--Left-Click to Open Settings Window
local Gold = TEXT("SYS_MONEY_TYPE_0")
-- Use the standard money label for the donate-gold button so localization is consistent
local Donategold = "Donate Gold"
local ContributionAmount = TEXT("GUILD_RESOURCE_TOTAL")
local Value = TEXT("PET_ATTR_VALUE")

local Herbs = TEXT("AC_ITEMTYPENAME_3_2")
local Ores = TEXT("AC_ITEMTYPENAME_3_0")
local Wood = TEXT("AC_ITEMTYPENAME_3_1")

local SelectAllState = false

AGDGuildResources = {
["207329"] = true, -- DauntlessCore
["207325"] = true, -- DreadEssence
["206261"] = true, -- FortuneGrass
["206262"] = true, -- GoldenEarofGrain
["202916"] = true, -- GuildRune
["202917"] = true, -- GuildStone
["207929"] = true, -- HandcraftedRuby
["206697"] = true, -- HerbEssence
["206590"] = true, -- MagicFortuneGrass
["206592"] = true, -- MoonlightPearl
["207326"] = true, -- NightmareEssence
["206695"] = true, -- OreEssence
["203450"] = true, -- RubyStone
["206263"] = true, -- StarPearl
["206591"] = true, -- SunsetEarofGrain
["207930"] = true, -- TeardropRuby
["207330"] = true, -- WisdomCore
["206696"] = true, -- WoodEssence
["207328"] = true, -- OriginalSinEssence
["207332"] = true, -- SoulCore
["207932"] = true, -- FlawlessRuby
["207324"] = true, -- MoonlightPearl1000
["207320"] = true, -- DarkNightPearl
["207322"] = true, -- ExquisiteWoodenChest
["1250540"] = true, -- AtlasCore
["1250539"] = true, -- AtlasEssence
["1244118"] = true, -- AtlasFernleaf
["1244117"] = true, -- AtlasFairywood
["1250538"] = true, -- AtlasRuby
["1244116"] = true, -- AtlasZinc
}

function AutoGuildDonate_OnLoad(this)
	this:RegisterEvent("VARIABLES_LOADED")
	this:RegisterEvent("PLAYER_BAG_CHANGED")
	this:RegisterEvent("PLAYER_MONEY")
    this:RegisterEvent("LOADING_END")
	SaveVariablesPerCharacter("AGDResources")
end

function AutoGuildDonate_OnEvent(this, event, arg1, arg2, arg3, arg4)
	if event == "VARIABLES_LOADED" then
		AGDResources = AGDResources or {}
		dofile("Interface/AddOns/AutoGuildDonate/AGDCheckboxIDs.lua")
	end
	if event == "PLAYER_BAG_CHANGED" then
		AGDDelay = 1
		AutoGuildDonatePopulateCheckBoxes()
	end
	if event == "LOADING_END" then
		AGDDelay = 1
		AutoGuildDonatePopulateCheckBoxes()
	end
	if event == "PLAYER_MONEY" and IsInGuild() then
		CurrGold = GetPlayerMoney("copper")
		if CurrGold > PrevGold then
			GoldMade = CurrGold - PrevGold
			PrevGold = CurrGold
			if DonateGoldCheckButton:IsChecked() and GoldMade > 0 then
				AutoGoldDonate(GoldMade)
			end
		end
	end
end

function AutoGuildDonate_OnUpdate(this, elapsedTime)
	AGDDelay = AGDDelay - elapsedTime
	if AGDDelay > 0 then
		return
	end
	PrevGold = GetPlayerMoney("copper")
	AutoGuildDonate()
	AGDDelay = 1
end

function AutoGuildDonate()
	if IsInGuild() then
		_, TotalAGDSlots = GetBagCount()
		for AGDBagSlot = 1, TotalAGDSlots do	
			AGDInvIndex = GetBagItemInfo(AGDBagSlot)
			AGDBagItemLink = GetBagItemLink(AGDInvIndex)
			if AGDBagItemLink ~= nil then
				AGDItemID = tostring(tonumber(string.sub(AGDBagItemLink, 8, 12), 16))
				if AGDCheckboxIDs[AGDItemID] and getglobal(AGDItemID):IsChecked() then
					PickupBagItem(AGDInvIndex)
					GCB_GetContributionItem(1)
					GCB_OnOK()
				end
			end
		end
	end
end

function AutoGoldDonate(GoldMade)
	if IsInGuild() then
		GoldMade = GoldMade or 0
		if DonateGoldCheckButton:IsChecked() then
			if ((GoldMade * AGDResources["GoldPerc"]/100) > 1) then
				GCB_ContributionItemOK((GoldMade * (AGDResources["GoldPerc"]/100)),0)
				GCB_OnOK()
			end
		else
			GCB_ContributionItemOK((GetPlayerMoney("copper") * (AGDResources["GoldPerc"]/100)),0)
			GCB_OnOK()
		end
	end
end

function AGDConfig()
	if IsInGuild() then
		if AutoGuildDonateLoaded then
			dofile("Interface/AddOns/AutoGuildDonate/AGDButtonLabels.lua")
			AutoGuildDonateLoaded = false
		end
		for ButtonName, ButtonText in pairs(AGDButtonLabels) do
			getglobal(ButtonName):SetText(ButtonText)
		end
		AutoGuildDonateLoad:Hide()
		getglobal("DonateGoldButton"):SetText(Donategold)
		ContributionAmountText:SetText(ContributionAmount)
		AGDResources["GoldPerc"] = AGDResources["GoldPerc"] or 1
		AutoGuildDonateTitle:SetText(ADDON)
		AutoGuildDonatePopulateCheckBoxes()
		WoodButtons:Hide()
		OreButtons:Hide()
		HerbButtons:Hide()
		GuildButtons:Show()
		ToggleUIFrame(AutoGuildDonateConfigFrame)
	else
		AGD_Config:Hide()
	end
end

function AGDMinimapButtonOnEnter(this)
	GameTooltip:SetOwner(this, "ANCHOR_LEFT", 4, 0)
	GameTooltip:SetText(ADDON.." v"..VERSION, 1, 1, 0)
	GameTooltip:AddSeparator()
	GameTooltip:AddLine(Auto.." "..GuildContribution, 1, 0.5, 0.12)
	GameTooltip:AddSeparator()
	GameTooltip:AddLine(LeftClickOpenSettings, 1, 1, 1)
	GameTooltip:AddSeparator()
	GameTooltip:AddLine(UI_MINIMAPBUTTON_MOVE, 0, 0.75, 0.95)
	GameTooltip:Show()
end

function AGDMinimapButtonOnClick(this, key)
	if key == "LBUTTON" then
		AGDConfig()
	end
end

function AutoGuildDonateSaveChanges()
	for ResourceID, _ in pairs(AGDCheckboxIDs) do
		if getglobal(ResourceID) ~= nil then
			if getglobal(ResourceID):IsChecked() then
				AGDResources[ResourceID] = true
			end
			if not getglobal(ResourceID):IsChecked() and AGDResources[ResourceID] == true then
				AGDResources[ResourceID] = false
			end
		end
	end
	AGDResources["DonateGoldCheckButton"] = DonateGoldCheckButton:IsChecked() and true or false
end

function AutoGuildDonatePopulateCheckBoxes()
	for ResourceID, _ in pairs(AGDCheckboxIDs) do
		if AGDResources and AGDResources[ResourceID] and getglobal(ResourceID) ~= nil then
			getglobal(ResourceID):SetChecked(AGDResources[ResourceID] == true)
		end
	end
	DonateGoldCheckButton:SetChecked(AGDResources["DonateGoldCheckButton"])
end

function ToggleAllCheckboxes()
	if type(AGDCheckboxIDs) ~= "table" then
		return
	end
	
	-- Check current state: count how many checkboxes are checked vs total
	local checkedCount = 0
	local totalCount = 0
	
	for ResourceID, _ in pairs(AGDCheckboxIDs) do
		local checkbox = getglobal(ResourceID)
		if checkbox ~= nil then
			totalCount = totalCount + 1
			if checkbox:IsChecked() then
				checkedCount = checkedCount + 1
			end
		end
	end
	
	-- If more than half are checked, uncheck all. Otherwise, check all.
	local shouldCheckAll = (checkedCount < totalCount / 2)
	
	for ResourceID, _ in pairs(AGDCheckboxIDs) do
		local checkbox = getglobal(ResourceID)
		if checkbox ~= nil then
			checkbox:SetChecked(shouldCheckAll)
		end
	end
	
	SelectAllState = shouldCheckAll
end

function SelectAllButtonOnEnter(this)
	if type(GameTooltip) ~= "table" or type(GameTooltip.SetOwner) ~= "function" then
		return
	end
	
	GameTooltip:SetOwner(this, "ANCHOR_RIGHT", 4, 0)
	GameTooltip:SetText("Select/Deselect All", 1, 1, 0)
	GameTooltip:AddLine("Click to toggle all resource checkboxes on or off", 1, 1, 1)
	GameTooltip:Show()
end
