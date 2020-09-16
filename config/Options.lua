local addonName, ns = ...
local L = ns.L

local function CreateOptions()
	CreateOptions = nop -- we only want to load this once

	LibStub('AceConfig-3.0'):RegisterOptionsTable(addonName, {
		type = 'group',
		get = function(info)
			return ns.db.profile.general[info[#info]]
		end,
		set = function(info, value)
			ns.db.profile.general[info[#info]] = value
		end,
		args = {
			modifierKey = {
				order = 1,
				name = string.format(L['Modified to use %s'], addonName),
				type = 'select',
				width = 'double',
				values = {
					ALT = L['ALT key'],
					CTRL = L['ALT + CTRL key'],
					SHIFT = L['ALT + SHIFT key']
				}
			},
		},
	})

	LibStub('AceConfigDialog-3.0'):AddToBlizOptions(addonName)
end

InterfaceOptionsFrameAddOns:HookScript('OnShow', function()
	CreateOptions() -- LoD
	ns.CreateBlocklistOptions() -- LoD

	-- we load too late, so we have to manually refresh the list
	InterfaceAddOnsList_Update()
end)

_G['SLASH_' .. addonName .. '1'] = '/molinari'
SlashCmdList[addonName] = function()
	CreateOptions() -- LoD
	ns.CreateBlocklistOptions() -- LoD

	InterfaceOptionsFrame_OpenToCategory(addonName)
	InterfaceOptionsFrame_OpenToCategory(addonName) -- load twice due to an old bug
end
