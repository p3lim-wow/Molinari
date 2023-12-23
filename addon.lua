local addonName, addon = ...
addon.data = {}

local Molinari = addon:CreateButton('Button', addonName, UIParent, 'SecureActionButtonTemplate,SecureHandlerAttributeTemplate,SecureHandlerEnterLeaveTemplate,AutoCastShineTemplate')
Molinari:SetFrameStrata('TOOLTIP')
Molinari:Hide()

addon:HookTooltip(function(tooltip, item)
	if tooltip:GetOwner() == Molinari then
		-- don't trigger on our own tooltips
		return
	end

	if not item then
		return
	elseif InCombatLockdown() then
		return
	elseif UnitHasVehicleUI and UnitHasVehicleUI('player') then
		return
	elseif (PaperDollFrameItemFlyoutButtons or EquipmentFlyoutFrame) and (PaperDollFrameItemFlyoutButtons or EquipmentFlyoutFrame):IsVisible() then
		return
	elseif (AuctionFrame or AuctionHouseFrame) and (AuctionFrame or AuctionHouseFrame):IsVisible() then
		return
	elseif not IsAltKeyDown() then
		return
	elseif addon.db.profile.general.modifierKey == 'CTRL' and not IsControlKeyDown() then
		return
	elseif addon.db.profile.general.modifierKey ~= 'CTRL' and IsControlKeyDown() then
		return
	elseif addon.db.profile.general.modifierKey == 'SHIFT' and not IsShiftKeyDown() then
		return
	elseif addon.db.profile.general.modifierKey ~= 'SHIFT' and IsShiftKeyDown() then
		return
	end

	local itemID = item:GetItemID()
	if not itemID or addon.db.profile.blocklist.items[itemID] then
		return
	end

	local spellID, color = addon:IsSalvagable(itemID)
	if spellID then
		return Molinari:ApplySpell(item, spellID, color)
	end

	local pickItemID
	pickItemID, color = addon:IsOpenableProfession(itemID)
	if pickItemID then
		return Molinari:ApplyItem(item, pickItemID, color)
	end
end)

local MACRO_SALVAGE = '/run C_TradeSkillUI.CraftSalvage(%d, 1, ItemLocation:CreateFromBagAndSlot(%d, %d))'
local MACRO_TRADE = '/cast %s\n/run ClickTargetTradeButton(7)'

function Molinari:ApplySpell(item, spellID, color)
	local location = item:GetItemLocation()
	if location and location:IsBagAndSlot() then
		local bagID, slotID = location:GetBagAndSlot()
		self:SetAttribute('target-bag', bagID)
		self:SetAttribute('target-slot', slotID)

		if not addon:IsRetail() or FindSpellBookSlotBySpellID(spellID) then
			self:SetAttribute('spell', spellID)
		else
			self:SetAttribute('macrotext', MACRO_SALVAGE:format(spellID, bagID, slotID))
		end
	elseif item:GetItemLink() == GetTradeTargetItemLink(7) and color == addon.colors.openable then
		self:SetAttribute('macrotext', MACRO_TRADE:format(GetSpellInfo(spellID)))
		self.itemLink = item:GetItemLink() -- store item link for the tooltip
	else
		return
	end

	self:Show()
	self:AddSparkles(color)
end

function Molinari:ApplyItem(item, color)
	local location = item:GetItemLocation()
	if location and location:IsBagAndSlot() then
		local bagID, slotID = location:GetBagAndSlot()
		self:SetAttribute('target-bag', bagID)
		self:SetAttribute('target-slot', slotID)
		self:SetAttribute('item', 'item:' .. item:GetItemID())
		self:Show()
		self:AddSparkles(color)
	end
end

function Molinari:AddSparkles(color)
	AutoCastShine_AutoCastStart(self, color:GetRGB())
end

-- update attribute driver with the correct modifiers
function Molinari:UpdateAttributeDriver()
	if addon.db.profile.general.modifierKey == 'CTRL' then
		addon:Defer(RegisterAttributeDriver, self, 'visibility', '[mod:alt,mod:ctrl] show; hide')
	elseif addon.db.profile.general.modifierKey == 'SHIFT' then
		addon:Defer(RegisterAttributeDriver, self, 'visibility', '[mod:alt,mod:shift] show; hide')
	else
		addon:Defer(RegisterAttributeDriver, self, 'visibility', '[mod:alt] show; hide')
	end
