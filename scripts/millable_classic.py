#!/usr/bin/env python3

from utils import *

itemSparse = CSVReader(open('dbc/itemsparse.csv', 'r'))

# I assume these two flags represent TBC and Wrath inscription
flags = [
	24580,
	24576,
]

items = {}
# iterate through ItemSparse for items that can be milled
for row in itemSparse:
	if row.ID == 785:
		# Mageroyal has broken data, unsure if this is the correct one
		row.RequiredSkillRank = 1

	if getattr(row, 'Flags[1]') in flags and row.BagFamily == 32 and row.RequiredSkill == 773 and row.RequiredSkillRank > 0:
		items[row.ID] = {
			'itemID': row.ID,
			'name': row.Display_lang,
			'requiredSkillLevel': row.RequiredSkillRank,
		}


# print data file structure
templateLuaTable('millable', '\t[{itemID}] = {requiredSkillLevel}, -- {name}', items)
