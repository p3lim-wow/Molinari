local addonName, ns = ...
local L = ns.L

local defaults = {
	modifier = 'ALT',
}

local Options = LibStub('Wasabi'):New(addonName, 'MolinariDB', defaults)
Options:AddSlash('/molinari')
Options:Initialize(function(self)
	local Title = self:CreateTitle()
	Title:SetPoint('TOPLEFT', 16, -16)
	Title:SetFormattedText('%s |cffffffffv%s|r', addonName, GetAddOnMetadata(addonName, 'version'))

	local Modifier = self:CreateDropDown('modifier')
	Modifier:SetPoint('TOPLEFT', Title, 'BOTTOMLEFT', 0, -8)
	Modifier:SetFormattedText(L['Modifier to show enable %s'], addonName)
	Modifier:SetValues({
		ALT = L['ALT key'],
		CTRL = L['ALT + CTRL key'],
		SHIFT = L['ALT + SHIFT key']
	})
	Modifier:SetNewFeature(true)
end)

Options:On('Okay', function()
	Molinari:UpdateModifier()
end)

local defaultBlacklist = {
	items = {
		[116913] = true, -- Peon's Mining Pick
		[116916] = true, -- Gorepetal's Gentle Grasp
	}
}

-- need this to get size of a pair table
local function tLength(t)
	local count = 0
	for _ in next, t do
		count = count + 1
	end
	return count
end

local Blacklist = Options:CreateChild('Item Blacklist', 'MolinariBlacklistDB', defaultBlacklist)
Blacklist:Initialize(function(self)
	local Title = self:CreateTitle()
	Title:SetPoint('TOPLEFT', 20, -16)
	Title:SetFontObject('GameFontNormalMed1')
	Title:SetText(L['Items blacklisted from potentially being processed.'])

	local Description = self:CreateDescription()
	Description:SetPoint('TOPLEFT', Title, 'BOTTOMLEFT', 0, -6)
	Description:SetText(L['Drag items into the window below to add more.'])

	local OnItemEnter = function(self)
		GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT')
		GameTooltip:SetItemByID(self.key)
		GameTooltip:AddLine(' ')
		GameTooltip:AddLine(L['Right-click to remove item'], 0, 1, 0)
		GameTooltip:Show()
	end

	local Items = self:CreateObjectContainer('items')
	Items:SetPoint('TOPLEFT', Description, 'BOTTOMLEFT', -20, -8)
	Items:SetSize(self:GetWidth(), 500)
	Items:SetObjectSize(34)
	Items:SetObjectSpacing(2)
	Items:On('ObjectCreate', function(self, event, Object)
		local Texture = Object:CreateTexture()
		Texture:SetAllPoints()

		Object:SetNormalTexture(Texture)
		Object:SetScript('OnEnter', OnItemEnter)
		Object:SetScript('OnLeave', GameTooltip_Hide)
	end)

	local queryItems = {}
	Items:On('ObjectUpdate', function(self, event, Object)
		local itemID = Object.key

		local _, _, _, _, _, _, _, _, _, textureFile = GetItemInfo(itemID)
		if(textureFile) then
			Object:SetNormalTexture(textureFile)
		elseif(not queryItems[itemID]) then
			queryItems[itemID] = true
			self:RegisterEvent('GET_ITEM_INFO_RECEIVED')
		end
	end)

	Items:On('ObjectClick', function(self, event, Object, button)
		if(button == 'RightButton') then
			Object:Remove()
		end
	end)

	Items:HookScript('OnEvent', function(self, event, itemID)
		if(event == 'GET_ITEM_INFO_RECEIVED') then
			if(queryItems[itemID]) then
				queryItems[itemID] = nil
				self:AddObject(itemID)

				if(tLength(queryItems) == 0) then
					self:UnregisterEvent('GET_ITEM_INFO_RECEIVED')
				end
			end
		end
	end)

	Items:SetScript('OnMouseUp', function(self)
		if(CursorHasItem()) then
			local _, itemID = GetCursorInfo()
			if(not self:HasObject(itemID)) then
				ClearCursor()
				self:AddObject(itemID)
			end
		end
	end)
end)
