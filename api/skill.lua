local _, addon = ...

local skillLevels = {}
function addon:GetProfessionSkillLevel(professionID)
	return skillLevels[professionID] or 0
end

if addon:IsForever() then
	function addon:SKILL_LINES_CHANGED()
		table.wipe(skillLevels)

		for index = 1, C_SkillInfo.GetNumSkillLines() do
			local info = C_SkillInfo.GetSkillLineInfo(index)
			if info then
				if info.isHeader and info.isCollapsed then
					C_SkillInfo.ExpandSkillHeader(index)
					return
				end

				skillLevels[info.skillID] = info.rank
			end
		end
	end
else
	local PROFESSION_IDS = {
		-- these are all the apprentice-level spells, except herbalism since there's no matching
		-- apprentice skill for it, an item effect is used instead
		[((C_Spell.GetSpellName or GetSpellInfo)(2259))] = 171, -- Alchemy
		[((C_Spell.GetSpellName or GetSpellInfo)(2018))] = 164, -- Blacksmithing
		[((C_Spell.GetSpellName or GetSpellInfo)(7411))] = 333, -- Enchanting
		[((C_Spell.GetSpellName or GetSpellInfo)(4036))] = 202, -- Engineering
		[((C_Spell.GetSpellName or GetSpellInfo)(9134))] = 182, -- Herbalism
		[((C_Spell.GetSpellName or GetSpellInfo)(45357)) or 0] = 773, -- Inscription
		[((C_Spell.GetSpellName or GetSpellInfo)(25229)) or 0] = 755, -- Jewelcrafting
		[((C_Spell.GetSpellName or GetSpellInfo)(2108))] = 165, -- Leatherworking
		[((C_Spell.GetSpellName or GetSpellInfo)(2575))] = 186, -- Mining
		[((C_Spell.GetSpellName or GetSpellInfo)(8613))] = 393, -- Skinning
		[((C_Spell.GetSpellName or GetSpellInfo)(3908))] = 197, -- Tailoring
	}

	function addon:SKILL_LINES_CHANGED()
		table.wipe(skillLevels) -- we have to do this in case the player unlearns a profession

		for index = 1, GetNumSkillLines() do
			local skillName, isHeader, isExpanded, skillLevel = GetSkillLineInfo(index)
			if skillName == TRADE_SKILLS and isHeader and not isExpanded then
				ExpandSkillHeader(index)
				return
			else
				local professionID = PROFESSION_IDS[skillName]
				if professionID then
					skillLevels[professionID] = skillLevel
				end
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
