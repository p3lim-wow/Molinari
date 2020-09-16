local addonName, ns = ...
local L = ns.L

StaticPopupDialogs[addonName .. 'ItemBlocklistPopup'] = {
	text = L['Block a new item by ID'],
	button1 = L['Accept'],
	button2 = L['Cancel'],
	hasEditBox = true,
	EditBoxOnEnterPressed = function(self)
		self.data.callback(self.data.pool, tonumber(strtrim(self.editBox:GetText())))
		self:GetParent():Hide()
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
	EditBoxOnTextChanged = function(editBox)
		local self = editBox:GetParent()
		local text = strtrim(editBox:GetText()):match('[0-9]+')
		editBox:SetText(text or '')

		local itemID, _, _, _, texture = GetItemInfoInstant(tonumber(text) or '')
		if itemID then
			self.data = self.data or {}
			self.data.link = '|Hitem:' .. itemID .. '|h'

			self.ItemFrame:RetrieveInfo(self.data)
			self.ItemFrame:DisplayInfo(self.data.link, self.data.name, self.data.color, self.data.texture)
		else
			self.ItemFrame:DisplayInfo(nil, L['Invalid Item'], nil, [[Interface\Icons\INV_Misc_QuestionMark]])
		end
	end,
	OnAccept = function(self)
		self.data.callback(self.data.pool, tonumber(strtrim(self.editBox:GetText())))
	end,
	OnShow = function(self)
		self.editBox:SetFocus()
		self.editBox:ClearAllPoints()
		self.editBox:SetPoint('BOTTOM', 0, 100)
	end,
	OnHide = function(self)
		self.editBox:SetText('')
	end,
	hideOnEscape = true,
	hasItemFrame = true,
	timeout = 0,
}
