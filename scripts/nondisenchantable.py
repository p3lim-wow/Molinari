#!/usr/bin/env python3

from utils import *

itemSparse = dbc('itemsparse')

items = {}
# iterate through ItemSparse for items that can't be disenchanted
for row in itemSparse:
	if (getattr(row, 'Flags[0]') & 0x10) != 0:
		# deprecated item
		continue

	if (getattr(row, 'Flags[0]') & 0x8000) == 0:
		# "No Disenchant" flag
		continue

	if row.OverallQualityID < 2 or row.OverallQualityID > 4:
		# can't disenchant items of too low or too high quality anyways
		continue

	if row.InventoryType == 0 or row.InventoryType == 4:
		# not equippable or a shirt
		continue

	if (getattr(row, 'Flags[3]') & 0x10000) != 0:
		# cosmetic item
		continue

	items[row.ID] = {
		'itemID': row.ID,
		'name': row.Display_lang.strip(),
	}

# print data file structure
templateLuaTable('nondisenchantable', '\t[{itemID}] = true, -- {name}', items)
