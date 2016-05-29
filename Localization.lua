local _, L = ...

setmetatable(L, {__index = function(L, key)
	local value = tostring(key)
	L[key] = value
	return value
end})

local locale = GetLocale()
if(locale == 'deDE') then
	--@localization(locale="deDE", format="lua_additive_table")@
elseif(locale == 'esES') then
	--@localization(locale="esES", format="lua_additive_table")@
elseif(locale == 'esMX') then
	--@localization(locale="esMX", format="lua_additive_table")@
elseif(locale == 'frFR') then
	--@localization(locale="frFR", format="lua_additive_table")@
elseif(locale == 'itIT') then
	--@localization(locale="itIT", format="lua_additive_table")@
elseif(locale == 'koKR') then
	--@localization(locale="koKR", format="lua_additive_table")@
elseif(locale == 'ptBR') then
	--@localization(locale="ptBR", format="lua_additive_table")@
elseif(locale == 'ruRU') then
	--@localization(locale="ruRU", format="lua_additive_table")@
elseif(locale == 'zhCN') then
	--@localization(locale="zhCN", format="lua_additive_table")@
elseif(locale == 'zhTW') then
	--@localization(locale="zhTW", format="lua_additive_table")@
end
