#!/usr/bin/env python3

from utils import *

spellEffect = CSVReader(open('dbc/spelleffect.csv', 'r'))
itemEffect = CSVReader(open('dbc/itemeffect.csv', 'r'))
itemXItemEffect = CSVReader(open('dbc/itemxitemeffect.csv', 'r'))
itemSparse = CSVReader(open('dbc/itemsparse.csv', 'r'))

effectSpells = {}
# iterate through spell effects for effect 33 (lockpicking)
for row in spellEffect:
	if row.Effect == 33 and row.EffectBasePointsF > 0 and getattr(row, 'EffectMiscValue[0]') == 1:
		effectSpells[row.SpellID] = row.EffectBasePointsF

effects = {}
# iterate through item effects that matches the spells from above
for row in itemEffect:
	if row.SpellID in effectSpells:
		effects[row.ID] = row.SpellID

items = {}
# iterate through the ItemXItemEffect dbc to match item effects to items
for row in itemXItemEffect:
	if row.ItemEffectID in effects:
		items[row.ItemID] = {
			'itemID': row.ItemID,
			'effectiveSkill': effectSpells[effects[row.ItemEffectID]]
		}

excluded = []
# iterate through ItemSparse to fill in extra info
for row in itemSparse:
	if row.ID in items:
		if getattr(row, 'Flags[3]') != 16384 or row.RequiredSkill == 0:
			# items that are not profession keys, like one-off quest rewards and such
			excluded.append(row.ID)
			continue

		items[row.ID]['name'] = row.Display_lang
		items[row.ID]['requiredSkill'] = row.RequiredSkill
		items[row.ID]['requiredSkillLevel'] = row.RequiredSkillRank
		items[row.ID]['requiredLevel'] = row.RequiredLevel

# remove excluded items from the item list
for itemID in list(items):
	if itemID in excluded:
		del items[itemID]

# print data file structure
templateLuaTable('keys', '\t[{itemID}] = {{{effectiveSkill}, {requiredSkill}, {requiredSkillLevel}, {requiredLevel}}}, -- {name}', items)
