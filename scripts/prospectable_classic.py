#!/usr/bin/env python3

import util

items = {}
# iterate through ItemSparse for items that can be prospected
for row in util.dbc('itemsparse'):
	if (row.Flags_0 & 0x40000) != 0 and row.RequiredSkill == 755:
		if row.ID == 24115:
			# random test item
			continue

		items[row.ID] = {
			'itemID': row.ID,
			'name': row.Display_lang,
			'requiredSkillLevel': row.RequiredSkillRank,
		}

# print data file structure
util.templateLuaTable(
	'local _, addon = ...',
	'addon.data.prospectable',
	'\t[{itemID}] = {recipeSpellID}, -- {name}',
	items
)
