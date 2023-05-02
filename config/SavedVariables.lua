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

addon:HookAddOn(addonName, function()
	-- initialize database with defaults
	addon.db = LibStub('AceDB-3.0'):New('MolinariDB2', defaults, true)
end)
