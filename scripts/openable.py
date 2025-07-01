#!/usr/bin/env python3

import util

# iterate through and store every single lock type, keyed by ID,
# so we can easily check using it later
lock_req = {}
for row in util.dbc('lock'):
	lock_req[row.ID] = row.Skill_1

items = {}
# iterate through ItemSparse for locked items
for row in util.dbc('itemsparse'):
	if (row.Flags_0 & 0x10) != 0:
		# deprecated item
		continue

	# every item that requires a key or lockpicking has a LockID,
	# and a corresponding entry in Lock.db2
	if row.LockID > 0 and row.LockID in lock_req:
		# any locked item that doesn't have a level requirement is opened with a specific key
		levelRequirement = lock_req[row.LockID]
		if levelRequirement > 0:
			items[row.ID] = {
				'itemID': row.ID,
				'name': row.Display_lang,
				'level': levelRequirement,
			}

# print data file structure
util.templateLuaTable(
	'local _, addon = ...',
	'addon.data.openable',
	'\t[{itemID}] = {level}, -- {name}',
	items
)
