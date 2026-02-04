local addonName, addon = ...

--[[
Local variables:
  sessionIgnoreList - variable with a list of ignored items for the current session
                      (until exiting the game or reloading UI).
                      Used when the user clicks the "No" button in the frame.
  enabled - variable for enabling/disabling the module.
  state - variable for tracking the module work stage.
          List of states:
            * stopped - when the module is disabling.
            * combat_lockdown - when player in the combat.
            * waiting - just waiting of some action.
            * bags_scaning - when the bags scanning is started.
            * item_found - when found valid item.
            * process_start - the process was started (beginning spell casting).
            * process_failed - the process was interrupted for any reason (unsuccessful spell casting).
            * processing - when the process occurs (casting a spell).
            * process_done - the process was completed successfully (successful spell casting).
            * item_looting - when loot frame is open.
  modes - variables for enabling/disabling specific operating modes of the module.
          You can use several modes at once.
          List of modes:
            * disenchant - the module will search and process the items for disenchanting.
            * prospecting - the module will search and process the ores for prospecting.
            * milling - the module will search and process the herbs for milling.
            * opening - the module will search and process the locked boxes for opening.

Saved variables:
  ignoreList - a stored variable with a list of ignored items.
               Used when the user clicks the "Ignore" button in the frame.
--]]

local auto_molinari = {
  defaultDB = {
    ignoreList = {}
  },
  sessionIgnoreList = {},
  enabled = false,
  state = 'stopped',
  modes = {
    disenchant = false,
    prospecting = false,
    milling = false,
    opening = false,
  }
}
addon.auto_molinari = auto_molinari

local rawset = rawset
local setmetatable = setmetatable
local tostring = tostring
local GetLocale = GetLocale
local CreateFrame = CreateFrame

local localizations = {}
local locale = GetLocale()
auto_molinari.L = setmetatable({}, {
  __index = function(_, key)
    local localeTable = localizations[locale]
    return localeTable and localeTable[key] or tostring(key)
  end,
  __call = function(_, newLocale)
    localizations[newLocale] = localizations[newLocale] or {}
    return localizations[newLocale]
  end,
})

function auto_molinari:SetState(state)
  self.state = state
end

function auto_molinari:GetState()
  return self.state
end

function auto_molinari:CheckState(state)
  return state == self.state
end

function auto_molinari:UpdateModes(d, p, m, o)
  self.modes.disenchant = type(d) == 'nil' and IsSpellKnown(13262) or d or false
  self.modes.prospecting = type(p) == 'nil' and IsSpellKnown(31252) or p or false
  self.modes.milling = type(m) == 'nil' and IsSpellKnown(51005) or m or false
  self.modes.opening = type(o) == 'nil' and (IsSpellKnown(1804) or addon:GetProfessionSkillLevel(164) > 0 or addon:GetProfessionSkillLevel(202) > 0) or o or false
end

local Initializer = CreateFrame('Frame')
Initializer:RegisterEvent('VARIABLES_LOADED')
Initializer:SetScript('OnEvent', function(self, event, ...)
  if not auto_molinari[event] then return end
  auto_molinari[event](auto_molinari, ...)
end)

function auto_molinari:VARIABLES_LOADED()
  self:OnInitilize()
end

function auto_molinari:OnInitilize()
  if not MolinariDB3.auto_molinari then MolinariDB3.auto_molinari = self.defaultDB end

  self:UpdateModes()
  if self.enabled then
    self:OnEnable()
  else
    self:OnDisable()
  end
end

function auto_molinari:OnEnable()
  Initializer:RegisterEvent('BAG_UPDATE')
  Initializer:RegisterEvent('LOOT_OPENED')
  Initializer:RegisterEvent('LOOT_CLOSED')
  Initializer:RegisterEvent('UNIT_SPELLCAST_START')
  Initializer:RegisterEvent('UNIT_SPELLCAST_INTERRUPTED')
  Initializer:RegisterEvent('UNIT_SPELLCAST_FAILED')
  Initializer:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
  Initializer:RegisterEvent('PLAYER_REGEN_ENABLED')
  Initializer:RegisterEvent('PLAYER_REGEN_DISABLED')
  self:ClearAndHideFrame()
  self:SetState('waiting')
  self:Scan()
end

function auto_molinari:OnDisable()
  Initializer:UnregisterAllEvents()
  self:ClearAndHideFrame()
  self:SetState('stopped')
end

-- redefinition
SlashCmdList.MOLINARI = function(command)
  local args = {}

  command = command:gsub("|cff.+|Hitem:(%d+).+|h|r", "%1") -- convert item link to itemID
  for arg in command:gmatch('%S+') do table.insert(args, arg) end

  if args[1] and args[1] == 'auto' then
    if args[2] == 'start' then
      if args[3] then
        if args[3] == 'disenchant' and IsSpellKnown(13262) then -- start only disenchant
          auto_molinari:UpdateModes(true, false, false, false)
        elseif args[3] == 'prospecting' and IsSpellKnown(31252) then -- start only prospecting
          auto_molinari:UpdateModes(false, true, false, false)
        elseif args[3] == 'milling' and IsSpellKnown(51005) then -- start only milling
          auto_molinari:UpdateModes(false, false, true, false)
        elseif args[3] == 'opening' and IsSpellKnown(1804) or addon:GetProfessionSkillLevel(164) > 0 or addon:GetProfessionSkillLevel(202) > 0 then -- start only opening
          auto_molinari:UpdateModes(false, false, false, true)
        else -- if entered a command that cannot be executed, for example, the required profession has not been learned
          auto_molinari:UpdateModes(false, false, false, false)
        end
      else -- start without mode specific
        auto_molinari:UpdateModes()
      end
      auto_molinari.enabled = true
      auto_molinari:OnEnable()
    elseif args[2] == 'stop' then
      auto_molinari.enabled = false
      auto_molinari:OnDisable()
    elseif args[2] == 'ignore' then
      if args[3] == 'add' and args[4] then
        local itemID = tonumber(args[4])
        if not itemID then
          return print('|cff33ff99Molinari-Auto|r: /molinari ignore add <itemID> - passed incorrect <itemID>')
        end
        MolinariDB3.auto_molinari.ignoreList[tonumber(args[4])] = true
        local _, itemLink = GetItemInfo(itemID)
        print('|cff33ff99Molinari-Auto|r: ' .. (itemLink or itemID) .. ' added to ignore list.')
      elseif args[3] == 'del' and args[4] then
        local itemID = tonumber(args[4])
        if not itemID then
          return print('|cff33ff99Molinari-Auto|r: /molinari ignore del <itemID> - passed incorrect <itemID>')
        end
        MolinariDB3.auto_molinari.ignoreList[tonumber(args[4])] = nil
        local _, itemLink = GetItemInfo(itemID)
        print('|cff33ff99Molinari-Auto|r: ' .. (itemLink or itemID) .. ' removed from ignore list.')
      elseif args[3] == 'list' then
        print('|cff33ff99Molinari-Auto|r ignore list:')
        for itemID in pairs(MolinariDB3.auto_molinari.ignoreList) do
          local _, itemLink = GetItemInfo(itemID)
          if itemLink then
            print('- ' .. itemLink .. ' (itemID: ' .. itemID .. ')')
          else
            print('- itemID: ' .. itemID .. ' |cfff00000(no data about this item)|r')
          end
        end
      end
    end
  else
    InterfaceOptionsFrame_OpenToCategory(addonName)
    InterfaceOptionsFrame_OpenToCategory(addonName)
  end
end
