#!/usr/bin/env python3

from utils import *

itemSparse = CSVReader(open('dbc/itemsparse.csv', 'r'))
itemSalvageLoot = CSVReader(open('dbc/itemsalvageloot.csv', 'r'))

recipeSpellIDs = {
	# ItemSalvageID = SpellID
	35: 382374, # Rummage Through Scrap
}

# iterate through ItemSalvageLoot for items that can be scrapped
items = {}
for row in itemSalvageLoot:
	if row.ItemSalvageID in recipeSpellIDs:
		items[row.SalvagedItemID] = {
			'itemID': row.SalvagedItemID,
			'recipeSpellID': recipeSpellIDs[row.ItemSalvageID]
		}

# iterate through ItemSparse for scrappable items and add their names to the dict
for row in itemSparse:
	if row.ID in items:
		items[row.ID]['name'] = row.Display_lang

# print data file structure
templateLuaTable('scrappable', '\t[{itemID}] = {recipeSpellID}, -- {name}', items)
