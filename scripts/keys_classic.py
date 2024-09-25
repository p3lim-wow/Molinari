#!/usr/bin/env python3

from utils import *

# SpellEffect does not have EffectBasePointsF (effectiveSkill),
# so we have to manually keep this updated with the effective skill?

itemSparse = dbc('itemsparse')
itemEffect = dbc('itemeffect')
spellEffect = dbc('spelleffect')

effectSpells = {}
# iterate through spell effects for effect 33 (lockpicking)
for row in spellEffect:
	if row.Effect == 33 and getattr(row, 'EffectMiscValue[0]') == 1:
		effectSpells[row.SpellID] = row.EffectBasePoints

items = {}
# iterate through item effects for items with the spell from above
for row in itemEffect:
	if row.SpellID in effectSpells:
		items[row.ParentItemID] = {
			'itemID': row.ParentItemID,
			'effectiveSkill': effectSpells[row.SpellID]
		}

excluded = []
# iterate through ItemSparse to fill in extra info
for row in itemSparse:
	if row.ID in items:
		if row.RequiredSkill == 0:
			# items that are not profession keys, like one-off quest rewards and such
			excluded.append(row.ID)
			continue

		items[row.ID]['name'] = row.Display_lang
		items[row.ID]['requiredSkill'] = row.RequiredSkill
		items[row.ID]['requiredSkillLevel'] = row.RequiredSkillRank

# remove excluded items from the item list
for itemID in list(items):
	if itemID in excluded:
		del items[itemID]

# print data file structure
templateLuaTable('keys', '\t[{itemID}] = {{{effectiveSkill}, {requiredSkill}, {requiredSkillLevel}, 0}}, -- {name}', items)
