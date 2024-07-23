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
	-- migrate old settings
	-- TODO: remove this in 12.x
	if MolinariDB2 and MolinariDB2.profiles and MolinariDB2.profiles.Default then
		-- I never implemented profiles so everything will be in the default profile
		if MolinariDB2.profiles.Default.modifier ~= nil then
			addon:SetOption('modifier', MolinariDB2.profiles.Default.modifier)
			addon:Print("migrated setting 'modifier' from old savedvariables")
		end
	end
	-- TODO: this needs testing, it assumes MolinariDB3 is loaded with defaults at this point
	MolinariDB2 = nil
end