end

-- update secure attribute type when setting the action
Molinari:HookScript('OnAttributeChanged', function(self, name)
	if name == 'spell' or name == 'item' or name == 'macrotext' then
		if addon.db.profile.general.modifierKey == 'CTRL' then
			self:SetAttribute('alt-ctrl-type1', name:gsub('macrotext', 'macro'))
		elseif addon.db.profile.general.modifierKey == 'SHIFT' then
			self:SetAttribute('alt-shift-type1', name:gsub('macrotext', 'macro'))
		else
			self:SetAttribute('alt-type1', name:gsub('macrotext', 'macro'))
		end
	end
end)

-- re-anchor when shown
Molinari:HookScript('OnShow', function(self)
	-- some addons put slots into a scrollframe for whatever reason, which we can't anchor to,
	-- lets calculate anchors ourselves instead, adjusting for scale
	local left, bottom, width, height = GameTooltip:GetOwner():GetScaledRect()
	local scaleMultiplier = 1/UIParent:GetScale()
	self:ClearAllPoints()
	self:SetPoint('BOTTOMLEFT', left * scaleMultiplier, bottom * scaleMultiplier)
	self:SetSize(width * scaleMultiplier, height * scaleMultiplier)
end)

-- set attribute to trigger EnterLeave driver
Molinari:HookScript('OnShow', function(self)
	self:SetAttribute('_entered', true)
end)

-- use EnterLeave to securely deactivate when the mouse leaves the item
Molinari:SetAttribute('_onleave', 'self:ClearAllPoints();self:Hide()')

-- use attribute driver to securely deactivate when the modifier key is released
Molinari:SetAttribute('_onattributechanged', [[
	if name == 'visibility' and value == 'hide' and self:IsShown() then
		self:ClearAllPoints()
		self:Hide()
	end
]])

-- reset attributes when hidden
Molinari:HookScript('OnHide', function(self)
	self.itemLink = nil
	addon:Defer(self, 'SetAttribute', self, 'target-bag')
	addon:Defer(self, 'SetAttribute', self, 'target-slot')
	addon:Defer(self, 'SetAttribute', self, '_entered', false)
end)

-- adjust the glow sparkles
for _, sparkle in next, Molinari.sparkles do
	sparkle:SetHeight(sparkle:GetHeight() * 3)
	sparkle:SetWidth(sparkle:GetWidth() * 3)
end

-- remove glow when hidden
-- Molinari:HookScript('OnLeave', AutoCastShine_AutoCastStop)
Molinari:HookScript('OnHide', AutoCastShine_AutoCastStop)

-- tooltips
Molinari:HookScript('OnLeave', GameTooltip_Hide)
Molinari:HookScript('OnEnter', function(self)
	if self:GetRight() >= GetScreenWidth() / 2 then
		GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
	else
		GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	end

	if self.itemLink then
		GameTooltip:SetHyperlink(self.itemLink)
	else
		GameTooltip:SetBagItem(self:GetAttribute('target-bag'), self:GetAttribute('target-slot'))
	end

	GameTooltip:Show()
end)

-- hide whenever a bag update occurs
function addon:BAG_UPDATE_DELAYED()
	if Molinari:IsShown() and not InCombatLockdown() then
		Molinari:Hide()
	end
end

-- force-update tooltip whenever a modifier changes, as the state driver doesn't handle OnEnter
function addon:MODIFIER_STATE_CHANGED()
	if Molinari:IsShown() then
		Molinari:GetScript('OnEnter')(Molinari)

		if addon.db.profile.general.modifierKey == 'CTRL' and not IsControlKeyDown() then
			addon:Defer(Molinari, 'Hide', Molinari)
		elseif addon.db.profile.general.modifierKey ~= 'CTRL' and IsControlKeyDown() then
			addon:Defer(Molinari, 'Hide', Molinari)
		elseif addon.db.profile.general.modifierKey == 'SHIFT' and not IsShiftKeyDown() then
			addon:Defer(Molinari, 'Hide', Molinari)
		elseif addon.db.profile.general.modifierKey ~= 'SHIFT' and IsShiftKeyDown() then
			addon:Defer(Molinari, 'Hide', Molinari)
		end
	end
end

-- register state driver
function addon:PLAYER_LOGIN()
	Molinari:UpdateAttributeDriver()
end
