#!/usr/bin/env python3

import util

# gather disenchant level ranges from DBC, filtering on
# class 2 (weapon) to deduplicate as there's no difference
# in skill requirements between weapons and armor
qualityMap = {}
for row in util.dbc('itemdisenchantloot'):
  if row.Class == 2:
    qualityMap.setdefault(row.Quality, []).append((row.MaxLevel, row.SkillRequired))

# iterate the maps for each quality independently since
# there are different skill requirements for each quality
mapping = {}
for quality, map in qualityMap.items():
  mapping.setdefault(quality, {})

  lastLevel, lastRequired = None, None
  for level, required in sorted(map):
    if lastRequired is not None and required != lastRequired:
      mapping[quality][len(mapping[quality])] = {
        'itemLevel': lastLevel,
        'skillLevel': lastRequired,
      }

    lastLevel = level
    lastRequired = required

  mapping[quality][len(mapping[quality])] = {
    'itemLevel': 'math.huge',
    'skillLevel': lastRequired,
  }

util.templateLuaTable('local _, addon = ...\naddon.data.disenchanting = {}')

for quality, itemLevels in mapping.items():
  util.templateLuaTable(None,
    f'addon.data.disenchanting[{quality}]',
    '\t{{{itemLevel}, {skillLevel}}},',
    itemLevels
  )
