-- this hacky mess exists because C_TradeSkill.OpenTradeSkill(skillLineID) is the only method of
-- requesting tradeskill data (like skill levels), and it requires a hardware event. all of this
-- could be prevented by blizzard implementing a way to request the data without a distruptive
-- (as in opening a UI), hardware event requiring trigger.
-- https://github.com/Stanzilla/WoWUIBugs/issues/424

-- how it works:
-- since we're always going to expect the player to hit the Alt key in order to use Molinari
-- we can listen to key events (which are valid hardware events), then open the tradeskill UI
-- ourselves, closing it as soon as it opens. by opening a single profession (even secondary) we
-- have valid data for all professions, even if we unlearn one and learn another. in case the
-- player doesn't have a profession yet we will wait until they do, then listen for key presses.
-- even if the player opens the bags without pressing keys, the OnKeyDown event triggers before
-- Molinari's tooltip handler fires, and the data will be available by then.

-- in case other addons copies this, make sure it never loads multiple times unless there is a
-- newer version of it, in which case we disable it and load anyways
local version = 1
if _G['ForceLoadTradeSkillData'] then
	if _G['ForceLoadTradeSkillData'].version < version then
		_G['ForceLoadTradeSkillData']:UnregisterAllEvents()
	else
		return
	end
end

local hack = CreateFrame('Frame', 'ForceLoadTradeSkillData')
hack.version = version
hack:SetPropagateKeyboardInput(true) -- make sure we don't own the keyboard
hack:RegisterEvent('PLAYER_LOGIN')
hack:SetScript('OnEvent', function(self, event)
	if event == 'PLAYER_LOGIN' then
		local professionID = self:GetAnyProfessionID()
		if not professionID then
			-- player has no professions, wait for them to learn one
			self:RegisterEvent('SKILL_LINES_CHANGED')
		elseif not self:HasProfessionData(professionID) then
			-- player has profession but the session has no data, listen for key event
			self.professionID = professionID
			self:SetScript('OnKeyDown', self.OnKeyDown)
		end
	elseif event == 'TRADE_SKILL_SHOW' then
		if not (C_TradeSkillUI.IsTradeSkillLinked() or C_TradeSkillUI.IsTradeSkillGuild()) then
			-- we've triggered the tradeskill UI, close it again and bail out
			C_TradeSkillUI.CloseTradeSkill()
			self:UnregisterEvent(event)
		end
	elseif event == 'SKILL_LINES_CHANGED' then
		if self:GetAnyProfessionID() then
			-- player has learned a profession, listen for key event
			self:SetScript('OnKeyDown', self.OnKeyDown)
			self:UnregisterEvent(event)
		end
	end
end)

function hack:OnKeyDown()
	-- unregister ourselves first to avoid duplicate queries
	self:SetScript('OnKeyDown', nil)

	-- listen for tradeskill UI opening then query it
	self:RegisterEvent('TRADE_SKILL_SHOW')
	C_TradeSkillUI.OpenTradeSkill(self.professionID)
end

function hack:GetAnyProfessionID()
	-- any profession except archaeology is valid for requesting data
	for index, professionIndex in next, {GetProfessions()} do
		if index ~= 3 and professionIndex then
			local _, _, _, _, _, _, professionID = GetProfessionInfo(professionIndex)
			if professionID then
				return professionID
			end
		end
	end
end

function hack:HasProfessionData(professionID)
	local skillInfo = C_TradeSkillUI.GetProfessionInfoBySkillLineID(professionID)
	return skillInfo and skillInfo.maxSkillLevel and skillInfo.maxSkillLevel > 0
end
