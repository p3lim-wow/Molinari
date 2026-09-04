local addonName, addon = ...
local L = addon.L

addon:RegisterSettings('MolinariDB3', {
	{
		key = 'modifier',
		type = 'menu',
		title = string.format(L['Modifier to activate %s'], addonName),
		default = 'ALT',
		options = {
			{value='ALT', label=ALT_KEY},
			{value='CTRL', label=ALT_KEY_TEXT .. ' + ' .. CTRL_KEY},
			{value='SHIFT', label=ALT_KEY_TEXT .. ' + ' .. SHIFT_KEY},
		}
	}
})

addon:RegisterSettingsSlash('/molinari')
