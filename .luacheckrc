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

	-- exposed globals
	'Molinari',

	-- savedvariables
	'MolinariDB3',
	'MolinariDB2', -- old
}

read_globals = {
	table = {fields = {'wipe'}},

	-- FrameXML objects
	'AuctionFrame', -- classic
	'AuctionHouseFrame', -- retail
	'EquipmentFlyoutFrame', -- retail
	'GameTooltip',
	'UIParent',
	'Item',
	'ItemLocation',
	'PaperDollFrameItemFlyoutButtons', -- classic

	-- FrameXML functions
	'AutoCastShine_AutoCastStart', -- classic
	'AutoCastShine_AutoCastStop', -- classic
	'CreateColor',
	'GameTooltip_Hide',
	'RegisterAttributeDriver',
	'Mixin',
	'nop',

	-- FrameXML constants
	'FACTION_RED_COLOR',

	-- GlobalStrings
	'ALT_KEY',
	'ALT_KEY_TEXT',
	'CTRL_KEY',
	'ERR_USE_LOCKED_WITH_SPELL_S',
	'ITEM_DISENCHANT_NOT_DISENCHANTABLE',
	'NPEV2_ABILITYINITIAL', -- retail
	'NPEV2_CASTER_ABILITYINITIAL', -- retail
	'SHIFT_KEY',
	'SPELL_FAILED_NEED_MORE_ITEMS',
	'TRADE_SKILLS',

	-- namespaces
	'C_Item',
	'C_Spell',
	'C_TradeSkillUI', -- retail
	'Enum',
	'TooltipDataProcessor', -- retail

	-- API
	'CreateFrame',
	'ExpandSkillHeader', -- classic
	'FindSpellBookSlotBySpellID',
	'GetNumSkillLines', -- classic
	'GetProfessionInfo', -- hack
	'GetProfessions', -- hack
	'GetScreenWidth',
	'GetSkillLineInfo', -- classic
	'GetSpellInfo', -- classic
	'GetTradeTargetItemLink',
	'InCombatLockdown',
	'IsAltKeyDown',
	'IsControlKeyDown',
	'IsPlayerSpell',
	'IsShiftKeyDown',
	'UnitHasVehicleUI',
	'UnitLevel',
}
