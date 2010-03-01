local addon = ...

local button = CreateFrame('Button', addon, UIParent, 'SecureActionButtonTemplate, AutoCastShineTemplate')
local macro = '/cast %s\n/use %s %s'
local spells = {}

local function ScanTooltip(text)
	for index = 1, GameTooltip:NumLines() do
		local info = spells[_G['GameTooltipTextLeft'..index]:GetText()]
		if(info) then
			return unpack(info)
		end
	end
end

local function Clickable()
	return not InCombatLockdown() and IsAltKeyDown()
end

local function Disperse(self)
	if(InCombatLockdown()) then
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
	else
		self:Hide()
		self:ClearAllPoints()
		AutoCastShine_AutoCastStop(self)
	end
end

function button:MODIFIER_STATE_CHANGED(event, key)
	if(self:IsShown() and (key == 'LALT' or key == 'RALT')) then
		Disperse(self)
	end
end

function button:PLAYER_REGEN_ENABLED(event)
	self:UnregisterEvent(event)
	Disperse(self)
end

GameTooltip:HookScript('OnTooltipSetItem', function(self)
	local item = self:GetItem()
	if(item and Clickable()) then
		local spell, r, g, b = ScanTooltip()
		if(spell) then
			local bag, slot = GetMouseFocus():GetParent(), GetMouseFocus()
			button:SetAttribute('macrotext', macro:format(spell, bag:GetID(), slot:GetID()))
			button:SetAllPoints(slot)
			button:Show()
			AutoCastShine_AutoCastStart(button, r, g, b)
		end
	end
end)

function button:PLAYER_LOGIN()
	if(IsSpellKnown(51005)) then
		spells[ITEM_MILLABLE] = {GetSpellInfo(51005), 0.5, 1, 0.5}
	end

	if(IsSpellKnown(31252)) then
		spells[ITEM_PROSPECTABLE] = {GetSpellInfo(31252), 1, 0.5, 0.5}
	end
end

do
	button:SetScript('OnLeave', Disperse)
	button:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
	button:SetFrameStrata('DIALOG')
	button:RegisterEvent('MODIFIER_STATE_CHANGED')
	button:RegisterEvent('PLAYER_LOGIN')
	button:RegisterForClicks('LeftButtonUp')
	button:SetAttribute('*type*', 'macro')
	button:Hide()

	for _, sparks in pairs(button.sparkles) do
		sparks:SetHeight(sparks:GetHeight() * 3)
		sparks:SetWidth(sparks:GetWidth() * 3)
	end
end
