local L = select(2, ...).L('zhTW')

L['ALT key'] = _G.ALT_KEY
L['ALT + CTRL key'] = _G.ALT_KEY_TEXT .. ' + ' .. _G.CTRL_KEY
L['ALT + SHIFT key'] = _G.ALT_KEY_TEXT .. ' + ' .. _G.SHIFT_KEY
L['You can\'t do that while in combat'] = _G.ERR_NOT_IN_COMBAT

-- config
L['Modifier to activate %s'] = '啟用%s的設置選項'
L['Item Blocklist'] = '物品屏蔽列表'
L['Block Item'] = '屏蔽物品'
L['Items in this list will not be processed.'] = '列表中的物品不會被處理'
L['Block a new item by ID'] = '通過物品ID屏蔽一個新的物品'
