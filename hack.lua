-- this hacky mess is a way around C_TradeSkillUI.OpenTradeSkill requiring a hardware event.

-- we circumvent it specifically for Molinari by replacing the keybinds for opening bags to
-- also open the tradeskill briefly then hide it. we also hook clicking the bag buttons for the same
-- reason and purpose.

-- since we're using Molinari for milling or prospecting, it's _highly_ likely (although not
-- fool-proof) that the user would open their bags to use Molinari. hooking into that will open and
-- close the tradeskill ui to validate the C_TradeSkillUI APIs.

-- when the tradeskill data is ready, LibProcessable will be able to cache the necessary data.

-- this might heavyly fuck with other addons that deal with professions or bags, and it might taint
-- the everliving shit out of everything, we'll just have to see.

-- blizzard, please just give us a way to request the tradeskill data in a way that doesn't require
-- hardware events or having to open the tradeskill ui, which is already possible in classic.

local addonName = ...

local done = false
local overrideActive = false
local overrideClicked = false
local bagsClicked = false

local TRADESKILL_MACRO = [[
/run C_TradeSkillUI.OpenTradeSkill(%d)
/click %s LeftButton
]]

local RESET_ONCLICK = [[
local ref = self:GetFrameRef('owner')
ref:ClearBindings()
]]

local ref = CreateFrame('Frame')
local function resetAction(self)
	overrideActive = false
	_G[self.action]()
end

local function overrideClick()
	overrideClicked = true
end

local function hookBinding(key, professionID, action)
	local reset = CreateFrame('Button', addonName .. 'HackyResetButton' .. key .. action, nil, 'SecureHandlerClickTemplate')
	reset:RegisterForClicks('AnyUp', 'AnyDown')
	reset:SetFrameRef('owner', ref)
	reset:SetAttribute('_onclick', RESET_ONCLICK)
	reset:HookScript('OnClick', resetAction)
	reset.action = action

	local tradeskill = CreateFrame('Button', addonName .. 'HackyTradeskillButton' .. key .. action, nil, 'SecureActionButtonTemplate')
	tradeskill:RegisterForClicks('AnyUp', 'AnyDown')
	tradeskill:SetAttribute('type', 'macro')
	tradeskill:SetAttribute('macrotext', TRADESKILL_MACRO:format(professionID, reset:GetName()))
	tradeskill:HookScript('PreClick', overrideClick)

	SetOverrideBindingClick(ref, true, key, tradeskill:GetName())

	overrideActive = true
end

local validProfessionID
local function bagButtonTradeskill()
	if not bagsClicked and not done then
		bagsClicked = true
		C_TradeSkillUI.OpenTradeSkill(validProfessionID)
	end
end

ref:RegisterEvent('PLAYER_LOGIN')
ref:SetScript('OnEvent', function(self, event)
	if event == 'PLAYER_LOGIN' then
		for _, professionIndex in next, {GetProfessions()} do
			local _, _, _, _, _, _, professionID = GetProfessionInfo(professionIndex)
			if professionID and professionID > 0 then
				validProfessionID = professionID
				break
			end
		end

		if not validProfessionID then
			return
		end

		for binding, action in next, {
			OPENALLBAGS = 'ToggleAllBags',
			TOGGLEBACKPACK = 'ToggleBackpack',
		} do
			local key1, key2 = GetBindingKey(binding)
			if key1 then
				hookBinding(key1, validProfessionID, action)
			end
			if key2 then
				hookBinding(key2, validProfessionID, action)
			end
		end

		for _, button in next, {
			'MainMenuBarBackpackButton',
			'CharacterBag0Slot',
			'CharacterBag1Slot',
			'CharacterBag2Slot',
			'CharacterBag3Slot',
			'CharacterReagentBag0Slot',
		} do
			if _G[button] then
				_G[button]:HookScript('OnClick', bagButtonTradeskill)
			end
		end

		self:RegisterEvent('TRADE_SKILL_SHOW')
		self:RegisterEvent('TRADE_SKILL_CLOSE')
	else
		if overrideActive then
			if not InCombatLockdown() then
				ClearOverrideBindings(ref)
				overrideActive = false
			else
				self:RegisterEvent('PLAYER_REGEN_ENABLED')
			end
		end

		self:UnregisterEvent(event)

		if not (overrideClicked or bagsClicked) then
			-- player must have opened a profession intentionally, bail out
			done = true
		end

		if not done then
			done = true
			C_TradeSkillUI.CloseTradeSkill()
		end
	end
end)
