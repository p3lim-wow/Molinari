local button = CreateFrame('Button', 'Molinari', UIParent, 'SecureActionButtonTemplate')
button:RegisterForClicks('LeftButtonUp')
button:SetAttribute('*type*', 'macro')

button:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=]})
button:SetBackdropColor(0, 0, 0, 0.4)

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
	[ITEM_MILLABLE] = {GetSpellInfo(51005), 0.5, 1, 0.5},
	[ITEM_PROSPECTABLE] = {GetSpellInfo(31252), 1, 0.5, 0.5},
}

function button:MODIFIER_STATE_CHANGED(event, key)
	if(self:IsShown() and (key == 'LALT' or key == 'RALT')) then
		self:GetScript('OnLeave')(self)
	end
end

function button:PLAYER_REGEN_ENABLED(event)
	self:UnregisterEvent(event)
	self:GetScript('OnLeave')(self)
end

local function Disenchantable(item)
	local _, _, quality, _, _, type = GetItemInfo(item)
	if ((type == ARMOR or type == ENCHSLOT_WEAPON) and quality > 1 and quality < 5) then
		return GetSpellInfo(13262), 0.5, 0.5, 1
	end
end

local function ScanTooltip()
	for index = 1, GameTooltip:NumLines() do
		local info = spells[_G['GameTooltipTextLeft'..index]:GetText()]
		if(info) then
			return unpack(info)
		end
	end
end

GameTooltip:HookScript('OnTooltipSetItem', function(self)
	local item = self:GetItem()
	if(item and IsAltKeyDown() and not InCombatLockdown()) then
		local spell, r, g, b = ScanTooltip()
		if(not spell) then
			spell, r, g, b = Disenchantable(item)
		end

		if(spell) then
			local slot = GetMouseFocus()
			button:SetAttribute('macrotext', macro:format(spell, slot:GetParent():GetID(), slot:GetID()))
			button:SetAllPoints(slot)
			button:SetParent(slot)
			button:Show()
			button:SetBackdropColor(r, g, b, 0.4)
		end
	end
end)
