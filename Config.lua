local addonName, L = ...
local defaults = {
	items = {
		[116913] = true, -- Peon's Mining Pick
		[116916] = true, -- Gorepetal's Gentle Grasp
	}
}

local Options = LibStub('Wasabi'):New(addonName, 'MolinariBlacklistDB', defaults)
Options:AddSlash('/molinari')
Options:Initialize(function(self)
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
	Items:SetPoint('TOPLEFT', Description, 'BOTTOMLEFT', -12, -8)
	Items:SetPoint('BOTTOMRIGHT', -8, 8)
	Items:SetObjectSize(34)
	Items:SetObjectSpacing(2)
	Items:On('ObjectCreate', function(self, event, Object)
		local Texture = Object:CreateTexture()
		Texture:SetAllPoints()

		Object:SetNormalTexture(Texture)
		Object:SetScript('OnEnter', OnItemEnter)
		Object:SetScript('OnLeave', GameTooltip_Hide)
	end)

	Items:On('ObjectUpdate', function(self, event, Object)
		local _, _, _, _, _, _, _, _, _, textureFile = GetItemInfo(Object.key)
		if(textureFile) then
			Object:SetNormalTexture(textureFile)
		elseif(not self.queryItems) then
			self.queryItems = true
			self:RegisterEvent('GET_ITEM_INFO_RECEIVED')
		end
	end)

	Items:On('PreUpdate', function(self)
		self.queryItems = nil
	end)

	Items:On('PostUpdate', function(self)
		if(not self.queryItems) then
			self:UnregisterEvent('GET_ITEM_INFO_RECEIVED')
		end
	end)

	Items:HookScript('OnEvent', Items.Update)
	Items:SetScript('OnMouseUp', function(self)
		if(CursorHasItem()) then
			local _, itemID = GetCursorInfo()
			if(not self:HasObject(itemID)) then
				ClearCursor()
				self:AddObject(itemID)
				self:Update()
			end
		end
	end)
end)
