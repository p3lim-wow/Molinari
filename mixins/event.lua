local _, addon = ...

local eventHandler = CreateFrame('Frame')
local callbacks = {}

local eventMixin = {}
function eventMixin:RegisterEvent(event, callback)
	if not callbacks[event] then
		callbacks[event] = {}
	end

	table.insert(callbacks[event], {
		parent = self,
		callback = callback,
	})

	if not eventHandler:IsEventRegistered(event) then
		eventHandler:RegisterEvent(event)
	end
end

function eventMixin:UnregisterEvent(event, callback)
	if not callbacks[event] then
		-- should probably error
		return
	end

	for i = #callbacks[event], 1, -1 do
		if callbacks[event][i].callback == callback then
			callbacks[event][i] = nil
		end
	end

	if #callbacks[event] == 0 then
		eventHandler:UnregisterEvent(event)
	end
end

function eventMixin:IsEventRegistered(event, callback)
	if callbacks[event] then
		for i = 1, #callbacks[event] do
			if callbacks[event][i].callback == callback then
				return true
			end
		end
	end

	return false
end

eventHandler:SetScript('OnEvent', function(self, event, ...)
	if callbacks[event] then
		for _, data in next, callbacks[event] do
			data.callback(data.parent, ...)
		end
	end
end)

addon.eventMixin = eventMixin
