local button = CreateFrame('Button', 'Molinari', UIParent, 'SecureActionButtonTemplate')
button:RegisterForClicks('LeftButtonUp')
button:SetAttribute('*type*', 'macro')

button:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=]})
button:SetBackdropColor(1, 0.5, 0.5, 0.4)

button:RegisterEvent('MODIFIER_STATE_CHANGED')
button:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
button:SetScript('OnLeave', function(self)
	if(InCombatLockdown()) then
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
	else
		self:Hide()
	end
end)

local macro = '/cast %s\n/use %s %s'

local spells = {
	[ITEM_MILLABLE] = GetSpellInfo(51005),
	[ITEM_PROSPECTABLE] = GetSpellInfo(31252),
}

function button:MODIFIER_STATE_CHANGED(event, key)
	if(self:IsShown() and (key == 'LALT' or key == 'RALT')) then
		self:GetScript('OnLeave')(self)
	end
end

function button:PLAYER_REGEN_ENABLED(event)
	self:UnregisterEvent(event)
	self:Hide()
end

GameTooltip:HookScript('OnTooltipSetItem', function(self)
	if(self:GetItem() and IsAltKeyDown() and not InCombatLockdown()) then
		local spell = spells[GameTooltipTextLeft2:GetText()]
		if(spell) then
			button:SetAttribute('macrotext', macro:format(spell, GetMouseFocus():GetParent():GetID(), GetMouseFocus():GetID()))
			button:SetAllPoints(GetMouseFocus())
			button:SetParent(GetMouseFocus())
			button:Show()
		end
	end
end)
