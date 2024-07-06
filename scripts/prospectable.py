#!/usr/bin/env python3

from utils import *

itemSparse = CSVReader(open('dbc/itemsparse.csv', 'r'))
itemSalvageLoot = CSVReader(open('dbc/itemsalvageloot.csv', 'r'))

# 2nd field in ItemSalvageLoot.db2 gives us the item that can be prospected
# 3rd field in ItemSalvageLoot.db2 gives us the ItemSalvageID used to prospect the item
# 1st field in ItemSalvage.db2 matches the ItemSalvageID from ItemSalvageLoot
# 2nd field in ItemSalvage.db2 gives us the SkillLineID for Jewelcrafting
# 6th field in SkillLine.db2 matches the SkillLineID from ItemSalvage
# 5th/1st field in SkillLine.db2 gives us the profession name
# 17th field in SkillLineAbility.db2 matches the SkillLineID from ItemSalvage
# 6th field in SkillLineAbility.db2 gives us the SpellID for the prospecting spell, but also a lot of other spells
# 36th field in SpellEffect.db2 matches SpellID from SkillLineAbility
# 26th field in SpellEffect.db2 matches ItemSalvageID from ItemSalvage

# tl;dr:
# 1. find the spellID for prospecting on wowhead
# 2. match that against the spellID field in SpellEffect.db2
# 3. find "EffectMiscValue[0]" - this is the ItemSalvageID

recipeSpellIDs = {
	# ItemSalvageID = SpellID
	1: 325248, # Shadowlands Prospecting
	2: 374627, # Dragon Isles Prospecting
	5: 382973, # Kul Tiras and Zandalar Prospecting
	6: 382975, # Legion Prospecting
	8: 382977, # Pandaria Prospecting
	9: 382978, # Cataclysm Prospecting
	10: 382979, # Northrend Prospecting
	11: 382980, # Outland Prospecting
	12: 382995, # Classic Prospecting
	69: 434018, # Algari Prospecting
}

# iterate through ItemSalvageLoot for items that can be prospected
items = {}
for row in itemSalvageLoot:
	if row.ItemSalvageID in recipeSpellIDs:
		items[row.SalvagedItemID] = {
			'itemID': row.SalvagedItemID,
			'recipeSpellID': recipeSpellIDs[row.ItemSalvageID]
		}

# TODO: check if Runic Core is prospectable with BfA Prospecting
#       if so, we'll have to manually handle it here
# [155830] = 382973, -- Runic Core

# iterate through ItemSparse for prospectable items and add their names to the dict
for row in itemSparse:
	if row.ID in items:
		items[row.ID]['name'] = row.Display_lang

# print data file structure
templateLuaTable('prospectable', '\t[{itemID}] = {recipeSpellID}, -- {name}', items)
