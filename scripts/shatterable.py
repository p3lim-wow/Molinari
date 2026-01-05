#!/usr/bin/env python3

import util

PROFESSION_ID = 333
PROFESSION_SALVAGE_SUFFIX = 'Shatter'

# gather all profession expansions
professionIDs = [PROFESSION_ID]
for row in util.dbc('skillline'):
  if row.ParentSkillLineID == PROFESSION_ID:
    professionIDs.append(row.ID)

# find all profession abilities
professionAbilities = []
for row in util.dbc('skilllineability'):
  if row.SkillupSkillLineID in professionIDs:
    professionAbilities.append(row.Spell)

# check spell effect info
numSpellReagents = {}
salvageSpellIDs = {}
spellSalvageIDs = {}
for row in util.dbc('spelleffect', [
  # BUG: these 4 spells have an incorrect EffectMiscValue0, so we add fake ones to correct it
  {'SpellID': 224199, 'EffectMiscValue_0': -991, 'EffectBasePointsF': 1}, # Ley Shatter
  {'SpellID': 252106, 'EffectMiscValue_0': -992, 'EffectBasePointsF': 1}, # Chaos Shatter
  {'SpellID': 290360, 'EffectMiscValue_0': -993, 'EffectBasePointsF': 1}, # Umbra Shatter
  {'SpellID': 290361, 'EffectMiscValue_0': -994, 'EffectBasePointsF': 1}, # Veiled Shatter
]):
  if not row.SpellID in professionAbilities:
    continue
  if row.EffectMiscValue_0 == 0:
    # all salvage abilities have this value, it's the salvage ID
    continue
  if row.EffectBasePointsF == 0:
    # all salvage abilities have this value, it's how many items are salvaged
    continue
  if row.EffectMiscValue_0 == 13:
    # BUG: the incorrect EffectMiscValue0 for the 4 spells, we just ignore it
    continue

  if not row.EffectMiscValue_0 in salvageSpellIDs:
    # this value might be used for other things not related to salvaging,
    # so we gotta track all spells using it and instead narrow it down later
    salvageSpellIDs[row.EffectMiscValue_0] = []

  # store info
  salvageSpellIDs[row.EffectMiscValue_0].append(row.SpellID)
  spellSalvageIDs[row.SpellID] = row.EffectMiscValue_0
  numSpellReagents[row.SpellID] = row.EffectBasePointsF

# check spell names
for row in util.dbc('spellname'):
  if row.ID in spellSalvageIDs:
    if not (row.Name_lang.startswith(PROFESSION_SALVAGE_SUFFIX) or row.Name_lang.endswith(PROFESSION_SALVAGE_SUFFIX)):
      # sadly the only proper way to check if it's the correct salvage spell,
      # there's no unique global ID for each type of salvage
      if spellSalvageIDs[row.ID] in salvageSpellIDs:
        salvageSpellIDs[spellSalvageIDs[row.ID]].remove(row.ID)

# iterate through salvage loot for items that can be milled
items = {}
for row in util.dbc('itemsalvageloot', [
  # BUG: the 4 spells we added above are also missing their items in this table
  {'ItemSalvageID': -991, 'SalvagedItemID': 124441}, # Leylight Shard
  {'ItemSalvageID': -992, 'SalvagedItemID': 124442}, # Chaos Crystal
  {'ItemSalvageID': -993, 'SalvagedItemID': 152876}, # Umbra Shard
  {'ItemSalvageID': -994, 'SalvagedItemID': 152877}, # Veiled Crystal
]):
  if row.ItemSalvageID in salvageSpellIDs:
    spells = salvageSpellIDs[row.ItemSalvageID]
    if len(spells) == 0:
      continue
    if len(spells) > 1:
      util.bail(f'ERROR: multiple spells for salvage {row.ItemSalvageID}: {",".join(map(str, spells))}')

    items[row.SalvagedItemID] = {
      'itemID': row.SalvagedItemID,
      'recipeSpellID': spells[0],
      'numItems': numSpellReagents[spells[0]],
    }

# get item names
for row in util.dbc('itemsparse'):
  if row.ID in items:
    if (row.Flags_0 & 0x10) != 0:
      # deprecated item
      del items[row.ID]
      continue

    items[row.ID]['name'] = row.Display_lang

# print data file structure
util.templateLuaTable(
  'local _, addon = ...',
  'addon.data.shatterable',
  '\t[{itemID}] = {{{recipeSpellID}, {numItems}}}, -- {name}',
  items
)
