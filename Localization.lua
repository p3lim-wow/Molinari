local _, L = ...

local ItemBlacklistTooltip = [[
Easily add more items to filter by
grabbing one from your inventory
and dropping it into the box below.

Just as easily you remove an existing
item by right-clicking on it.
]]

setmetatable(L, {__index = function(L, key)
	local value = key == 'ItemBlacklistTooltip' and ItemBlacklistTooltip or tostring(key)
	L[key] = value
	return value
end})
