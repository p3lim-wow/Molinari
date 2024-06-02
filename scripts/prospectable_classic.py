#!/usr/bin/env python3

from utils import *

itemSparse = CSVReader(open('dbc/itemsparse.csv', 'r'))

items = {}
# iterate through ItemSparse for items that can be prospected
for row in itemSparse:
	if (getattr(row, 'Flags[0]') & 0x40000) != 0 and row.RequiredSkill == 755:
		if row.ID == 24115:
			# random test item
			continue

		items[row.ID] = {
			'itemID': row.ID,
			'name': row.Display_lang,
			'requiredSkillLevel': row.RequiredSkillRank,
		}


# print data file structure
templateLuaTable('prospectable', '\t[{itemID}] = {requiredSkillLevel}, -- {name}', items)
