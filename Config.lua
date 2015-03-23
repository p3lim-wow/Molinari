local addonName, L = ...

local defaults = {
	itemBlacklist = {
		[116913] = true, -- Peon's Mining Pick
		[116916] = true, -- Gorepetal's Gentle Grasp
	}
}

local Panel = CreateFrame('Frame', nil, InterfaceOptionsFramePanelContainer)
Panel.name = addonName
Panel:Hide()

Panel:RegisterEvent('PLAYER_LOGIN')
Panel:SetScript('OnEvent', function()
	MolinariDB = MolinariDB or defaults

	for key, value in next, defaults do
		if(MolinariDB[key] == nil) then
			MolinariDB[key] = value
		end
	end
end)

local containerBackdrop = {
	bgFile = [[Interface\ChatFrame\ChatFrameBackground]], tile = true, tileSize = 16,
	edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]], edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4}
}

function Panel:default()
	table.wipe(MolinariDB.itemBlacklist)

	for item in next, defaults.itemBlacklist do
		MolinariDB.itemBlacklist[item] = true
	end

	self:UpdateList()
end

local items = {}

StaticPopupDialogs.MOLINARI_ITEM_REMOVE = {
	text = L['Are you sure you want to delete\n|T%s:16|t%s\nfrom the filter?'],
	button1 = 'Yes',
	button2 = 'No',
	OnAccept = function(self, data)
		MolinariDB.itemBlacklist[data.itemID] = nil
		items[data.itemID] = nil
		data.button:Hide()

		Panel:UpdateList()
	end,
	timeout = 0,
	hideOnEscape = true,
	preferredIndex = 3, -- Avoid some taint
}

Panel:SetScript('OnShow', function(self)
	local Title = self:CreateFontString(nil, nil, 'GameFontHighlight')
	Title:SetPoint('TOPLEFT', 20, -20)
	Title:SetText(L['Items filtered from automation'])

	local Description = CreateFrame('Button', nil, self)
	Description:SetPoint('LEFT', Title, 'RIGHT')
	Description:SetNormalTexture([[Interface\GossipFrame\ActiveQuestIcon]])
	Description:SetSize(16, 16)

	Description:SetScript('OnLeave', GameTooltip_Hide)
	Description:SetScript('OnEnter', function(self)
		GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT')
		GameTooltip:AddLine(L.ItemBlacklistTooltip, 1, 1, 1)
		GameTooltip:Show()
	end)

	local Items = CreateFrame('Frame', nil, self)
	Items:SetPoint('TOPLEFT', Title, 'BOTTOMLEFT', -12, -8)
	Items:SetPoint('BOTTOMRIGHT', -8, 8)
	Items:SetBackdrop(containerBackdrop)
	Items:SetBackdropColor(0, 0, 0, 1/2)

	local Boundaries = CreateFrame('Frame', nil, Items)
	Boundaries:SetPoint('TOPLEFT', 8, -8)
	Boundaries:SetPoint('BOTTOMRIGHT', -8, 8)

	local function ItemOnClick(self, button)
		if(button == 'RightButton') then
			local _, link, _, _, _, _, _, _, _, texture = GetItemInfo(self.itemID)
			local dialog = StaticPopup_Show('MOLINARI_ITEM_REMOVE', texture, link)
			dialog.data = {
				itemID = self.itemID,
				questID = self.questID,
				button = self
			}
		end
	end

	local function ItemOnEnter(self)
		GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT')
		GameTooltip:SetItemByID(self.itemID)
		GameTooltip:AddLine(' ')
		GameTooltip:AddLine(L['Right-click to remove from list'], 0, 1, 0)
		GameTooltip:Show()
	end

	self.UpdateList = function()
		local index = 1
		local width = Boundaries:GetWidth()
		local cols = math.floor((width > 0 and width or 591) / 36)

		for item in next, MolinariDB.itemBlacklist do
			local Button = items[item]
			if(not Button) then
				Button = CreateFrame('Button', nil, Items)
				Button:SetSize(34, 34)
				Button:RegisterForClicks('AnyUp')

				local Texture = Button:CreateTexture()
				Texture:SetAllPoints()
				Button.Texture = Texture

				Button:SetScript('OnClick', ItemOnClick)
				Button:SetScript('OnEnter', ItemOnEnter)
				Button:SetScript('OnLeave', GameTooltip_Hide)

				items[item] = Button
			end

			local _, _, _, _, _, _, _, _, _, textureFile = GetItemInfo(item)

			if(textureFile) then
				Button.Texture:SetTexture(textureFile)
			elseif(not queryItems) then
				self:RegisterEvent('GET_ITEM_INFO_RECEIVED')
				queryItems = true
			end

			Button:ClearAllPoints()
			Button:SetPoint('TOPLEFT', Boundaries, (index - 1) % cols * 36, math.floor((index - 1) / cols) * -36)

			Button.itemID = item

			index = index + 1
		end

		if(not queryItems) then
			self:UnregisterEvent('GET_ITEM_INFO_RECEIVED')
		end
	end

	self:UpdateList()

	Items:SetScript('OnMouseUp', function()
		if(CursorHasItem()) then
			local _, itemID = GetCursorInfo()
			if(not MolinariDB.itemBlacklist[itemID]) then
				MolinariDB.itemBlacklist[itemID] = true
				ClearCursor()

				self:UpdateList()
				return
			end
		end
	end)

	self:SetScript('OnShow', nil)
end)

Panel:HookScript('OnEvent', function(self, event)
	if(event == 'GET_ITEM_INFO_RECEIVED') then
		self:UpdateList()
	end
end)

InterfaceOptions_AddCategory(Panel)

_G['SLASH_' .. addonName .. 1] = '/molinari'
SlashCmdList[addonName] = function()
	-- On first load IOF doesn't select the right category or panel, this is a dirty fix
	InterfaceOptionsFrame_OpenToCategory(addonName)
	InterfaceOptionsFrame_OpenToCategory(addonName)
end
