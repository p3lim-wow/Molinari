local _, addon = ...

if TooltipDataProcessor and C_TooltipInfo then
	function addon:HookTooltip(callback)
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
			if not (tooltip and not tooltip:IsForbidden() and tooltip:GetOwner()) then
				return
			end

			if tooltip ~= GameTooltip then
				-- disqualify shopping tooltips
				return
			end

			if data.guid then
				local location = C_Item.GetItemLocation(data.guid)
				if location and location:IsBagAndSlot() then
					local bagID = location:GetBagAndSlot()
					if bagID >= 0 and bagID <= 5 then -- limit to player bags
						callback(tooltip, Item:CreateFromItemLocation(location))
					end
				end
			elseif tooltip:GetOwner():GetName() == 'TradeRecipientItem7ItemButton' then
				-- special handling for trade window
				local _, itemLink = tooltip:GetItem()
				if itemLink then
					callback(tooltip, Item:CreateFromItemLink(itemLink))
				end
			end
		end)
	end
else
	function addon:HookTooltip(callback)
		hooksecurefunc(GameTooltip, 'SetBagItem', function(tooltip, bagID, slotID)
			if not (tooltip and not tooltip:IsForbidden() and tooltip:GetOwner()) then
				return
			end

			local _, itemLink = tooltip:GetItem()
			if itemLink then
				if bagID and slotID and bagID >= 0 and bagID <= 4 then -- limit to player bags
					callback(tooltip, Item:CreateFromItemLocation(ItemLocation:CreateFromBagAndSlot(bagID, slotID)))
				end
			end
		end)

		hooksecurefunc(GameTooltip, 'SetTradeTargetItem', function(tooltip)
			if not (tooltip and not tooltip:IsForbidden() and tooltip:GetOwner()) then
				return
			end

			local _, itemLink = tooltip:GetItem()
			if itemLink and tooltip:GetOwner():GetName() == 'TradeRecipientItem7ItemButton' then
				callback(tooltip, Item:CreateFromItemLink(itemLink))
			end
		end)
	end
end
