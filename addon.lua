local addonName, addon = ...
addon.data = {}

local modifier

local ERR_COLOR = CreateColor(1, 32/255, 32/255)
local TEMPLATES = {
	'SecureActionButtonTemplate',
	'SecureHandlerAttributeTemplate',
	'SecureHandlerEnterLeaveTemplate',
}

local IsPlayerSpell = C_SpellBook.IsSpellKnown or IsPlayerSpell -- 12.x deprecation

if not addon:IsRetail() then
	-- AutoCastShine was removed in 11.0, but we'll keep on using it in classic
	table.insert(TEMPLATES, 'AutoCastShineTemplate')
end

local Molinari = addon:CreateButton('Button', addonName, UIParent, table.concat(TEMPLATES, ','))
Molinari:SetFrameStrata('TOOLTIP')
Molinari:Hide()

local function tooltipHelp(msg, color)
	GameTooltip:AddLine(' ')
	GameTooltip:AddLine(msg, color and color:GetRGB())
	GameTooltip:Show() -- re-render
end

local function tooltipHook(tooltip, item)
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
	elseif modifier == 'CTRL' and not IsControlKeyDown() then
		return
	elseif modifier ~= 'CTRL' and IsControlKeyDown() then
		return
	elseif modifier == 'SHIFT' and not IsShiftKeyDown() then
		return
	elseif modifier ~= 'SHIFT' and IsShiftKeyDown() then
		return
	end

	local itemID = item:GetItemID()
	if not itemID then
		return
	end

	if addon:NonDisenchantable(itemID) or (C_Item.IsCosmeticItem and C_Item.IsCosmeticItem(itemID)) then
		tooltipHelp(ITEM_DISENCHANT_NOT_DISENCHANTABLE, ERR_COLOR)
		return
	end

	local spellID, color, numItemsRequired = addon:IsSalvagable(itemID)
	if spellID then
		if not IsPlayerSpell(spellID) then
			tooltipHelp(ERR_USE_LOCKED_WITH_SPELL_S:format(C_Spell.GetSpellName(spellID)), ERR_COLOR)
			return
		elseif numItemsRequired and C_Item.GetStackCount(item:GetItemLocation()) < numItemsRequired then
			tooltipHelp(SPELL_FAILED_NEED_MORE_ITEMS:format(numItemsRequired, C_Item.GetItemNameByID(itemID)), ERR_COLOR)
			return
		else
			return Molinari:ApplySpell(item, spellID, color)
		end
	end

	local key
	key, color = addon:IsOpenableProfession(itemID)
	if key then
		return Molinari:ApplyItem(item, key, color)
	end
end

local function tooltipShow(self)
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

	if addon:IsRetail() then
		if self.spellID then
			tooltipHelp((('\n'):split(NPEV2_CASTER_ABILITYINITIAL:gsub(' %%s ', '%s'))):format('|A:NPE_LeftClick:18:18|a', '|cff0090ff' .. C_Spell.GetSpellName(self.spellID) .. '|r'))
		elseif self.itemID then
			tooltipHelp(NPEV2_ABILITYINITIAL:format('|A:NPE_LeftClick:18:18|a', '|cff0090ff' .. C_Item.GetItemNameByID(self.itemID) .. '|r'))
		end
	end

	GameTooltip:Show()
end

function addon:OnLogin()
	-- load late so our hooks are added late, that way our tooltip lines are more
	-- likely to render at the bottom of the tooltip (but no guarantee)
	addon:HookTooltip(tooltipHook)
end

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
		self:SetAttribute('macrotext', MACRO_TRADE:format(C_Spell.GetSpellName(spellID)))
		self.itemLink = item:GetItemLink() -- store item link for the tooltip
	else
		return
	end

	self.spellID = spellID -- for tooltips
	self:Show()
	self:SetColor(color)
end

function Molinari:ApplyItem(item, key, color)
	local location = item:GetItemLocation()
	if location and location:IsBagAndSlot() then
		local bagID, slotID = location:GetBagAndSlot()
		self:SetAttribute('target-bag', bagID)
		self:SetAttribute('target-slot', slotID)
		self:SetAttribute('item', 'item:' .. key)

		self.itemID = key -- for tooltips
		self:Show()
		self:SetColor(color)
	end
end

-- update attribute driver with the correct modifiers
function Molinari:UpdateAttributeDriver()
	if modifier == 'CTRL' then
		addon:Defer('RegisterAttributeDriver', self, 'visibility', '[mod:alt,mod:ctrl] show; hide')
	elseif modifier == 'SHIFT' then
		addon:Defer('RegisterAttributeDriver', self, 'visibility', '[mod:alt,mod:shift] show; hide')
	else
		addon:Defer('RegisterAttributeDriver', self, 'visibility', '[mod:alt] show; hide')
	end
