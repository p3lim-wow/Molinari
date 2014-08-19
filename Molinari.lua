local Molinari = CreateFrame('Button', (...), UIParent, 'SecureActionButtonTemplate, AutoCastShineTemplate')
Molinari:SetScript('OnEvent', function(self, event, ...) self[event](self, ...) end)
Molinari:RegisterEvent('PLAYER_LOGIN')

local LibProcessable = LibStub('LibProcessable')

local scripts = {'OnClick', 'OnMouseUp', 'OnMouseDown'}
local function ParentClick(self, button, ...)
	if(button ~= 'LeftButton') then
		local _, parent = self:GetPoint()
		if(parent) then
			for _, script in next, scripts do
				local handler = parent:GetScript(script)
				if(handler) then
					handler(parent, button, ...)
				end
			end
		end
	end
end

local function ApplyButton(itemLink, spell, r, g, b)
	local parent = GetMouseFocus()
	local slot = parent:GetID()
	local bag = parent:GetParent():GetID()

	if(GetContainerItemLink(bag, slot) == itemLink) then
		if(type(spell) == 'number') then
			Molinari:SetAttribute('alt-type1', 'item')
			Molinari:SetAttribute('item', GetItemInfo(spell))
		else
			Molinari:SetAttribute('alt-type1', 'spell')
			Molinari:SetAttribute('spell', spell)
		end

		Molinari:SetAttribute('target-bag', bag)
		Molinari:SetAttribute('target-slot', slot)
		Molinari:SetAllPoints(parent)
		Molinari:Show()

		AutoCastShine_AutoCastStart(Molinari, r, g, b)
	end
end

function Molinari:PLAYER_LOGIN()
	local MILLING = GetSpellInfo()
	local PROSPECTING = GetSpellInfo(31252)
	local DISENCHANTING = GetSpellInfo(13262)
	local LOCKPICKING = GetSpellInfo(1804)

	GameTooltip:HookScript('OnTooltipSetItem', function(self)
		local _, itemLink = self:GetItem()
		if(itemLink and not InCombatLockdown() and IsAltKeyDown() and not (AuctionFrame and AuctionFrame:IsShown())) then
			local itemID = tonumber(string.match(itemLink, 'item:(%d+):'))
			if(LibProcessable:IsMillable(itemID) and GetItemCount(itemID) >= 5) then
				ApplyButton(itemLink, MILLING, 1/2, 1, 1/2)
			elseif(LibProcessable:IsProspectable(itemID) and GetItemCount(itemID) >= 5) then
				ApplyButton(itemLink, PROSPECTING, 1, 1/3, 1/3)
			elseif(LibProcessable:IsDisenchantable(itemID)) then
				ApplyButton(itemLink, DISENCHANTING, 1/2, 1/2, 1)
			else
				local openable, keyID = LibProcessable:IsOpenable(itemID)
				if(openable) then
					if(keyID) then
						ApplyButton(itemLink, keyID, 0, 1, 1)
					else
						ApplyButton(itemLink, LOCKPICKING, 0, 1, 1)
					end
				end
			end
		end
	end)

	self:RegisterForClicks('AnyUp')
	self:SetFrameStrata('TOOLTIP')
	self:SetScript('OnLeave', self.MODIFIER_STATE_CHANGED)
	self:HookScript('OnClick', ParentClick)

	self:RegisterEvent('MODIFIER_STATE_CHANGED')
	self:Hide()

	for _, sparks in next, self.sparkles do
		sparks:SetHeight(sparks:GetHeight() * 3)
		sparks:SetWidth(sparks:GetWidth() * 3)
	end
end

function Molinari:MODIFIER_STATE_CHANGED(key)
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

function Molinari:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent('PLAYER_REGEN_ENABLED')
	self:MODIFIER_STATE_CHANGED()
end
