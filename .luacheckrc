std = 'lua51'

quiet = 1 -- suppress report output for files without warnings

-- see https://luacheck.readthedocs.io/en/stable/warnings.html#list-of-warnings
-- and https://luacheck.readthedocs.io/en/stable/cli.html#patterns
ignore = {
	'212/self', -- unused argument self
	'631', -- line is too long
}

exclude_files = {
}

globals = {
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
	'CreateColor', -- SharedXML/Color.lua
	'TooltipDataProcessor', -- SharedXML/Tooltip/TooltipDataHandler.lua

	-- GlobalStrings
	'ALT_KEY',
	'ALT_KEY_TEXT',
	'CTRL_KEY',
	'ALT_KEY_TEXT',
	'SHIFT_KEY',
	'ERR_NOT_IN_COMBAT',

	-- namespaces
	'C_Timer',
	'C_TradeSkillUI',
	'C_Container',
	'C_Item',
	'Enum',

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
