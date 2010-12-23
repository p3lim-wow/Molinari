local _, ns = ...

local notDisenchantable = {
	-- Weapons
	['52889'] = true,
	['52876'] = true,
	['52870'] = true,
	['52872'] = true,
	['52875'] = true,
	['59043'] = true,
	['59042'] = true,
	['59040'] = true,
	['66196'] = true,
	['66291'] = true,

	-- Armor
	['40483'] = true,
	['22206'] = true,
	['52873'] = true,
	['52874'] = true,
	['57115'] = true,
	['31404'] = true,
	['21525'] = true,
	['67108'] = true,
	['52019'] = true,
	['31405'] = true,
	['21524'] = true,
	['23192'] = true,
}

function ns.Disenchantable(link)
	local _, _, quality = GetItemInfo(link)

	if(IsEquippableItem(link) and quality and quality > 1 and quality < 5) then
		return not notDisenchantable[link:match('item:(%d+):')]
	end
end
