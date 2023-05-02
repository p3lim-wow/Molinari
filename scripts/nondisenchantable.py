#!/usr/bin/env python3

from utils import *

itemSparse = CSVReader(open('dbc/itemsparse.csv', 'r'))

items = {}
# iterate through ItemSparse for items that can't be disenchanted
for row in itemSparse:
	if getattr(row, 'Flags[0]') == 32768:
		items[row.ID] = {
			'itemID': row.ID,
			'name': row.Display_lang.strip(),
		}

# print data file structure
templateLuaTable('nondisenchantable', '\t[{itemID}] = true, -- {name}', items)
