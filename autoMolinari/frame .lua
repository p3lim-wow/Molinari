local _, addon = ...
local auto_molinari = addon.auto_molinari
local L = auto_molinari.L

local twipe = table.wipe
local CreateFrame = CreateFrame

local frameTexts = {
  ['disenchant'] = L["Do you want to disenchant"],
  ['prospecting'] = L["Do you want to prospect"],
  ['milling'] = L["Do you want to mill"],
  ['opening'] = L["Do you want to open"],
}

local frame = CreateFrame('Frame', 'AutoMolinariFrame', UIParent)
auto_molinari.frame = frame
frame.objdata = {}

frame:SetSize(300, 110)
frame:SetPoint('TOP', 0, -100)
frame:SetFrameStrata('DIALOG')
frame:SetMovable(true)
frame:SetBackdrop({
  bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
  edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
  tile = true, tileSize = 32, edgeSize = 14,
  insets = { left = 2, right = 2, top = 2, bottom = 2 }
  })
frame:SetBackdropColor(0, 0, 0, 0.8)
frame:Hide()

frame.drag = CreateFrame('Button', '$parentDragButton', frame)
frame.drag:SetPoint('TOPLEFT', 10, -5)
frame.drag:SetPoint('TOPRIGHT', -30, -5)
frame.drag:SetHeight(6)
frame.drag:SetHighlightTexture([[Interface\FriendsFrame\UI-FriendsFrame-HighlightBar]])
frame.drag:SetScript('OnMouseDown', function() frame:StartMoving() end)
frame.drag:SetScript('OnMouseUp', function() frame:StopMovingOrSizing() end)

frame.close = CreateFrame('Button', '$parentCloseButton', frame, 'UIPanelCloseButton')
frame.close:SetPoint('TOPRIGHT', 2, 2)
frame.close:SetScript('OnClick', function()
  auto_molinari:SetState('stopped')
  auto_molinari:ClearAndHideFrame()
end)

frame.headerText = frame:CreateFontString('$parentHeaderText', 'ARTWORK', 'SystemFont_Large')
frame.headerText:SetPoint('TOPLEFT', 10, -15)
frame.headerText:SetWidth(frame:GetWidth() - 50)
frame.headerText:SetJustifyH('LEFT')

frame.itemIcon = CreateFrame('Button', '$parentItemIcon', frame)
frame.itemIcon:SetNormalTexture([[Interface\Buttons\UI-Slot-Background]])
frame.itemIcon:SetPoint('TOPLEFT', frame.headerText, 'BOTTOMLEFT', 0, -10)
frame.itemIcon:SetSize(37, 37)
frame.itemIcon:SetScript('OnEnter', function(self)
  GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT')
  GameTooltip:SetHyperlink(frame.objdata.itemLink)
  GameTooltip:Show()
end)
frame.itemIcon:SetScript('OnLeave', GameTooltip_Hide)

frame.itemName = frame:CreateFontString('$parentItemName', 'ARTWORK', 'SystemFont_Med2')
frame.itemName:SetPoint('TOPLEFT', frame.itemIcon, 'TOPRIGHT', 5, -5)
frame.itemName:SetWidth(frame:GetWidth() - 50)
frame.itemName:SetJustifyH('LEFT')

frame.yes = CreateFrame('Button', '$parentYesButton', frame, 'SecureActionButtonTemplate, OptionsButtonTemplate')
frame.yes:SetText(YES)
frame.yes:SetPoint('BOTTOMLEFT', frame, 'BOTTOMLEFT', 5, 5)
frame.yes:HookScript('OnClick', function()
  if not auto_molinari:CheckState('item_found') and not auto_molinari:CheckState('process_failed') then
    return error('[Molinari-Auto]: something went wrong!!! Current state - '..auto_molinari:GetState())
  end
  auto_molinari:SetState('process_start')
end)

frame.no = CreateFrame('Button', '$parentNoButton', frame, 'OptionsButtonTemplate')
frame.no:SetText(NO)
frame.no:SetPoint('LEFT', frame.yes, 'RIGHT', 0, 0)
frame.no:SetScript('OnClick', function()
  auto_molinari.sessionIgnoreList[frame.objdata.itemID] = true
  auto_molinari:ClearAndHideFrame()
  auto_molinari:Scan() -- rescan bagы
end)

frame.ignore = CreateFrame('Button', '$parentIgnoreButton', frame, 'OptionsButtonTemplate')
frame.ignore:SetText(L['Ignore'])
frame.ignore:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -5, 5)
frame.ignore:SetScript('OnClick', function()
  MolinariDB3.auto_molinari.ignoreList[frame.objdata.itemID] = true
  auto_molinari:ClearAndHideFrame()
  auto_molinari:Scan() -- rescan bagы
end)

frame:SetScript('OnShow', function(self)
  if self.objdata.spellID then
    self.yes:SetAttribute('type', 'spell')
    self.yes:SetAttribute('spell', self.objdata.spellID)
  elseif self.objdata.keyItemID then
    self.yes:SetAttribute('type', 'item')
    self.yes:SetAttribute('item', 'item:' .. self.objdata.keyItemID)
  else
    return error('[Molinari-Auto]: incorrect object data!')
  end
  self.yes:SetAttribute('target-bag', self.objdata.bagID)
  self.yes:SetAttribute('target-slot', self.objdata.slotID)
end)

frame:SetScript('OnHide', function(self)
  self.yes:SetAttribute('type', nil)
  self.yes:SetAttribute('spell', nil)
  self.yes:SetAttribute('item', nil)
  self.yes:SetAttribute('target-bag', nil)
  self.yes:SetAttribute('target-slot', nil)
end)

function auto_molinari:SetObjData(bagID, slotID, mode, spellID, keyItemID)
  local texture = GetContainerItemInfo(bagID, slotID)
  self.frame.objdata = {
    mode = mode,
    bagID = bagID,
    slotID = slotID,
    spellID = spellID,
    keyItemID = keyItemID,
    itemTexture = texture,
    itemID = GetContainerItemID(bagID, slotID),
    itemLink = GetContainerItemLink(bagID, slotID),
  }
end

function auto_molinari:ClearObjData()
  twipe(self.frame.objdata)
end

function auto_molinari:ShowFrame()
  if not self:CheckState('item_found') and not self:CheckState('process_failed') then return end
  self.frame.headerText:SetText(frameTexts[self.frame.objdata.mode]..':')
  self.frame.itemIcon:SetNormalTexture(self.frame.objdata.itemTexture)
  self.frame.itemName:SetText(self.frame.objdata.itemLink)
  self.frame:Show()
end

function auto_molinari:HideFrame()
  self.frame.headerText:SetText('')
  self.frame.itemIcon:SetNormalTexture('')
  self.frame.itemName:SetText('')
  self.frame:Hide()
end

function auto_molinari:ClearAndHideFrame()
  self:ClearObjData()
  self:HideFrame()
end
