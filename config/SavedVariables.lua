local addonName, addon = ...

local defaults = {
	profile = {
		general = {
			modifierKey = 'ALT',
		},
		blocklist = {
			items = {
				[116913] = true, -- Peon's Mining Pick
				[116916] = true, -- Gorepetal's Gentle Grasp
			},
		},
	},
}

function addon:ADDON_LOADED(name)
	if name == addonName then
		-- initialize database with defaults
		addon.db = LibStub('AceDB-3.0'):New('MolinariDB2', defaults, true)

		return true
	end
end
