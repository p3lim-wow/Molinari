local Molinari = CreateFrame('Button', (...), UIParent, 'SecureActionButtonTemplate, SecureHandlerStateTemplate, AutoCastShineTemplate')
RegisterStateDriver(Molinari, 'visible', '[nomod:alt] hide; show')
Molinari:SetAttribute('_onstate-visible', [[
	if(newstate == 'hide' and self:IsShown()) then
		self:ClearAllPoints()
		self:Hide()
	end
]])

local scripts = {'OnClick', 'OnMouseUp', 'OnMouseDown'}
function Molinari:OnClick(button, ...)
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

function Molinari:OnLeave()
	if(not InCombatLockdown()) then
		self:ClearAllPoints()
		self:Hide()
	end
end

function Molinari:Apply(itemLink, spell, r, g, b)
	local parent = GetMouseFocus()
	local slot = parent:GetID()
	local bag = parent:GetParent():GetID()

	local show = true
	if(GetTradeTargetItemLink(7) == itemLink) then
		self:SetAttribute('alt-type1', 'macro')
		self:SetAttribute('macrotext', string.format('/cast %s\n/run ClickTargetTradeButton(7)', spell))
	elseif(GetContainerItemLink(bag, slot) == itemLink) then
		if(type(spell) == 'number') then
			self:SetAttribute('alt-type1', 'item')
			self:SetAttribute('item', GetItemInfo(spell))
		else
			self:SetAttribute('alt-type1', 'spell')
			self:SetAttribute('spell', spell)
		end

		self:SetAttribute('target-bag', bag)
		self:SetAttribute('target-slot', slot)
	else
		show = false
	end

	if(show) then
		self:SetAllPoints(parent)
		self:Show()

		AutoCastShine_AutoCastStart(self, r, g, b)
	end
end

local MILLING, PROSPECTING, DISENCHANTING, LOCKPICKING
local LibProcessable = LibStub('LibProcessable')
function Molinari:OnTooltipSetItem()
	local _, itemLink = self:GetItem()
	if(itemLink and not InCombatLockdown() and IsAltKeyDown() and not (AuctionFrame and AuctionFrame:IsShown())) then
		local itemID = tonumber(string.match(itemLink, 'item:(%d+):'))
		if(LibProcessable:IsMillable(itemID) and GetItemCount(itemID) >= 5) then
			Molinari:Apply(itemLink, MILLING, 1/2, 1, 1/2)
		elseif(LibProcessable:IsProspectable(itemID) and GetItemCount(itemID) >= 5) then
			Molinari:Apply(itemLink, PROSPECTING, 1, 1/3, 1/3)
		elseif(LibProcessable:IsDisenchantable(itemID)) then
			Molinari:Apply(itemLink, DISENCHANTING, 1/2, 1/2, 1)
		else
			local openable, keyID = LibProcessable:IsOpenable(itemID)
			if(openable) then
				if(keyID) then
					Molinari:Apply(itemLink, keyID, 0, 1, 1)
				else
					Molinari:Apply(itemLink, LOCKPICKING, 0, 1, 1)
				end
			end
		end
	end
end

Molinari:RegisterEvent('PLAYER_LOGIN')
Molinari:SetScript('OnEvent', function(self)
	MILLING = GetSpellInfo(51005)
	PROSPECTING = GetSpellInfo(31252)
	DISENCHANTING = GetSpellInfo(13262)
	LOCKPICKING = GetSpellInfo(1804)

	GameTooltip:HookScript('OnTooltipSetItem', self.OnTooltipSetItem)

	self:Hide()
	self:RegisterForClicks('AnyUp')
	self:SetFrameStrata('TOOLTIP')
	self:SetScript('OnHide', AutoCastShine_AutoCastStop)
	self:SetScript('OnLeave', self.OnLeave)
	self:HookScript('OnClick', self.OnClick)

	for _, sparkle in next, self.sparkles do
		sparkle:SetHeight(sparkle:GetHeight() * 3)
		sparkle:SetWidth(sparkle:GetWidth() * 3)
	end
end)
