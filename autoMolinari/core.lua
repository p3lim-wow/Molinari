local _, addon = ...
local auto_molinari = addon.auto_molinari

local select = select
local LootSlot = LootSlot
local GetItemInfo = GetItemInfo
local IsSpellKnown = IsSpellKnown
local GetSpellInfo = GetSpellInfo
local GetNumLootItems = GetNumLootItems
local GetContainerItemID = GetContainerItemID
local GetContainerNumSlots = GetContainerNumSlots
local GetContainerItemInfo = GetContainerItemInfo
local GetContainerItemLink = GetContainerItemLink
local GetAuctionItemClasses = GetAuctionItemClasses
local GetAuctionItemSubClasses = GetAuctionItemSubClasses

local LOC_Weapon,LOC_Armor,_,_,_,LOC_Trade_Goods,_,_,_,_,LOC_Trade_Other = GetAuctionItemClasses()
local _,_,_,LOC_Metal_Stone,_,LOC_Herb = GetAuctionItemSubClasses(6) -- 6 - Trade Goods
local LOC_Junk = GetAuctionItemSubClasses(11) -- 11 - Other

function auto_molinari:IsItemIgnored(itemID)
  return auto_molinari.sessionIgnoreList[itemID] or MolinariDB3.auto_molinari.ignoreList[itemID]
end

function auto_molinari:ScanBag(bagID)
  for slotID = 1, GetContainerNumSlots(bagID) do
    local itemID = GetContainerItemID(bagID, slotID)
    if itemID and not self:IsItemIgnored(itemID) then
      local itemType, itemSubType = select(6, GetItemInfo(itemID))

      if (itemType == LOC_Weapon or itemType == LOC_Armor) and self.modes.disenchant then
        local spellID = addon:IsDisenchantable(itemID)
        if spellID then
          return slotID, 'disenchant', spellID
        end
      elseif itemType == LOC_Trade_Goods then
        local _, numItems = GetContainerItemInfo(bagID, slotID)
        if itemSubType == LOC_Metal_Stone and self.modes.prospecting then
          local spellID, _, numItemsRequired = addon:IsProspectable(itemID)
          if spellID and numItemsRequired and numItems >= numItemsRequired then
            return slotID, 'prospecting', spellID
          end
        elseif itemSubType == LOC_Herb and self.modes.milling then
          local spellID, _, numItemsRequired = addon:IsMillable(itemID)
          if spellID and numItemsRequired and numItems >= numItemsRequired then
            return slotID, 'milling', spellID
          end
        end
      elseif itemType == LOC_Trade_Other and itemSubType == LOC_Junk and self.modes.opening then
        local spellID = addon:IsOpenable(itemID)
        if spellID then
          return slotID, 'opening', spellID
        end
        local key = addon:IsOpenableProfession(itemID)
        if key then
          return slotID, 'opening', nil, key
        end
      end
    end
  end
end

function auto_molinari:Scan(bag)
  if self:GetState() == 'stopped' or self:GetState() == 'combat_lockdown' then return end
  self:SetState('bags_scaning')

  local bagID = bag
  local slotID, mode, spellID, keyItemID
  if bagID then
    -- scan specific bag
    slotID, mode, spellID, keyItemID = self:ScanBag(bagID)
    if not slotID then
      -- scan the next bag if nothing is found in the current bag
      if bagID == 4 then return else bagID = bagID + 1 end
      slotID, mode, spellID, keyItemID = self:ScanBag(bagID)
    end
  else
    -- scan all bags
    for scanBagID = 0, 4 do
      slotID, mode, spellID, keyItemID = self:ScanBag(scanBagID)
      if slotID then bagID = scanBagID break end
    end
  end
  if not slotID then
    self:SetState('waiting')
  else
    self:SetState('item_found')
    self:SetObjData(bagID, slotID, mode, spellID, keyItemID)
    self:ShowFrame()
  end
end

function auto_molinari:PLAYER_REGEN_ENABLED()
  if self:CheckState('combat_lockdown') then
    if self.frame.objdata.bagID then
      self:SetState('item_found')
      self:ShowFrame()
    else
      self:SetState('waiting')
      self:Scan()
    end
  end
end

function auto_molinari:PLAYER_REGEN_DISABLED()
  -- lol API InCombatLockdown return 'nil'. I think the return value of this API will be updated later than the event triggering.
  self:SetState('combat_lockdown')
  self:HideFrame()
end

function auto_molinari:BAG_UPDATE(bagID)
  if self:CheckState('item_found') and bagID == self.frame.objdata.bagID then
    -- If an item was found, but the bag was updated, then we cannot trust
    -- the existing data, so we delete the data and rescan current bag.
    self:ClearAndHideFrame()
    self:Scan(bagID)
  elseif self:CheckState('waiting') or self:CheckState('stopped') then
    self:Scan(bagID)
  end
end

function auto_molinari:UNIT_SPELLCAST_START(unit, spell)
  if unit ~= 'player' or not self:CheckState('process_start') or spell ~= GetSpellInfo(self.frame.objdata.spellID) then return end
  self:SetState('processing')
  self:HideFrame() -- hide WITHOUT clearing data because cast can be interrupted!
end

function auto_molinari:UNIT_SPELLCAST_INTERRUPTED(unit, spell)
  if unit ~= 'player' or not self:CheckState('processing') or spell ~= GetSpellInfo(self.frame.objdata.spellID) then return end
  self:SetState('process_failed')
  self:ShowFrame()
end

function auto_molinari:UNIT_SPELLCAST_FAILED(unit, spell)
  if unit ~= 'player' or not self:CheckState('processing') or spell ~= GetSpellInfo(self.frame.objdata.spellID) then return end
  self:SetState('process_failed')
  self:ShowFrame()
end

function auto_molinari:UNIT_SPELLCAST_SUCCEEDED(unit, spell)
  if unit ~= 'player' or not self:CheckState('processing') or spell ~= GetSpellInfo(self.frame.objdata.spellID) then return end
  self:SetState('process_done')
  self:ClearObjData()
  -- after this event will be automatically fire LOOT_OPENED
end

function auto_molinari:LOOT_OPENED(autolooting)
  if not self:CheckState('process_done') then return end
  self:SetState('item_looting')
  if autolooting == 0 then
    for slotID = 1, GetNumLootItems() do
      LootSlot(slotID)
    end
  end
  -- after loot each item will be automatically fire BAG_UPDATE
  -- after loot all items will be automatically fire LOOT_CLOSED
end

function auto_molinari:LOOT_CLOSED()
  if not self:CheckState('item_looting') then return end
  self:SetState('waiting')
end

