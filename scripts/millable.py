#!/usr/bin/env python3

from utils import *

itemSparse = CSVReader(open('dbc/itemsparse.csv', 'r'))
itemSalvageLoot = CSVReader(open('dbc/itemsalvageloot.csv', 'r'))

# 2nd field in ItemSalvageLoot.db2 gives us the item that can be milled
# 3rd field in ItemSalvageLoot.db2 gives us the ItemSalvageID used to mill the item
# 1st field in ItemSalvage.db2 matches the ItemSalvageID from ItemSalvageLoot
# 2nd field in ItemSalvage.db2 gives us the SkillLineID for Inscription
# 6th field in SkillLine.db2 matches the SkillLineID from ItemSalvage
# 5th/1st field in SkillLine.db2 gives us the profession name
# 17th field in SkillLineAbility.db2 matches the SkillLineID from ItemSalvage
# 6th field in SkillLineAbility.db2 gives us the SpellID for the milling spell, but also a lot of other spells
# 36th field in SpellEffect.db2 matches SpellID from SkillLineAbility
# 26th field in SpellEffect.db2 matches ItemSalvageID from ItemSalvage

recipeSpellIDs = {
	# ItemSalvageID = SpellID
	13: 382981, # Dragon Isles Milling
	14: 382982, # Shadowlands Milling
	15: 382984, # Kul Tiras and Zandalar Milling
	16: 382986, # Legion Milling
	17: 382987, # Draenor Milling
	18: 382988, # Pandaria Milling
	19: 382989, # Cataclysm Milling
	20: 382990, # Northrend Milling
	21: 382991, # Outland Milling
	22: 382994, # Classic Milling
}

# iterate through ItemSalvageLoot for items that can be milled
items = {}
for row in itemSalvageLoot:
	if row.ItemSalvageID in recipeSpellIDs:
		items[row.SalvagedItemID] = {
			'itemID': row.SalvagedItemID,
			'recipeSpellID': recipeSpellIDs[row.ItemSalvageID]
		}

# iterate through ItemSparse for millable items and add their names to the dict
for row in itemSparse:
	if row.ID in items:
		items[row.ID]['name'] = row.Display_lang

# print data file structure
templateLuaTable('millable', '\t[{itemID}] = {recipeSpellID}, -- {name}', items)
