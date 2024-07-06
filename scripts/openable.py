#!/usr/bin/env python3

from utils import *

itemSparse = CSVReader(open('dbc/itemsparse.csv', 'r'))
lock = CSVReader(open('dbc/lock.csv', 'r'))

# iterate through and store every single lock type, keyed by ID,
# so we can easily check using it later
locks = {}
for row in lock:
	locks[row.ID] = row

items = {}
# iterate through ItemSparse for locked items
for row in itemSparse:
	if (getattr(row, 'Flags[0]') & 0x10) != 0:
		# deprecated item
		continue

	# every item that requires a key or lockpicking has a LockID,
	# and a corresponding entry in Lock.db2
	if row.LockID > 0 and row.LockID in locks:
		# any locked item that doesn't have a level requirement is opened with a specific key
		levelRequirement = getattr(locks[row.LockID], 'Skill[1]')
		if levelRequirement > 0:
			items[row.ID] = {
				'itemID': row.ID,
				'name': row.Display_lang,
				'level': levelRequirement,
			}

# print data file structure
templateLuaTable('openable', '\t[{itemID}] = {level}, -- {name}', items)
