std = 'lua51'

quiet = 1 -- suppress report output for files without warnings

-- see https://luacheck.readthedocs.io/en/stable/warnings.html#list-of-warnings
-- and https://luacheck.readthedocs.io/en/stable/cli.html#patterns
ignore = {
	'212/self', -- unused argument self
	'212/event', -- unused argument event
	'212/unit', -- unused argument unit
	'212/element', -- unused argument element
	'312/event', -- unused value of argument event
	'312/unit', -- unused value of argument unit
	'431', -- shadowing an upvalue
	'614', -- trailing whitespace in a comment
	'631', -- line is too long
}

exclude_files = {
}

globals = {
	-- FrameXML objects we mutate
	'SlashCmdList', -- FrameXML/ChatFrame.lua
	'StaticPopupDialogs', -- FrameXML/StaticPopup.lua

	-- savedvariables
	'MolinariDB',
	'MolinariBlacklistDB',
}

read_globals = {
	table = {fields = {'wipe'}},

	-- FrameXML objects
	'UIParent', -- FrameXML/UIParent.xml
	'GameTooltip', -- ???
	'EquipmentFlyoutFrame', -- FrameXML/EquipmentFlyout.xml
	'AuctionFrame', -- AddOns/Blizzard_AuctionUI/Blizzard_AuctionUI.xml
	'AuctionHouseFrame', -- AddOns/Blizzard_AuctionHouseUI/Blizzard_AuctionHouseFrame.xml

	'InterfaceOptionsFrameAddOns', -- OLD
	'InterfaceOptionsFramePanelContainer', -- OLD

	-- FrameXML functions
	'nop', -- FrameXML/UIParent.lua
	'GameTooltip_Hide', -- FrameXML/GameTooltip.lua
	'StaticPopup_Show', -- FrameXML/StaticPopup.lua
	'RegisterStateDriver', -- FrameXML/SecureStateDriver.lua
	'AutoCastShine_AutoCastStart', -- FrameXML/UIParent.lua
	'AutoCastShine_AutoCastStop', -- FrameXML/UIParent.lua

	'InterfaceOptions_AddCategory', -- OLD
	'InterfaceAddOnsList_Update', -- OLD
	'InterfaceOptionsFrame_OpenToCategory', -- OLD

	-- SharedXML objects
	'Settings', -- SharedXML/Settings/Blizzard_Settings.lua
	'SettingsPanel', -- SharedXML/Settings/Blizzard_SettingsPanel.xml

	-- SharedXML functions
	'Mixin', -- SharedXML/Mixin.lua
	'CreateFramePool', -- SharedXML/Pools.lua
	'FramePool_HideAndClearAnchors', -- SharedXML/Pools.lua
	'GetItemInfoFromHyperlink', -- SharedXML/LinkUtil.lua

	-- GlobalStrings
	'ALT_KEY',
	'ALT_KEY_TEXT',
	'CTRL_KEY',
	'ALT_KEY_TEXT',
	'SHIFT_KEY',
	'ERR_NOT_IN_COMBAT',

	-- namespaces
	'C_Timer',

	-- API
	'CreateFrame',
	'GetBuildInfo',
	'GetContainerItemLink',
	'GetItemCount',
	'GetItemInfo',
	'GetItemInfoInstant',
	'GetLocale',
	'GetMouseFocus',
	'GetScreenWidth',
	'GetSpellInfo',
	'GetTradeTargetItemLink',
	'InCombatLockdown',
	'IsAltKeyDown',
	'IsControlKeyDown',
	'IsShiftKeyDown',
	'UnitHasVehicleUI',

	-- exposed globals
	'Molinari',

	-- exposed from other addons
	'LibStub',
}
