#!/usr/bin/env python3

from utils import *

itemSparse = CSVReader(open('dbc/itemsparse.csv', 'r'))

items = {}
# iterate through ItemSparse for items that can't be disenchanted
for row in itemSparse:
	if (getattr(row, 'Flags[0]') & 0x10) != 0: # deprecated item
		continue

	if (getattr(row, 'Flags[0]') & 0x8000) != 0: # "No Disenchant" flag
		if row.InventoryType != 0: # equippable
			items[row.ID] = {
				'itemID': row.ID,
				'name': row.Display_lang.strip(),
			}

# print data file structure
templateLuaTable('nondisenchantable', '\t[{itemID}] = true, -- {name}', items)
