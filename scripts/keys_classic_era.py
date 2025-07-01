#!/usr/bin/env python3

import util

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

effectSpells = {}
# iterate through spell effects for effect 33 (lockpicking)
for row in util.dbc('spelleffect'):
	if row.Effect == 33 and row.EffectMiscValue_0 == 1:
		effectSpells[row.SpellID] = row.EffectBasePoints + 1 # it's 1 lower for whatever reason

items = {}
# iterate through item effects for items with the spell from above
for row in util.dbc('itemeffect'):
	if row.SpellID in effectSpells:
		items[row.ParentItemID] = {
			'itemID': row.ParentItemID,
			'effectiveSkill': effectSpells[row.SpellID]
		}

# iterate through ItemSparse to fill in extra info
for row in util.dbc('itemsparse'):
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
util.templateLuaTable(
	'local _, addon = ...',
	'addon.data.keys',
	'\t[{itemID}] = {{{effectiveSkill}, {requiredSkill}, {requiredSkillLevel}, 0}}, -- {name}',
	items
)
