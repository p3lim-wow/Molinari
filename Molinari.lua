local addonName, spells = ...
local button = CreateFrame('Button', addonName, UIParent, 'SecureActionButtonTemplate, AutoCastShineTemplate')
button:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
button:RegisterEvent('PLAYER_LOGIN')

local function ScanTooltip()
	for index = 1, GameTooltip:NumLines() do
		local info = spells[_G['GameTooltipTextLeft'..index]:GetText()]
		if(info) then
			return unpack(info)
		end
	end
end

local function OnLeave(self)
	if(InCombatLockdown()) then
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
	else
		AutoCastShine_AutoCastStop(self)
		self:ClearAllPoints()
		self:Hide()
	end
end

local function OnTooltip(self)
	if(self:GetItem() and not InCombatLockdown() and IsAltKeyDown()) then
		local spell, r, g, b = ScanTooltip()

		if(spell) then
			local bag, slot = GetMouseFocus():GetParent(), GetMouseFocus()
			button:SetAttribute('macrotext', string.format('/cast %s\n/use %s %s', spell, bag:GetID(), slot:GetID()))
			AutoCastShine_AutoCastStart(button, r, g, b)
			button:SetAllPoints(slot)
			button:Show()
		end
	end
end

function button:PLAYER_LOGIN()
	if(not IsSpellKnown(51005) and not IsSpellKnown(31252)) then return end

	if(IsSpellKnown(51005)) then
		spells[ITEM_MILLABLE] = {GetSpellInfo(51005), 1/2, 1, 1/2}
	end
	if(IsSpellKnown(31252)) then
		spells[ITEM_PROSPECTABLE] = {GetSpellInfo(31252), 1, 1/2, 1/2}
	end

	GameTooltip:HookScript('OnTooltipSetItem', OnTooltip)
	self:SetFrameStrata('DIALOG')
	self:SetAttribute('alt-type1', 'macro')
	self:SetScript('OnLeave', OnLeave)
	self:RegisterEvent('MODIFIER_STATE_CHANGED')
	self:Hide()

	for _, sparks in pairs(button.sparkles) do
		sparks:SetHeight(sparks:GetHeight() * 2)
		sparks:SetWidth(sparks:GetWidth() * 2)
	end
end

function button:MODIFIER_STATE_CHANGED(event, key)
	if(self:IsShown() and (key == 'LALT' or key == 'RALT')) then
		OnLeave(self)
	end
end

function button:PLAYER_REGEN_ENABLED(event)
	self:UnregisterEvent(event)
	OnLeave(self)
end
