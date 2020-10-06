local addonName, ns = ...

local ButtonPoolMixin = {}
function ButtonPoolMixin.Reposition(pool)
	if pool.parent:GetParent():GetWidth() == 0 then
		-- until the frame is visible the width is 0
		C_Timer.After(0.5, function()
			pool:Reposition()
		end)

		return
	end

	local cols = math.floor((pool.parent:GetParent():GetWidth() - pool.offset) / (pool.buttonWidth + pool.buttonSpacing))

	local index = 1
	for _, button in pool:EnumerateActiveSorted() do
		local col = (index - 1) % cols
		local row = math.floor((index - 1) / cols)

		local x = (pool.offset / 4) + (col * (pool.buttonWidth + pool.buttonSpacing))
		local y = (pool.offset / 4) + (row * (pool.buttonHeight + pool.buttonSpacing))

		button:ClearAllPoints()
		button:SetPoint('TOPLEFT', x, -y)

		index = index + 1
	end

	-- update the width of the parent so the buttons can be displayed properly
	pool.parent:SetWidth(pool.parent:GetParent():GetWidth())
end

function ButtonPoolMixin:SetSortField(field)
	self.sortField = field
end

do
	local objects = {}
	function ButtonPoolMixin:EnumerateActiveSorted()
		table.wipe(objects)

		for obj in self:EnumerateActive() do
			table.insert(objects, obj)
		end

		local sortField = self.sortField
		table.sort(objects, function(a, b)
			return a[sortField] < b[sortField]
		end)

		return pairs(objects)
	end
end

local function ReleaseButton(pool, button)
	FramePool_HideAndClearAnchors(pool, button) -- super

	-- reposition remaining buttons
	pool:Reposition()
end

local function OnButtonEnter(self)
	self.remove:Show()

	if self.OnEnter then
		self:OnEnter()
	end
end

local function OnButtonLeave(self)
	if not (self:IsMouseOver() or self.remove:IsMouseOver()) then
		self.remove:Hide()
	end

	if self.OnLeave then
		self:OnLeave()
	end
end

local function OnRemoveLeave(self)
	if not (self:IsMouseOver() or self:GetParent():IsMouseOver()) then
		self:Hide()
	end
end

local function OnRemoveClick(self)
	local button = self:GetParent()
	if button.OnRemove then
		button:OnRemove()
	end

	button.pool:Release(button)
end

function ButtonPoolMixin.CreateButton(pool)
	local button = pool:Acquire()
	if not button.pool then
		button.pool = pool

		local remove = CreateFrame('Button', nil, button, 'UIPanelCloseButton')
		remove:SetPoint('TOPRIGHT', 6, 8)
		remove:SetSize(20, 22)
		button.remove = remove

		button:SetSize(pool.buttonWidth, pool.buttonHeight)
		button:SetScript('OnEnter', OnButtonEnter)
		button:SetScript('OnLeave', OnButtonLeave)
		remove:SetScript('OnLeave', OnRemoveLeave)
		remove:SetScript('OnClick', OnRemoveClick)
	end

	button:Show()
	button.remove:Hide()

	-- TODO: remove other metadata we attach
	button.OnEnter = nil
	button.OnLeave = nil

	return button
end

function ns.CreateButtonPool(parent, offset, buttonWidth, buttonHeight, buttonSpacing)
	local pool = CreateFramePool('Button', parent, BackdropTemplateMixin and 'BackdropTemplate', ReleaseButton)
	pool:ReleaseAll()

	pool.parent = parent
	pool.offset = offset
	pool.buttonWidth = buttonWidth
	pool.buttonHeight = buttonHeight
	pool.buttonSpacing = buttonSpacing

	Mixin(pool, ButtonPoolMixin)

	return pool
end
