local L = select(2, ...).L('deDE')

L['ALT key'] = _G.ALT_KEY
L['ALT + CTRL key'] = _G.ALT_KEY_TEXT .. ' + ' .. _G.CTRL_KEY
L['ALT + SHIFT key'] = _G.ALT_KEY_TEXT .. ' + ' .. _G.SHIFT_KEY
L['You can\'t do that while in combat'] = _G.ERR_NOT_IN_COMBAT

-- config
-- L['Modifier to activate %s'] -- MISSING! %s = "Molinari"
-- L['Item Blocklist'] = '' -- MISSING!
-- L['Block Item'] = '' -- MISSING!
-- L['Items in this list will not be processed.'] = '' -- MISSING!
-- L['Block a new item by ID'] = '' -- MISSING!