end

-- update secure attribute type when setting the action
Molinari:HookScript('OnAttributeChanged', function(self, name)
	if name == 'spell' or name == 'item' or name == 'macrotext' then
		if modifier == 'CTRL' then
			self:SetAttribute('alt-ctrl-type1', name:gsub('macrotext', 'macro'))
		elseif modifier == 'SHIFT' then
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
	self.spellID = nil
	self.itemID = nil
	addon:DeferMethod(self, 'SetAttribute', 'target-bag')
	addon:DeferMethod(self, 'SetAttribute', 'target-slot')
	addon:DeferMethod(self, 'SetAttribute', '_entered', false)
end)

-- tooltips
Molinari:HookScript('OnLeave', GameTooltip_Hide)
Molinari:HookScript('OnEnter', tooltipShow)

-- hide whenever a bag update occurs
function addon:BAG_UPDATE_DELAYED()
	if Molinari:IsShown() and not InCombatLockdown() then
		Molinari:Hide()
	end
end

-- force-update tooltip whenever a modifier changes, as the state driver doesn't handle OnEnter
function addon:MODIFIER_STATE_CHANGED()
	if Molinari:IsShown() then
		tooltipShow(Molinari)

		if modifier == 'CTRL' and not IsControlKeyDown() then
			addon:DeferMethod(Molinari, 'Hide')
		elseif modifier ~= 'CTRL' and IsControlKeyDown() then
			addon:DeferMethod(Molinari, 'Hide')
		elseif modifier == 'SHIFT' and not IsShiftKeyDown() then
			addon:DeferMethod(Molinari, 'Hide')
		elseif modifier ~= 'SHIFT' and IsShiftKeyDown() then
			addon:DeferMethod(Molinari, 'Hide')
		end
	elseif GameTooltip:IsShown() then
		if GameTooltip:IsForbidden() or GameTooltip:IsProtected() then
			return
		end

		local owner = GameTooltip:GetOwner()
		if owner and not owner:IsAnchoringRestricted() and owner:IsMouseOver() then
			if owner.GetSlotAndBagID then
				local slotIndex, bagID = owner:GetSlotAndBagID()
				if slotIndex and bagID then
					local item = Item:CreateFromBagAndSlot(bagID, slotIndex)
					if item then
						tooltipHook(GameTooltip, item)
						return
					end
				end
			end

			local _, itemLink = GameTooltip:GetItem()
			if itemLink then
				tooltipHook(GameTooltip, Item:CreateFromItemLink(itemLink))
			end
		end
	end
end

-- update state driver when setting changes
addon:RegisterOptionCallback('modifier', function(value)
	modifier = value
	addon:DeferMethod(Molinari, 'UpdateAttributeDriver')
end)

if addon:IsRetail() then
	-- glow animation
	local Glow = Molinari:CreateTexture(nil, 'ARTWORK')
	Glow:SetPoint('CENTER')
	Glow:SetAtlas('UI-HUD-ActionBar-Proc-Loop-Flipbook')
	Glow:SetDesaturated(true) -- it's normally yellow, can't color that

	local Animation = Molinari:CreateAnimationGroup()
	Animation:SetLooping('REPEAT')

	local FlipBook = Animation:CreateAnimation('FlipBook')
	FlipBook:SetTarget(Glow)
	FlipBook:SetDuration(1)
	FlipBook:SetFlipBookColumns(5)
	FlipBook:SetFlipBookRows(6)
	FlipBook:SetFlipBookFrames(30)

	function Molinari:SetColor(color)
		Glow:SetVertexColor(color:GetRGB())

		-- need to adjust the size too
		local width, height = self:GetSize()
		Glow:SetSize(width * 1.4, height * 1.4)
	end

	Molinari:HookScript('OnShow', function()
		Animation:Play()
	end)

	Molinari:HookScript('OnHide', function()
		Animation:Stop()
	end)
else
	-- use AutoCastShine
	function Molinari:SetColor(color)
		AutoCastShine_AutoCastStart(self, color:GetRGB())
	end

	-- adjust the glow sparkles
	for _, sparkle in next, Molinari.sparkles do
		sparkle:SetHeight(sparkle:GetHeight() * 3)
		sparkle:SetWidth(sparkle:GetWidth() * 3)
	end

	Molinari:HookScript('OnHide', AutoCastShine_AutoCastStop)
end
