#!/usr/bin/env python3

from utils import *

itemSparse = CSVReader(open('dbc/itemsparse.csv', 'r'))
itemSalvageLoot = CSVReader(open('dbc/itemsalvageloot.csv', 'r'))
spellEffect = CSVReader(open('dbc/spelleffect.csv', 'r'))

recipeSpellIDs = {
  44: 391302, # Crystalline Shatter (Dragon Isles)
  45: 391304, # Elemental Shatter (Dragon Isles)
  86: 445466, # Shatter Essence (Khaz Algar)
  # TODO: add new shatter recipe for Gleaming Shard
}

# figure out how many items are needed to perform the salvage
spellItemsRequired = {}
for _, spellID in recipeSpellIDs.items():
  spellItemsRequired[spellID] = 0

for row in spellEffect:
  if row.SpellID in spellItemsRequired:
    spellItemsRequired[row.SpellID] = row.EffectBasePointsF

# iterate through ItemSalvageLoot for items that can be shattered
items = {}
for row in itemSalvageLoot:
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
for row in itemSparse:
  if row.ID in items:
    if (getattr(row, 'Flags[0]') & 0x10) != 0:
      # deprecated item
      del items[row.ID]
      continue

    items[row.ID]['name'] = row.Display_lang

# print data file structure
templateLuaTable('shatterable', '\t[{itemID}] = {{{recipeSpellID}, {numItems}}}, -- {name}', items)
