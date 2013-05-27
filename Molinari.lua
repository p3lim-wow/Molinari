
local addonName, ns = ...
local button = CreateFrame('Button', addonName, UIParent, 'SecureActionButtonTemplate, AutoCastShineTemplate')
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

local function ApplyButton(itemLink, spell, r, g, b)
	local slot = GetMouseFocus()
	local bag = slot:GetParent():GetID()

	if(GetContainerItemLink(bag, slot:GetID()) == itemLink) then
		button:SetAttribute('spell', spell)
		button:SetAttribute('target-bag', bag)
		button:SetAttribute('target-slot', slot:GetID())
		button:SetAllPoints(slot)
		button:Show()

		AutoCastShine_AutoCastStart(button, r, g, b)
	end
end

function button:PLAYER_LOGIN()
	local spells, disenchanter, lockpicking, smith = {}
	if(IsSpellKnown(51005)) then
		spells[ITEM_MILLABLE] = {GetSpellInfo(51005), 1/2, 1, 1/2}
	end

	if(IsSpellKnown(31252)) then
		spells[ITEM_PROSPECTABLE] = {GetSpellInfo(31252), 1, 1/3, 1/3}
	end

	disenchanting = IsSpellKnown(13262) and GetSpellInfo(13262)
	lockpicking = IsSpellKnown(1804) and GetSpellInfo(1804)
	smith = GetSpellBookItemInfo((GetSpellInfo(2018)))

	GameTooltip:HookScript('OnTooltipSetItem', function(self)
		local item, itemLink = self:GetItem()
		if(item and not InCombatLockdown() and IsAltKeyDown() and not (AuctionFrame and AuctionFrame:IsShown())) then
			local spell, r, g, b = ScanTooltip(self, spells)
			if(spell) then
				ApplyButton(itemLink, spell, r, g, b)
			else
				if(disenchanting and ns.Disenchantable(itemLink)) then
					ApplyButton(itemLink, disenchanting, 1/2, 1/2, 1)
				elseif(lockpicking and ns.Openable(itemLink)) then
					ApplyButton(itemLink, lockpicking, 0, 1, 1)
				elseif(smith and ns.Openable(itemLink)) then
					ApplyButton(itemLink, ns.SkeletonKey(), 0, 1, 1)
				end
			end
		end
	end)

	self:SetFrameStrata('TOOLTIP')
	self:SetAttribute('alt-type1', 'spell')
	self:SetScript('OnLeave', self.MODIFIER_STATE_CHANGED)

	self:RegisterEvent('MODIFIER_STATE_CHANGED')
	self:Hide()

	for _, sparks in pairs(self.sparkles) do
		sparks:SetHeight(sparks:GetHeight() * 3)
		sparks:SetWidth(sparks:GetWidth() * 3)
	end
end

function button:MODIFIER_STATE_CHANGED(key)
	if(not self:IsShown() and not key and key ~= 'LALT' and key ~= 'RALT') then return end

	if(InCombatLockdown()) then
		self:SetAlpha(0)
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
	else
		self:ClearAllPoints()
		self:SetAlpha(1)
		self:Hide()
		AutoCastShine_AutoCastStop(self)
	end
end

function button:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent('PLAYER_REGEN_ENABLED')
	self:MODIFIER_STATE_CHANGED()
end
