#!/usr/bin/env python3

import util

recipeSpellIDs = {
  44: 391302, # Crystalline Shatter (Dragon Isles)
  45: 391304, # Elemental Shatter (Dragon Isles)
  86: 445466, # Shatter Essence (Khaz Algar)
  102: 470726, # Gleaming Shatter (Khaz Algar)
}

# figure out how many items are needed to perform the salvage
spellItemsRequired = {}
for _, spellID in recipeSpellIDs.items():
  spellItemsRequired[spellID] = 0

for row in util.dbc('spelleffect'):
  if row.SpellID in spellItemsRequired:
    spellItemsRequired[row.SpellID] = row.EffectBasePointsF

# iterate through ItemSalvageLoot for items that can be shattered
items = {}
for row in util.dbc('itemsalvageloot'):
  if row.ItemSalvageID in recipeSpellIDs:
    items[row.SalvagedItemID] = {
      'itemID': row.SalvagedItemID,
      'recipeSpellID': recipeSpellIDs[row.ItemSalvageID],
      'numItems': spellItemsRequired[recipeSpellIDs[row.ItemSalvageID]],
    }

# shatterable items somehow not in ItemSalvageLoot
items[124441] = { # Leylight Shard
  'itemID': 124441,
  'recipeSpellID': 224199, # Ley Shatter (Legion)
  'numItems': 1,
}
items[124442] = { # Chaos Crystal
  'itemID': 124442,
  'recipeSpellID': 252106, # Chaos Shatter (Legion)
  'numItems': 1,
}

# iterate through ItemSparse for shatterable items and add their names to the dict
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
