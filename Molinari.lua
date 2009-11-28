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

local function Disenchantable(item)
	local _, _, quality, _, _, type = GetItemInfo(item)
	return (type == ARMOR or type == ENCHSLOT_WEAPON) and quality > 1 and quality < 5 and GetSpellInfo(13262)
end

local function ScanTooltip()
	local spell = nil
	for index = 1, GameTooltip:NumLines() do
		spell = spells[_G['GameTooltipTextLeft'..index]:GetText()]
	end
	return spell
end

GameTooltip:HookScript('OnTooltipSetItem', function(self)
	local item = self:GetItem()
	if(item and IsAltKeyDown() and not InCombatLockdown()) then
		local spell = ScanTooltip() or Disenchantable(item)
		if(spell) then
			local slot = GetMouseFocus()
			button:SetAttribute('macrotext', macro:format(spell, slot:GetParent():GetID(), slot:GetID()))
			button:SetAllPoints(slot)
			button:SetParent(slot)
			button:Show()
		end
	end
end)
