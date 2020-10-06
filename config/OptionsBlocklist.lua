local addonName, ns = ...
local L = ns.L

local BACKDROP = {
	bgFile = [[Interface\ChatFrame\ChatFrameBackground]], tile = true, tileSize = 16,
	edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]], edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4}
}

-- need this to get size of a pair table
local function tLength(t)
	local count = 0
	for _ in next, t do
		count = count + 1
	end
	return count
end

local function CreateOptionsPanel(name, localizedName, description, buttonLocalizedText)
	local panel = CreateFrame('Frame', addonName .. name, InterfaceOptionsFramePanelContainer)
	panel.name = localizedName
	panel.parent = addonName

	local title = panel:CreateFontString('$parentTitle', 'ARTWORK', 'GameFontNormalLarge')
	title:SetPoint('TOPLEFT', 15, -15)
	title:SetText(panel.name)

	local desc = panel:CreateFontString('$parentDescription', 'ARTWORK', 'GameFontHighlight')
	desc:SetPoint('TOPLEFT', title, 'BOTTOMLEFT', 0, -8)
	desc:SetText(description)

	local bounds = CreateFrame('Frame', '$parentBounds', panel, BackdropTemplateMixin and 'BackdropTemplate')
	bounds:SetPoint('TOPLEFT', 15, -60)
	bounds:SetPoint('BOTTOMRIGHT', -15, 15)
	bounds:SetBackdrop(BACKDROP)
	bounds:SetBackdropColor(0, 0, 0, 0.5)
	bounds:SetBackdropBorderColor(0.5, 0.5, 0.5)

	local scrollchild = CreateFrame('Frame', '$parentScrollChild', panel)
	scrollchild:SetHeight(1) -- it needs something
	panel.container = scrollchild

	local scrollframe = CreateFrame('ScrollFrame', '$parentContainer', bounds, 'UIPanelScrollFrameTemplate')
	scrollframe:SetPoint('TOPLEFT', 4, -4)
	scrollframe:SetPoint('BOTTOMRIGHT', -4, 4)
	scrollframe:SetScrollChild(scrollchild)

	scrollframe.ScrollBar:ClearAllPoints()
	scrollframe.ScrollBar:SetPoint('TOPRIGHT', bounds, -6, -22)
	scrollframe.ScrollBar:SetPoint('BOTTOMRIGHT', bounds, -6, 22)

	local button = CreateFrame('Button', '$parentButton', panel, 'UIPanelButtonTemplate')
	button:SetPoint('BOTTOMRIGHT', bounds, 'TOPRIGHT', 0, 5)
	button:SetText(buttonLocalizedText)
	button:SetWidth(button:GetTextWidth() * 1.5)
	button:SetHeight(button:GetTextHeight() * 2)
	panel.button = button

	InterfaceOptions_AddCategory(panel)
	return panel
end

local function CreateItemBlocklistOptions()
	local panel = CreateOptionsPanel('ItemBlocklist',
		L['Item Blocklist'],
		L['Items in this list will not be processed.'],
		L['Block Item'])

	local function OnEnter(self)
		GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT')
		GameTooltip:SetItemByID(self.itemID)
		GameTooltip:Show()
	end

	local function OnRemove(self)
		for itemID in next, ns.db.profile.blocklist.items do
			if itemID == self.itemID then
				ns.db.profile.blocklist.items[itemID] = nil
			end
		end
	end

	local queryItems = {}
	local function UpdateTexture(button)
		local _, _, _, _, _, _, _, _, _, textureFile = GetItemInfo(button.itemID)
		if textureFile then
			button:SetNormalTexture(textureFile)
		else
			-- wait for cache and retry
			queryItems[button.itemID] = button
			panel.container:RegisterEvent('GET_ITEM_INFO_RECEIVED')
		end
	end

	panel.container:SetScript('OnEvent', function(self, event, itemID)
		local button = queryItems[itemID]
		if button then
			queryItems[itemID] = nil
			UpdateTexture(button)

			if tLength(queryItems) == 0 then
				self:UnregisterEvent(event)
			end
		end
	end)

	local function AddButton(pool, itemID)
		if itemID then
			local button = pool:CreateButton()
			button.itemID = itemID
			button.OnEnter = OnEnter
			button.OnLeave = GameTooltip_Hide
			button.OnRemove = OnRemove

			local texture = button:CreateTexture(nil, 'OVERLAY')
			texture:SetPoint('CENTER')
			texture:SetSize(54, 54)
			texture:SetTexture([[Interface\Buttons\UI-Quickslot2]])

			UpdateTexture(button)
			pool:Reposition()

			-- check if the item is already blocked
			local exists = false
			for existingItemID in next, ns.db.profile.blocklist.items do
				if existingItemID == itemID then
					exists = true
				end
			end

			if not exists then
				-- inject into db
				ns.db.profile.blocklist.items[itemID] = true
			end
		else
			print(addonName .. ': Invalid item ID')
		end
	end

	local itemPool = ns.CreateButtonPool(panel.container, 16, 33, 33, 4)
	itemPool:SetSortField('itemID')

	for itemID in next, ns.db.profile.blocklist.items do
		AddButton(itemPool, itemID)
	end

	panel.button:SetScript('OnClick', function()
		StaticPopup_Show(addonName .. 'ItemBlocklistPopup', nil, nil, {
			callback = AddButton,
			pool = itemPool,
		})
	end)
end

function ns.CreateBlocklistOptions()
	ns.CreateBlocklistOptions = nop -- we only want to run this once

	CreateItemBlocklistOptions()
end
