#!/usr/bin/env python3

import util
items = {}

effectSpells = {}
# iterate through spell effects for effect 33 (open_lock)
for row in util.dbc('spelleffect'):
  if row.Effect == 33 and row.EffectMiscValue_0 == 1:
    if util.classic:
      effectiveLevel = row.EffectBasePoints
    else:
      effectiveLevel = row.EffectBasePointsF

    if effectiveLevel > 0:
        effectSpells[row.SpellID] = effectiveLevel + (1 if util.flavor in ('vanilla', 'tbc', 'wrath') else 0)

effects = {}
# iterate through item effects that matches the spells from above
for row in util.dbc('itemeffect'):
  if row.SpellID in effectSpells:
    if hasattr(row, 'ParentItemID'): # classic
      items[row.ParentItemID] = {
        'itemID': row.ParentItemID,
        'effectiveSkill': effectSpells[row.SpellID]
      }
    else:
      effects[row.ID] = row.SpellID

if not items:
  # iterate through the ItemXItemEffect dbc to match item effects to items,
  # this relational dbc doesn't exist for classic (they have ParentItemID in
  # ItemEffect instead)
  for row in util.dbc('itemxitemeffect'):
    if row.ItemEffectID in effects:
      items[row.ItemID] = {
        'itemID': row.ItemID,
        'effectiveSkill': effectSpells[effects[row.ItemEffectID]]
      }

# iterate through ItemSparse to fill in extra info
for row in util.dbc('itemsparse'):
  if row.ID in items and (row.Flags_0 & 0x10) == 0: # exclude deprecated items
    items[row.ID]['name'] = row.Display_lang
    items[row.ID]['requiredLevel'] = row.RequiredLevel
    items[row.ID]['requiredSkillLevel'] = row.RequiredSkillRank
    items[row.ID]['requiredSkill'] = row.RequiredSkill

# remove bad items from the list
for itemID in list(items):
  if 'name' not in items[itemID]:
    del items[itemID]
  elif not items[itemID]['requiredSkill'] and not items[itemID]['requiredLevel']:
    # remove items that don't require a profession or level, they are typically
    # special items for quests or special items players might want to keep
    util.log(f'- keys: excluding item {itemID} ({items[itemID]["name"]})')
    del items[itemID]

# print data file structure
util.templateLuaTable(
  'local _, addon = ...',
  'addon.data.keys',
  '\t[{itemID}] = {{{effectiveSkill}, {requiredSkill}, {requiredSkillLevel}, {requiredLevel}}}, -- {name}',
  items
)
