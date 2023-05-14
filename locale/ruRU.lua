local L = select(2, ...).L('ruRU')

L['ALT key'] = _G.ALT_KEY
L['ALT + CTRL key'] = _G.ALT_KEY_TEXT .. ' + ' .. _G.CTRL_KEY
L['ALT + SHIFT key'] = _G.ALT_KEY_TEXT .. ' + ' .. _G.SHIFT_KEY
L['You can\'t do that while in combat'] = _G.ERR_NOT_IN_COMBAT

-- config
-- L['Modifier to activate %s'] -- MISSING! %s = "Molinari"
L['Item Blocklist'] = 'Блок-список предметов'
L['Block Item'] = 'Заблокированный предмет'
L['Items in this list will not be processed.'] = 'Предметы из этого списка не будут обрабатываться.'
L['Block a new item by ID'] = 'Заблокировать новый предмет по ID'
