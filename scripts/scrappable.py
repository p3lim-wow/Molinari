#!/usr/bin/env python3

from utils import *

itemSparse = CSVReader(open('dbc/itemsparse.csv', 'r'))
itemSalvageLoot = CSVReader(open('dbc/itemsalvageloot.csv', 'r'))
spellEffect = CSVReader(open('dbc/spelleffect.csv', 'r'))

recipeSpellIDs = {
	# ItemSalvageID = SpellID
	35: 382374, # Rummage Through Scrap
	87: 447313, # Disassemble Invention
	88: 447310, # Scour Through Scrap
	89: 447311, # Pilfer Through Parts
}

# figure out how many items are needed to perform the salvage
spellItemsRequired = {}
for _, spellID in recipeSpellIDs.items():
	spellItemsRequired[spellID] = 0

for row in spellEffect:
	if row.SpellID in spellItemsRequired:
		spellItemsRequired[row.SpellID] = row.EffectBasePointsF

# iterate through ItemSalvageLoot for items that can be scrapped
items = {}
for row in itemSalvageLoot:
	if row.ItemSalvageID in recipeSpellIDs:
		items[row.SalvagedItemID] = {
			'itemID': row.SalvagedItemID,
			'recipeSpellID': recipeSpellIDs[row.ItemSalvageID],
			'numItems': spellItemsRequired[recipeSpellIDs[row.ItemSalvageID]],
		}

# iterate through ItemSparse for scrappable items and add their names to the dict
for row in itemSparse:
	if row.ID in items:
		if (getattr(row, 'Flags[0]') & 0x10) != 0:
			# deprecated item
			del items[row.ID]
			continue

		items[row.ID]['name'] = row.Display_lang

# need to filter bad data
for item in list(items.keys()):
	if 'name' not in items[item]:
		del items[item]

# print data file structure
templateLuaTable('scrappable', '\t[{itemID}] = {{{recipeSpellID}, {numItems}}}, -- {name}', items)
