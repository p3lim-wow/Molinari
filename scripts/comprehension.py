#!/usr/bin/env python3

import util

items = {}
for row in util.dbc('itemsparse'):
  if row.RequiredSkill == 3012: # Comprehension
    items[row.ID] = {
      'itemID': row.ID,
      'name': row.Display_lang,
      'requiredSkillLevel': row.RequiredSkillRank,
    }

# print data file structure
util.templateLuaTable(
  'local _, addon = ...',
  'addon.data.comprehensible',
  '\t[{itemID}] = {requiredSkillLevel}, -- {name}',
  items
)
