#!/usr/bin/env python3

import csv

from types import SimpleNamespace
class CSVReader(csv.DictReader):
	def __next__(self):
		row = super().__next__()
		for key in self.fieldnames:
			try:
				row[key] = int(row[key])
			except:
				pass
		return SimpleNamespace(**row)

def dbc(file):
	return CSVReader(open(f'dbc/{file}.csv', 'r'))

def has_header(file, header):
	f = csv.DictReader(open(f'dbc/{file}.csv', 'r'))
	return not not (header in f.fieldnames)

template = '''
-- this file is auto-generated
local _, addon = ...
addon.data.{} = {{
{}
}}
'''

def templateLuaTable(kind, lineFormat, data):
	lines = [lineFormat.format(**data[item]) for item in sorted(data)]
	print(template.format(kind, '\n'.join(lines)).strip())
