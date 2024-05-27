local _, addon = ...

local Enum = Enum -- upvalue so we can modify it
if not addon:IsRetail() then
	-- these were renamed in 9.0.1
	Enum.ItemQuality.Common = Enum.ItemQuality.Standard
	Enum.ItemQuality.Uncommon = Enum.ItemQuality.Good
end

function addon:IsProspectable(itemID)
	-- returns the spell used to prospect the item if the player can prospect it
	if addon:IsClassic() then
		local skillRequired = addon.data.prospectable[itemID]
		return skillRequired and addon:GetProfessionSkillLevel(755) >= skillRequired and ((GetItemCount or C_Item.GetItemCount)(itemID)) >= 5 and 31252, addon.colors.prospectable
	elseif addon:IsRetail() then
		local professionSkillID = addon.data.prospectable[itemID]
		return professionSkillID and IsPlayerSpell(professionSkillID) and professionSkillID, addon.colors.prospectable
	end
end

function addon:IsMillable(itemID)
	-- returns the spell used to mill the item if the player can mill it
	if addon:IsClassic() then
		local skillRequired = addon.data.millable[itemID]
		return skillRequired and addon:GetProfessionSkillLevel(773) >= skillRequired and ((GetItemCount or C_Item.GetItemCount)(itemID)) >= 5 and 51005, addon.colors.millable
	elseif addon:IsRetail() then
		local professionSkillID = addon.data.millable[itemID]
		return professionSkillID and IsPlayerSpell(professionSkillID) and ((GetItemCount or C_Item.GetItemCount)(itemID)) >= 5 and professionSkillID, addon.colors.millable
	end
end

function addon:IsCrushable(itemID)
	-- returns the spell used to crush the item if the player can crush it
	if addon:IsRetail() then
		local professionSkillID = addon.data.crushable[itemID]
		return professionSkillID and IsPlayerSpell(professionSkillID) and ((GetItemCount or C_Item.GetItemCount)(itemID)) >= 3 and professionSkillID, addon.colors.crushable
	end
end

function addon:IsScrappable(itemID)
	-- returns the spell used to scrap the item if the player can scrap it
	if addon:IsRetail() then
		local professionSkillID = addon.data.scrappable[itemID]
		return professionSkillID and IsPlayerSpell(professionSkillID) and ((GetItemCount or C_Item.GetItemCount)(itemID)) >= 5 and professionSkillID, addon.colors.scrappable
	end
end

function addon:IsDisenchantable(itemID)
	-- returns the spell used to disenchant the item if the player can disenchant it
	if IsPlayerSpell(13262) then
		if addon:IsRetail() and addon.data.disenchantable[itemID] then
			return 13262, addon.colors.disenchantable
		elseif addon.data.nondisenchantable[itemID] then
			return
		end

		local _, _, quality, _, _, _, _, _, _, _, _, class, subClass = (GetItemInfo or C_Item.GetItemInfo)(itemID)
		-- if addon:IsClassic() then
		-- 	-- make sure the player has enough skill to disenchant the item
		-- 	if addon:GetProfessionSkillLevel(333) < addon:RequiredDisenchantingLevel(itemID) then
		-- 		return
		-- 	end
		-- end

		-- match against common traits between items that are disenchantable
		return quality and (
			(
				quality >= Enum.ItemQuality.Uncommon and quality <= Enum.ItemQuality.Epic
			) and C_Item.GetItemInventoryTypeByID(itemID) ~= Enum.InventoryType.IndexBodyType and (
				class == Enum.ItemClass.Weapon or (
					class == Enum.ItemClass.Armor and subClass ~= Enum.ItemArmorSubclass.Cosmetic
				) or (
					class == Enum.ItemClass.Gem and subClass == Enum.ItemGemSubclass.Artifactrelic
				) or class == Enum.ItemClass.Profession
			)
		) and 13262, addon.colors.disenchantable
	end
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
	local spellID, color
	spellID, color = addon:IsProspectable(itemID)
	if spellID then
		return spellID, color
	end
	spellID, color = addon:IsMillable(itemID)
	if spellID then
		return spellID, color
	end
	spellID, color = addon:IsCrushable(itemID)
	if spellID then
		return spellID, color
	end
	spellID, color = addon:IsScrappable(itemID)
	if spellID then
		return spellID, color
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
				((GetItemCount or C_Item.GetItemCount)(pickItemID)) > 0
			then
				return pickItemID, addon.colors.openable
			end
		end
	end
end


