local L = select(2, ...).L('ptBR')

L['ALT key'] = _G.ALT_KEY
L['ALT + CTRL key'] = _G.ALT_KEY_TEXT .. ' + ' .. _G.CTRL_KEY
L['ALT + SHIFT key'] = _G.ALT_KEY_TEXT .. ' + ' .. _G.SHIFT_KEY
L['You can\'t do that while in combat'] = _G.ERR_NOT_IN_COMBAT

-- config
-- L['Modifier to activate %s'] -- MISSING! %s = "Molinari"
