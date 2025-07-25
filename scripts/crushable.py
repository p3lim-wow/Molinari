#!/usr/bin/env python3

import util

# 2nd field in ItemSalvageLoot.db2 gives us the item that can be prospected
# 3rd field in ItemSalvageLoot.db2 gives us the ItemSalvageID used to prospect the item
# 1st field in ItemSalvage.db2 matches the ItemSalvageID from ItemSalvageLoot
# 2nd field in ItemSalvage.db2 gives us the SkillLineID for Jewelcrafting
# 6th field in SkillLine.db2 matches the SkillLineID from ItemSalvage
# 5th/1st field in SkillLine.db2 gives us the profession name
# 17th field in SkillLineAbility.db2 matches the SkillLineID from ItemSalvage
# 6th field in SkillLineAbility.db2 gives us the SpellID for the crushing spell, but also a lot of other spells
# 36th field in SpellEffect.db2 matches SpellID from SkillLineAbility
# 26th field in SpellEffect.db2 matches ItemSalvageID from ItemSalvage

# tl;dr:
# 1. find the spellID for crushing on wowhead
# 2. match that against the spellID field in SpellEffect.db2
# 3. find "EffectMiscValue[0]" - this is the ItemSalvageID

recipeSpellIDs = {
	# ItemSalvageID = SpellID
	46: 395696, # Dragon Isles Crushing
	50: 404740, # Cataclysm Crushing
	70: 434020, # Algari Crushing
}

# figure out how many items are needed to perform the salvage
spellItemsRequired = {}
for _, spellID in recipeSpellIDs.items():
	spellItemsRequired[spellID] = 0

for row in util.dbc('spelleffect'):
	if row.SpellID in spellItemsRequired:
		spellItemsRequired[row.SpellID] = row.EffectBasePointsF

# iterate through ItemSalvageLoot for items that can be crushed
items = {}
for row in util.dbc('itemsalvageloot'):
	if row.ItemSalvageID in recipeSpellIDs:
		items[row.SalvagedItemID] = {
			'itemID': row.SalvagedItemID,
			'recipeSpellID': recipeSpellIDs[row.ItemSalvageID],
			'numItems': spellItemsRequired[recipeSpellIDs[row.ItemSalvageID]],
		}

# iterate through ItemSparse for crushable items and add their names to the dict
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
	'addon.data.crushable',
	'\t[{itemID}] = {{{recipeSpellID}, {numItems}}}, -- {name}',
	items
)
