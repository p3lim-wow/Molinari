local addonName, ns = ...
local Molinari = CreateFrame('Button', addonName, UIParent, 'SecureActionButtonTemplate, SecureHandlerStateTemplate, SecureHandlerEnterLeaveTemplate, AutoCastShineTemplate')
Molinari:RegisterForClicks('AnyUp')
Molinari:SetFrameStrata('TOOLTIP')
Molinari:SetScript('OnHide', AutoCastShine_AutoCastStop)
Molinari:HookScript('OnLeave', AutoCastShine_AutoCastStop)
Molinari:Hide()

local modifiers = {
	ALT = {'[mod:alt]', 'alt'},
	CTRL = {'[mod:alt, mod:ctrl]', 'alt-ctrl'},
	SHIFT = {'[mod:alt, mod:shift]', 'alt-shift'},
}

Molinari:SetAttribute('_onleave', 'self:ClearAllPoints() self:Hide()')
Molinari:SetAttribute('_onstate-visible', [[
	if(newstate == 'hide' and self:IsShown()) then
		self:ClearAllPoints()
		self:Hide()
	end
]])

Molinari:HookScript('OnClick', function(self, button, down)
	if(button ~= 'LeftButton') then
		local _, parent = self:GetPoint()
		if(parent) then
			local onClick = parent:GetScript('OnClick')
			if(onClick) then
				onClick(parent, button, down)
			end

			local onMouseDown = parent:GetScript('OnMouseDown')
			if(down and onMouseDown) then
				onMouseDown(parent, button)
			end

			local onMouseUp = parent:GetScript('OnMouseUp')
			if(not down and onMouseUp) then
				onMouseUp(parent, button)
			end
		end
	end
end)

local function OnEnter(self)
	if(self:GetRight() >= (GetScreenWidth() / 2)) then
		GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
	else
		GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	end

	if(self.itemLink) then
		GameTooltip:SetHyperlink(self.itemLink)
	else
		GameTooltip:SetBagItem(self:GetAttribute('target-bag'), self:GetAttribute('target-slot'))
	end
end

function Molinari:Apply(itemLink, spell, r, g, b, isItem)
	local parent = GetMouseFocus()
	local slot = parent:GetID()
	local bag = parent:GetParent():GetID()
	if(not bag or bag < 0) then return end

	local modifier = modifiers[ns.db.profile.general.modifierKey][2]
	if(GetTradeTargetItemLink(7) == itemLink) then
		if(isItem) then
			return
		else
			self:SetAttribute(modifier .. '-type1', 'macro')
			self:SetAttribute('macrotext', string.format('/cast %s\n/run ClickTargetTradeButton(7)', (GetSpellInfo(spell))))
		end

		self.itemLink = itemLink
	elseif(GetContainerItemLink(bag, slot) == itemLink) then
		if(isItem) then
			self:SetAttribute(modifier .. '-type1', 'item')
			self:SetAttribute('item', 'item:' .. spell)
		else
			self:SetAttribute(modifier .. '-type1', 'spell')
			self:SetAttribute('spell', spell)
		end

		self.itemLink = nil
		self:SetAttribute('target-bag', bag)
		self:SetAttribute('target-slot', slot)
	else
		return
	end

	self:SetAttribute('_entered', true)
	self:ClearAllPoints()
	self:SetAllPoints(parent)
	self:Show()

	AutoCastShine_AutoCastStart(self, r, g, b)
end

function Molinari:UpdateModifier()
	if(InCombatLockdown()) then
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
	else
		RegisterStateDriver(self, 'visible', modifiers[ns.db.profile.general.modifierKey][1] .. ' show; hide')
	end
end

function Molinari:AreStarsAligned(itemLink)
	if(not itemLink) then
		return false
	elseif(InCombatLockdown()) then
		return false
	elseif(UnitHasVehicleUI and UnitHasVehicleUI('player')) then
		return false
	elseif(EquipmentFlyoutFrame and EquipmentFlyoutFrame:IsVisible()) then
		return false
	elseif(AuctionFrame and AuctionFrame:IsVisible()) then
		return false
	elseif(not IsAltKeyDown()) then
		return false
	elseif(ns.db.profile.general.modifierKey == 'CTRL' and not IsControlKeyDown()) then
		return false
	elseif(ns.db.profile.general.modifierKey == 'SHIFT' and not IsShiftKeyDown()) then
		return false
	end

	return true
end

local LibProcessable = LibStub('LibProcessable')
GameTooltip:HookScript('OnTooltipSetItem', function(self)
	if(self:GetOwner() == Molinari) then
		return
	end

	local _, itemLink = self:GetItem()
	if(not Molinari:AreStarsAligned(itemLink)) then
		return
	end

	local itemID = GetItemInfoFromHyperlink(itemLink)
	if(not itemID or ns.db.profile.blocklist.items[itemID]) then
		return
	end

	local isMillable, isMortar = LibProcessable:IsMillable(itemID)
	if(isMillable and GetItemCount(itemID) >= 5) then
		Molinari:Apply(itemLink, isMortar and 114942 or 51005, 1/2, 1, 1/2, isMortar)
	elseif(LibProcessable:IsProspectable(itemID) and GetItemCount(itemID) >= 5) then
		Molinari:Apply(itemLink, 31252, 1, 1/3, 1/3)
	elseif(LibProcessable:IsDisenchantable(itemLink)) then
		Molinari:Apply(itemLink, 13262, 1/2, 1/2, 1)
	else
		local isOpenable, spellID = LibProcessable:IsOpenable(itemID)
		if(isOpenable) then
			Molinari:Apply(itemLink, spellID, 0, 1, 1)
			return
		end

		local isOpenable, keyItemID = LibProcessable:IsOpenableProfession(itemID)
		if(isOpenable) then
			Molinari:Apply(itemLink, keyItemID, 0, 1, 1, true)
		end
	end
end)

for _, sparkle in next, Molinari.sparkles do
	sparkle:SetHeight(sparkle:GetHeight() * 3)
	sparkle:SetWidth(sparkle:GetWidth() * 3)
end

Molinari:HookScript('OnEnter', OnEnter)
Molinari:HookScript('OnLeave', GameTooltip_Hide)
Molinari:RegisterEvent('PLAYER_LOGIN')
Molinari:RegisterEvent('BAG_UPDATE_DELAYED')
Molinari:RegisterEvent('MODIFIER_STATE_CHANGED')
Molinari:SetScript('OnEvent', function(self, event)
	if(event == 'PLAYER_LOGIN') then
		self:UpdateModifier()
	elseif(event == 'PLAYER_REGEN_ENABLED') then
		self:UpdateModifier()
		self:UnregisterEvent(event)
	else
		if(self:IsShown()) then
			if(event == 'BAG_UPDATE_DELAYED' and not InCombatLockdown()) then
				self:Hide()
			elseif(event == 'MODIFIER_STATE_CHANGED') then
				OnEnter(self)
			end
		end
	end
end)
