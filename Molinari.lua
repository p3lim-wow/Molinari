local ARMORTYPE
if(GetLocale() == 'ruRU') then
	ARMORTYPE = 'Доспехи' -- DIAF Blizzard
else
	ARMORTYPE = ARMOR
end

local button = CreateFrame('Button', 'Molinari', UIParent, 'SecureActionButtonTemplate, AutoCastShineTemplate')
button:RegisterForClicks('LeftButtonUp')
button:SetAttribute('*type*', 'macro')
button:Hide()

for _, spark in pairs(button.sparkles) do
	spark:SetHeight(spark:GetHeight() * 3)
	spark:SetWidth(spark:GetWidth() * 3)
end

button:SetFrameStrata('DIALOG')
button:RegisterEvent('PLAYER_LOGIN')
button:RegisterEvent('MODIFIER_STATE_CHANGED')
button:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
button:SetScript('OnLeave', function(self)
	if(InCombatLockdown()) then
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
	else
		self:Hide()
		self:ClearAllPoints()
		AutoCastShine_AutoCastStop(self)
	end
end)

local disenchanting = GetSpellInfo(13262)
local macro = '/cast %s\n/use %s %s'
local spells = {}

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
	if((type == ARMORTYPE or type == ENCHSLOT_WEAPON) and quality > 1 and quality < 5) then
		return disenchanting, 0.5, 0.5, 1
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

local function Clickable()
	return not InCombatLockdown() and IsAltKeyDown()
end

GameTooltip:HookScript('OnTooltipSetItem', function(self)
	local item = self:GetItem()
	if(item and Clickable()) then
		local spell, r, g, b = ScanTooltip()
		if(not spell) then
			spell, r, g, b = Disenchantable(item)
		end

		local bag, slot = GetMouseFocus():GetParent(), GetMouseFocus()
		if(spell and GetContainerItemInfo(bag:GetID(), slot:GetID()) and bag ~= PaperDollFrameItemFlyoutButtons) then
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

	if(not IsSpellKnown(13262)) then
		Disenchantable = function() end
	end
end
