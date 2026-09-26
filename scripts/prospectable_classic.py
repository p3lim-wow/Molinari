#!/usr/bin/env python3

import util

SPELL_ID = 31252 # Prospecting
SKILL_ID = 755 # Jewelcrafting

items = {}
# iterate through ItemSparse for items that can be prospected
for row in util.dbc('itemsparse'):
	if (row.Flags_0 & 0x40000) != 0 and row.RequiredSkill == SKILL_ID:
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
	'addon.data.salvage.prospectable',
  '\t[{itemID}] = {{{spellID}, 5, {skillID}, {requiredSkillLevel}}}, -- {name}',
	items
)
