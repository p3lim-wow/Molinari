#!/usr/bin/env python3

import util

# this script is identical to the retail one, except it filters
# out bad items.

effectSpells = {}
# iterate through spell effects for effect 33 (lockpicking)
for row in util.dbc('spelleffect'):
  if row.Effect == 33 and row.EffectBasePointsF > 0 and row.EffectMiscValue_0 == 1:
    effectSpells[row.SpellID] = row.EffectBasePointsF

effects = {}
# iterate through item effects that matches the spells from above
for row in util.dbc('itemeffect'):
  if row.SpellID in effectSpells:
    effects[row.ID] = row.SpellID

items = {}
# iterate through the ItemXItemEffect dbc to match item effects to items
for row in util.dbc('itemxitemeffect'):
  if row.ItemEffectID in effects:
    items[row.ItemID] = {
      'itemID': row.ItemID,
      'effectiveSkill': effectSpells[effects[row.ItemEffectID]]
    }

# iterate through ItemSparse to fill in extra info
for row in util.dbc('itemsparse'):
  if row.ID in items:
    if not row.Display_lang:
      excluded.append(row.ID)
      continue

    items[row.ID]['name'] = row.Display_lang
    items[row.ID]['requiredLevel'] = row.RequiredLevel

# remove excluded items from the item list
for itemID in list(items):
  if 'name' not in items[itemID]:
    del items[itemID]

util.templateLuaTable(
  'local _, addon = ...',
  'addon.data.keys',
  '\t[{itemID}] = {{{effectiveSkill}, {requiredLevel}}}, -- {name}',
  items
)
