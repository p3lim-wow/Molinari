#!/usr/bin/env python3

from utils import *

itemSparse = dbc('itemsparse')

# non-equipment disenchantable items I can't find a flag for
extra = [
	137195, # Highmountain Armor
	137221, # Enchanted Raven Sigil
	137286, # Fel-Crusted Rune
	200479, # Sophic Amalgamation
]

items = {}
# iterate through ItemSparse for items that can't be disenchanted
for row in itemSparse:
	if (getattr(row, 'Flags[1]') & 0x40000000) != 0 and row.InventoryType == 0:
		items[row.ID] = {
			'itemID': row.ID,
			'name': row.Display_lang,
		}

# print data file structure
templateLuaTable('disenchantable', '\t[{itemID}] = true, -- {name}', items)
