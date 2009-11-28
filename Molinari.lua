local button = CreateFrame('Button', 'Molinari', UIParent, 'SecureActionButtonTemplate')
button:RegisterForClicks('LeftButtonUp')
button:SetAttribute('*type*', 'macro')

button:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=]})
button:SetBackdropColor(1, 0.5, 0.5, 0.4)

button:RegisterEvent('MODIFIER_STATE_CHANGED')
button:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
button:SetScript('OnLeave', function(self) self:Hide() end)

local macro = '/cast %s\n/use %s %s'
local spell = GetSpellInfo(51005)

function button:MODIFIER_STATE_CHANGED(event, key)
	if(self:IsShown() and (key == 'LALT' or key == 'RALT')) then
		self:GetScript('OnLeave')(self)
	end
end

GameTooltip:HookScript('OnTooltipSetItem', function(self)
	if(self:GetItem() and IsAltKeyDown()) then
		if(GameTooltipTextLeft2:GetText() == ITEM_MILLABLE) then
			
			button:SetAttribute('macrotext', macro:format(spell, GetMouseFocus():GetParent():GetID(), GetMouseFocus():GetID()))
			button:SetAllPoints(GetMouseFocus())
			button:SetParent(GetMouseFocus())
			button:Show()
		end
	end
end)
