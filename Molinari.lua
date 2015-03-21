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

local BlackListedItems = {
	116916,	-- Gorepetal's Gentle Grasp (WoD Herbalism Gloves)
	116913	-- Peon's Mining Pick (WoD Mining Pick)
}

local function IsBlackListedItem(ItemID)
	for i, BlackID in ipairs(BlackListedItems) do
		if ItemID == BlackID then return true end
	end
	return false
end

Molinari:HookScript('OnClick', function(self, button, down)
	if(button ~= 'LeftButton') then
		local _, parent = self:GetPoint()
		if(parent) then
			local onClick = parent:GetScript('OnClick')
			if(onClick) then
				onClick(self, button, down)
			end

			local onMouseDown = parent:GetScript('OnMouseDown')
			if(down and onMouseDown) then
				onMouseDown(self, button)
			end

			local onMouseUp = parent:GetScript('OnMouseUp')
			if(not down and onMouseUp) then
				onMouseUp(self, button)
			end
		end
	end
end)

function Molinari:Apply(itemLink, spell, r, g, b, isItem)
	local parent = GetMouseFocus()
	local slot = parent:GetID()
	local bag = parent:GetParent():GetID()
	if(not bag or bag < 0) then return end

	local ItemID = (GetContainerItemID(bag,slot) or 0)
	if ItemID == 0 then return end	
	if IsBlackListedItem(ItemID) then return end

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
	local _, itemLink = self:GetItem()
	if(not itemLink) then return end
	if(not IsAltKeyDown()) then return end
	if(InCombatLockdown()) then return end
	if(UnitHasVehicleUI('player')) then return end
	if(EquipmentFlyoutFrame:IsVisible()) then return end
	if(AuctionFrame and AuctionFrame:IsVisible()) then return end

	local itemID = tonumber(string.match(itemLink, 'item:(%d+):'))

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
