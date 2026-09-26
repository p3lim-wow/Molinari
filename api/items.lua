local _, addon = ...

local ItemQuality = CopyTable(Enum.ItemQuality)
if addon:IsClassic() then
	-- these were renamed in 9.0.1
	ItemQuality.Common = ItemQuality.Standard
	ItemQuality.Uncommon = ItemQuality.Good
end

function addon:IsOpenable(itemID)
	local requiredLevel = addon.data.openable[itemID]
	if requiredLevel then
		if C_SpellBook.IsSpellKnown(1804) and requiredLevel <= (UnitLevel('player') * (addon:IsRetail() and 1 or 5)) then
			return 1804, addon.colors.openable -- Pick Lock, Rogue ability
		elseif C_SpellBook.IsSpellKnown(312890) and requiredLevel <= UnitLevel('player') then
			return 312890, addon.colors.openable -- Skeleton Pinkie, Mechagnome racial ability
		elseif C_SpellBook.IsSpellKnown(323427) and requiredLevel <= 60 then
			return 323427, addon.colors.openable -- Kevin's Keyring, Necrolord soulbind ability
		end
	end
end

if addon:IsRetail() then
	-- use tooltip scanning to check if the key is usable
	local COLOR_WHITE = CreateColor(1, 1, 1)
	local function isKeyUsable(itemID)
		local data = C_TooltipInfo.GetItemByID(itemID)
		if data and data.lines then
			for index = 3, #data.lines do -- skip a few lines that holds item name and such
				local line = data.lines[index]
				if line.type == Enum.TooltipDataLineType.RestrictedSkill then
					return line.leftColor:IsRGBEqualTo(COLOR_WHITE)
				end
			end
		end

		return true
	end

	function addon:IsOpenableProfession(itemID)
		-- returns the pick used to open the item if the player can open it
		local requiredLevel = addon.data.openable[itemID]
		if requiredLevel then
			local playerLevel = UnitLevel('player')
			for keyItemID, info in next, addon.data.keys do
				if
					info[1] >= requiredLevel and
					info[2] <= playerLevel and
					C_Item.GetItemCount(keyItemID) > 0 and
					isKeyUsable(keyItemID)
				then
					return keyItemID, addon.colors.openable
				end
			end
		end
	end
else
	function addon:IsOpenableProfession(itemID)
		-- returns the pick used to open the item if the player can open it
		local requiredLevel = addon.data.openable[itemID]
		if requiredLevel then
			local playerLevel = UnitLevel('player')
			for keyItemID, info in next, addon.data.keys do
				if
					info[1] >= requiredLevel and
					(info[2] == 0 or info[3] <= addon:GetProfessionSkillLevel(info[2])) and
					info[4] <= playerLevel and
					C_Item.GetItemCount(keyItemID) > 0
				then
					return keyItemID, addon.colors.openable
				end
			end
		end
	end
end

local salvagers = addon:T()
function addon:IsSalvagable(itemID)
	for kind, salvager in next, salvagers do
		local spellID, numItems, skillID, skillRequired = salvager(itemID)
		if spellID then
			if skillRequired and skillID then
				local skillLevel = addon:GetProfessionSkillLevel(skillID)
				if skillLevel >= skillRequired then
					return spellID, addon.colors[kind], numItems
				end
			else
				return spellID, addon.colors[kind], numItems
			end
		end
	end
end

for kind, data in next, addon.data.salvage do
	salvagers[kind] = function(itemID)
		local info = data[itemID]
		if info and C_SpellBook.IsSpellKnown(info[1]) then
			return unpack(info)
		end
	end
end

function salvagers.disenchantable(itemID)
	if not C_SpellBook.IsSpellKnown(13262) then
		return
	end

	-- returns the spell used to disenchant the item if it can be disenchanted
	if addon:IsRetail() and addon.data.disenchantable[itemID] then
		-- special items
		return 13262
	end

	local _, _, quality, _, _, _, _, _, _, _, _, class, subClass = C_Item.GetItemInfo(itemID)
	-- if not addon:IsRetail() then
	-- 	-- make sure the player has enough skill to disenchant the item
	-- 	if addon:GetProfessionSkillLevel(333) < addon:RequiredDisenchantingLevel(itemID) then
	-- 		return
	-- 	end
	-- end

	if not quality or quality < ItemQuality.Uncommon or quality > ItemQuality.Epic then
		-- grey, white, legendary, artifacts and heirlooms can't be disenchanted
		return
	elseif class ~= Enum.ItemClass.Weapon and class ~= Enum.ItemClass.Armor and class ~= Enum.ItemClass.Profession and not (class == Enum.ItemClass.Gem and subClass == Enum.ItemGemSubclass.Artifactrelic) then
		-- only armor, weapons, tools and artifact relics can be disenchanted
		return
	elseif C_Item.GetItemInventoryTypeByID(itemID) == Enum.InventoryType.IndexBodyType then
		-- shirts can't be disenchanted
		return
	elseif C_Item.IsCosmeticItem and C_Item.IsCosmeticItem(itemID) then
		-- cosmetic items can't be disenchanted
		return
	end

	return 13262
end

if addon:IsForever() and UnitClassBase('player') == 'HUNTER' then
	function salvagers.food(itemID) -- not really a "salvager" but w/e
		return C_PetInfo.CanPetEatItem(itemID) and 6991
	end
end
