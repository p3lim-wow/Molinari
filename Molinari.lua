local Molinari = CreateFrame('Button', (...), UIParent, 'SecureActionButtonTemplate, SecureHandlerStateTemplate, SecureHandlerEnterLeaveTemplate, AutoCastShineTemplate')
Molinari:RegisterForClicks('AnyUp')
Molinari:SetFrameStrata('TOOLTIP')
Molinari:SetScript('OnHide', AutoCastShine_AutoCastStop)
Molinari:HookScript('OnLeave', AutoCastShine_AutoCastStop)
Molinari:Hide()

RegisterStateDriver(Molinari, 'visible', '[nomod:alt] hide; show')
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

Molinari:HookScript('OnLeave', GameTooltip_Hide)
Molinari:HookScript('OnEnter', function(self)
	local point, anchor, relative, x, y = GameTooltip:GetPoint()
	GameTooltip:SetOwner(self, 'ANCHOR_NONE')

	if(anchor == select(2, self:GetPoint())) then
		GameTooltip:SetPoint(point, self, relative, x, y)
	else
		GameTooltip:SetPoint('BOTTOMRIGHT', self, 'TOPLEFT')
	end

	GameTooltip:SetBagItem(self:GetAttribute('target-bag'), self:GetAttribute('target-slot'))
	GameTooltip:Show()
end)

function Molinari:Apply(itemLink, spell, r, g, b, isItem)
	local parent = GetMouseFocus()
	local slot = parent:GetID()
	local bag = parent:GetParent():GetID()
	if(not bag or bag < 0) then return end

	if(GetTradeTargetItemLink(7) == itemLink) then
		if(isItem) then
			return
		else
			self:SetAttribute('alt-type1', 'macro')
			self:SetAttribute('macrotext', string.format('/cast %s\n/run ClickTargetTradeButton(7)', spell))
		end
	elseif(GetContainerItemLink(bag, slot) == itemLink) then
		if(isItem) then
			self:SetAttribute('alt-type1', 'item')
			self:SetAttribute('item', 'item:' .. spell)
		else
			self:SetAttribute('alt-type1', 'spell')
			self:SetAttribute('spell', spell)
		end

		self:SetAttribute('target-bag', bag)
		self:SetAttribute('target-slot', slot)
	else
		return
	end

	self:SetAttribute('_entered', true)
	self:SetAllPoints(parent)
	self:Show()

	AutoCastShine_AutoCastStart(self, r, g, b)
end

local LibProcessable = LibStub('LibProcessable')
GameTooltip:HookScript('OnTooltipSetItem', function(self)
	if(self:GetOwner() == Molinari) then return end
	local _, itemLink = self:GetItem()
	if(not itemLink) then return end
	if(not IsAltKeyDown()) then return end
	if(InCombatLockdown()) then return end
	if(UnitHasVehicleUI('player')) then return end
	if(EquipmentFlyoutFrame:IsVisible()) then return end
	if(AuctionFrame and AuctionFrame:IsVisible()) then return end

	local itemID = tonumber(string.match(itemLink, 'item:(%d+):'))
	if(MolinariBlacklistDB.items[itemID]) then
		return
	end

	local isMillable, _, _, mortarItem = LibProcessable:IsMillable(itemID)
	if(isMillable and GetItemCount(itemID) >= 5) then
		Molinari:Apply(itemLink, mortarItem or 51005, 1/2, 1, 1/2, not not mortarItem)
	elseif(LibProcessable:IsProspectable(itemID) and GetItemCount(itemID) >= 5) then
		Molinari:Apply(itemLink, 31252, 1, 1/3, 1/3)
	elseif(LibProcessable:IsDisenchantable(itemID, true)) then
		Molinari:Apply(itemLink, 13262, 1/2, 1/2, 1)
	else
		local isOpenable, _, _, keyItem = LibProcessable:IsOpenable(itemID)
		if(isOpenable) then
			if(keyItem and GetItemCount(keyItem) > 0) then
				Molinari:Apply(itemLink, keyItem, 0, 1, 1, true)
			elseif(not keyItem) then
				Molinari:Apply(itemLink, 1804, 0, 1, 1)
			end
		end
	end
end)

for _, sparkle in next, Molinari.sparkles do
	sparkle:SetHeight(sparkle:GetHeight() * 3)
	sparkle:SetWidth(sparkle:GetWidth() * 3)
end

Molinari:RegisterEvent('BAG_UPDATE_DELAYED')
Molinari:SetScript('OnEvent', function(self, ...)
	if(self:IsShown() and not InCombatLockdown()) then
		self:Hide()
	end
end)
