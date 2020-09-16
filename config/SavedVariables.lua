local addonName, ns = ...

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

local EventHandler = CreateFrame('Frame')
EventHandler:RegisterEvent('ADDON_LOADED')
EventHandler:SetScript('OnEvent', function(self, event, addon)
	if(addon == addonName) then
		-- initialize database with defaults
		ns.db = LibStub('AceDB-3.0'):New('MolinariDB2', defaults, true)

		-- migrate old dbs
		if(MolinariDB) then
			if(MolinariDB.itemBlacklist) then
				for key, value in next, MolinariDB.itemBlacklist do
					if not ns.db.profile.blocklist.items[key] then
						ns.db.profile.blocklist.items[key] = value
					end
				end
			end

			if(MolinariDB.modifier ~= nil) then
				ns.db.profile.general.modifierKey = MolinariDB.modifier
			end

			MolinariDB = nil
		end
		if(MolinariBlacklistDB and MolinariBlacklistDB.items) then
			for key, value in next, MolinariBlacklistDB.items do
				if not ns.db.profile.blocklist.items[key] then
					ns.db.profile.blocklist.items[key] = value
				end
			end

			MolinariBlacklistDB = nil
		end

		-- unregister
		self:UnregisterEvent(event)
	end
end)
