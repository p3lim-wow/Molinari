local addonName, addon = ...
local L = addon.L

local function updateOptions()
	if (InterfaceOptionsFrameAddOns or SettingsPanel):IsShown() then
		LibStub('AceConfigRegistry-3.0'):NotifyChange(addonName)
	end
end

local function createOptions()
	createOptions = nop -- we only want to load this once

	LibStub('AceConfig-3.0'):RegisterOptionsTable(addonName, {
		type = 'group',
		get = function(info)
			return addon.db.profile.general[info[#info]]
		end,
		set = function(info, value)
			addon.db.profile.general[info[#info]] = value
		end,
		args = {
			modifierKey = {
				order = 1,
				name = string.format(L['Modifier to activate %s'], addonName),
				type = 'select',
				values = {
					ALT = L['ALT key'],
					CTRL = L['ALT + CTRL key'],
					SHIFT = L['ALT + SHIFT key']
				},
				set = function(info, value)
					addon.db.profile.general[info[#info]] = value
					_G.Molinari:UpdateStateDriver()
				end,
				disabled = InCombatLockdown,
			},
			combatWarning = {
				order = 2,
				name = string.format('|cff990000%s|r', L['You can\'t do that while in combat']),
				type = 'description',
				hidden = function() return not InCombatLockdown() end,
			},
		},
	})

	LibStub('AceConfigDialog-3.0'):AddToBlizOptions(addonName)

	-- handle combat updates
	local EventHandler = CreateFrame('Frame', nil, InterfaceOptionsFrameAddOns or SettingsPanel)
	EventHandler:RegisterEvent('PLAYER_REGEN_ENABLED')
	EventHandler:RegisterEvent('PLAYER_REGEN_DISABLED')
	EventHandler:SetScript('OnEvent', updateOptions)
end

addon:HookSettings(function()
	createOptions() -- LoD
	addon.CreateBlocklistOptions() -- LoD
end)

addon:RegisterSlash('/molinari', function()
	createOptions() -- LoD
	addon.CreateBlocklistOptions() -- LoD

	addon:OpenSettings(addonName)
end)
