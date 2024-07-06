-- AutoCastShine was removed from the game in 11.x, this is just a fork
local _, addon = ...

local sparkles = CreateFrame('Frame')
sparkles:Hide()
sparkles.orbs = {}

for _ = 1, 4 do
	for mult = 3, 0, -1 do
		local orb = sparkles:CreateTexture(nil, 'OVERLAY')
		orb:SetPoint('CENTER')
		orb:SetSize(12 + (9 * mult), 12 + (9 * mult)) -- 3x larger than the original template
		orb:SetTexture([[Interface\ItemSocketingFrame\UI-ItemSockets]])
		orb:SetTexCoord(0.3984375, 0.4453125, 0.40234375, 0.44921875)
		orb:SetBlendMode('ADD')
		table.insert(sparkles.orbs, orb)
	end
end

local spacing = 6
local timers = {0, 0, 0, 0}
local speeds = {2, 4, 6, 8}
sparkles:SetScript('OnUpdate', function(self, elapsed)
	for index in next, timers do
		timers[index] = timers[index] + elapsed

		if timers[index] > speeds[index] * 4 then
			timers[index] = 0
		end
	end

	local parent = self:GetParent()
	local distance = parent:GetWidth()
	for index = 1, 4 do
		local timer = timers[index]
		local speed = speeds[index]

		if timer <= speed then
			local position = timer / speed * distance
			self.orbs[0 + index]:SetPoint('CENTER', parent, 'TOPLEFT', position, 0)
			self.orbs[4 + index]:SetPoint('CENTER', parent, 'BOTTOMRIGHT', -position, 0)
			self.orbs[8 + index]:SetPoint('CENTER', parent, 'TOPRIGHT', 0, -position)
			self.orbs[12 + index]:SetPoint('CENTER', parent, 'BOTTOMLEFT', 0, position)
		elseif timer <= speed * 2 then
			local position = (timer - speed) / speed * distance
			self.orbs[0 + index]:SetPoint('CENTER', parent, 'TOPRIGHT', 0, -position)
			self.orbs[4 + index]:SetPoint('CENTER', parent, 'BOTTOMLEFT', 0, position)
			self.orbs[8 + index]:SetPoint('CENTER', parent, 'BOTTOMRIGHT', -position, 0)
			self.orbs[12 + index]:SetPoint('CENTER', parent, 'TOPLEFT', position, 0)
		elseif timer <= speed * 3 then
			local position = (timer - speed * 2) / speed * distance
			self.orbs[0 + index]:SetPoint('CENTER', parent, 'BOTTOMRIGHT', -position, 0)
			self.orbs[4 + index]:SetPoint('CENTER', parent, 'TOPLEFT', position, 0)
			self.orbs[8 + index]:SetPoint('CENTER', parent, 'BOTTOMLEFT', 0, position)
			self.orbs[12 + index]:SetPoint('CENTER', parent, 'TOPRIGHT', 0, -position)
		else
			local position = (timer - speed * 3) / speed * distance
			self.orbs[0 + index]:SetPoint('CENTER', parent, 'BOTTOMLEFT', 0, position)
			self.orbs[4 + index]:SetPoint('CENTER', parent, 'TOPRIGHT', 0, -position)
			self.orbs[8 + index]:SetPoint('CENTER', parent, 'TOPLEFT', position, 0)
			self.orbs[12 + index]:SetPoint('CENTER', parent, 'BOTTOMRIGHT', -position, 0)
		end
	end
end)

function addon:StartSparkles(parent, color)
	sparkles:SetParent(parent)
	sparkles:SetAllPoints()

	local r, g, b = color:GetRGB()
	for _, orb in next, sparkles.orbs do
		orb:SetVertexColor(r, g, b)
	end

	sparkles:Show()
end

function addon:StopSparkles()
	sparkles:Hide()
end
