local Molinari = CreateFrame('Button', (...), UIParent, 'SecureActionButtonTemplate, SecureHandlerStateTemplate, AutoCastShineTemplate')
Molinari:SetScript('OnEvent', function(self, event, ...) self[event](self, ...) end)
Molinari:RegisterEvent('PLAYER_LOGIN')

RegisterStateDriver(Molinari, 'visible', '[nomod:alt] hide; show')
Molinari:SetAttribute('_onstate-visible', [[
	if(newstate == 'hide' and self:IsShown()) then
		self:ClearAllPoints()
		self:Hide()
	end
]])

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

local function OnLeave(self)
	if(not InCombatLockdown()) then
		self:ClearAllPoints()
		self:Hide()
	end
end

local function ApplyButton(itemLink, spell, r, g, b)
	local parent = GetMouseFocus()
	local slot = parent:GetID()
	local bag = parent:GetParent():GetID()

	local show = true
	if(GetTradeTargetItemLink(7) == itemLink) then
		Molinari:SetAttribute('alt-type1', 'macro')
		Molinari:SetAttribute('macrotext', string.format('/cast %s\n/run ClickTargetTradeButton(7)', spell))
	elseif(GetContainerItemLink(bag, slot) == itemLink) then
		if(type(spell) == 'number') then
			Molinari:SetAttribute('alt-type1', 'item')
			Molinari:SetAttribute('item', GetItemInfo(spell))
		else
			Molinari:SetAttribute('alt-type1', 'spell')
			Molinari:SetAttribute('spell', spell)
		end

		Molinari:SetAttribute('target-bag', bag)
		Molinari:SetAttribute('target-slot', slot)
	else
		show = false
	end

	if(show) then
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

	self:Hide()
	self:RegisterForClicks('AnyUp')
	self:SetFrameStrata('TOOLTIP')
	self:SetScript('OnHide', AutoCastShine_AutoCastStop)
	self:SetScript('OnLeave', OnLeave)
	self:HookScript('OnClick', ParentClick)

	for _, sparks in next, self.sparkles do
		sparks:SetHeight(sparks:GetHeight() * 3)
		sparks:SetWidth(sparks:GetWidth() * 3)
	end
end
