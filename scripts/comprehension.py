#!/usr/bin/env python3

import util

SPELL_ID = 1296017 # Comprehend Scroll
SKILL_ID = 3012 # Comprehension

items = {}
for row in util.dbc('itemsparse'):
  if row.RequiredSkill == SKILL_ID:
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
  'addon.data.salvage.comprehensible',
  '\t[{itemID}] = {{{spellID}, 1, {skillID}, {requiredSkillLevel}}}, -- {name}',
  items
)
