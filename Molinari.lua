
local button = CreateFrame('Button', 'Molinari', UIParent, 'SecureActionButtonTemplate')
button:SetScript('OnEvent', function(self, event, ...) self[event](self, ...) end)
button:RegisterEvent('PLAYER_LOGIN')

local function ScanTooltip(self, spells)
	for index = 1, self:NumLines() do
		local info = spells[_G['GameTooltipTextLeft' .. index]:GetText()]
		if(info) then
			return unpack(info)
		end
	end
end

function button:PLAYER_LOGIN()
	local spells = {}
	if(IsSpellKnown(51005)) then
		spells[ITEM_MILLABLE] = {GetSpellInfo(51005), 1/2, 1, 1/2}
	end

	if(IsSpellKnown(31252)) then
		spells[ITEM_PROSPECTABLE] = {GetSpellInfo(31252), 1, 1/3, 1/3}
	end

	GameTooltip:HookScript('OnTooltipSetItem', function(self)
		local item, link = self:GetItem()
		if(item and not InCombatLockdown() and IsAltKeyDown()) then
			local spell, r, g, b = ScanTooltip(self, spells)

			local bag, slot = GetMouseFocus():GetParent(), GetMouseFocus()
			if(spell and GetContainerItemLink(bag:GetID(), slot:GetID()) == link) then
				button:SetAttribute('macrotext', string.format('/cast %s\n/use %s %s', spell, slot:GetParent():GetID(), slot:GetID()))
				button:GetNormalTexture():SetVertexColor(r, g, b)
				button:SetAllPoints(slot)
				button:Show()
			end
		end
	end)

	self:SetFrameStrata('DIALOG')
	self:SetAttribute('alt-type1', 'macro')
	self:SetNormalTexture([=[Interface\PaperDollInfoFrame\UI-GearManager-ItemButton-Highlight]=])
	self:GetNormalTexture():SetTexCoord(0.11, 0.66, .11, 0.66)
	self:SetScript('OnLeave', self.MODIFIER_STATE_CHANGED)

	self:RegisterEvent('MODIFIER_STATE_CHANGED')
	self:Hide()
end

function button:MODIFIER_STATE_CHANGED(key)
	if(not self:IsShown() and not key and key ~= 'LALT' and key ~= 'RALT') then return end
	
	if(InCombatLockdown()) then
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
	else
		self:ClearAllPoints()
		self:Hide()
	end
end

function button:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent('PLAYER_REGEN_ENABLED')
	self:ClearAllPoints()
	self:Hide()
end
