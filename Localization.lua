local _, L = ...

setmetatable(L, {__index = function(L, key)
	local value = tostring(key)
	L[key] = value
	return value
end})
