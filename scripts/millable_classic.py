#!/usr/bin/env python3

import util

items = {}
# iterate through ItemSparse for items that can be milled
for row in util.dbc('itemsparse'):
	if row.ID == 785:
		# Mageroyal has broken data, unsure if this is the correct one
		row.RequiredSkillRank = 1

	if (row.Flags_0 & 0x20000000) != 0 and row.RequiredSkill == 773:
		items[row.ID] = {
			'itemID': row.ID,
			'name': row.Display_lang,
			'requiredSkillLevel': row.RequiredSkillRank,
		}

# print data file structure
util.templateLuaTable(
	'local _, addon = ...',
	'addon.data.millable',
	'\t[{itemID}] = {requiredSkillLevel}, -- {name}',
	items
)
