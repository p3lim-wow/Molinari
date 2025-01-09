local _, addon = ...

-- classic only
local PROFESSION_IDS = {
	-- these are all the apprentice-level spells, except herbalism since there's no matching
	-- apprentice skill for it, an item effect is used instead
	[(GetSpellInfo(2259))] = 171, -- Alchemy
	[(GetSpellInfo(2018))] = 164, -- Blacksmithing
	[(GetSpellInfo(7411))] = 333, -- Enchanting
	[(GetSpellInfo(4036))] = 202, -- Engineering
	[(GetSpellInfo(9134))] = 182, -- Herbalism
	[(GetSpellInfo(45357)) or 0] = 773, -- Inscription
	[(GetSpellInfo(25229)) or 0] = 755, -- Jewelcrafting
	[(GetSpellInfo(2108))] = 165, -- Leatherworking
	[(GetSpellInfo(2575))] = 186, -- Mining
	[(GetSpellInfo(8613))] = 393, -- Skinning
	[(GetSpellInfo(3908))] = 197, -- Tailoring
}

local professionSkillLevels = {}
function addon:GetProfessionSkillLevel(professionID)
	return professionSkillLevels[professionID] or 0
end

function addon:SKILL_LINES_CHANGED()
	table.wipe(professionSkillLevels) -- we have to do this in case the player unlearns a profession

	for index = 1, GetNumSkillLines() do
		local skillName, isHeader, isExpanded, skillLevel = GetSkillLineInfo(index)
		if skillName == TRADE_SKILLS and isHeader and not isExpanded then
			ExpandSkillHeader(index)
			return
		else
			local professionID = PROFESSION_IDS[skillName]
			if professionID then
				professionSkillLevels[professionID] = skillLevel
			end
		end
	end
end

function addon:RequiredDisenchantingLevel(itemID)
	-- TODO: this isn't working
	local _, _, _, _, itemRequiredLevel = C_Item.GetItemInfo(itemID)
	if not itemRequiredLevel then
		return
	end

	-- this is pretty much pure guesswork and probably won't be entirely accurate
	if itemRequiredLevel <= 15 then
		return 1
	elseif itemRequiredLevel <= 20 then
		return 25
	elseif itemRequiredLevel <= 25 then
		return 50
	elseif itemRequiredLevel <= 30 then
		return 75
	elseif itemRequiredLevel <= 35 then
		return 100
	elseif itemRequiredLevel <= 40 then
		return 125
	elseif itemRequiredLevel <= 45 then
		return 150
	elseif itemRequiredLevel <= 50 then
		return 175
	elseif itemRequiredLevel <= 55 then
		return 200
	elseif itemRequiredLevel <= 63 then
		return 225
	elseif itemRequiredLevel <= 70 then
		return 275
	elseif itemRequiredLevel <= 72 then
		return 325
	elseif itemRequiredLevel <= 80 then
		return 350
	else
		return 9999 -- fallback to avoid errors without information available
	end
end
