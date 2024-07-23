local addonName, addon = ...
local L = addon.L

addon:RegisterSettings('MolinariDB3', {
	{
		key = 'modifier',
		type = 'menu',
		title = string.format(L['Modifier to activate %s'], addonName),
		default = 'ALT',
		options = {
			ALT = L['Alt key'],
			CTRL = L['ALT + CTRL key'],
			SHIFT = L['ALT + SHIFT key'],
		}
	}
})

addon:RegisterSettingsSlash('/molinari')

function addon:OnLoad()
	-- TODO: migrate old settings
end
