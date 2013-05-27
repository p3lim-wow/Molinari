local _, ns = ...

-- http://www.wowhead.com/items?filter=cr=10:5;crs=1:2;crv=0:0

local openable = {
	['68729'] = true,
	['63349'] = true,
	['45986'] = true,
	['43624'] = true,
	['43622'] = true,
	['43575'] = true,
	['31952'] = true,
	['12033'] = true,
	['29569'] = true,
	['5760'] = true,
	['13918'] = true,
	['5759'] = true,
	['16885'] = true,
	['5758'] = true,
	['13875'] = true,
	['4638'] = true,
	['16884'] = true,
	['4637'] = true,
	['4636'] = true,
	['6355'] = true,
	['16883'] = true,
	['4634'] = true,
	['4633'] = true,
	['6354'] = true,
	['16882'] = true,
	['4632'] = true,
	['88165'] = true,
	['88567'] = true,
}

function ns.Openable(link)
	return openable[link:match('item:(%d+)')]
end

-- http://www.wowhead.com/items?filter=na=key;cr=86;crs=2;crv=0

local keys = {
	[GetSpellInfo(130100)] = true, -- Ghostly Skeleton Key
	[GetSpellInfo(94574)] = true, -- Obsidium Skeleton Key
	[GetSpellInfo(59403)] = true, -- Titanium Skeleton Key
	[GetSpellInfo(59404)] = true, -- Colbat Skeleton Key
	[GetSpellInfo(20709)] = true, -- Arcanite Skeleton Key
	[GetSpellInfo(19651)] = true, -- Truesilver Skeleton Key
	[GetSpellInfo(19649)] = true, -- Golden Skeleton Key
	[GetSpellInfo(19646)] = true, -- Silver Skeleton Key
}

function ns.SkeletonKey()
	for key in pairs(keys) do
		if(GetItemCount(key) > 0) then
			return key
		end
	end
end
