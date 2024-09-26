local _, addon = ...

local Enum = Enum -- upvalue so we can modify it
if not addon:IsRetail() then
	-- these were renamed in 9.0.1
	Enum.ItemQuality.Common = Enum.ItemQuality.Standard
	Enum.ItemQuality.Uncommon = Enum.ItemQuality.Good
end

function addon:IsProspectable(itemID)
	-- returns the spell used to prospect the item
	if addon:IsClassic() then
		local skillRequired = addon.data.prospectable[itemID]
		return skillRequired and addon:GetProfessionSkillLevel(755) >= skillRequired and C_Item.GetItemCount(itemID) >= 5 and 31252, addon.colors.prospectable
	elseif addon:IsRetail() then
		local info = addon.data.prospectable[itemID]
		if info then
			return info[1], addon.colors.prospectable, info[2]
		end
	end
end

function addon:IsMillable(itemID)
	-- returns the spell used to mill the item
	if addon:IsClassic() then
		local skillRequired = addon.data.millable[itemID]
		return skillRequired and addon:GetProfessionSkillLevel(773) >= skillRequired and C_Item.GetItemCount(itemID) >= 5 and 51005, addon.colors.millable
	elseif addon:IsRetail() then
		local info = addon.data.millable[itemID]
		if info then
			return info[1], addon.colors.millable, info[2]
		end
	end
end

function addon:IsCrushable(itemID)
	-- returns the spell used to crush the item
	if addon:IsRetail() then
		local info = addon.data.crushable[itemID]
		if info then
			return info[1], addon.colors.crushable, info[2]
		end
	end
end

function addon:IsScrappable(itemID)
	-- returns the spell used to scrap the item
	if addon:IsRetail() then
		local info = addon.data.scrappable[itemID]
		if info then
			return info[1], addon.colors.scrappable, info[2]
		end
	end
end

function addon:IsShatterable(itemID)
	if addon:IsRetail() then
		local info = addon.data.shatterable[itemID]
		if info then
			return info[1], addon.colors.disenchantable, info[2]
		end
	end
end

function addon:NonDisenchantable(itemID)
	return not not addon.data.nondisenchantable[itemID]
end

function addon:IsDisenchantable(itemID)
	-- returns the spell used to disenchant the item if it can be disenchanted
	if addon:IsRetail() and addon.data.disenchantable[itemID] then
		-- special items
		return 13262, addon.colors.disenchantable
	end

	local _, _, quality, _, _, _, _, _, _, _, _, class, subClass = C_Item.GetItemInfo(itemID)
	-- if addon:IsClassic() then
	-- 	-- make sure the player has enough skill to disenchant the item
	-- 	if addon:GetProfessionSkillLevel(333) < addon:RequiredDisenchantingLevel(itemID) then
	-- 		return
	-- 	end
	-- end

	if not quality or quality < Enum.ItemQuality.Uncommon or quality > Enum.ItemQuality.Epic then
		-- grey, white, and legendary items, plus artifacts and heirlooms can't be disenchanted
		return
	elseif class == Enum.ItemClass.Gem and subClass ~= Enum.ItemGemSubclass.Artifactrelic then
		-- any gem other than artifact relics can't be disenchanted
		return
	elseif class ~= Enum.ItemClass.Weapon and class ~= Enum.ItemClass.Armor and class ~= Enum.ItemClass.Profession then
		-- only armor or weapons can be disenchanted
		return
	elseif C_Item.GetItemInventoryTypeByID(itemID) == Enum.InventoryType.IndexBodyType then
		-- shirts can't be disenchanted
		return
	elseif addon:IsRetail() and C_Item.IsCosmeticItem(itemID) then
		-- cosmetic items can't be disenchanted
		return
	end

	-- TODO: check if profession items can still be disenchanted
	return 13262, addon.colors.disenchantable
end

function addon:IsOpenable(itemID)
	-- returns the spell used to open the item if the player can open it
	local requiredLevel = addon.data.openable[itemID]
	if requiredLevel then
		if IsPlayerSpell(1804) and requiredLevel <= (UnitLevel('player') * (addon:IsRetail() and 1 or 5)) then
			return 1804, addon.colors.openable -- Pick Lock, Rogue ability
		elseif IsPlayerSpell(312890) and requiredLevel <= UnitLevel('player') then
			return 312890, addon.colors.openable -- Skeleton Pinkie, Mechagnome racial ability
		elseif IsPlayerSpell(323427) and requiredLevel <= 60 then
			return 323427, addon.colors.openable -- Kevin's Keyring, Necrolord soulbind ability
		end
	end
end

function addon:IsSalvagable(itemID)
	-- wrapper for all of the above
	local spellID, color, numItems
	spellID, color, numItems = addon:IsProspectable(itemID)
	if spellID then
		return spellID, color, numItems
	end
	spellID, color, numItems = addon:IsMillable(itemID)
	if spellID then
		return spellID, color, numItems
	end
	spellID, color, numItems = addon:IsCrushable(itemID)
	if spellID then
		return spellID, color, numItems
	end
	spellID, color, numItems = addon:IsScrappable(itemID)
	if spellID then
		return spellID, color, numItems
	end
	spellID, color, numItems = addon:IsShatterable(itemID)
	if spellID then
		return spellID, color, numItems
	end
	spellID, color = addon:IsDisenchantable(itemID)
	if spellID then
		return spellID, color
	end
	spellID, color = addon:IsOpenable(itemID)
	if spellID then
		return spellID, color
	end
end

function addon:IsOpenableProfession(itemID)
	-- returns the pick used to open the item if the player can open it
	local requiredLevel = addon.data.openable[itemID]
	if requiredLevel then
		for pickItemID, info in next, addon.data.keys do
			if
				info[1] > requiredLevel and
				info[3] < addon:GetProfessionSkillLevel(info[2]) and
				info[4] < UnitLevel('player') and
				C_Item.GetItemCount(pickItemID) > 0
			then
				return pickItemID, addon.colors.openable
			end
		end
	end
end
