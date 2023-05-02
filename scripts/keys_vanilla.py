#!/usr/bin/env python3

from utils import *

# this script is identical to the wrath one, except it filters out seaforium charges,
# as they can't be used to open lockboxes until tbc
excluded = [
	4367, # Small Seaforium Charge
	4398, # Large Seaforium Charge
	18594, # Powerful Seaforium Charge
	23819, # Elemental Seaforium Charge
]

# SpellEffect does not have EffectBasePointsF (effectiveSkill),
# so we have to manually keep this updated with the effective skill?

itemSparse = CSVReader(open('dbc/itemsparse.csv', 'r'))
itemEffect = CSVReader(open('dbc/itemeffect.csv', 'r'))
spellEffect = CSVReader(open('dbc/spelleffect.csv', 'r'))

effectSpells = {}
# iterate through spell effects for effect 33 (lockpicking)
for row in spellEffect:
	if row.Effect == 33 and getattr(row, 'EffectMiscValue[0]') == 1:
		effectSpells[row.SpellID] = row.EffectBasePoints + 1 # it's 1 lower for whatever reason

items = {}
# iterate through item effects for items with the spell from above
for row in itemEffect:
	if row.SpellID in effectSpells:
		items[row.ParentItemID] = {
			'itemID': row.ParentItemID,
			'effectiveSkill': effectSpells[row.SpellID]
		}

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
	if itemID in excluded or itemID in excluded:
		del items[itemID]

# print data file structure
templateLuaTable('keys', '\t[{itemID}] = {{{effectiveSkill}, {requiredSkill}, {requiredSkillLevel}, 0}}, -- {name}', items)
