std = 'lua51'

quiet = 1 -- suppress report output for files without warnings

-- see https://luacheck.readthedocs.io/en/stable/warnings.html#list-of-warnings
-- and https://luacheck.readthedocs.io/en/stable/cli.html#patterns
ignore = {
	'212/self', -- unused argument self
	'631', -- line is too long
}

globals = {
	-- FrameXML objects we mutate
	'StaticPopupDialogs', -- FrameXML/StaticPopup.lua
}

read_globals = {
	table = {fields = {'wipe'}},

	-- FrameXML objects
	'AuctionFrame', -- Blizzard_AuctionUI/Blizzard_AuctionUI.xml (classic)
	'AuctionHouseFrame', -- Blizzard_AuctionHouseUI/Blizzard_AuctionHouseFrame.xml
	'EquipmentFlyoutFrame', -- FrameXML/EquipmentFlyout.xml
	'GameTooltip', -- FrameXML/GameTooltip.xml
	'UIParent', -- FrameXML/UIParent.xml

	'InterfaceOptionsFrameAddOns', -- OLD
	'InterfaceOptionsFramePanelContainer', -- OLD
	'PaperDollFrameItemFlyoutButtons', -- OLD
	'InterfaceAddOnsList_Update', -- OLD
	'InterfaceOptionsFrame_OpenToCategory', -- OLD

	-- FrameXML functions
	'AutoCastShine_AutoCastStart', -- FrameXML/UIParent.lua
	'AutoCastShine_AutoCastStop', -- FrameXML/UIParent.lua
	'CreateColor', -- FrameXML/Color.lua
	'GameTooltip_Hide', -- FrameXML/GameTooltip.lua
	'RegisterAttributeDriver', -- FrameXML/SecureStateDriver.lua
	'StaticPopup_Show', -- FrameXML/StaticPopup.lua
	'nop', -- FrameXML/UIParent.lua

	-- SharedXML objects
	'Settings', -- SharedXML/Settings/Blizzard_Settings.lua
	'SettingsPanel', -- SharedXML/Settings/Blizzard_SettingsPanel.xml
	'Item', -- FrameXML/ObjectAPI/Item.lua
	'ItemLocation', -- FrameXML/ObjectAPI/ItemLocation.lua

	-- SharedXML functions
	'CreateFramePool', -- SharedXML/Pools.lua
	'FramePool_HideAndClearAnchors', -- SharedXML/Pools.lua
	'GetItemInfoFromHyperlink', -- SharedXML/LinkUtil.lua
	'InterfaceOptions_AddCategory', -- SharedXML/Settings/Blizzard_Deprecated.lua
	'Mixin', -- SharedXML/Mixin.lua

	-- namespaces
	'C_Item',
	'C_Timer',
	'C_TradeSkillUI',
	'Enum',
	'TooltipDataProcessor', -- ?

	-- API
	'CreateFrame',
	'ExpandSkillHeader', -- (classic)
	'FindSpellBookSlotBySpellID',
	'GetItemCount',
	'GetItemInfo',
	'GetItemInfoInstant',
	'GetMouseFocus',
	'GetNumSkillLines', -- (classic)
	'GetProfessionInfo',
	'GetProfessions',
	'GetScreenWidth',
	'GetSkillLineInfo', -- (classic)
	'GetSpellInfo',
	'GetTradeTargetItemLink',
	'InCombatLockdown',
	'IsAltKeyDown',
	'IsControlKeyDown',
	'IsPlayerSpell',
	'IsShiftKeyDown',
	'UnitHasVehicleUI',
	'UnitLevel',

	-- exposed from other addons
	'LibStub',
}
