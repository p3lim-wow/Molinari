#!/usr/bin/env python3

import util

SPELL_ID = 51005 # Milling
SKILL_ID = 773 # Inscription

items = {}
# iterate through ItemSparse for items that can be milled
for row in util.dbc('itemsparse'):
	if row.ID == 785:
		# BUG: Mageroyal has broken data
		row.RequiredSkillRank = 1

	if (row.Flags_0 & 0x20000000) != 0 and row.RequiredSkill == SKILL_ID:
		items[row.ID] = {
      'spellID': SPELL_ID,
      'skillID': SKILL_ID,
			'itemID': row.ID,
			'name': row.Display_lang,
			'requiredSkillLevel': row.RequiredSkillRank,
		}

# print data file structure
util.templateLuaTable(
	'local _, addon = ...',
	'addon.data.salvage.millable',
  '\t[{itemID}] = {{{spellID}, 5, {skillID}, {requiredSkillLevel}}}, -- {name}',
	items
)
