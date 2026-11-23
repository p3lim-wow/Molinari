#!/usr/bin/env python3

import util

items = {}
# iterate through ItemSparse for items that can't be disenchanted
for row in util.dbc('itemsparse'):
	if (row.Flags_1 & 0x40000000) != 0 and row.InventoryType == 0:
		items[row.ID] = {
			'itemID': row.ID,
			'name': row.Display_lang,
		}

# print data file structure
util.templateLuaTable(
	'local _, addon = ...',
	'addon.data.disenchantable',
	'\t[{itemID}] = true, -- {name}',
	items
)
